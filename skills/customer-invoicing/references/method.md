<!-- customer-invoicing · method.md · read for: Stages 3–6 — Steps 0–7: reading the books, mandatory fields, line and total checks, the JE, the invoice document, the workbook, saving; and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Apply jurisdiction-mandated invoice fields
- Step 2 — Validate line items
- Step 3 — Compute totals
- Step 4 — Construct the AR / Revenue / Tax JE
- Step 5 — Generate the invoice document
- Step 6 — Output
- Step 7 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the customer record,
the item list, the tax catalogue, the terms and the recent invoice sequence do not depend on each other.
Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, for the selling entity:

- *`get_company_info`* — **the seller's legal name, address and base currency** — usually **[auto]**
- *`search_customers`* / *`get_customer`* — **the customer's name, address, tax ID and default terms** —
  usually **[auto]**
- *`search_items`* / *`read_item`* — **descriptions, SKUs, standard prices and default income accounts**
  — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* / *`search_tax_agencies`* — **the tax codes and rates in
  use** — usually **[auto]**
- *`search_terms`* / *`get_term`* — the terms catalogue, including any early-pay discount — usually
  **[auto]**
- *`search_invoices`* over recent periods — **the existing number sequence, for the next number and the
  gap check** — usually **[auto]**
- *`read_invoice`* on recent invoices to this customer — **what they were last billed, on what terms, with
  what PO reference** — usually **[auto]**
- *`search_accounts`* — the revenue, output tax and deferred revenue accounts — usually **[auto]**
- *`get_customer_balance`* / *`get_aged_receivables`* — what they already owe, worth knowing before
  invoicing more — usually **[auto]**
- *`search_estimates`* — a quote that this invoice may be billing against — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — an invoice drafted from it would go to a real
customer with invented details, and a number drawn from a fixture sequence would collide with the real
one.

## Step 1 — Apply jurisdiction-mandated invoice fields

**Most jurisdictions require specific fields on a valid (tax-reclaimable) invoice. Ask the user for their
jurisdiction's required content, or include the common set and let them validate.**

Common required fields across jurisdictions — verdicts noted, since roughly half are `[auto]`:

- **Seller's legal name, address, and tax registration number** — **[auto]** for name and address
- **Customer's legal name and address** (and tax registration if B2B in many VAT / GST regimes) —
  **[auto]** from the customer record
- **Unique sequential invoice number** — **[auto]** to derive the next in sequence
- **Invoice date** — **[manual]**
- **Tax point / date of supply** (**may differ from the invoice date**) — **[manual]**, and frequently
  overlooked: the tax point, not the invoice date, decides which period the tax falls in
- **Description of goods / services** — **[auto]** from the item list
- **Quantity and unit** — **[manual]**
- **Unit price exclusive of tax** — **[auto]** for the standard price
- **Tax rate per line** — **[auto]** for the rate; **[manual]** for whether it is the right one
- **Tax amount per line and total** — **[auto]** arithmetic
- **Total exclusive of tax** — **[auto]**
- **Total inclusive of tax** — **[auto]**
- **Currency** — **[auto]**
- **Payment terms / due date** — **[auto]**
- **Any specific phrases the jurisdiction requires** (e.g. "Reverse charge", "Zero-rated export", "Tax
  invoice") — **[manual]**, and their absence is a common reason a customer's tax authority disallows
  their claim and they come back asking for a reissue

**If the user is in a jurisdiction with electronic invoicing mandates** — e-invoicing portals, QR codes,
government clearance — **flag it: the skill can produce the data but submission requires the relevant
platform.** Mosofin cannot submit to a government portal.

**In validate mode**, run this list against existing invoices and report every missing field.

## Step 2 — Validate line items

Each line — **[auto]** for all five checks, whether on a draft or on an existing invoice:

- **Description is non-blank and specific**
- **Qty > 0, unit price > 0** — **allow zero only with an explicit reason** (e.g. a free trial line)
- **Tax code valid for the jurisdiction**
- **Currency matches the invoice header**
- **Product / service code (SKU) if the entity uses one**

**Compute line totals: qty × unit price = line subtotal; subtotal × tax rate = line tax; subtotal + line
tax = line total.**

**[auto]** and worth adding in prepare mode: **compare the price being charged against the item's standard
price and against what this customer was last charged** (*`read_item`*, *`read_invoice`*). A price that
departs from both is either a deliberate concession or a keying error, and it is much cheaper to ask now.

## Step 3 — Compute totals

- **Subtotal** (sum of line subtotals)
- **Total tax by rate** (e.g. $X at 5%, $Y at 20%)
- **Discount** (if any) applied at invoice or line level — **specify which**
- **Shipping / freight** (if applicable)
- **Total exclusive of tax**
- **Total inclusive of tax**
- **Amount due**

**For tax-inclusive jurisdictions, show pre-tax and tax separately even if list prices were
tax-inclusive.**

All **[auto]** arithmetic. In **validate mode this is the arithmetic check** — recompute every existing
invoice's totals from its lines and report any that do not agree. Rounding differences at the line-versus-
total level are the usual cause and are worth quantifying rather than ignoring.

## Step 4 — Construct the AR / Revenue / Tax JE

Hand off to `journal-entry-builder`. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a
proposal:

```
DR  Accounts Receivable                            $total inclusive
    CR  Revenue (per product/service line)           $subtotal
    CR  Output Tax / VAT / GST Payable               $tax
    CR  Other (shipping income, etc.)                $other
Memo: Invoice [#] — [Customer]
```

**If revenue recognition is deferred** (e.g. a subscription invoiced annually in advance), book:

```
DR  Accounts Receivable                            $total inclusive
    CR  Deferred Revenue                             $subtotal
    CR  Output Tax Payable                           $tax
```

**And schedule periodic recognition. ASC 606 compliance is a revenue-recognition task.**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*, **[auto]**) —
including the **default income account already set against each item** (*`read_item`*), which is usually
the correct one and saves a decision per line.

Note that in most accounting systems, **entering the invoice generates this entry automatically.** So in
prepare mode this JE is documentation of what will happen; in validate mode it is a check that what did
happen was right — particularly the deferred-revenue case, which systems rarely handle without help.

## Step 5 — Generate the invoice document

**Format the invoice as a clean, professional document.** The format depends on user preference (PDF,
HTML, or system input):

- **Header**: seller logo, name, address, tax IDs, contact
- **Bill-to**: customer name, address, tax ID
- **Invoice metadata**: number, date, due date, currency, PO reference
- **Line items**: table with description, qty, unit price, tax %, line total
- **Totals**: subtotal, tax breakdown, total due
- **Payment instructions**: how and where to pay
- **Footer**: any required statutory text

**If the user wants a PDF, confirm the file name with them, then produce it with whatever PDF capability the host has; if there is none, give the invoice as text they can print or save as a PDF.**

**Mark every generated document as a draft for review.** Mosofin has not created it in the accounting
system and has not sent it. Two specific cautions:

- **Payment instructions carry bank details.** Confirm them with the user from a trusted source rather
  than reproducing them from memory or from an old document — invoice payment-detail fraud works by
  altering exactly this block.
- **The number on the draft is a proposal.** Until the invoice is actually entered, someone else may take
  that number.

## Step 6 — Output

**For a single invoice** → invoice document + JE inputs.
**For a batch** → an `.xlsx` with one row per invoice + a JE batch import.

**Sheet 1: Invoice Register**

| Inv # | Date | Due Date | Customer | Currency | Subtotal | Tax | Total | Status |

Add a header block: workspace name; **the selling entity by `display_name`**; each excluded company file
and why; the mode (prepare / validate); whether any figure rests on `mock` data.

**Sheet 2: Line Detail**

| Inv # | Line | Description | Qty | Unit Price | Subtotal | Tax Rate | Tax | Total | GL Revenue Account |

Add a **Source** column per field — pulled from the books, or supplied.

**Sheet 3: GL Posting**

Pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 4: Validation Results — NEW, Mosofin-specific**

| Inv # | Check | Result | Detail |

Covering mandatory fields, line validations, the arithmetic check, **duplicate invoice numbers**, and
**gaps in the number sequence**.

**Sheet 5: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be evidenced and who supplied it |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Invoices_[YYYY-MM-DD]_batch[N].xlsx`

In a multi-entity run, include the entity: `Invoices_[EntityDisplayName]_[YYYY-MM-DD]_batch[N].xlsx`.
Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the jurisdiction's field list, an exemption certificate — **name the source required**
instead of estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The jurisdiction's mandatory-field list** and the required statutory phrases. The most valuable item
  here: it is stable, it is genuinely hard to look up, and getting it wrong causes reissues
- **The numbering scheme** — prefixes, sequence rules, whether it resets, and whether each entity has its
  own
- **The invoice template**: layout, statutory footer text, and which fields appear where
- **The account map**: revenue accounts by item or service line, output tax, deferred revenue
- **Customer-specific requirements** — who requires a PO number, who is tax-exempt (with the certificate
  reference, not the certificate), who is billed under reverse charge, who withholds at source
- **The tax treatment per supply type**, including zero-rated and reverse-charge cases
- **Whether e-invoicing submission applies**, and through which platform
- The replay recipe: the exact sequence of reads that produced the pre-filled data

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; **no `.html`, `.css`, or `.svg` files** — which matters here, because
an invoice template is a natural thing to want to store that way. Keep the template as structured
description, not markup. Or write preference files alongside the installed skill.

**Never persist customer tax IDs, bank details, or invoice contents.** Tax IDs are personal or
commercially identifying data; **bank details are the target of invoice payment fraud**, and an invoice
template stored with live payment instructions is exactly what an attacker would want to alter. Persist
the *structure and the rules*, and keep payment details in the system that controls them.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading Ltd — invoice prefix NT-, sequence continuous; statutory footer required; reverse charge for EU
B2B services" — not "invoice prefix NT-". **Each entity has its own legal identity, tax registration and
number sequence**, and an unlabelled numbering scheme applied to the wrong company file produces
duplicate numbers across two legal entities. Record the chosen **scenario** (single vs multi, and which
entity sells) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and **the next invoice number is state**, re-read every time.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One legal identity, one sequence.

**Multi-entity.** The selling entity is chosen at Gate 1, and **the draft is built from that entity's file
only**. Then:

- **Each entity has its own legal name, tax registration and number sequence.** Never draw the customer's
  details from one entity's records and the seller's details from another's — the resulting document is
  legally wrong and, in a VAT regime, unusable by the customer.
- **The same customer may exist in several entities' records with different details.** Use the selling
  entity's record; it is the one the contract sits under.
- **Number sequences must not collide.** Where entities share a numbering convention, confirm each has its
  own range or prefix. Two legal entities issuing invoice "1042" is a real problem at audit.
- **Invoicing between group entities is an intercompany transaction.** It still needs a proper invoice
  where the jurisdictions require one, and it must be eliminated on consolidation and agreed in an
  intercompany reconciliation.
- **The gap-and-duplicate check runs per entity**, since each sequence is its own.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
