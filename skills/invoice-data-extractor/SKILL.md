---
name: invoice-data-extractor
description: "Extracts structured, accounting-ready data from vendor invoices — PDFs, scans, photos, single or batch — vendor, tax ID, invoice number, dates, terms, line items with service periods, totals and tax by rate, then validates each invoice against the books: duplicate invoice number for the vendor, already paid, known vendor, Bill-To entity, terms, PO and currency. Reads the vendor master and posted bills through a connected Mosofin workspace when the user agrees, or works from uploaded invoices plus a vendor list and bill listing. Use when the user says 'extract the data from this invoice', 'pull the fields from this bill', 'parse these invoices' or 'turn this PDF into a row I can post', or uploads a vendor invoice, bill, receipt or supplier statement to capture. Do not use for OCR alone (it extracts semantically) or to post the entry (use journal-entry-builder). Read-only: produces a structured row per invoice with line items, tax detail, validation results and a coverage sheet, and posts nothing."
---

# Invoice data extractor

Reads a **vendor invoice** — PDF, scan or photo, one or a batch — and turns every number and date
on it into **fields a system can use**: vendor, tax ID, invoice number, dates, terms, line items,
service periods, totals and tax by rate, payment instructions. It extracts **semantically**,
knowing which figure is the tax and which the total, and it never guesses a field it cannot see.

Then it checks each invoice against **your books** before anyone pays it. The mistake it exists
to catch is the **duplicate**: an invoice number already posted for that vendor is a double
payment about to happen. It also flags an invoice already paid, a Bill-To that is a different
company, a new vendor, terms that differ from the vendor record, and a remit-to that has changed.

**Works with or without Mosofin.** With Mosofin connected, it reads the vendor master — name, tax
ID, address, terms — posted bills and payments, how the vendor is usually coded, purchase orders
where they exist, and the company's legal name for the Bill-To check. **It can never read the
invoice itself or any vendor's bank details** — there is no document store and no vendor
verification service on this surface — so the documents always come from you, and the bank-detail
check is always reported as **not run**. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never guesses a field.** Anything not visible is `null`; it **never defaults a currency** — a
  "$" alone is never assumed to be USD — **a date interpretation or a vendor identity**, and never silently fixes
  an invoice whose figures do not add up.
- **Reports the bank-detail fraud check as NOT RUN** and never lets the remit-to comparison stand
  in for it; a bank-detail change needs **out-of-band verification**. It never enters, transmits
  or stores bank details, and masks them in output.
- **Stops on a duplicate, an already-paid invoice or a Bill-To for another entity**, and on a
  Bill-To matching no connected entity it asks — never routes to the nearest match. A new vendor
  is flagged for review, never accused.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–8" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *The invoice document(s) — PDF, PNG, JPG or a multi-page scan.* | Not in the workspace; the user always supplies them | **Required.** Note each filename and the count. |
| **C** | *Which entity is being invoiced?* In a batch across group companies, which entity each invoice belongs to | The Bill-To is validated against it, and in a group it decides whose books the invoice belongs in | On the Mosofin path the legal name comes from the profile. **Required if multi-entity:** routing is proposed from each Bill-To and confirmed with the user. |
| **D** | *Which output — xlsx, csv or JSON?* | Shapes the deliverable | Optional; default xlsx, created only on a yes, otherwise the same sheets as tables in the chat. |
| **E** | *Anything in the batch that is not an invoice — a receipt, statement, contract or quote?* | Statements and pro formas are usually not posted | Confirm with the user before extracting any non-invoice document. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- The **entity's legal name, base currency and country** come from the company profile; the
  **coding history replaces a vendor mapping file**. Don't ask for them.
- **Extraction may start before the gates** — the document is yours — but **nothing is validated,
  and no result reported as checked, until the workspace is confirmed.**

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Invoice document(s)** | **Required** | PDF, PNG, JPG or multi-page scan — a single file or a batch |
| Entity being invoiced: legal name and any trading names | Required — the Bill-To check needs it | Type it in the chat |
| **Posted bills and payments** for the vendors in the batch — an AP listing or aged payables | Recommended — without it **the duplicate and already-paid checks cannot run**, and the output says so prominently | CSV or XLSX |
| **Vendor list** — name, tax ID, address, terms | Recommended — enables the vendor, terms and remit-to checks | CSV or XLSX |
| Vendor mapping file; output format | Optional — default xlsx | CSV or XLSX; type the format in the chat |

**Read back before starting, then wait for a yes:**

> *Extracting **12 invoices** from **two PDFs you uploaded** for **Northbrook Trading**, and
> validating each against **the vendor master and posted bills read from your Mosofin
> connection**. Output as **xlsx**. One file looks like a supplier statement, which is usually not
> posted — shall I set it aside and go ahead with the rest?*

On the upload path, name each file you received and say what was read from it — page count, how
many invoices, and for any listing the period it covers and row count. Flag anything unreadable
straight away, and ask for a text-based copy rather than guessing.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files — in a group, the set the batch may be billed to — check which read tools are
enabled, and read the company profile — **legal name** for the Bill-To check, **base currency**
and **country** as cues for ambiguous symbols and dates. **If the posted-bill read is disabled,
the duplicate check cannot run: say so prominently.** On the upload path, go straight to Stage 3.

## Stage 3 — Read each document and extract the fields

Read each document, record its filename and page count, and split bundled invoices. Extract the
header fields with the vendor's labels as ground truth, dates in ISO `YYYY-MM-DD`, line items
exactly as shown — no merging, no splitting — with service periods, then totals and tax by rate
and jurisdiction, tax-inclusive or exclusive, and the **Subtotal + Tax + Shipping − Discount =
Total** cross-check, and the payment instructions: [`references/method.md`](references/method.md)
Steps 1–5. Check [`references/edge-cases.md`](references/edge-cases.md) for poor scans, statements,
credit memos, pro formas, foreign language, ambiguous dates and currency, and "PAID" stamps.

## Stage 4 — Validate against the books, and classify

Once the header fields are out, batch the reads — vendor master, posted bills for the duplicate
check, payments, coding history, POs, aged payables, company profile — and check the `mock` flag:
[`references/method.md`](references/method.md) Step 0. Report the vendor match as known, new or a
duplicate record; compare the remit-to; record the bank-detail check as **NOT RUN**. Then tag
document type, recurrence and confidence, and give each invoice a separate **Validation Status —
Clean, Review or Stop**: Step 6. In a group, route each invoice by Bill-To, confirm the routing,
and consider running the duplicate check across all entities (both entity scenarios, end of method.md).

## Stage 5 — Present the extraction

Single invoice inline plus a file; a batch as one workbook — Invoices with Entity, Validation
Status and Duplicate Match columns, Line Items, Tax Detail, Source Reference, Validation Results
and Coverage — or JSON: [`references/method.md`](references/method.md) Step 7. Every figure
traces to a file and page, every validation to a tool result, and any check that could not run is
named. Before presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist vendor naming conventions,
invoice-number formats, duplicate-match tolerances, Bill-To names per entity, the status rules,
known ambiguities by vendor and the escalation path — never invoice contents, amounts, bank
details, remit-to addresses or documents.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 3–4, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
