---
name: credit-card-reconciliation
description: "Reconciles a company credit card statement (Amex, Visa, Mastercard, Brex, Ramp) to the general ledger: ties the statement closing balance to the card liability, matches receipts to charges, checks coding and tax, flags missing receipts, possible personal use, duplicates, forgotten subscriptions and capital purchases sitting in expense. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded exports — the card statement, receipts, GL detail or a trial balance. Always asks for the statement and the receipts, which no accounting connection can supply, and labels a run without the statement as a review of posted charges, not a reconciliation. Use when the user asks to reconcile a corporate card, match receipts to a card statement, or uploads a card statement. Do not use for employee expense reports (use expense-report-processor) or bank accounts (use bank-reconciliation). Read-only: produces a workpaper, a proposed entry and a coverage sheet, and posts nothing."
---

# Credit card ↔ books reconciliation

Checks that every charge on the **company card statement** is in **your books**, coded to the
right account, backed by a receipt and actually for the business — and that the card liability
in the books ties to the statement's closing balance once timing items are named. It also runs
three tests every month that need no statement at all: **duplicate charges**, **forgotten
subscriptions** and **capital purchases sitting in expense**.

**Works with or without Mosofin.** With Mosofin connected, it reads the book side directly: every
card charge posted in the period with its merchant and coding, the card liability and the payments
made to it. **It can never read the card statement or the receipts** — no accounting connection
exposes them — so it always asks you for them. Without the statement it reviews the posted charges
and says plainly that this is not a reconciliation. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never calls it reconciled without the statement**, and **never treats an attached file as a
  matched receipt** — a file existing says nothing about whether it supports the amount.
- **Never estimates a figure** that should come from the books or the statement, and **never
  defaults the period, the receipt threshold or the capitalisation threshold.**
- **Treats a possible personal charge as a judgment for a person**, not a finding, and never
  stores card numbers or an individual's spending.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–9" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which card, or cards, and who holds each?* | One tie-out per card liability account; the cardholder is who answers for a missing receipt | On the Mosofin path, list the card liability accounts from the chart of accounts **by name** and ask which are in scope. Record cards **by role, never by card number**. |
| **C** | *Which statement period? Start and end date.* | Sets every read, and whether the statement and the accounting period line up | **Never default the period.** |
| **D** | *The card statement — PDF, CSV or XLSX, or at least the opening and closing balances and the lines.* | The one side Mosofin cannot see | **Required, always.** Ask early. If it cannot be supplied, say now that the result will be a review of posted charges, not a reconciliation. |
| **E** | *The receipts for the period, or a receipt-tool export (Expensify, Brex, Ramp).* | Receipt matching is impossible without them | **Required for receipt matching.** Without them, say that no receipt was matched and why. |
| **F** | *The receipt threshold (below which no receipt is needed) and the capitalisation threshold.* | They separate an acceptable missing receipt from an exception, and an expense from an asset | **Never default either.** Ask; if still unanswered, say which test could not be run. |
| **G** | *Is tax recovered on card spend, and in which jurisdiction?* | Drives the tax step | Ask only if the profile does not answer it. Without it, tax recoverability is not assessed, and the output says so. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **card or spend platform** is also connected. If one is, the
  statement side may be readable after all — never assume it is not.
- Find the card liability account in the chart of accounts, and **confirm it with the user**.
- Still ask for the **statement** (D) and the **receipts** (E). Neither is available through the
  books; attachment metadata shows a file exists, not that it is the right receipt.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Card statement** for the period — or the opening and closing balances plus every statement line | **Required** — without it there is no reconciliation, only a review of posted charges, and the output says so | PDF, CSV or XLSX |
| **Receipts** for the period, or a receipt-tool export | **Required for receipt matching** | PDF, images, or a CSV/XLSX export |
| Your books: **GL detail** for the card liability account and the accounts the card is coded to — date, merchant, amount, account — plus the **liability balance** at the statement closing date and at period end | Required | CSV or XLSX |
| Card name(s), cardholder role(s), base currency | Required | Type it in the chat |
| **Last month's reconciliation** — its open reconciling items | Recommended — lets the run confirm they cleared | Any format |
| **Receipt and capitalisation thresholds**; tax jurisdiction if tax is recovered | Recommended — enables the receipt-exception, capital-purchase and tax tests | Type it in the chat |
| **Chart of accounts** | Recommended — needed to check and propose coding | CSV or XLSX |

**Read back before starting, then wait for a yes:**

> *Reconciling the **Amex Business card** held by **the operations manager** at **Northbrook
> Trading** for **1–30 September**, against **the statement and 46 receipts you uploaded**, with
> the books read from **your Mosofin connection**. Receipt threshold **$75**, capitalisation
> threshold **$2,500**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the opening and closing balances. Flag anything unreadable, or covering
the wrong period or a different card, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check which read tools are enabled, and read the company profile — base currency,
which decides which charges count as foreign, fiscal calendar and time zone — so Stage 1's
answers do not need asking twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read both sides, and parse the statement

Pull the book side in one batch — every card charge in the period, the liability account's full
movement, payments to the card, several prior months for the recurring tests — then parse each
statement line: transaction and posting dates, merchant, amount, currency and FX fee:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Tie the balance, match receipts, check coding and tax

Tie the statement closing balance to the card liability, naming every timing item; **if no
statement was supplied, do not build this bridge** and present the posted-charge review instead.
Then match receipts, check each charge's coding and tax treatment, and flag exceptions —
including the three monthly tests: duplicates, recurring subscriptions with their annualised cost,
and capitalisation-threshold breaches: [`references/method.md`](references/method.md) Steps 2–6.
Check [`references/edge-cases.md`](references/edge-cases.md) for pre-authorisation holds, foreign
currency, cash advances, disputes, rewards, cards shared across entities, and a statement period
that crosses the accounting period.

## Stage 5 — Propose the entry and present the result

Construct the posting entry as a **proposal**, in the real account names from the chart of
accounts; then the summary, the transaction detail with a source column, the exceptions and the
coverage sheet: [`references/method.md`](references/method.md) Steps 7–8. Before presenting,
check it against [`references/output.md`](references/output.md). The header says whether a
statement was supplied, and therefore whether this is a reconciliation or a posted-charge review.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the card register by role, the
thresholds and the merchant-to-account coding map — never balances, transaction detail or card
numbers.

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
