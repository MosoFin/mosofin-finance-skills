---
name: merchant-and-payment-processor-rec
description: "Use this skill whenever the user wants to reconcile a payment processor (Stripe, Square, PayPal, Braintree, Adyen, Shopify Payments, etc.) to the GL using their Mosofin workspace. Triggers include: 'reconcile Stripe to GL', 'process Square settlements', 'PayPal monthly rec', 'merchant processor reconciliation', 'why doesn't Stripe match revenue', 'reconcile online payments', or uploading a processor export. Workspace-scoped: it confirms the workspace, discovers which company files and processors are connected and which read-only tools are enabled, then rolls forward the clearing account, ages unsettled balances, and tests the classic error — revenue recorded net of processor fees. Do NOT use for bank reconciliation alone — use bank-reconciliation. Do NOT use for cash application — use cash-application. Outputs a processor-to-GL reconciliation with gross sales, fees, refunds, chargebacks, the posting JEs, and a coverage sheet."
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
- **Reads nothing until Step 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never estimates a figure** that should come from your books or the processor. A gap is
  reported as a gap.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Step 1 — Intake: ask these first, in one message

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use your Mosofin connection for this, or upload the data yourself?* | Decides the path | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
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

## Step 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check which read tools are enabled, and read the company profile, so Step 1's
answers do not need asking twice. On the upload path, go straight to Step 3.

## Step 3 — Read both sides, and test for net revenue

Pull the GL side and the processor side, then break each payout into gross, fees, refunds and
chargebacks: [`references/method.md`](references/method.md) Steps 0–3.

**Always run the net-revenue test.** It is the most valuable check in this skill, and it lives
in [`references/edge-cases.md`](references/edge-cases.md) under *Revenue recorded net of fees*.

## Step 4 — Roll forward the clearing account and tie payouts

Clearing roll-forward and ageing, payouts against recorded deposits, then currency and tax:
[`references/method.md`](references/method.md) Steps 4–7. Check
[`references/edge-cases.md`](references/edge-cases.md) for reserves, chargebacks, payout freezes
and multi-entity accounts.

## Step 5 — Propose entries and present the result

Construct the correcting entries as **proposals**, then build the output and coverage sheet:
[`references/method.md`](references/method.md) Steps 8–9. Before presenting, check it against
[`references/output.md`](references/output.md).

## Step 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 10.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Step 2, Mosofin path |
| [`references/method.md`](references/method.md) | Steps 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Step 3, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
