---
name: ap-accrual-cutoff
description: "Finds and drafts period-end accounts payable accruals: goods received not invoiced (GRNI) from open purchase orders and their receipts, recurring vendors whose bill has not arrived, and bills dated after period end for services delivered before it. Prices each one, applies materiality, and drafts the accrual entry with its reversing entry for the new period. Reads purchase orders, bills, vendor spend history and the chart of accounts through a connected Mosofin workspace when the user agrees, or works from uploaded exports, and asks where goods receipts are logged, since most books hold none. Use when the user asks to book the AP accrual at month-end, accrue for services received but not invoiced, book a GRNI accrual or AP cutoff entries, or asks what AP to accrue. Do not use for accruals beyond AP (use accruals-and-deferrals) or the full month-end close (use month-end-close-checklist). Read-only: produces an accrual schedule, proposed accrual and reversing entries and a coverage sheet, and posts nothing."
---

# AP accrual cutoff

Finds the costs that belong in the month being closed but have **no bill in the books yet** —
goods that arrived against a purchase order, a recurring vendor whose monthly bill has not
landed, a bill dated after period end for work done before it — estimates each one, and drafts
the accrual entry plus the **reversing entry** for the first day of the new period.

The mistake it catches is a month that looks cheaper than it was. It also catches the opposite
mistake: accruing an **open purchase order that was never received** (a commitment, not a
liability), or counting the same cost twice, once as GRNI and once as a late invoice.

**Works with or without Mosofin.** With Mosofin connected, it reads the books directly: open
purchase orders and their lines, bills in the period and after it, vendor spend history for the
recurring pattern, the chart of accounts, the accrued-liability balance and last period's
accruals. **It usually cannot read the goods receipts** — most accounting connectors carry
orders and bills but no receipt record — and **it can never see a bill still sitting in an
inbox or approval queue**, so it asks for both. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never treats an open purchase order as received without evidence**, and never substitutes
  a vendor spend report for the purchase orders — spend is what was already billed, the one
  population that needs no accrual.
- **Never defaults the period, the accounting method or the entity, and never assumes the tax
  rule.** With no materiality threshold it accrues everything identified and says so, rather
  than applying a figure of its own.
- **Never counts an item twice:** a cost is GRNI, a subsequent invoice or a recurring accrual —
  only one — and every PO-to-bill match says whether it was linked or inferred.

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
| **B** | *Which period is being closed — month or quarter, exact dates? And are the books kept on an accrual or a cash basis?* | Sets every read. A cash-basis ledger carries no accruals, so a zero opening accrued-liability balance may be legitimate | **Never default the period or the accounting method.** |
| **C** | *Where are goods receipts logged — a warehouse system, signed delivery notes, an inventory module? Any service confirmations or time sheets?* | GRNI is received quantity × PO unit price; most books hold no receipt record | **Required for GRNI accruals.** Never treat an open PO as received; mark the receipt quantity `[manual]` and list the GRNI lines left without evidence. |
| **D** | *How many days after period end should I look for late invoices?* | Sets the Step 3 search range for the subsequent-events review | **Required.** The common answer is "up to the date the books close" — propose it and get a yes. |
| **E** | *Which account holds accrued liabilities?* | Every proposed entry credits it; naming varies | **Required.** On the Mosofin path, find it in the chart of accounts and confirm it by name. |
| **F** | *Is input tax recoverable, and in which jurisdiction?* | Decides whether an input-tax line is booked without a tax invoice (Step 4) | **Required if tax is recoverable. Do not assume**, and do not carry a stored rule over without re-confirming it. |
| **G** | *Is there a materiality threshold for accruals? At year-end, is it tighter?* | Below it, accruals can be skipped with disclosure | Accrue everything identified, and **say that is what you did**. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). Name any connected-but-inactive
  company file **as excluded**, and say which costs are therefore unaccrued.
- At Gate 2, check that the **purchase-order tool** is enabled. If it is disabled, GRNI is
  `[manual]` — ask for an open-PO export rather than reading vendor spend instead.
- Derive the **recurring vendor list** from spend history and ask the user to confirm it and add
  anything the books do not show.
- Ask the user to **clear the bill approval queue** before finalising: an unposted bill dated on
  or before period end should simply be posted, not accrued. No tool can see the queue, so ask
  them to send any invoices received since period end that are not yet entered — Step 3
  reviews them like posted bills.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Open purchase orders** with line detail — quantity and unit price | **Required for GRNI accruals** | CSV or XLSX export, or PDF |
| **Goods receipts** — receiving log, signed delivery notes, service confirmations or time sheets | **Required for GRNI accruals** — an open PO without one is not accrued | CSV, XLSX, PDF, or a clear scan |
| **Chart of accounts**, with the accrued-liability account named | Required | CSV or XLSX |
| Period, entity name, functional currency, accounting basis, subsequent-event window | Required | Type it in the chat |
| **Bills** posted in the period and in the subsequent-event window, with service dates and any PO reference, plus invoices received since period end not yet entered | **Required** — without them GRNI cannot be netted and the late-invoice review is not performed; the output says so | CSV or XLSX export, or PDF |
| **Vendor bill history** for several prior periods, and any contracts for recurring vendors | Recommended — establishes the recurring vendors and their expected amounts | CSV or XLSX, or PDF |
| Trial balance and last period's accrual entries | Recommended — checks that last period's reversals posted | CSV or XLSX |
| Materiality threshold; tax jurisdiction if tax is recoverable | Recommended — required for tax if it is recoverable | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Building the **September** AP accrual schedule for **Northbrook Trading** (accrual basis),
> with purchase orders, bills and spend history from **your Mosofin connection** and goods
> receipts from **the warehouse log you uploaded**. Late invoices searched **1–10 October**,
> when the books close; accruals credited to **Accrued Expenses**; materiality **$500**;
> accrued net of recoverable tax, no input-tax line. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the totals. Flag anything unreadable, or covering the wrong period or
entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, build the capability map — purchase orders are usually `[auto]`, the goods-receipt
record often `[manual]` — and read the company profile for functional currency, fiscal calendar
and year-end, so Stage 1's answers do not need asking twice. On the upload path, go straight to
Stage 3.

## Stage 3 — Read the evidence

Pull the reads in one batch, per entity: open purchase orders and their lines, bills in the
period and in the subsequent window, vendor spend history, the chart of accounts, the
accrued-liability balance and last period's accrual entries:
[`references/method.md`](references/method.md) Step 0. Pass `data_source_id` on every call, and
flag at the top any figure that rests on `mock: true` data — it cannot support a posted entry.

## Stage 4 — Find the accrual candidates

Three populations: **GRNI** — received quantity × PO unit price, less invoices already matched
to that PO line; **recurring vendors** billed in prior periods but not this one, at the most
recent invoice, the contract amount or the recurring schedule, with any variance flagged; and
**post-period invoices**, where the service period, not the invoice date, decides —
straddles are accrued pro rata: [`references/method.md`](references/method.md) Steps 1–3.
Check [`references/edge-cases.md`](references/edge-cases.md) for partial receipts per line,
services with no receipt, bills with no PO link, prepaid contracts, multi-currency, and an
accrual reversed last period whose invoice never came.

## Stage 5 — Price, screen, propose the entries and present

Calculate each amount and apply the confirmed tax rule — the conservative default is the expense
net of recoverable tax, with no input-tax line; draft each accrual with its reversing entry in
the real account names, and check that last period's reversals posted; then the materiality
screen, including whether skipped items are material in aggregate; then the seven sheets:
[`references/method.md`](references/method.md) Steps 4–7. Before presenting, check it against
[`references/output.md`](references/output.md). Ask whether the user wants the workpaper as an
Excel file before creating one.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist the Gate 3 answers, the recurring
vendor list with expected amounts, bases and expense accounts, the account mapping, standing
exclusions and how receipts are evidenced — keyed by datasource and company name. Never persist
connections, company files, tool policies or `mock` status.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stage 4, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
