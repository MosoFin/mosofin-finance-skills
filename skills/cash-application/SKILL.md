---
name: cash-application
description: "Applies customer payments to open invoices: matches each receipt through a six-level hierarchy with fuzzy payer-name matching; works out why a short pay is short (discount, bank fee, withholding tax, FX, dispute or unknown); parks overpayments as customer credit; and drafts the entry with every component on its own line. Reads open invoices, the customer master, recorded payments, credit memos and deposits through a connected Mosofin workspace when the user agrees, or works from uploaded files; always asks for lockbox files, remittance advices and FX rates, which no accounting connection holds. Use when the user asks to apply customer payments, cash app a remittance, match payments to invoices, allocate a wire, process a lockbox file, or handle a short pay. Do not use for refunds (use credit-memo-and-refund-handler) or the bank reconciliation itself (use bank-reconciliation). Read-only: produces an application schedule, exceptions, a proposed entry and a coverage sheet, and posts nothing."
---

# Cash application

Decides which open invoices each incoming customer payment was meant to settle, and drafts the
entry. That sounds trivial and is not: the name on the bank line is often a truncated bank string,
not the customer's name; the amount often matches no single invoice; and when it is short, the
reason — an early-pay discount, a bank fee, tax withheld at source, an FX difference, or a
complaint nobody mentioned — decides the accounting.

The mistakes it catches are the quiet ones: a payment forced onto the wrong invoice or the wrong
customer, a short pay written off that was really a dispute, an overpayment booked as revenue or a
duplicate payment treated as one, and a bank fee netted into the cash line where nobody sees it.

**Works with or without Mosofin.** With Mosofin connected, it reads the books directly: the full
open invoice population with balances and dates, the customer master for payer matching, payments
already recorded and how they were applied, credit memos that may explain a short pay, and
deposits — which reveal a netted fee. **It can never read a lockbox file, a bank statement, a
remittance advice, or a payment processor's settlement report** unless that processor is itself
connected, **nor supply an FX rate or a withholding-tax certificate**, so it asks for them.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every application, credit and
  write-off it produces is a proposal for a person to post.
- **Never picks silently.** No fuzzy name match below the threshold is auto-accepted; an amount
  that fits several customers or two same-amount invoices is reported, not chosen; where several
  invoice combinations fit, the one selected is named along with the alternative.
- **Never absorbs a short or over pay.** A residual with no explanation stays open for
  collections, never written off; an excess is customer credit, never revenue, and is checked
  for a duplicate payment first.
- **Never defaults the FX rate, the tolerance or the entity**, and never applies one entity's
  receipt to another entity's invoice.

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
| **B** | *Which payments — ones already recorded in the books, or a file not yet entered (deposit listing, lockbox file, processor export)? As of what date for the open invoices?* | They are different jobs: payments already applied make this a **review** of how they were applied, not a proposal | **Required.** Ask which population; the output states which one was processed. |
| **C** | *Any remittance advices, and where are they?* | The single biggest driver of match quality | Recommended. Without them, matching rests on references and payer names, and an amount that fits several customers stays unresolved. |
| **D** | *What tolerance for short and over pays — an amount or a %?* | Decides what counts as a short or over pay at all | **Never invent one.** Match exact and say that is what you did. |
| **E** | *Apply oldest invoice first (FIFO), or another order?* | Lump payments and partial payments both depend on it | Recommended. **Confirm rather than assume.** |
| **F** | *Any payments in a different currency from the invoice — what rate, from what source?* | Converts at the receipt date and drives the FX gain or loss | **Required if currencies differ. Never default the rate** — no accounting connector supplies one. |
| **G** | *Does any customer withhold tax at source, and in which jurisdiction?* | A withheld amount is a receivable pending a tax certificate, not a short pay | Optional — needed only where withholding applies. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). Check whether a **payment
  processor** is connected: it turns batch settlements into readable sales, fees, refunds and
  chargebacks.
- At Gate 2, confirm the **invoice-level** open population is readable. A customer balance report
  is not a substitute; if the invoice search is disabled, ask for an open-invoice export.
- Use the A/R aging as the population where available, and **state the invoice search window** —
  a recent-only window misses the old invoices a payment may be settling.
- Ask only for **payer aliases** the customer master does not hold, and still ask for the
  remittances (C) and any FX rates (F).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Customer payments** — deposit listing, lockbox file or processor export: date, amount, currency, payer name, method, reference | Required | CSV or XLSX, or the bank's file |
| **Open A/R invoices** — customer, number, dates, original amount, paid-to-date, open balance, currency | Required | CSV or XLSX export |
| Entity name and base currency | Required | Type it in the chat |
| FX rate and its source, per currency | **Required if currencies differ** | Type it in the chat |
| **Remittance advices** | Recommended — the biggest driver of match quality | PDF, email or CSV |
| **Customer master**, with any known payer aliases | Recommended — for fuzzy payer matching | CSV or XLSX |
| Application order; tolerance; withholding jurisdiction and certificates | Recommended / optional | Type it in the chat; certificates as PDF |

**Read back before starting, then wait for a yes:**

> *Applying the **14 October lockbox file you uploaded** — 38 payments — to **Northbrook
> Trading**'s open invoices **as of 14 October**, read from **your Mosofin connection**. Exact
> match, no tolerance; oldest invoice first; remittances for **11** of the payments. Shall I go
> ahead?*

On the upload path, name each file you received and say what was read from it — the dates it
covers, the payment count, the total. Flag anything unreadable, or covering the wrong date or
entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, build the capability map, and read the company profile for base currency — which
decides whether the multi-currency step applies — and time zone, which decides which day a
receipt near midnight falls on. On the upload path, go straight to Stage 3.

## Stage 3 — Read and parse both sides

Pull the open invoices, customer master, recorded payments, deposits, credit memos, terms and
accounts in one batch, per entity; then parse each payment — date, amount, currency, payer name,
method, reference — and each invoice, matching on the **open balance**, never the original
amount: [`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Match, then explain every difference

Work down the match hierarchy, recording the level of every match and the similarity score and
alternatives of every fuzzy one; then the short-pay reason, checked first against credit memos,
the invoice's terms and the deposit; then overpayments, checked for a duplicate; then currency
differences: [`references/method.md`](references/method.md) Steps 2–5. Check
[`references/edge-cases.md`](references/edge-cases.md) for lockbox files, processor batch
settlements, payments before the invoice exists, NSF reversals, intermediary bank fees, trade
versus early-pay discounts, withholding tax, and a stale payer alias.

## Stage 5 — Propose the entry and present

Draft the cash application entry with cash, receivables, customer credit, sales discount, bank
fee, withholding tax receivable and FX each on its own line, in the real account names; then the
five sheets — summary, payment-to-invoice mapping, exceptions, GL posting and coverage:
[`references/method.md`](references/method.md) Steps 6–7. Before presenting, check it against
[`references/output.md`](references/output.md). Ask whether the user wants the workpaper as an
Excel file before creating one.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist the payer-alias map, tolerances and
application order, the account mapping, customers who withhold tax or pay by statement or PO, and
standing disputes — keyed by datasource and company name. Never persist bank account numbers,
payment-level data, customer balances or remittance contents.

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
