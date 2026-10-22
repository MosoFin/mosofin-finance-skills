---
name: bank-reconciliation
description: "Reconciles a bank account to the books for a period: builds the two-ladder bridge from the statement ending balance and the GL cash balance, matches transactions four ways, classifies what is unmatched — deposits in transit, outstanding cheques, fees, interest, bounced items — and proposes the correcting entries, each tied to a statement line. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded exports — the bank statement, the GL cash activity and a trial balance. Always asks for the bank statement, which no accounting connection can supply, and labels a run without one as a book-side preparation, never a reconciliation. Use when the user asks to reconcile a bank account, tie out cash, explain outstanding cheques or deposits in transit, investigate a reconciliation difference, or uploads a bank statement. Do not use for a card processor's payouts (use merchant-and-payment-processor-rec) or a credit-card statement (use credit-card-reconciliation). Read-only: produces the bridge, matched and unmatched lists, proposed entries and a coverage sheet, and posts nothing."
---

# Bank ↔ books reconciliation

Proves that the cash balance in **your books** and the balance on **the bank statement** differ
only for reasons you can name — a cheque not yet cashed, a deposit not yet credited, a fee the
books never saw — and that the two meet **to the cent** once those reasons are applied. Anything
left over is an unidentified item, and finding it is the point.

**Works with or without Mosofin.** With Mosofin connected, it reads the book side directly: the
cash balance, every payment, deposit, transfer and manual entry. **It can never read the bank
statement** — no accounting connection exposes one — so it always asks you for it. Without the
statement it builds the whole book side and labels the result a preparation, not a
reconciliation. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** It cannot mark an item cleared
  or sign a reconciliation off; every entry it produces is a proposal for a person to post.
- **Never calls it reconciled without the statement.** Comparing the books to the books is a
  total agreeing with itself.
- **Never estimates a figure** that should come from the books or the statement, and **never
  shows a full bank account number** — masked, always.

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
| **B** | *Which bank account, or accounts?* | One bridge per account; several accounts at one bank are a classic mix-up | On the Mosofin path, list the cash accounts from the chart of accounts **by name** and ask which are in scope. **Never display or store a full account number.** |
| **C** | *Which period? Start and end date.* | Sets every read and the statement date on both sides | **Never default the period.** |
| **D** | *The bank statement — PDF or CSV, or at least the ending balance and the lines.* | The one side Mosofin cannot see | **Required, always.** Ask early. If it cannot be supplied, say now what the output will and will not be, then continue with the book-side preparation. |
| **E** | *When was this account last reconciled? The prior report, or just the date.* | Without it, opening outstanding items are unknown and the bridge starts blind | Say the bridge starts unqualified and recommend establishing a baseline. |
| **F** | *How small a difference is worth chasing?* | Materiality governs which items get an owner and a date — the bridge still ties to the cent | Ask; do not assume. Propose a default and **say that you proposed it.** |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **banking or payments platform** is also connected. If one is, the
  statement side may be readable after all — never assume it is not.
- Find the cash accounts in the chart of accounts, and **confirm the in-scope ones with the user**.
- Still ask for the **bank statement** (D). It is never available through the books.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Bank statement** for the period — or the ending balance plus every statement line | **Required** — without it there is no reconciliation, only a book-side preparation, and the output says so | PDF or CSV |
| Your books: **GL activity for the cash account(s)** — date, description, amount, counterparty, reference — plus the **ending balance** (a trial balance works) | Required | CSV or XLSX |
| Account name(s), masked identifier, base currency | Required | Type it in the chat |
| **Prior month's reconciliation** report, or the last reconciled date | Recommended — sets the opening outstanding items | PDF, CSV or a date |
| **Cutoff policy** — posting cutoffs, deposit processing, cheque clearing windows | Recommended — sets the matching windows and escalation ages | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Reconciling the **Operating account (…4471)** of **Northbrook Trading** for **1–30 September**
> against **the statement you uploaded**, with the books read from **your Mosofin connection**.
> Last reconciled **31 August**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the opening and ending balances. Flag anything unreadable, or covering
the wrong period or a different account, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check which read tools are enabled, and read the company profile — base currency,
fiscal calendar and **time zone**, which decides whether a transaction falls on the statement's
last day — so Stage 1's answers do not need asking twice. On the upload path, go straight to
Stage 3.

## Stage 3 — Read both sides, and establish the two starting points

Pull the book side in one batch, then capture the statement ending balance and the GL ending
balance for the same account, currency and date: [`references/method.md`](references/method.md)
Steps 0–1. **If the statement balance is not available, stop here and say so** — continue with
the book-side preparation, clearly labelled, and never present it as a reconciliation.

## Stage 4 — Build the bridge, match, and classify

Two ladders that must meet; four matching methods, each match recorded with the method that made
it; the book side checked against itself for duplicates before the statement is even needed;
then every unmatched item classified: [`references/method.md`](references/method.md) Steps 2–4.
Check [`references/edge-cases.md`](references/edge-cases.md) for transfers recorded once, batched
deposits, foreign-currency accounts, shared accounts and stale items.

## Stage 5 — Propose entries and present the result

Construct the correcting entries as **proposals**, in the real account names from the chart of
accounts, each naming the statement line that evidences it; then the summary, the lists, the
exception log and the coverage sheet: [`references/method.md`](references/method.md) Steps 5–6.
Before presenting, check it against [`references/output.md`](references/output.md). The sign-off
line names two different people; the skill fills in neither.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist the policy, the thresholds and the
account names — never balances, item lists or account numbers.

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
