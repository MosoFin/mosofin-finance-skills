---
name: invoice-data-extractor
description: "Use this skill whenever the user uploads a vendor invoice (PDF, image, or scanned doc) and wants structured data extracted, validated against their Mosofin workspace. Triggers include: 'extract the data from this invoice', 'pull the fields from this bill', 'parse these invoices', 'turn this PDF into a row I can post', or uploading any vendor invoice with implicit intent to capture it. Also trigger for bills, receipts, purchase invoices, and supplier statements where the goal is to convert visual document data into structured fields. Workspace-scoped on the validation side: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then checks each extracted invoice against the vendor master, the posted transaction history and the Bill-To entity — catching duplicates before they are paid. Do NOT use for OCR alone — extract semantically. Do NOT use for posting the JE — pair with journal-entry-builder. Outputs a structured row per invoice with vendor, dates, amounts, line items, tax breakdown, validation results, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill works with or without Mosofin

**With Mosofin connected**, the skill reads your live accounting data through the
gateway: the figures come from your own books, it validates against the real chart of
accounts, and most steps run automatically.

**Without it, the skill still works.** No subscription, no connector, or a skill copied
on its own — you are not blocked and you are not asked to buy anything first. The
Mosofin gates are skipped and you are asked for what each step needs instead: a trial
balance, a statement, an export, the documents themselves. **The accounting logic, the
edge cases and the output standards are identical** — only where the numbers come from
changes, and the output always says which is which.

### Strict rule — this skill never changes your data

**This skill will never write, update or delete existing data in any data source.**
Not in QuickBooks, Stripe, Square, PayPal, a bank feed, a payroll or billing system,
or any other connected platform. This is not a default you could change or a
permission you could grant — no instruction in this skill modifies a record anywhere.

It will **never**:

- create, edit, overwrite, void or delete a record in a connected platform
- invoke a write operation, or ask you to approve or enable one — a write tool is out
  of scope even when your policy has it enabled
- direct you to update, overwrite or delete existing data in a data source
- copy or move data from one connected platform into another

What it does instead is **read, and propose.** Every entry, schedule, reconciliation
and document it produces is a **draft for you to review.** Where it finds a problem —
a duplicate, a mismatch, a stale balance — it describes the problem and proposes a
correcting entry as a draft. It does not tell you to delete or overwrite the original,
and it never acts on one itself.

Whether anything reaches your books is a decision you make outside this skill, in your
own system, by your own hand. **If you act on none of it, nothing in your data has
changed.**

### Onboarding — required whenever Mosofin is connected

**If the Mosofin gateway is connected, onboarding is not optional and not per-skill.**
Before any skill reads anything, the workspace and the data sources in it must be
confirmed with you. It is the same sequence for every Mosofin skill, so it is kept in
one place rather than repeated in each:

- in this repo: [`shared/onboarding.md`](../../shared/onboarding.md)
- installed on its own, or you would rather read the product docs:
  [docs.mosofin.com/start-here/quickstart](https://docs.mosofin.com/start-here/quickstart)

**Already onboarded this workspace?** Then you have answered it once and will not be
asked again from scratch — but **the confirmation itself still happens every run.**
Gate 0 reads your workspace back and waits for an explicit yes; Gate 1 settles which
company file. Those are not skippable, and no data is read before them.

**No Mosofin connector? The skill still works.** If the gateway is not present at all,
there is nothing to onboard: the gates are skipped, every step becomes `[manual]`, and
you are asked for what each step needs — a trial balance, a statement, an export.
**The accounting work is unchanged**; only the data source is. You will be told this
once, and you will not be asked to install anything before being helped.

What follows in **Part A** is not more onboarding. It is this skill exploring what your
confirmed workspace and data sources can actually do — which tools exist, which serve
this particular request — so the run is shaped around your books rather than a generic
template.

---
<!-- shared:onboarding-inline end -->
# Invoice Data Extractor (Mosofin)

Extracts **structured data from vendor invoices** — PDFs, scans, photos — into **accounting-ready fields**.
Handles single invoices and batches. Designed to feed downstream workflows: **GL coding, AP entry,
three-way match, or accounting system import**.

**In plain words:** somebody sends a bill as a PDF. Before it can go into the accounts, every number and
date on it has to become a field — and before it gets paid, somebody should check it is a real supplier, a
bill for this company, and one nobody has already paid.

This skill is **jurisdiction-agnostic**. **It captures whatever tax fields appear on the invoice — rates,
jurisdictions, amounts — as they are; it does not assume any tax regime or recoverability rules.**

## Extraction is document work; validation is workspace work

**The invoice is not in the workspace.** Mosofin holds no PDFs, no images and no document store — **the
document comes from the user, and reading it is model work exactly as the original describes.** Steps 1
through 6 are unchanged in substance.

**But everything you would want to check that extraction against is readable**, and that is where this
skill gains most:

| Validation | How | Verdict |
|---|---|---|
| **Is this invoice already in the system?** | Vendor + invoice number + amount against posted bills | **[auto]** — **the highest-value check here** |
| **Is this a known vendor?** | Against the vendor master, by name, tax ID and address | **[auto]** |
| **Is the Bill-To the right entity?** | Against the connected company's legal name | **[auto]** |
| **Do the payment terms match the vendor record?** | Against the vendor master | **[auto]** |
| **Is there a PO to match to?** | Against purchase orders, where they exist | **[gated]** |
| **Has it already been paid?** | Against payments and the vendor balance | **[auto]** |
| **How is this vendor usually coded?** | Against posted history — see `gl-coding-assistant` | **[auto]** |
| **Is the currency plausible?** | Against the entity's currency and the vendor's history | **[gated]** |

**The duplicate check is the one that pays for the skill.** An invoice number already posted for that vendor
is a **double payment about to happen**, and it is a single query at exactly the moment it can still be
prevented. See `duplicate-invoice-detection` for the full matching discipline; the same rules apply.

**And one check the original specifies that cannot be fully performed here — stated plainly:**

> **Step 5's bank-detail fraud check.** The original says: *"If the user has prior invoices from the same
> vendor with different bank details, flag immediately."* **Vendor bank details are not exposed on this
> surface.** The prior invoices are readable; **their bank details are not.**
>
> **Report this check as NOT RUN**, with what it would have shown and how to perform it. **Do not substitute
> a weaker comparison and imply it covered the same ground** — this is the same gap named in
> `duplicate-invoice-detection` (Rule 7) and `fraud-detection-and-forensics`, and it is consistent across
> all three.
>
> **What can be compared** is the **remit-to name and address** against the vendor master, which catches
> some redirection attempts and is worth doing. **It is not the bank-detail check.**

**Mosofin is read-only.** It cannot create a vendor, post a bill or schedule a payment. Extraction produces
a *proposal*.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before validating anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

**Extraction itself can begin without the gates** — the document is the user's. **But nothing may be
validated, and no result reported as checked, until the workspace is confirmed.**

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

<!-- shared:scope-protocol start -->
### First — is Mosofin connected at all?

**Before Gate 0, check whether the Mosofin tools are present** — `list_workspaces` and
the rest of the gateway.

**If they are not present** — the skill was copied on its own, the connector was never
added, or there is no subscription — **skip Gates 0-2 entirely.**
**Do not make connecting a condition of helping.** Say once, plainly, that Mosofin is not connected
and this run will be manual, then **carry on with the skill's normal workflow**: ask
for what each step needs — a trial balance, a statement, an export, the documents
themselves — and do the accounting work on what the user provides.

In that mode:

- every step is `[manual]`; there are no `[auto]` verdicts to claim, and none may be
  implied
- the coverage sheet records that **the gateway was absent** — not that checks passed
- the accounting logic, edge cases and output standards are **unchanged**. That is the
  part of this skill that never depended on a connection
- mention **once** that connecting Mosofin would automate the manual steps, with a link
  to [docs.mosofin.com](https://docs.mosofin.com). Do not raise it again, and never
  withhold work to press the point

**Present but not authenticated is not the same as absent.** If the tools are there and
a call returns a `reconnect_url` or an auth error, surface it and let the user choose —
reconnect, or continue manually. Do not silently fall back.

**If the tools are present, onboarding is required** and the gates below run as written.

### Confirming scope — workspace, then data sources, then tools

**Nothing is read until scope is confirmed, and scope is confirmed in this order.**
Each step depends on the answer to the one before it, so none of them may be skipped,
merged, or guessed at.

| # | Question to the user | How it is settled |
|---|---|---|
| 1 | **Which workspace?** | `list_workspaces` with **no arguments**. Read the workspace back **by name** and wait for an explicit yes. On `selection_required`, ask whether this is single- or multi-workspace, then which **by name**, then call again with `workspace_ids=[…]` and `mode="single"`/`"multi"`. |
| 2 | **Which data sources, in that workspace?** | `get_agent_datasources` with the confirmed `workspace_id`. `connected: true` is in scope; `connected: false` is **excluded and named as excluded**, with any `reconnect_url` surfaced. Then settle the entity scenario — single-entity: which company; multi-entity: which set — always by `display_name`. |
| 3 | **Which tools do those sources actually expose?** | `get_datasource_tools` per in-scope datasource, **and per company file when several are live — permissions are per company.** This is discovery, not a question: read what is there before promising anything. |

**Never auto-pick.** Not the workspace, not the company file, not the entity scenario.
**Silence is not a yes**, and an answer to one question is not an answer to the next.

**Names, never internal ids.** Name the workspace and refer to companies by
`display_name`. Never print an internal numeric tenant id, and never show a raw
`data_source_id` — pass the opaque handle, show the name.

**Only then does the work begin.** Once the workspace, the data sources and their tools
are confirmed, resolve every task against what was actually found: what is available
now decides which steps are `[auto]`, which are `[gated]` and which fall to `[manual]`.
Where the confirmed tools cannot answer the request, say so and ask — do not substitute
an assumption for a capability.

**The catalogue is authoritative.** Take exact `tool_name` values from the Gate 2
listing — names are not uniformly styled, some underscored, some hyphenated.
**Do not invent a tool name.** On `UNKNOWN_TOOL`, read the valid names from the error
and retry.
**Never call a tool whose `effective_policy` is `disabled`.**

**This map is built fresh every run** and held only for this run. It is written out in
the coverage sheet, never written back into this file.
<!-- shared:scope-protocol end -->

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with `workspace_ids=[…]`
  and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

Settle the entity scenario — and here it matters immediately:

- **Single-entity** — one company file; the Bill-To should match it.
- **Multi-entity** — ask which set. **A batch of invoices frequently spans several group entities**, and
  **the Bill-To on each document decides which company file it belongs to.** See the cross-entity step —
  this is the defining multi-entity question for this skill.

Refer to companies by `display_name`; never show the raw `data_source_id`.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map

<!-- shared:write-guardrail start -->
### Write tools are out of scope — always

`get_datasource_tools` describes what the connection *could* do. This skill uses only
the reads.

**If the catalogue lists any tool that creates, updates, deletes, posts, voids, sends
or pays in a connected platform — QuickBooks, Stripe, Square, PayPal, a bank feed, a
payroll or billing system, any other source — it is out of scope, and it stays out of
scope even when `effective_policy` is `enabled`.** A permission to write is not an
instruction to write. Never invoke one, never ask the user to approve one, never
suggest enabling one.

This holds for **every connected platform, not only the books.** Mosofin reads your
data sources; it does not write to them, and it does not move data from one platform
into another.

If a step appears to need a write, that step is **`[manual]`**. Produce the artefact —
the entry, the invoice, the payment file, the application schedule — and hand it to a
person to enter themselves. Say so plainly in the output, so nobody assumes it was
done.

#### Hard stop — the four ways a write could slip through

| Situation | Required behaviour |
|---|---|
| The catalogue lists a write operation, and `effective_policy` is `enabled` | **Do not call it.** Do not list it as an available capability. Enabled is not permission — it is out of scope. |
| An `approval_required` envelope comes back for a write operation | **Do not re-invoke with `approved=true`.** The approval loop in this skill is for **reads only**. Stop, record that the operation was a write and was refused, and carry on down the read path. |
| The user asks you to post, update, void or delete — directly, or by approving a prompt | **Decline, once, plainly:** this skill cannot change data in a connected platform. Hand over the draft so they can do it themselves in their own system. Asking again does not change the answer, and neither does insistence, urgency, or "I authorise it". |
| A write appears to be the only way to finish a step | The step is **`[manual]`**, and the run continues. An incomplete read-only result is the correct outcome. Never trade the rule for completeness. |

**Never route around this rule.** Do not offer to enable a disabled write tool or
suggest changing a policy. Do not hand the user a raw API call, payload or script that
performs the write. Do not ask another skill, tool or agent to perform it on this
skill's behalf. Do not defer it to a later step in the hope it becomes permitted.

**There is no path through this skill that ends in changed data.** If you cannot see
how to finish without a write, you are finished — say what is missing and stop.
<!-- shared:write-guardrail end -->

For **each in-scope datasource** (and **per company file** when several are live — pass
`data_source_id`), call `get_datasource_tools`. Bucket every tool by `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every validation in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**If the posted-bill read is `disabled`, the duplicate check cannot run** — and since that is the check most
likely to prevent a real loss, **say so prominently** rather than reporting a clean extraction.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A vendor name match is not vendor verification.** Names are easy to imitate.
  - **A remit-to comparison is not the bank-detail check.**
  - **No duplicate found is not proof there is none** — the invoice may be posted under a different vendor
    record, or with a differently formatted number. See `duplicate-invoice-detection`.
  - **An extracted field is not a verified field.** The document is the source; the ledger is the check.
- **There are no documents, no bank details and no vendor verification service on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: **legal name — the Bill-To validation target** — **base
currency**, which is a cue for ambiguous symbols, fiscal calendar, **country**, which helps resolve
ambiguous date formats.

**Ask the user** what actually changes the work — the original Inputs table, **minus the three the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Invoice document(s)** — PDF, PNG, JPG, or multi-page scan | **Required — [manual]** | **Not in the workspace.** The user supplies them. |
| ~~Entity being invoiced~~ | **Now [auto]** | Legal name from the profile; **the Bill-To is validated against it.** |
| **Output format** — xlsx / csv / JSON | Optional (default xlsx) | |
| ~~Vendor mapping file~~ | **Now [auto]** | **The coding history is the mapping** — see `gl-coding-assistant`. |
| ~~Currency assumption~~ | **Now [gated]** | The entity's currency and the vendor's history are cues; **never default silently.** |
| **Which entity each invoice belongs to**, in a batch | **Required if multi-entity — [gated]** | Proposed from Bill-To; confirmed by the user. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm manual evidence** | **Required** | The documents are `[manual]`; note their filenames and count. |

**If a non-invoice document is uploaded — receipt, statement, contract, quote — confirm with the user before
extracting.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a currency, a date
interpretation, or a vendor identity.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The vendor naming conventions, the invoice-number formats and the validation tolerances persist; **every
document and every validation result is new each time.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The documents are `[manual]` by nature, and the bank-detail
check cannot run — both are recorded rather than quietly omitted.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the validation evidence (grounding) — Mosofin addition

**Runs alongside extraction, not before it** — you need the vendor name and invoice number from the document
before you can look for them.

**Batch independent reads into one message** once the header fields are extracted. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical batch, per in-scope entity:

- *`search_vendors`* + *`get_vendor`* — **the vendor master: name, tax ID, address, terms, default
  account** — usually **[auto]**
- *`search_bills`* / *`search_purchases`* — **posted bills for this vendor, and for this invoice number:
  the duplicate check** — usually **[auto]**
- *`search_payments`* — **whether it has already been paid** — usually **[auto]**
- *`get_general_ledger`* / *`get_profit_and_loss`* — **how this vendor is usually coded** — usually
  **[auto]**
- *`search_purchase_orders`* — **PO matching**, where POs are used — often **[gated]**
- *`get_aged_payables`* — the vendor's current balance — usually **[auto]**
- *`get_company_info`* — **legal name for Bill-To validation**, currency, country — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that validation to **[manual]** and record the gap. **Name the duplicate
  check specifically if it is the one lost.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate check against fixture bills proves
nothing**, and reporting an invoice as "not previously seen" on that basis is worse than not checking.

## Step 1 — Read the document(s)

**Read the pdf-reading skill first**: `/mnt/skills/public/pdf-reading/SKILL.md`

- **PDF with text layer → extract text directly**
- **Scanned PDF or image → OCR-capable extraction**
- **Multi-page → confirm whether one invoice spans pages or multiple invoices are bundled**
- **Rotate if orientation is off**

**[manual]** on the source, model work on the reading. **Record the original filename and page count** — the
original's Sheet 4 requires it, and it is the audit trail.

## Step 2 — Identify header fields

**Extract these. Use the vendor's labels as ground truth and normalize to standard field names:**

| Standard field | Common invoice labels | Mosofin validation |
|----------------|----------------------|---|
| **Vendor name** | Top of invoice, letterhead | **[auto]** against the vendor master |
| **Vendor address** | Below vendor name | **[auto]** against the vendor record |
| **Vendor tax registration ID** | **"VAT #", "GST #", "ABN", "EIN", "CR No.", "Tax ID", "TRN"** — whatever the local term is | **[auto]** where held on the vendor record |
| **Vendor remit-to** | **"Remit payment to", "Mail payments to"** | **[gated]** — **the closest available proxy for the bank-detail check** |
| **Invoice number** | **"Invoice #", "Bill #", "Document #", "Tax Invoice #"** | **[auto]** — **the duplicate check** |
| **Invoice date** | "Invoice Date", "Date Issued", "Bill Date" | — |
| **Due date** | "Due Date", "Payment Due" — or calculated from terms | **[auto]** against vendor terms |
| **Payment terms** | **"Terms", "Net 30", "2/10 Net 30", "End of Month + N"** | **[auto]** against the vendor record |
| **Customer / billed-to name** | **"Bill To", "Sold To", "Invoice To"** | **[auto]** against the entity's legal name |
| **Customer reference / PO #** | **"PO #", "Customer Ref", "Your Reference"** | **[gated]** against open POs |
| **Currency** | Symbol or explicit code | **[gated]** against entity currency and vendor history |

**If a field is not visible on the invoice, set to `null`. Do not guess.**

**Date normalization**: **output all dates in ISO `YYYY-MM-DD`**, regardless of how the invoice formats them
— DD/MM/YYYY, MM/DD/YYYY, DD-Mon-YY. **Be cautious with ambiguous formats** — e.g. "03/04/2025" — **use
other invoice cues (vendor country, language) to resolve, and flag if ambiguous.** *Mosofin note*: **the
vendor's address on the vendor master and the entity's country are additional cues**, and **prior invoices
from the same vendor show the convention that vendor actually uses.**

**Currency identification**: **a "$" symbol alone is ambiguous — USD, CAD, AUD, NZD, SGD, HKD, and others.
Look for explicit ISO codes, country-specific cues, or ask the user. Never default to USD silently.**
*Mosofin note*: **what currency this vendor has been billed in before is readable**, which usually resolves
it — but it is a cue, not proof, and a vendor can change.

**Vendor name normalization**: **use the legal name as it appears. Consolidate variants across invoices in
the same batch.** *Mosofin note*: **consolidate against the vendor master's spelling**, so the batch matches
the books rather than inventing a third variant.

**Mosofin vendor check — three outcomes, reported differently:**

- **Matches an existing vendor** → validated; terms, tax ID and address comparable
- **No match** → **a new vendor.** Not wrong, but **a new vendor with an immediate invoice is the shape of a
  fictitious-vendor scheme** — see `fraud-detection-and-forensics`. Flag for setup and review, do not
  accuse
- **Matches several similar vendors** → **a duplicate vendor record**; the history is split, and the
  duplicate check is weakened

## Step 3 — Extract line items

**For each row in the line item table:**

| Field | Description |
|-------|-------------|
| **Line description** | Service or product description |
| **Quantity** | Numeric; **default 1 if not shown** |
| **Unit price** | Numeric |
| **Line subtotal** | Quantity × Unit price |
| **Line tax** | Tax allocated to this line, if shown |
| **Line total** | Subtotal + tax |
| **Service period** | **"From — To" dates if shown** |
| **Product code / SKU** | If shown |

**If the invoice has only a single total with no line breakdown, capture as one line with description = main
service description.**

**Do not invent line items. Three lines on invoice = three lines in output. No merging, no splitting.**

*Mosofin note*: **the service period matters downstream** — it drives `prepaid-amortization-schedule` and
`accruals-and-deferrals`, and **it is the field most often dropped in extraction.** Capture it.

## Step 4 — Totals and tax breakdown

| Field | Description |
|-------|-------------|
| **Subtotal (pre-tax)** | Sum of line subtotals |
| **Discount** | If shown |
| **Shipping / freight** | If shown separately |
| **Tax — total** | Total tax on invoice |
| **Tax — by rate** | **Break down by rate if multiple** — e.g. 5% on one item, 13% on another |
| **Tax — by jurisdiction** | **If multiple jurisdictions stacked** — e.g. federal + sub-national |
| **Tax inclusive or exclusive** | **Identify whether prices include tax** — common in UK, AU, EU, NZ — **or exclude tax** |
| **Total amount due** | Final amount payable |
| **Amount paid (if any)** | If the invoice shows partial payment |
| **Balance due** | Total − paid |

**Cross-check: Subtotal + Tax + Shipping − Discount should equal Total. If not, capture as-is and flag the
discrepancy. Do not silently force a match.** **[auto]** arithmetic, and it is one of the more useful
extraction quality signals — **a failed cross-check usually means a misread figure, not a wrong invoice.**

**Tax-inclusive pricing**: **if the invoice shows "Total includes VAT / GST" or similar, decompose
explicitly**: show pre-tax subtotal, tax amount, and total. **The invoice may show only the inclusive total
— extract what's visible and flag any decomposition that requires assumption.**

**Mosofin note on shipping and freight**: where the invoice is for inventory or a capital item, **freight is
part of the asset's cost** — see `inventory-costing-fifo-lifo-wavg` and
`fixed-asset-register-and-depreciation`, both of which flag freight expensed rather than capitalised.
**Capturing it separately is what makes that treatable.**

## Step 5 — Payment instructions

| Field | Description | Verdict |
|-------|-------------|---|
| **Payment methods accepted** | **ACH, wire, cheque, credit card, SEPA, BACS, UPI**, etc. | **[manual]** — from the document |
| **Bank account details** | If shown — **offer to mask for security** | **[manual]**; **and see below** |
| **Online payment link** | If present | **[manual]** |
| **Late fee policy** | If stated | **[manual]** |

**Critical fraud check: if the user has prior invoices from the same vendor with different bank details,
flag immediately. Bank-detail changes are a top vector for invoice fraud.**

**Mosofin position on this check — stated rather than softened:**

**This check cannot be fully performed here.** **Vendor bank details are not exposed on this surface**, so
prior invoices' bank details cannot be read for comparison. **Report it as NOT RUN**, name what it would
have shown, and say how to run it: compare against the vendor's banking record in the payment system or the
prior invoice documents themselves.

**What can be done, and should be:**

- **Compare the remit-to name and address to the vendor master** — **[auto]**. A remit-to that differs from
  the known address is worth a question, and it catches some redirection attempts.
- **Flag any invoice whose remit-to differs from prior invoices in the same batch.**
- **Treat bank-detail changes as requiring out-of-band verification** — a phone call to a known number,
  never a number on the invoice. **Say this**; it is the control that actually works, and it is not
  something any system performs.

**Never enter or transmit bank details.** Mask them in output as the original suggests.

## Step 6 — Classify and tag

| Tag | Values |
|-----|--------|
| **Document type** | **Invoice / Tax Invoice / Credit Memo / Pro Forma / Statement / Receipt** |
| **Recurrence** | **One-time / Subscription** (if service period shown) **/ Recurring** (vendor history) |
| **Confidence** | **High** (clear, all fields) **/ Medium** (some unclear) **/ Low** (poor quality) |

**Optionally, hand off to `gl-coding-assistant` for account suggestions.** **[auto]** — and in a Mosofin
workspace that handoff is stronger than the original assumes, because **the coding history is readable with
counts** rather than depending on a mapping file.

**Mosofin additions to the tags:**

- **Recurrence is `[auto]`**: **prior invoices from this vendor at regular intervals and similar amounts**
  are readable, so "Recurring" is an observation rather than an inference.
- **Confidence should incorporate validation, not just legibility.** A perfectly legible invoice from an
  unknown vendor, with an invoice number already in the system, is **not high confidence** — it is a clear
  document with a serious problem. **Add a separate Validation Status** so the two are not conflated:

| Validation status | Meaning |
|---|---|
| **Clean** | Known vendor, no duplicate, Bill-To matches, terms consistent |
| **Review** | New vendor, terms mismatch, currency unusual for this vendor, remit-to differs |
| **Stop** | **Duplicate invoice number for this vendor**, or **already paid**, or **Bill-To is a different entity** |

## Step 7 — Output

**Single invoice → structured summary inline + downloadable file. Multiple invoices → one xlsx with multiple
sheets.**

**Sheet 1: Invoices** (one row per invoice)

| Vendor | Vendor Tax ID | Invoice # | Invoice Date | Due Date | Currency | Subtotal | Tax | Shipping | Discount | Total | Tax-Inclusive? | PO # | Payment Terms | Confidence | Notes |

**Add three Mosofin columns**: **Entity** (`display_name`), **Validation Status**, and **Duplicate Match**
(the posted bill it matches, where one exists).

**Sheet 2: Line Items**

| Invoice # | Line # | Description | Qty | Unit Price | Subtotal | Tax | Total | Service Period Start | Service Period End | Product Code |

**Sheet 3: Tax Detail** (if multi-rate / multi-jurisdiction)

| Invoice # | Tax Rate | Tax Jurisdiction Label | Tax Amount |

**Sheet 4: Source Reference**

| Invoice # | Original Filename | Pages | Notes from extraction |

**Sheet 5: Validation Results — NEW, Mosofin-specific**

| Invoice # | Check | Result | Evidence | Verdict |

Covering: vendor match, duplicate check, already-paid check, Bill-To match, terms match, PO match, currency
plausibility, remit-to comparison — **and the bank-detail check, recorded as NOT RUN with its reason.**

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

**JSON output structure** — extended with the validation block:

```json
{
  "invoices": [
    {
      "vendor": { "name": "...", "tax_id": "...", "address": "..." },
      "invoice_number": "...",
      "invoice_date": "YYYY-MM-DD",
      "due_date": "YYYY-MM-DD",
      "currency": "ISO-4217 code",
      "tax_inclusive": false,
      "totals": { "subtotal": 0, "tax": 0, "shipping": 0, "discount": 0, "total": 0 },
      "tax_breakdown": [{ "rate": 0, "jurisdiction": "...", "amount": 0 }],
      "line_items": [...],
      "extraction_confidence": "High|Medium|Low",
      "validation": {
        "entity": "display_name",
        "status": "Clean|Review|Stop",
        "vendor_match": "...",
        "duplicate_match": null,
        "already_paid": false,
        "bill_to_match": true,
        "checks_not_run": ["bank_detail_comparison"]
      },
      "notes": [...]
    }
  ]
}
```

If creating xlsx, read: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Invoices_Extracted_[YYYY-MM-DD]_[count]invoices.xlsx`

**Grounding:** every extracted figure traces to the source document, named by filename and page; **every
validation result traces to a tool result in this conversation.** End with a single **Data sources** line.
Where a check could not run — the bank-detail comparison, or any `disabled` read — **name it as not run**
rather than omitting it.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **Vendor naming conventions** — how this entity's vendor master spells names, so batches consolidate to
  the books rather than to a third variant
- **Invoice-number formats by vendor** — which matters for duplicate matching, since a vendor whose numbers
  are sometimes prefixed and sometimes not defeats an exact match
- **The duplicate-match tolerances** — the date window and amount tolerance agreed with this client
- **The Bill-To names** for each connected entity, including trading names that appear on invoices
- **The validation status rules** — what constitutes Review versus Stop here
- **Known ambiguities by vendor** — date format conventions, currency, tax-inclusive pricing
- **The escalation path** for a Stop result, and **the out-of-band verification procedure** for bank-detail
  changes
- The replay recipe: the exact sequence of reads that performed the validations

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist invoice contents, amounts, vendor bank details, remit-to addresses or extracted documents.**
Invoice data is commercially sensitive — **supplier pricing in particular is frequently confidential** —
and bank details must never be stored anywhere by this skill.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — Bill-To appears as 'Northbrook Trading Ltd' and 'Northbrook Trading', invoice numbers from
Vendor A carry an 'INV-' prefix inconsistently, 3-day duplicate window" — not "3-day duplicate window".
**Bill-To names and vendor conventions are entity-specific**, and applying one entity's Bill-To list to
another would validate an invoice against the wrong company. Record the chosen **scenario** (single vs
multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. Every Bill-To should match that entity;
one that does not is a finding.

**Multi-entity.** **The defining question for this skill is which entity each invoice belongs to**, and the
document answers it:

- **Route by Bill-To.** **[auto]**: compare the extracted Bill-To against each connected entity's legal name
  and known trading names. **Propose the routing; confirm it with the user** before validating against that
  entity's books.
- **Run the duplicate check against the right entity — and consider running it across all of them.** An
  invoice posted to the wrong group company is still a payment made; **a cross-entity duplicate is invisible
  to any single entity's review.** See `duplicate-invoice-detection` and `intercompany-reconciliation`.
- **A Bill-To that matches no connected entity** is either a group member that is not connected, an invoice
  for someone else entirely, or a fraud attempt. **Stop and ask** — never route it to the nearest match.
- **Vendor masters differ by entity.** A known vendor in one company file may be unknown in another, so
  **"new vendor" is entity-specific** and should be reported that way.
- **The same supplier may invoice several group entities**, which is normal — and **it also means the
  duplicate check should consider whether the same invoice was booked twice across two entities.**
- **Currency may differ by entity**, so the currency plausibility cue is per entity, not per group.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each validation's verdict per
company file.

---

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on discovery; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 8. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The vendor master: name, tax ID, address, terms** | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **Posted bills — the duplicate check** | `search_bills` / `search_purchases` / `get_bill` | `start_date`, `end_date` (required); `id` |
| **Whether it has already been paid** | `search_payments` / `get_aged_payables` | `start_date`, `end_date`; `as_of_date` |
| **How this vendor is usually coded** | `get_general_ledger` / `get_profit_and_loss` | `start_date`, `end_date`, `account` |
| PO matching, where POs are used | `search_purchase_orders` | `start_date`, `end_date` |
| **Legal name for Bill-To validation, currency, country** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There are no documents, no bank details and no vendor verification service on this surface.**

---

## Plain-language glossary

- **Extraction** — turning what a document shows into fields a system can use. **Semantic, not just OCR**:
  knowing that a number is the tax and not the total.
- **OCR** — reading text off an image. **It makes mistakes**, which is what confidence ratings are for.
- **Header fields** — the invoice-level information: who, when, how much in total.
- **Line items** — the individual things being charged for.
- **Tax-inclusive vs. exclusive** — whether the prices shown already contain the tax. **Misreading one for
  the other overstates expense and understates tax.**
- **Remit-to** — where the supplier wants to be paid, which may differ from their trading address.
- **Bill-To** — who the invoice is addressed to. **In a group, this decides whose books it belongs in.**
- **PO (purchase order)** — the order placed before the goods came. **Matching to it is the first half of a
  three-way match.**
- **Pro forma invoice** — a quote dressed as an invoice. **Not a legal invoice and not an accounting
  document.**
- **Statement** — a summary of many invoices. **The invoices get posted, not the statement.**
- **Credit memo** — a negative invoice: money coming back.
- **DBA / trading name** — a name a business operates under that is not its legal name.
- **Duplicate invoice** — the same bill entered twice. **The single most expensive routine AP error.**
- **Out-of-band verification** — confirming a change through a separate channel, using contact details you
  already had. **The only control that reliably catches payment redirection.**

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Poor-quality scans / handwriting**: **Mark Confidence: Low. Output what's legible; mark unreadable fields
as `null`. Do not guess.**

**Multiple invoices in one PDF**: **detect page breaks — header repetition, new "Invoice #". Treat each as
separate. Confirm count with user.**

**Statement vs invoice**: **a statement summarizes multiple invoices — Beginning Balance, Charges, Payments,
Ending Balance. Detect and ask — statements are usually not posted; their underlying invoices are.**
*Mosofin note*: **a statement is genuinely useful for a different purpose** — reconciling the vendor's view
to the entity's payable balance, which is `[auto]` (*`get_aged_payables`*). **Offer that instead of
posting it.**

**Credit memos**: **negative amounts, "Credit Memo", "Refund", or parenthesized amounts. Tag as Credit Memo.
Output amounts negative for downstream processing.**

**Foreign language**: **identify language, translate field labels, preserve original amounts and currency.
Note translation in output.**

**Embedded purchase orders**: **sometimes a PO is attached. Extract separately and link via PO #.**

**Recurring service invoices**: **service periods — e.g. "Service from Jan 1 – Jan 31" — matter for prepaid
amortization. Capture them.**

**Tax-inclusive vs exclusive prices**: **always identify which. Misreading inclusive as exclusive overstates
expense and understates tax.**

**Ambiguous date format**: **"03/04/2025" — use vendor country, language, or other date cues. Flag if
unresolved.** *Mosofin note*: **prior invoices from the same vendor show that vendor's convention.**

**Ambiguous currency symbol**: **"$" alone — never default to USD. Use vendor country, ISO code if shown, or
ask user.** *Mosofin note*: **the vendor's billing history is a strong cue** — and still a cue.

**Vendor / DBA / payee name mismatch**: **a vendor may operate under a different trade or payment name.
Capture all; flag the mismatch.**

**Math discrepancies on the invoice**: **if line items don't sum to subtotal, or subtotal + tax ≠ total,
capture as-is and flag. The invoice is the legal document; do not silently fix.** *Mosofin note*: **a failed
cross-check usually indicates a misread figure** — re-check the extraction before concluding the invoice is
wrong.

**"PAID" stamp or paid date shown**: **capture and flag. AP entry may not be needed, or only the unpaid
portion is.** *Mosofin note*: **whether it is paid in the books is `[auto]`**, and the two can disagree —
paid per the stamp but open in the ledger, or the reverse.

**Pro Forma invoices**: **not legal invoices — they're quotes. Flag and exclude from AP unless the user
explicitly wants to record them as a commitment.**

**The invoice number is already posted for this vendor** — *Mosofin-specific, and the highest-value
finding*. **A double payment about to happen.** Status: **Stop.**

**The vendor is not in the master** — *Mosofin-specific*. Not wrong in itself, but **a new vendor with an
immediate invoice is the shape of a fictitious-vendor scheme.** Flag for setup and review; do not accuse.

**Duplicate vendor records split the history** — *Mosofin-specific*. **The duplicate check is weakened**
because prior invoices are spread across records.

**The Bill-To is a different group entity** — *Mosofin-specific*. Route it, do not post it here.

**The Bill-To matches no connected entity** — *Mosofin-specific*. **Stop and ask.** Never route to the
nearest match.

**The bank-detail fraud check cannot run** — *Mosofin-specific, and it must be stated*. **Vendor bank details
are not on this surface.** Report NOT RUN; compare remit-to instead, and require out-of-band verification
for any change.

**A remit-to differs from the vendor master** — *Mosofin-specific*. Worth a question. **Not proof of
anything**, and not a substitute for the bank check.

**The extracted currency is one this vendor has never billed in** — *Mosofin-specific*. A cue worth
resolving before posting.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A duplicate check against fixture bills
proves nothing**, and reporting "not previously seen" on that basis is worse than not checking.

**A stored invoice or amount is reused** — *Mosofin-specific*. Invoice contents are sensitive and are never
persisted. **Persist the conventions; never the documents.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
validate against the wrong entity's Bill-To list.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the validation as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **All dates in ISO `YYYY-MM-DD`**
- **All amounts numeric** — no currency symbols or commas; minus sign for negatives
- **Currency identified as ISO-4217 code or explicitly flagged ambiguous**
- **Vendor names consistent across a batch**
- **Every invoice has a Confidence rating**
- **Math is verified; discrepancies flagged, not hidden**
- **Missing fields are `null`, never guessed**
- **File naming**: `Invoices_Extracted_[YYYY-MM-DD]_[count]invoices.xlsx`
- **Audit trail: original document reference preserved**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any validation was performed
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every invoice carries a Validation Status** — Clean, Review or Stop — **separate from extraction
  confidence**, so a legible document with a serious problem is not marked High
- **Every invoice was checked against posted bills for a duplicate**, and any match is reported with the
  matching bill named and status **Stop**
- **Every invoice was checked against the vendor master**, with new vendors and duplicate vendor records
  flagged
- **The Bill-To was validated against the entity's legal name**, and an invoice for another entity is routed
  rather than posted
- **The bank-detail fraud check is reported as NOT RUN**, with what it would have shown and how to perform
  it, and **out-of-band verification is stated as the control for bank-detail changes**
- **The remit-to comparison is reported as what it is** — a partial proxy, not the bank check
- **Whether the invoice is already paid in the books is checked**, and any disagreement with a "PAID" stamp
  reported
- **Vendor names are consolidated against the vendor master's spelling**, not to a new variant
- **Service periods are captured** where shown, for downstream prepaid and accrual treatment
- **Freight and shipping are captured separately**, so inventory and fixed-asset cost treatment remains
  possible
- In a multi-entity run, **each invoice is routed by Bill-To with the routing confirmed**, the duplicate
  check considers other group entities, and a Bill-To matching no connected entity **stops rather than
  routing to the nearest match**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no duplicate check is reported as clean against mock
  data**
- Every extracted figure traces to the source document by filename and page; every validation traces to a
  tool result; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No invoice contents, amounts, bank details, remit-to addresses or documents are persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no vendor created, no bill posted, no payment scheduled
