<!-- invoice-data-extractor · method.md · read for: Stages 3–6 — Steps 1–5 extract, Step 0 and Step 6 validate and classify, Step 7 presents, Step 8 saves; plus both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the validation evidence (grounding) — Mosofin addition
- Step 1 — Read the document(s)
- Step 2 — Identify header fields
- Step 3 — Extract line items
- Step 4 — Totals and tax breakdown
- Step 5 — Payment instructions
- Step 6 — Classify and tag
- Step 7 — Output
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


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

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that validation to **[manual]** and record the gap. **Name the duplicate
  check specifically if it is the one lost.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate check against fixture bills proves
nothing**, and reporting an invoice as "not previously seen" on that basis is worse than not checking.

## Step 1 — Read the document(s)

**Read uploaded PDFs with whatever PDF-reading ability the host provides.** If text cannot be extracted, say so and ask for a text-based copy rather than guessing.

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
  fictitious-vendor scheme**. Flag for setup and review, do not
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
part of the asset's cost** — see
`fixed-asset-register-and-depreciation`, which flags freight expensed rather than capitalised, as an inventory costing review does.
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

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

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
  to any single entity's review.** See `duplicate-invoice-detection`, and treat it as an intercompany reconciliation item.
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
