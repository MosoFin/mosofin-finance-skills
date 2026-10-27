---
name: ap-aging-and-payment-runs
description: "Builds an accounts payable aging by vendor and due-date bucket and proposes a prioritised payment run within the cash the user confirms: early-pay discounts with their deadline and annualised return, late-pay penalties, critical vendors first, held and disputed bills kept out, and the unpaid remainder shown. Reads the A/P aging report, or rebuilds it from open bills, payments and credits and ties it to the A/P control balance, through a connected Mosofin workspace when the user agrees, or works from an uploaded open-bill list. Always asks for the cash available and never reads it off a bank balance. Use when the user asks for an AP aging, who they owe and when it is due, a payment run for this week, which bills to pay first, early-pay discounts or who is overdue, or uploads an AP balance or open bill list. Do not use for extracting individual vendor invoices (use invoice-data-extractor). Read-only: produces an aging, a proposed payment run, a discount analysis and a coverage sheet, and posts and pays nothing."
---

# AP aging and payment runs

Answers two questions: **who do we owe, and how late are we?** — an aging that sorts every
unpaid bill by vendor and by how overdue it is, tied to the A/P control balance — and **given
the cash we actually have this week, who should we pay first?** — a proposed payment run that
puts critical vendors, accruing penalties and expiring early-pay discounts ahead of the rest,
stops when the cash runs out, and shows what is left unpaid.

The mistakes it catches are the expensive ones: a 2/10 Net 30 discount (about 36% a year)
missed, a held or disputed bill paid by accident, a duplicate bill paid twice, and a payment
sent to bank details a fraudster just "updated".

**Works with or without Mosofin.** With Mosofin connected, it reads the books directly: the
A/P aging report where the workspace allows it, open bills, payments and credits, vendor terms
and payment methods, and the A/P control and bank balances. **It can never read how much cash
is actually available** — a bank balance has not netted off payments in flight or the minimum
the business keeps back — **nor which vendors are critical, which are on hold, or which lines
are disputed**: those are decisions, not ledger fields, so it asks. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every payment run it produces
  is a proposal for a person to approve and execute; no line implies a payment was made or
  scheduled.
- **Never defaults the as-of date, the cash available or the entity**, and never reads a bank
  balance and calls it available cash.
- **Never presents a vendor balance report as an aging.** An aging rebuilt from bills, payments
  and credits is labelled reconstructed and tied to the A/P control balance, gap shown.
- **Never puts vendor bank details in any output or stored preference**, and never lets
  `mock` data drive a payment run.

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
| **B** | *What as-of date for the aging? Do you use aging buckets other than the standard ones?* | The aging changes materially day to day; days past due are counted from it | **Never default the as-of date.** Buckets default to not yet due, 1–30, 31–60, 61–90, 91–120 and over 120 days overdue. |
| **C** | *Aging only, or a payment run too — and if a run, how much cash is available for it?* | Every proposed payment must fit inside it | **Required for a payment run. Never default or infer it** from a bank balance. Without it, say that no payment run can be proposed. |
| **D** | *Which vendors are critical, standard or discretionary?* | Critical vendors — services that stop without payment — rank first in the run | Optional, but the books cannot supply it. Ask; once given, it need not be re-asked every week. |
| **E** | *Any vendors on hold, or bills with disputed lines? Any payments already scheduled or sent that are not yet in the books? Has any vendor in this run asked to change bank details since their last payment?* | Held vendors are excluded; only the undisputed portion is paid; payments in flight are deducted; a bank-detail change is held until confirmed | Hold and dispute status come only from you or a stored preference — **never inferred from the books**. Unanswered bank-detail question: Sheet 3 states "bank-detail changes not screened". |
| **F** | *How is each vendor paid — ACH, wire, cheque or card?* | Fills the payment method on every proposed line | Recommended. Method names are usually readable; the per-vendor mapping usually is not. |
| **G** | *Any bills in another currency — what FX rate, from what source?* | Converting to the functional currency for the run | Ask only if bills show more than one currency. **No connector supplies a live wire rate**; the rate source and date are flagged on the output. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)) — a run proposed from the wrong
  entity's books is a list of payments that entity does not owe. In a multi-entity run, each
  entity's run is limited to **its own cash**, never a pooled figure, unless the user confirms
  a shared treasury.
- At Gate 2, check the **A/P aging report's own policy** — never assume it from the receivables
  one. If it is unavailable, rebuild the aging from bills, payments and credits; if bill-level
  data is unavailable too, ask for an open-bill export.
- Still ask for the cash available (C), the vendor tiers (D) and any holds or disputes (E).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Open bill list or A/P aging** — vendor, bill number, bill date, due date or terms, open amount, currency | Required | CSV or XLSX export |
| As-of date, entity name, functional currency | Required | Type it in the chat |
| **Cash available** for the run | **Required for a payment run** | Type it in the chat |
| **A/P control balance** — a trial balance or balance sheet | **Required for the tie-out** — without it, Sheet 1 is headed "not agreed to the A/P control balance", and the read-back says so | CSV, XLSX or PDF |
| Payments made and vendor credits open against those bills | Recommended — open amount is original less payments less credits | CSV or XLSX |
| **Vendor master** with payment terms, including early-pay discount terms | Recommended — drives due dates and the discount analysis | CSV or XLSX |
| Vendor tiers, payment method per vendor, holds and disputes | Recommended — tiers optional | Type it in the chat, or CSV |

**Read back before starting, then wait for a yes:**

> *Aging **Northbrook Trading**'s payables **as of 14 October**, with bills, payments and credits
> from **your Mosofin connection**, standard buckets. Then a payment run within the **$85,000**
> you confirmed as available, critical vendors as you listed them, **Harbor Supply on hold**.
> Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the as-of date
it covers, the bill count, the total open amount. Flag anything unreadable, or any bill missing a
minimum field, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, build the capability map — including whether the aging is report-native or must be
reconstructed — and read the company profile for functional currency and time zone (a discount
deadline is a date in someone's local time), so Stage 1's answers do not need asking twice. On
the upload path, go straight to Stage 3.

## Stage 3 — Read the bills and normalise them

Pull the aging report, open bills, payments, credits, vendor terms and balances in one batch, per
entity; then put every open item in one shape — non-zero open amount, with open credits and
unapplied payments kept as negatives, days past due from the as-of date, a due date derived from terms (and labelled derived) where none is held — and flag
open-above-original, bill-after-due, future-dated and possible duplicate bills:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Age the bills, find discounts and penalties

Bucket by vendor with totals per vendor and per bucket, saying whether the buckets came from the
report or were computed; then each early-pay discount with its last day, amount and implied
annualised return, flagged where the deadline falls inside the run horizon; then late fees or
interest accruing: [`references/method.md`](references/method.md) Steps 2–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for credit memos, payments in flight,
remit-to entities, a reconstructed aging that does not tie, and a bill with no due date.

## Stage 5 — Propose the payment run and present

Rank by critical vendor, then past-due with penalties or collection threats, then expiring
discounts, then due this week, then next week — or the user's own order; stop when the
confirmed cash runs out and show what is left unpaid; then convert other currencies at the
user's rate, and build the six sheets: [`references/method.md`](references/method.md)
Steps 5–7. Keep held vendors and disputed amounts out of the run, and flag any change of bank
details for confirmation through a channel the vendor did not supply. Before presenting, check
it against [`references/output.md`](references/output.md). Ask whether the user wants the
workpaper as an Excel file before creating one.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist the vendor priority tiers,
payment method per vendor, standing holds and disputes, non-default buckets and any override of
the ranking order — keyed by datasource and company name. Never persist vendor bank details,
cash available, connections, tool policies or `mock` status.

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
