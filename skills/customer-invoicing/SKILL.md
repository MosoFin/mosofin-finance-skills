---
name: customer-invoicing
description: "Prepares customer invoices with the content the jurisdiction requires (seller and customer details, sequential number, tax point, lines, tax by rate, totals, statutory wording) and the matching AR / revenue / tax entry, or validates invoices already issued against the same rules: mandatory fields, line checks, arithmetic, duplicate numbers and gaps in the sequence. Reads customers, items, prices, tax codes, terms and the existing invoice sequence through a connected Mosofin workspace when the user agrees, or works from uploaded lists and invoices. Use when the user asks to create an invoice, a batch or an invoice template, or to check issued invoices, including multi-currency, progress billing and reverse charge. Do not use for parsing vendor invoices (use invoice-data-extractor), subscription scheduling (use recurring-transaction-builder) or credits and refunds (use credit-memo-and-refund-handler). Read-only: produces draft invoices, a proposed entry and a coverage sheet, and posts, numbers or sends nothing."
---

# Customer invoicing: prepare and validate

Builds customer invoices that carry everything a valid tax invoice needs: the seller's and the
customer's legal details, a unique sequential number, the invoice date and the tax point, every line
with its tax, the totals by rate, the terms and any wording the jurisdiction requires. It also runs
the same rules over **invoices already issued**, adding the **duplicate-number and sequence-gap
check**, and proposes the matching **AR / Revenue / Tax** entry.

The mistake it catches: an invoice is a legal document, not just a request for money. A missing field
or legend lets the customer's tax authority disallow their claim, and they come back asking for a
reissue; a gap in the number sequence usually means a deleted invoice, and in many jurisdictions is
itself a compliance problem.

**Works with or without Mosofin.** With Mosofin connected, it pre-fills from the books: the seller's
legal name and address from the company profile, the customer's record and terms, items and standard
prices, the tax codes in use, the account map, prior invoices to the customer, and the **next invoice
number in the live sequence**. **It can never create, number or send an invoice**, and some inputs no
connection holds: what to bill and for how much, the jurisdiction's mandatory-field list, exemption
certificates, progress-billing milestones, e-invoicing submission, and whether a tax ID on file is
still valid. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never implies an invoice has been raised.** Every document is a draft for review, and the number
  on it is proposed, not reserved, until a person enters the invoice.
- **Never defaults the jurisdiction, a tax rate, the invoice date or the numbering scheme**, and
  never infers the jurisdiction from the profile's country. It drafts from the **selling entity's own
  file only**, and never to a real customer on `mock` data.
- **Never reproduces payment instructions from memory or an old document**: they are confirmed with
  you from a trusted source. Customer tax IDs, bank details and invoice contents are never persisted.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–7" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Prepare new invoices, or validate ones already issued?* | They are different jobs: validate mode runs Steps 1–3 over existing invoices, plus the duplicate and gap check | **Required.** |
| **C** | *Which entity is selling?* | Its legal name, tax registration and number sequence go on the invoice; drafting from the wrong file is legally wrong on its face | **Required.** On the Mosofin path, ask by `display_name`; name and address come from its profile, the registration number is asked if the profile lacks it. |
| **D** | *Which customer, and what to bill: description, quantity, unit price, tax code per line?* | What to bill is never in the books | **Required.** Customer details pull from the record on the Mosofin path; **confirm the tax ID is current**. |
| **E** | *The invoice date, and the tax point if it differs — and the delivery date or service period for each line.* | The tax point, not the invoice date, decides which period the tax falls in; delivery decides whether revenue or deferred revenue is credited | **Never default the invoice date.** |
| **F** | *Which jurisdiction, and its mandatory fields and required phrases? Any e-invoicing mandate?* | Drives the mandatory fields and the tax | **Never infer from the profile's country.** Without a field list, include the common set and ask the user to validate it. |
| **G** | *Tax rate per line, and any exemption certificates or reverse-charge customers. Are your prices tax-inclusive, and is tax rounded per line or per rate total?* | Whether a rate is correct for this supply cannot be read | **Required if tax applies. Never default a rate.** The certificate is always `[manual]`. |
| **H** | *The numbering scheme: prefixes, resets, per-entity sequences.* | Duplicates and gaps are measured against it | **Never default it.** On the Mosofin path the next number is read from the live sequence. |
| **I** | *Payment terms, currency, customer PO, and the payment instructions.* | Terms and currency are Required; some customers will not pay without their PO number | Terms and currency usually pull on the Mosofin path; confirm. **Payment instructions are confirmed from a trusted source**, never reproduced. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). In a multi-entity workspace, ask
  **which entity is actually selling**.
- Say plainly that Mosofin **cannot create the invoice in the accounting system**; if the user
  expects it to appear there, it will not.
- Read the next invoice number from the live sequence every run; the invoice search usually needs a
  date range, so search recent periods deliberately.
- Still ask for what to bill, the jurisdiction's field list, the invoice date, exemption
  certificates and the payment instructions. None of them is in the books.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Customer** name, address and tax ID | Required | CSV, XLSX, or type it in the chat |
| **Selling entity**: legal name, address, tax registration | Required | Type it in the chat |
| **Line items**: description, quantity, unit price, tax code | Required | CSV, XLSX, or a pasted table |
| Invoice date, payment terms, currency, jurisdiction, tax rate per line | Required (tax rates if tax applies) | Type it in the chat |
| **Numbering scheme** and the recent invoice listing, for the next number | Required | CSV or XLSX export |
| **Chart of accounts**: revenue, output tax and deferred revenue accounts | Required | CSV or XLSX |
| **Issued invoices to check**, plus an invoice list for the range under test, voids included | **Required in validate mode** — gaps and duplicates cannot be tested from a sample | PDF or image, or a CSV/XLSX export |
| Customer PO or reference | Recommended | Type it in the chat |
| Exemption certificate reference, if a customer is tax-exempt | When it applies | PDF or image |

**Read back before starting, then wait for a yes:**

> *Preparing **one invoice** from **Northbrook Trading Ltd** to **the customer you named**, dated
> **30 September**, tax point the same, under **UK VAT** with the field list you gave, books read
> from **your Mosofin connection**. Next number in the **NT-** sequence: **NT-1043**, proposed, not
> reserved. Payment instructions as you confirmed them. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — row count, the
invoices or customers it covers, the period. Flag anything unreadable, or any invoice from a
different entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
selling entity, check which read tools are enabled (no write tool exists on this surface), read the
company profile for the seller's legal name, address and base currency, and interview only for what
Stage 1 did not cover. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books

Pull the opening batch in one message — company profile, customer record, items, tax codes, terms,
the recent invoice sequence, recent invoices to this customer, the accounts, what the customer
already owes, any quote being billed — and check every result for `mock: true`:
[`references/method.md`](references/method.md) Step 0.

## Stage 4 — Apply the mandatory fields, validate the lines, compute the totals

Apply the jurisdiction's mandatory fields, including the tax point and any required phrases; check
every line, comparing the price against the item's standard price and the customer's last charge;
compute totals by rate. **In validate mode**, run all three over the issued invoices and report every
missing field, line failure and arithmetic difference, plus duplicate numbers and gaps listed by
number: [`references/method.md`](references/method.md) Steps 1–3. Check
[`references/edge-cases.md`](references/edge-cases.md) for multi-currency, progress billing,
retainage, early-pay discounts, tax-exempt and reverse-charge customers, withholding, re-issued
invoices and e-invoicing.

## Stage 5 — Propose the entry, draft the document, present the result

Construct the AR / Revenue / Tax entry as a **proposal** in the real account names, with the deferred
revenue form where recognition is deferred; generate the invoice document marked as a draft; then the
register, line detail, GL posting, validation results and coverage sheet:
[`references/method.md`](references/method.md) Steps 4–6. Confirm the file name before making a
PDF, and ask whether the user wants the workbook as an Excel file before creating one. Before
presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist the jurisdiction's field list and
phrases, the numbering scheme, the template as structured description, the account map, customer
requirements and tax treatments, keyed by datasource and entity — never customer tax IDs, bank
details, invoice contents, or the next invoice number, which is re-read every run.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 4–5, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
