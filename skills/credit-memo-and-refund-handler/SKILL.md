---
name: credit-memo-and-refund-handler
description: "Processes customer credit memos and refunds, vendor credit notes and refunds, sales returns, chargebacks and goodwill credits: identifies the type, validates the credit against the original invoice or bill (existence, balance, period, currency), checks that the tax reversal mirrors the original, proposes the journal entry for each type, tracks application, and surfaces unapplied credits in both directions, vendor credits first. Reads credits, refunds and the originals through a connected Mosofin workspace when the user agrees, or works from uploaded documents and exports. Use when the user asks to issue a credit memo, process a refund, record a vendor credit note or sales return, apply a credit against an invoice, or handle a chargeback, or uploads a credit memo. Do not use for extracting data from invoices (use invoice-data-extractor) or for preparing new invoices (use customer-invoicing). Read-only: produces a credit register, proposed entries and a coverage sheet, and issues, applies or posts nothing."
---

# Credit memos and refunds

Handles money going back the other way: a customer returns goods, a price was wrong, a supplier
over-billed you, or a card payment is reversed. These look alike on the surface and are accounted for
quite differently underneath. It works out **which type** each credit is, **validates it against the
original** invoice or bill, checks that **the tax reversal mirrors the original tax**, proposes the
entry, and tracks how the credit is used up.

The mistakes it catches: a credit larger than the invoice balance that nobody approved, tax on a
credit that does not mirror the original, a vendor credit posted to income instead of back to the
original expense, a second journal proposed when a credit is merely applied, and **vendor credits
sitting unused on account**, a discount already negotiated and not being taken.

**Works with or without Mosofin.** With Mosofin connected, it reads the credit memos, refund receipts
and vendor credits already recorded, the original invoices and bills with their balances, dates,
currencies and tax codes, the open customer and vendor positions, item costs and the chart of
accounts. **It can never read the reason for a credit**, which drives the accounting, nor whether
returned goods came back saleable, the jurisdiction's write-off rules, the FX rate, or a chargeback's
processor fee and reference unless a payment processor is connected. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never infers the reason from the document type**, and **never defaults the reason, the credit
  type or the tax treatment.** Three types can share an identical document and need three entries.
- **Tax on a credit mirrors tax on the original**, as a separate line, and output tax is **never
  claimed back automatically** on a write-off.
- **Never proposes a second journal when a credit is applied**, never applies one entity's credit
  against another's invoice, and never proposes a refund on `mock` data.

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
| **B** | *What type is it: customer credit, customer refund, vendor credit, or chargeback?* | The accounting differs materially by type | **Never default it.** On the Mosofin path the recorded document type narrows it; **confirm it**. |
| **C** | *The original invoice or bill: number, date, amount.* | Existence, balance, period and currency are then all checkable | **Required if applicable.** With no original, flag it and ask for the business reason. |
| **D** | *The credit amount.* | Compared against the invoice balance | **Required.** |
| **E** | *The reason: return, pricing dispute, goodwill, damage, error.* | A return hits inventory, a goodwill credit hits expense, a pricing error hits revenue | **Required. Never infer it.** |
| **F** | *The tax jurisdiction, if the original carried tax.* | Drives the write-off recoverability question | **Required if tax was on the original.** The original's tax codes are read on the Mosofin path; confirm rather than ask. |
| **G** | *Which period's credits to review?* | The Step 2 checks run on every credit in the period, not only the one being processed; the file is named for the month | Ask. |
| **H** | *Who approves a credit that exceeds the invoice balance?* | Such a credit needs management approval | **Required if that check fails.** The check is `[auto]`; the approval is `[manual]`. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- At Gate 1, **check for a connected payment processor**: chargebacks originate there, and it supplies
  the processor fee and reference the books usually lack.
- Use the right search for each document: credit memos, refund receipts, vendor credits, invoices and
  bills each have their own, and the wrong one silently returns nothing.
- Confirm the sales returns, chargeback fee and write-off accounts by their real names. Still ask for
  the **reason** (E): no system holds it.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **The credit memo, refund, vendor credit or chargeback** document(s) | Required | PDF or image, or a CSV/XLSX export |
| **The original invoice or bill**: number, date, amount, balance, currency, tax codes | Required if applicable | PDF or image, or a CSV/XLSX export |
| Credit type (B), reason (E), credit amount (D) | Required | Type it in the chat |
| **Chart of accounts** | Required for GL posting | CSV or XLSX |
| Tax jurisdiction | Required if the original carried tax | Type it in the chat |
| Open credits, and AR and AP aging with credit balances | Recommended — enables the unapplied-credit register | CSV or XLSX export |
| Processor statement with the chargeback fee and reference; item cost and condition for a return | When it applies | PDF, CSV or XLSX |

**Read back before starting, then wait for a yes:**

> *Processing **credit memo CM-0418** for **Northbrook Trading**: a **customer credit** of **$1,200**
> against **invoice 1042**, reason **pricing error**, tax under **the jurisdiction you named**, with
> the books read from **your Mosofin connection**. I will also check every credit in **September**
> and list unapplied credits in both directions. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — document count,
amounts, dates, the period. Flag anything unreadable, or a credit and original that disagree on
counterparty or currency, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check which read tools are enabled, read the company profile — base currency and
**fiscal year end**, which the period check needs — and interview only for what Stage 1 did not
cover. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books

Pull the opening batch in one message, per entity — credits, refunds, vendor credits, the original
invoices and bills, customer and vendor balances, the accounts, tax codes, item costs, the company
profile — and check every result for `mock: true`:
[`references/method.md`](references/method.md) Step 0.

## Stage 4 — Identify the type, validate against the original, check the tax

Identify the type, separating the document from the reason; run the four checks against the original
on **every** credit in the period — existence, credit ≤ invoice balance, period, currency — and flag
any credit with no original; compute the expected tax reversal from the original's tax codes and
compare it with the tax on the credit: [`references/method.md`](references/method.md) Steps 1–3.
Check [`references/edge-cases.md`](references/edge-cases.md) for cross-period and cross-currency
credits, restocking fees, overpayments, rebates, damaged returns and remitted tax on chargebacks.

## Stage 5 — Propose the entry, track application, present the result

Construct the entry for the type as a **proposal**, in the real account names, with vendor credits
posted back to the account the original cost was booked to; track application with no new journal;
build the unapplied-credit register in both directions, vendor credits first by value; then the
register, posting inputs, application tracking, validation exceptions and coverage sheet:
[`references/method.md`](references/method.md) Steps 4–6. Ask whether the user wants the workpaper as
an Excel file before creating one. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist the account map, the reason-code set
and its treatments, the approval threshold, the write-off tax position, restocking and chargeback
handling and the review cadence, keyed by datasource and entity — never counterparty names with
credit amounts, reasons or dispute detail, and never the open credit balance.

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
