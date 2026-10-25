---
name: accruals-and-deferrals
description: "Identifies and computes period-end accruals and deferrals beyond AP cutoff — bonus, commission, vacation and payroll accruals, interest, utilities and services, professional fees, accrued revenue and deferred revenue — and drafts the entries, the reversing entries, a roll-forward by category and a materiality list with the cumulative total of excluded items. Reads balances, prior accruals and their reversals, billing history and receipts through Mosofin when the user agrees, or works from uploaded exports, and asks for what no ledger holds: bonus pools, loan terms, contract service periods, fee estimates. Use when the user asks to book period-end accruals, accrue bonuses, interest or utilities, defer revenue, or prepare period-end adjustments. Do not use for GRNI and AP cutoff accruals (use ap-accrual-cutoff), prepaid expenses (use prepaid-amortization-schedule) or the full close (use month-end-close-checklist). Read-only: produces a schedule, proposed entries and a coverage sheet, and posts nothing."
---

# Accruals and deferrals

Your books should show costs and income in the month they actually **happened**, not the month
the paperwork or the money showed up. An **accrual** records something that already happened but
hasn't been billed yet — March's electricity, billed in April. A **deferral** does the opposite —
a customer paid in January for a year of service, so the income is spread out. This skill finds
those items, works out the amounts, and drafts the entries and their reversals for a person to
post.

It covers what AP cutoff does not: bonus, commission, vacation and payroll accruals, interest,
utilities and services, professional fees, accrued revenue and deferred revenue. The mistake it
watches for is the accrual balance that **keeps climbing** — a reversal that never posted, or an
accrual booked twice — and the accrual with **no underlying basis**.

**Works with or without Mosofin.** With Mosofin connected, it reads the chart of accounts, the
trial balance, the ledger detail behind the accrual and deferred-revenue accounts, last period's
accruals and whether they reversed, vendor billing history and run-rates, unbilled hours,
invoices and customer money received in advance. **It cannot read what lives outside the
ledger** — bonus plans and pools, pay rates and vacation balances, loan rates and day-count
conventions, contract service periods, engagement estimates — so it asks for them, category by
category. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never proposes an accrual without an underlying basis.** What the ledger cannot supply is
  `[manual]` and asked for; a bonus payout estimate is recorded with its owner named.
- **Never defaults the period, the accounting method or the entity**, and **never invents a
  materiality threshold** — if you decline one, everything found is accrued and the output says
  so.
- **Never guesses an account** from a name that merely looks plausible, and no proposed entry
  rests on `mock` data.

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
| **B** | *Which company — or, for a group, which entities?* | Each entity runs separately and every accrual carries its name | **Never default the entity.** On the Mosofin path, ask **by name**. |
| **C** | *Which period? Exact start and end dates.* | Sets every read, the cutoff and the reversal date | **Never default the period.** |
| **D** | *Which categories are in scope — compensation, interest, utilities and services, revenue, deferred revenue, professional fees, tax?* | Decides what is looked for | **Required.** Offer the Step 1 and Step 2 lists as a checklist, not an open question. |
| **E** | *The supporting data for each category — bonus pool, commission plan, pay rates, loan rate and day-count, contract terms, time sheets, engagement letters.* | Most amounts depend on it, and it is not in the ledger | **Required per category.** Ask only for what the books cannot show, and say which is which. A gap stays a named gap. |
| **F** | *Do accruals reverse automatically on day one of the next period, or does the incoming invoice post straight against the accrual?* | Both are valid; the answer changes the reversing entries | **Required.** State the policy in the output. |
| **G** | *Are the books kept on an accrual or a cash basis?* | A cash-basis ledger may legitimately carry no accruals at all | **Never default it.** On a cash basis, say so rather than "no accruals found", and ask whether you are converting. |
| **H** | *What materiality threshold applies?* | Items below it can be skipped, but their cumulative total is still tracked | Recommended. **Do not invent one**; if declined, accrue everything found and say so. |
| **I** | *Reporting framework, and tax jurisdiction?* | Presentation and some measurement; tax recoverability and employer payroll tax on compensation accruals | Recommended. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Derive the functional currency and the fiscal calendar — which sets the year-to-date fraction
  for a bonus accrual — from the company profile; ask about currency only if several appear.
- **Confirm the accrued-liability, accrued-revenue and deferred-revenue accounts** with the user;
  naming varies, and an unidentifiable account is asked for, never guessed.
- If the transaction-level ledger tool is disabled, a summary balance is **not** a substitute: the
  roll-forward becomes manual and a ledger export is asked for.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Supporting data per category in scope** — bonus plan and pool, commission plan, payroll or vacation balances, loan agreements, customer contracts, time sheets, engagement letters | **Required per category** | PDF, CSV or XLSX |
| **Chart of accounts** — the accrual, deferred-revenue and expense accounts to post to | **Required** | CSV or XLSX |
| Period, entity, categories in scope, reversal policy, accrual or cash basis | **Required** | Type it in the chat |
| **Trial balance** at period end and **GL detail** for the accrual and deferred-revenue accounts, including last period's accruals and reversals | Needed for the roll-forward and the reversal check | CSV or XLSX |
| Vendor bills or billing history for utilities and services; customer receipts in advance | Recommended — utility estimates and deferred revenue from the books | CSV or XLSX |
| Materiality threshold; reporting framework; tax jurisdiction | Recommended | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Accruing for **Northbrook Trading** for **1–30 September**, accrual basis, with the books read
> from **your Mosofin connection**. In scope: **bonus** (from the $240k pool you gave me),
> **interest** on the term loan, **utilities**, **audit fees** and **deferred revenue**. Accruals
> **reverse on day one**; materiality **$500**. Shall I go ahead?*

On the upload path, name each file you received and what was read from it — the period it
covers, the row count, the balances. Flag anything unreadable or for the wrong period at once.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files — naming any excluded file and the accruals it leaves unsupported — check which read
tools are enabled, and read the company profile, so Stage 1's answers are not asked twice. On the
upload path, go straight to Stage 3.

## Stage 3 — Read the books and identify the items

Pull the chart of accounts, trial balance, balance sheet, ledger detail, last period's journal
entries and the P&L run-rates in one batch, and check the `mock` flag. Then work through the
**accrual** categories — compensation, interest, service and utility, revenue, other — and the
**deferral** categories, noting for each what the books show and what must be supplied; prepaid
expenses go to the prepaid skill: [`references/method.md`](references/method.md) Steps 0–2.

## Stage 4 — Compute each accrual and deferral

Apply each category's basis — bonus pool × year-to-date fraction × payout probability plus
employer payroll tax; commission per the plan's booking, billing or collection trigger; vacation
at earned days × pay rate; interest on the loan's own day-count convention; utilities from the
last invoice's daily rate, the contract, or last year; revenue from unbilled hours, milestones or
subscriptions; professional fees from engagement letters:
[`references/method.md`](references/method.md) Step 3. Check
[`references/edge-cases.md`](references/edge-cases.md) for uncertain bonuses, vacation policies,
multi-currency, clawbacks and vesting, variable-rate debt, payroll tax, true-ups, accruals not
owed, stock-based compensation and pensions.

## Stage 5 — Propose the entries, reversals and roll-forward, and present

Draft each accrual and deferral entry in the real account names, with output tax split out of
deferred revenue at receipt; draft the reversing entries dated the first day of the next period
per the stated policy, and check last period's reversals actually posted; roll forward each
category and **investigate any balance that grows beyond the current accrual**; apply materiality
and total the excluded items: [`references/method.md`](references/method.md) Steps 4–8. Before
presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the categories in scope,
materiality, framework, tax jurisdiction, reversal policy, the account mapping, the computation
basis per category, recurring items and standing exclusions, keyed by datasource and entity —
never connections, tool policies or `mock` status.

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
