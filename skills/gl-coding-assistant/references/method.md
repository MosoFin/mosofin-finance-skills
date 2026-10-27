<!-- gl-coding-assistant · method.md · read for: Stages 3–6 — Steps 0–1 read and normalize, Steps 2–4 classify and flag, Step 5 presents, Step 6 and the Learning Loop save; plus both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Parse and normalize
- Step 2 — Classify each transaction
- Step 3 — Tax codes (jurisdiction-driven)
- Step 4 — Special-case rules
- Step 5 — Output
- Step 6 — Evolve the skill (Mosofin-specific, final step)
- Learning Loop
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The capitalization threshold and the tax rules are
legitimately `[manual]`.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the vendors, the history and the tax codes do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the real chart of accounts**, including **uncategorized and suspense accounts** —
  usually **[auto]**
- *`search_vendors`* + *`get_vendor`* — the vendor master and any default accounts — usually **[auto]**
- *`get_general_ledger`* — **the coding history**, which is the Tier 1 evidence — usually **[auto]**
- *`search_purchases`* / *`search_bills`* / *`search_expenses`* — **prior transactions by vendor with their
  accounts** — usually **[auto]**
- *`get_general_ledger`* on **Uncategorized Expense / Income and any suspense account** — **the work waiting
  to be done** — usually **[auto]**. **This covers only items already posted** to those accounts: bank-feed
  items awaiting review ("For Review" in QuickBooks Online, unreconciled bank lines in Xero) are not in the
  ledger and are not visible here. Ask for the bank and card statement CSVs for the period to code them
- *`get_general_ledger`* on **Accounts Receivable, Undeposited Funds / Payments to Deposit and any processor
  clearing account** — for the receipts rule in Step 4 — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — **the codes configured in this entity** — often **[auto]**
- *`search_accounts`* on **bank and credit card accounts** — for transfer detection — usually **[auto]**
- *`search_employees`* — for related-party name comparison — usually **[auto]**
- *`get_company_info`* — legal name, currency, **country, industry** — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the COA read,
  say explicitly which fallback is now in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **coding history from fixtures is not this
entity's history**, and a Tier 1 match against it is worthless. Downgrade every history-based confidence to
Low and say why.

## Step 1 — Parse and normalize

For each transaction extract — **[gated]**: `[auto]` for transactions already in the system, `[manual]` for
a pasted export:

- **Date**
- **Vendor / payee** — normalize: **strip corporate suffixes ("INC", "LLC", "LTD", "GMBH", "PTY"), trailing
  numeric IDs, payment-processor prefixes ("SQ *", "TST*", "POS DEBIT", "PAYPAL *", "WISE *")**
- **Description / memo**
- **Amount (signed)**
- **Source account** (bank, credit card, etc.) — if provided

**Normalize examples:**

- **"AMZN MKTP US*1A2B3C" → "Amazon"**
- **"SQ *COFFEE SHOP" → "Coffee Shop (via Square)"**
- **"PAYPAL *VENDORNAME 12345" → "VendorName (via PayPal)"**

**Mosofin addition — match the normalized name to the vendor master.** **[auto]** via *`search_vendors`*.
Three outcomes, each worth reporting differently:

- **Matches an existing vendor** → the full coding history is available. Best case.
- **Matches nothing** → a new vendor, so Tier 1 cannot apply. Fall to Tier 2.
- **Matches several similar vendors** → **a duplicate vendor record**, which is a data-quality finding in
  its own right and means the history is split across records. Report it; see
  `duplicate-invoice-detection` for the matching discipline.

## Step 2 — Classify each transaction

**Apply this decision hierarchy in order. Stop at the first confident match.** The receipts rule and the
other Step 4 checks still run on every transaction, whatever tier matched.

### Tier 1 — Exact vendor match (Confidence: High) — **[auto]**

**If the vendor exists in the user's prior mappings, use that account.**
**Reasoning: "Matches prior coding for [vendor]."**

**In a Mosofin workspace this tier is read, not supplied.** Query the ledger history for this vendor
(*`get_general_ledger`*, *`search_purchases`*) and report **the account, the count and the recency**:

> *"6120 Office Supplies — this entity's coding for this vendor in 43 of 45 prior transactions, most
> recently 2026-07-14."*

**Three history shapes, three different answers:**

| History | Confidence | What to say |
|---|---|---|
| **Consistent** — one account dominates | 🟢 **High** | The account, with the count. |
| **Inconsistent** — split across accounts | 🟡 **Medium**, flagged | **Report the split.** Do not pick the most common or the most recent. The category was probably never decided. |
| **Changed** — one account, then another, cleanly | 🟡 **Medium** | Use the newer, **and say a change occurred and when** — it may be a deliberate reclassification or an error. |

**Frequency is evidence of practice, not of correctness.** Where history conflicts with a supplied coding
policy, **the policy wins and the conflict is reported.**

### Tier 2 — Vendor-type pattern match (Confidence: High) — **[gated]**

**Map common vendor types to the closest matching account in the user's COA. Never output an account that
isn't in the COA the user provided.**

| Vendor type | Conceptual category to map into user's COA |
|-------------|---------------------------------------------|
| **Cloud infrastructure providers** | Hosting / Cloud Services |
| **SaaS productivity tools** | Software Subscriptions |
| **Payment processor fees** | Merchant Processing Fees |
| **Ride-share / taxi** | Travel — Ground Transport |
| **Hotels / lodging** | Travel — Lodging |
| **Airlines** | Travel — Airfare |
| **Office supply retailers** | Office Supplies |
| **Payroll service providers** | Payroll Services |
| **Accounting software** | Software — Accounting |
| **Job boards / recruiting** | Recruiting |
| **Ad platforms** | Advertising — Digital |
| **Utilities (power, gas, water)** | Utilities |
| **Telecom carriers** | Telephone & Internet |
| **Insurance carriers** | Insurance |
| **Government tax authorities** | Tax payments — to specific tax liability |

**If the user's COA has no matching account for a vendor type, flag it and ask the user which account to
use.** **[auto]** to determine — the real chart is readable, so **whether a matching account exists is a
fact here, not a question.** Where none exists, say so precisely: *"no Hosting or Cloud Services account
exists in this chart; the nearest is 6300 Software Subscriptions — confirm."*

### Tier 3 — Keyword inference (Confidence: Medium) — **[auto]**

| Keywords | Conceptual category |
|----------|---------------------|
| **"subscription", "license", "monthly plan"** | Software Subscriptions |
| **"consulting", "advisory"** | Professional Services |
| **"legal", "attorney", "barrister", "solicitor"** | Legal Fees |
| **"audit", "bookkeeping", "CPA", "chartered accountant"** | Accounting / Audit Fees |
| **"rent", "lease" (non-equipment)** | Rent / Occupancy |
| **"freight", "shipping", "courier", "postage"** | Shipping & Postage |
| **"training", "course", "conference"** | Training & Development |
| **"restaurant", "café", "meals"** | Meals |
| **"fuel", "petrol", "diesel"** | Vehicle / Fuel |
| **"repair", "maintenance"** | Repairs & Maintenance |
| **"bank fee", "wire fee", "transaction charge"** | Bank Charges |
| **"interest"** | **Outflow**: Interest Expense; **inflow**: Interest Income |
| **"loan payment"** | **Split**: Interest Expense + Loan Principal (BS) |
| **"dividend", "distribution"** | **Outflow**: Owner Distributions / Dividends Paid (equity); **inflow**: Dividend / Investment Income |
| **"refund", "credit" + positive amount** | Contra to original expense account |

### Tier 4 — Amount heuristics (Confidence: Medium-Low) — **[auto]**

- **Recurring same-amount monthly charges → likely subscription.** *Mosofin note*: **the full history is
  available**, so recurrence is a measured fact — "same amount on the same day for 11 consecutive months" —
  rather than a guess from one export.
- **Round-number month-end amounts → likely rent, payroll, or owner draw**
- **Many small food-vendor charges → Meals**
- **Amounts ≥ entity capitalization threshold → flag as possible Fixed Asset** — **ask the user for the
  threshold if unknown; do not assume**

### Tier 5 — Cannot classify (Confidence: Low)

**Mark as "Needs Review" with reason. Do not guess.**

## Step 3 — Tax codes (jurisdiction-driven)

**Only suggest tax codes if the user provided a jurisdiction AND a tax code list.** **[gated]** — the
**jurisdiction is now `[auto]`** from the profile and **the configured codes are `[auto]`**, but **which code
applies remains `[manual]`.**

**Common jurisdiction patterns recognized structurally, without baking in rates or rules:**

- **Single-rate VAT / GST** — standard / zero / exempt / out-of-scope
- **Multi-rate VAT with reduced rates**
- **Federal + sub-national stacked indirect taxes**
- **US-style sales tax** — paid by buyer at POS, **generally not input-creditable**
- **No indirect tax for the entity** — small supplier exemption, free zone, etc.

**For each transaction suggest a tax code based on:**

- **Vendor's tax registration status** (if known)
- **Nature of supply** — goods / services, domestic / cross-border
- **Recoverability under the entity's regime**

**Cross-border / reverse charge**: **if a vendor appears outside the entity's jurisdiction, flag for
possible reverse-charge or import-VAT treatment. Surface for review — do not silently apply.** **[auto]**
support: the vendor's address is readable, and the entity's country is readable, so **the cross-border flag
itself is determinable** even though the treatment is not.

**If no tax code list is available, output "Tax code: TBD — confirm with tax setup."** *Mosofin note*: where
the platform exposes the entity's configured codes, **name the codes that exist** rather than only "TBD" —
it turns a blank into a short list to choose from.

## Step 4 — Special-case rules

**Step 4 runs on every transaction regardless of tier, and any Step 4 flag caps confidence at Medium.**

**Receipts** — **[gated]**

**Before suggesting an income account for any inflow, check for an open invoice of the same amount or
customer, and for a matching balance in Undeposited Funds / Payments to Deposit or a processor clearing
account** — Mosofin: the AR and clearing ledgers from Step 0 (and an open-invoice read where the Gate 2
catalog lists one); upload: the open-invoices / AR aging export. If one exists, flag **"🔁 Possible invoice
payment / deposit — match, do not code to income"**: coding it to income when the invoice or sales receipt
already recognised the revenue double-counts it and leaves the invoice open on the aging. **Treat processor
payouts (Stripe, Square, PayPal) as gross sales less fees from the processor report, never as net income.**

**Unusual amount** — **[auto]** where history exists

**An amount well outside this vendor's historical range — state the measure used, such as a multiple of the
median — or at or above the capitalization threshold: flag ⚠️ Unusual amount and cap at Medium.**

**Capitalization threshold check** — **[gated]**

For equipment, computers, furniture, vehicles and so on, **if the amount ≥ the entity's capitalization
threshold, flag**:

> **"Possible capital expenditure — consider Fixed Asset. Capitalization threshold: [user-provided or
> 'unknown — please confirm']."**

**Do not pick a threshold. Ask the user if not provided.** See
`fixed-asset-register-and-depreciation`, whose threshold scan is the same test run in the other direction.

**Personal-use detection** — **[auto]** on the patterns

Flag patterns suggesting personal rather than business use:

- **Groceries, personal retail**
- **Travel timing inconsistent with business** — weekend, vacation destinations
- **Personal services** — gym, spa, grooming
- **Family-member-named bookings**

**Surface as: "Possible personal — confirm business purpose."** **Surface, never conclude** — and where a
name match against the employee or owner list drives the flag, say that is what drove it.

**Split-transaction detection** — **[auto]**

**Single transactions likely covering multiple categories** — e.g. a warehouse-club run with mixed items —
**flag for split coding.**

**Inter-account transfer detection** — **[auto], and now genuinely determinable**

**Same amount, opposite sign, within ~3 days, between the entity's own accounts → flag as transfer, not
P&L.** **With ledger access both legs are visible**, so this moves from inference to observation: name the
matching transaction and its account. **The entity's own bank and card accounts are readable**
(*`search_accounts`*), which is what makes "between the entity's own accounts" checkable at all.

**Owner / related-party transactions** — **[gated]**

**Payments to / from owners, shareholders, directors, or related entities → flag for Due to / from accounts
or distributions.** **[auto]** support: compare vendor names against the employee list, against the other
connected company files' legal names, and against the owner, family and other-business names from Stage 1
(G) — those names are used only for this flag and never stored. **A vendor whose name matches another entity in the group is an
intercompany transaction**, not a third-party expense.

**Loan payments** — **[gated]**

**Always split between Interest Expense (P&L) and Principal (BS liability reduction). Ask for the split if
not obvious from the source.** **The split comes from the lender statement or amortization schedule
(`[manual]`).** The ledger balance is used only to confirm the loan balance after the payment agrees to the
lender's figure. **Without the statement, code the full payment to the loan account, flagged "split
required" — never to expense.**

## Step 5 — Output

**Pasted lists → markdown table inline. Uploaded files → `.xlsx`.**

| Date | Vendor (Cleaned) | Description | Amount | Suggested GL Account | Tax Code | Confidence | Reasoning | Flags |

**Add two Mosofin columns**: **Evidence** — the history count behind a Tier 1 match, or the tier used — and
**Verdict** (`[auto]` / `[gated]` / `[manual]`).

**Confidence:**

- 🟢 **High** — exact vendor match or unambiguous pattern
- 🟡 **Medium** — keyword or amount-based inference
- 🔴 **Low** — needs review

**Flags:**

- 🏛️ **Possible CapEx**
- 👤 **Possible personal**
- ✂️ **Possible split**
- 🔁 **Possible transfer**
- ⚠️ **Unusual amount**
- 🌍 **Cross-border / reverse-charge candidate**
- 🔗 **Related-party**

**Two Mosofin flags added:**

- 📊 **Inconsistent history** — this vendor has been coded to more than one account
- 👥 **Duplicate vendor record** — the history is split across records

**End with summary: total coded, % by confidence band, count of flagged items.** Plus the Mosofin header
block: workspace name; the entity by `display_name`; each excluded company file and why; whether any read
returned `mock` data; **and whether the COA was read or a fallback is in use.**

**For an `.xlsx`, add two sheets:**

**Sheet: Uncoded Population — NEW, Mosofin-specific** — what is sitting in uncategorized and suspense
accounts, with ages and amounts. **This is the work list**, and it is often more useful than the batch that
prompted the request. **Its header says: "Covers only items already posted to Uncategorized / suspense.
Bank-feed items awaiting review are not in the ledger and are not visible here. Upload the bank and card
statement CSVs for the period to code them."

**Sheet: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict | Tool used / external source | As-at date | Policy | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Output naming:** `[EntityName]_Coded_Transactions_[YYYY-MM-DD].xlsx`

`[EntityName]` is the company file's `display_name`.

**Grounding:** every suggestion traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the threshold, the tax rules — **name the source required** instead of assuming.

## Step 6 — Evolve the skill (Mosofin-specific, final step)

**The Learning Loop below and this step are the same mechanism.** The original already asks whether a
correction should become a rule for future runs; **this is where that rule is actually kept.**

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The vendor-to-account rules the user confirmed or corrected** — expressed as **vendor type or rule**
  wherever possible, and **as a specific vendor only where the user chose that**
- **The house coding policy** — any rule that overrides history
- **The capitalization threshold**, with its effective date
- **The tax code mapping** — which configured code applies to which kind of supply
- **The account map**: which accounts are uncategorized or suspense, which are the bank and card accounts
  for transfer detection, which is the intercompany account
- **The normalization rules** — the processor prefixes and vendor aliases specific to this entity's feeds
- **Known inconsistencies deliberately left alone**, and why
- The replay recipe: the exact sequence of reads that produced the history and the uncoded population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist transaction lists, amounts, or the coding history itself.** The history is state and is
re-read every run — that is the point of reading it. **Persist the rules; never the transactions.** And
**never persist a "possible personal" or related-party flag against a named individual** — an
unrebutted suspicion must not be carried forward.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — cloud hosting to 6310, threshold 1,000 from 2025-01-01, uncategorized is 8999" — not "cloud
hosting to 6310". **Account numbers are chart-specific and therefore entity-specific**, and applying one
company file's mapping to another files costs under headings that may not even exist. Record the chosen
**scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Learning Loop

**Preserved from the original, and now with somewhere to put the result.**

**If the user corrects a coding suggestion, apply the same logic to similar future transactions in the same
session.** At the end:

> **"I noticed you recoded [vendor] from [A] to [B]. Want me to note this as a rule for future runs?"**

**On yes, that rule goes into the Step 6 preferences** — keyed by datasource and `display_name` — and is
read back at the start of the next run, where it **overrides the ledger history**. A user correction is a
decision; the history is only practice.

**Encourage the user to maintain a vendor-to-account mapping file for reuse.** *Mosofin note*: **that file
is now largely redundant** — the ledger is the mapping, and the stored rules cover the exceptions. **What is
still worth maintaining by hand is the exception list**: the vendors where the obvious answer is wrong.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one history, one set of
rules.

**Multi-entity.** Steps 0–5 run **once per entity**, each call targeting exactly one `data_source_id`, every
suggestion carrying its entity's `display_name`. Then:

- **Confirm which entity each transaction belongs to before coding it.** This is the first question, not the
  last. A batch spanning two company files coded against one chart produces accounts that do not exist in
  the other.
- **The same vendor maps to different accounts in different entities**, because the charts differ. **Read
  each entity's history separately.** Never carry a Tier 1 match across company files.
- **A vendor whose name matches another connected entity is an intercompany transaction.** **[auto]** to
  detect — compare vendor names against the other files' legal names — and it should be coded to an
  intercompany account, not an expense.
- **A transfer between two group entities is not an inter-account transfer.** The original's transfer rule
  covers movements between the entity's *own* accounts. Money moving to a sibling company is an
  intercompany balance in both sets of books.
- **Thresholds and tax codes may differ by entity** — different sizes, different jurisdictions. Store them
  keyed by entity.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
