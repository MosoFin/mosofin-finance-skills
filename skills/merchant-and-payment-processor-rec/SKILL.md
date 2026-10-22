---
name: merchant-and-payment-processor-rec
description: "Reconciles a payment processor — Stripe, Square, PayPal, Braintree, Adyen, Shopify Payments — to the general ledger: gross sales, fees, refunds, chargebacks and payouts, with the clearing account rolled forward and aged. Tests the most common error, revenue recorded net of processor fees. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded exports — processor payout and transaction CSVs, GL detail or a trial balance. Use when the user asks to reconcile Stripe or Square to the books, process processor settlements, explain why payouts do not match revenue, check merchant fees, or uploads a processor export. Do not use for bank reconciliation alone (use bank-reconciliation) or for applying customer payments (use cash-application). Read-only: produces a reconciliation, proposed entries and a coverage sheet, and posts nothing."
---

# Payment processor ↔ books reconciliation

Checks that what **Stripe, Square or PayPal** says matches **your books** for a period: gross
sales, fees, refunds, chargebacks and payouts. It also catches the most common error in small
business books — **revenue recorded net of processor fees**. Profit still looks right, but sales
and every margin are understated by the full amount of the fees.

**Works with or without Mosofin.** With Mosofin connected, it reads your books directly, and the
processor too if that is linked. Without it, you upload the files and the accounting is exactly
the same. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never estimates a figure** that should come from your books or the processor. A gap is
  reported as a gap.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–10" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which processor? Stripe, Square, PayPal or another* | Each has its own clearing account and export | Ask again. Nothing can start without it. |
| **C** | *Which period? Start and end date.* | Sets every read and every cut-off | **Never default the period.** |
| **D** | *Are sales recorded one by one, or as one entry per payout?* | The reconciliation is built differently for each, and the workpaper must say which | **Required.** If the user is unsure, show them the clearing-account entries for the period — one per sale, or one per payout — and **let them confirm.** Don't decide for them. |
| **E** | *Does the processor hold a reserve or delay payouts?* | Held money is your asset and is shown separately | Assume none, and **say that you assumed it.** |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check whether the processor is connected too. If it is, both sides are read automatically.
- Find the clearing account in the chart of accounts, and **confirm it with the user**.
- Ask for the **bank statement** for the period. It is never available through Mosofin, on any
  path — without it, payouts are tied to recorded deposits only, and the output says so.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| Processor **payout / settlement** report for the period | Required | CSV export from the processor dashboard |
| Processor **transactions or balance** report — charges, fees, refunds, disputes | Required | CSV export |
| Your books: **GL detail** for the clearing, revenue and fee accounts, or a **trial balance** plus GL export | Required | CSV or XLSX |
| Clearing account name, base currency and country | Required | Type it in the chat |
| **Bank statement** for the period | **Required** — the only proof the payouts actually arrived. Without it the skill still runs, ties payouts to the deposits recorded in your books instead, and **says so in the output** | PDF or CSV |

**Read back before starting, then wait for a yes:**

> *Reconciling **Stripe** to **Northbrook Trading** for **1–30 September**. Sales are recorded **one
> entry per payout**, and the numbers come from **your Mosofin connection**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count and the totals. Flag anything unreadable, or covering the wrong period,
straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check which read tools are enabled, and read the company profile, so Step 1's
answers do not need asking twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read both sides, and test for net revenue

Pull the GL side and the processor side, then break each payout into gross, fees, refunds and
chargebacks: [`references/method.md`](references/method.md) Steps 0–3.

**Always run the net-revenue test.** It is the most valuable check in this skill, and it lives
in [`references/edge-cases.md`](references/edge-cases.md) under *Revenue recorded net of fees*.

## Stage 4 — Roll forward the clearing account and tie payouts

Clearing roll-forward and ageing, payouts against recorded deposits, then currency and tax:
[`references/method.md`](references/method.md) Steps 4–7. Check
[`references/edge-cases.md`](references/edge-cases.md) for reserves, chargebacks, payout freezes
and multi-entity accounts.

## Stage 5 — Propose entries and present the result

Construct the correcting entries as **proposals**, then build the output and coverage sheet:
[`references/method.md`](references/method.md) Steps 8–9. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 10.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stage 3, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
