---
name: budget-vs-actual-analysis
description: "Compares actual results to budget or forecast and explains the variances: aligns both sides line by line, computes dollar and percentage variances for the month, QTD and YTD, labels each favorable or unfavorable by line type, applies the user's materiality thresholds, decomposes material variances into volume, price, mix, rate and FX drivers, separates timing from permanent, assesses the full-year impact, and drafts commentary that never invents a cause. Reads actuals and the budget held in the accounting system through a connected Mosofin workspace when the user agrees, or works from uploaded actuals and budget exports. Use when the user asks for budget vs actual, a BvA report, variance or flux analysis, plan vs actual, why they are over or under budget, or uploads actuals alongside a budget. Do not use for building the budget itself or for period-over-period MD&A narrative. Read-only: produces a variance report, commentary and a coverage sheet, and revises, reclassifies or posts nothing."
---

# Budget vs. actual: variances and their causes

Measures the gap between what you planned and what happened on every line, for the month, the
quarter to date and the year to date; labels each gap **favorable or unfavorable by line type**;
filters for materiality; and for the variances that matter, works out **why**: volume, price, mix,
rate, FX, timing or a one-off. Then it drafts the commentary someone can take to a management
meeting. The hard part is never the subtraction; it is saying what caused it.

The mistakes it catches: subtracting unlike from like (a budget line with no matching actual account
reads as a 100% favourable variance); a "+$50K" on an expense line read as good; prior-year actuals
passed off as a budget; a group total that nets one entity's overspend against another's underspend
and reports zero; and commentary that narrates a cause nobody evidenced.

**Works with or without Mosofin.** With Mosofin connected, **both sides can come from the books**:
actuals by line and by month, and the budget itself where the accounting platform holds it, plus the
prior year, the chart and its groupings, and the transactions behind each variance. **It can never
read why a variance happened**, where that depends on business events the ledger cannot see, nor the
materiality thresholds, the timing-versus-permanent judgment, or a budget the system does not hold.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never defaults the period, the materiality thresholds, the budget version or the entity**, and
  never presents prior-year actuals as a budget: without a budget there is no variance report.
- **Never invents a cause.** Commentary goes to management verbatim; an unknown driver is written
  as **to be confirmed**, with the transactions behind it and an owner.
- **Reports each entity first, then the group**, and never compares one entity's actuals to another's
  budget.

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
| **B** | *Which entity, or which set of entities?* | Each entity is compared to its own budget; a missing entity reads as a favourable cost variance | **Never default the entity.** On the Mosofin path, ask by `display_name`. |
| **C** | *Which period, and at what granularity: month, QTD, YTD? Is that period closed (reconciliations done, accruals posted)?* | QTD and YTD are measured against the fiscal year, not the calendar; an open month shows unbooked bills as savings | **Never default the period.** Confirm it against the year-end. If not closed, or unknown, the report is marked PRELIMINARY (Step 1). |
| **D** | *Which budget, by name: the original, a revised budget, or the latest forecast?* | Each tells a different story | **Required. Never pick the most recent by default**; name the chosen one on the report. |
| **E** | *Materiality thresholds: a dollar amount and a percentage — and must a variance exceed both, or either?* | Decides which variances get commentary | **Don't assume.** If the user declines, say no rule was applied and rank every variance by size (Step 4). |
| **F** | *Any known one-time items in the period?* | Saves misattributing a legal settlement to run-rate cost | Recommended. A single large ledger transaction is evidence of a one-off; whether it recurs is a judgment. |
| **G** | *Driver data: units, headcount, prices, and the budgeted drivers.* | Decomposition needs both actual and budgeted drivers | Recommended. Actual units and prices are often readable; headcount cost and planned drivers are usually supplied. |
| **H** | *Which grouping does management actually read?* | Decides how lines roll up | Recommended. The chart, classes and departments pull on the Mosofin path; confirm which one. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). Name every excluded company file and
  the consequence.
- At Gate 2, **check the budget-reading tool first**: it decides whether the run is two-sided or
  one-sided. If it is disabled or absent, ask for the budget.
- Where the system holds several budgets, **list them and ask which one** (D).
- Read the fiscal calendar and functional currency from the profile; confirm the report breaks down
  by month, and say so if it will not, rather than deriving monthly figures.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Actuals** for the period, by line, by month | Required | CSV or XLSX export |
| **Budget or forecast** for the same period, by line, by month, with its name, its basis (cash or accrual) and any subdivision (class, location, customer) | **Required** — without it there is no variance report | CSV or XLSX |
| Period and granularity; fiscal year-end and functional currency | Required | Type it in the chat |
| Materiality thresholds, dollar and percentage | Recommended | Type it in the chat |
| **Prior-year actuals**, same granularity | Recommended — the YoY column, never a substitute for the budget | CSV or XLSX export |
| Chart of accounts and the reporting hierarchy | Recommended — F/U is taken from each line's type | CSV or XLSX |
| Driver data: units, prices, headcount | Recommended | CSV, XLSX, or type it in the chat |
| Known one-time items | Recommended | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Comparing **Northbrook Trading**'s actuals for **September**, **QTD and YTD** on a **June
> year-end**, to the **FY26 Board Budget**, with both read from **your Mosofin connection**.
> Thresholds **$5,000 and 10%**; prior year shown as a separate column. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the line count, the totals. Flag anything unreadable, a budget not phased by month, or two
files covering different periods or entities, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, check which read tools are enabled (the budget tool per entity, since one company file
may be two-sided and its sibling one-sided), read the company profile for the functional currency and
fiscal calendar, and interview only for what Stage 1 did not cover. On the upload path, go straight
to Stage 3.

## Stage 3 — Read both sides and align them

Pull actuals by month, prior year, the budget, the chart and groupings, and the transactions and
journal entries behind the period in one batch, checking for `mock: true`; then align: list every
account present on one side and not the other **before** computing anything, confirm period,
currency and accounting basis, and **show** any mapping of actual accounts to budget lines:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Compute, classify, filter, and find the drivers

Variance in dollars and percent at each level, with `|Budget|` in the denominator and no percentage
on zero-budget lines; F/U from each line's type in the chart, not its name; both thresholds applied;
material variances decomposed into volume, price, mix, FX, headcount, rate, one-time and timing; and
timing separated from permanent, checking the following period where it exists:
[`references/method.md`](references/method.md) Steps 2–6. Check
[`references/edge-cases.md`](references/edge-cases.md) for reclassifications, unphased budgets,
mid-year revisions, FX, one-offs, accrual catch-ups, new initiatives and cumulative small misses.

## Stage 5 — Assess the full year, draft commentary, present the result

For each material permanent variance, the full-year implication (the run-rate arithmetic is
computed; whether it persists is the user's judgment); then concise commentary per material variance,
cause evidenced or marked **to be confirmed**; then the six sheets, with the budget version named in
the header: [`references/method.md`](references/method.md) Steps 7–9. Ask whether the user wants the
workpaper as an Excel file before creating one. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 10. Persist the thresholds, the budget-version
convention, the reporting hierarchy, the account mapping, line owners, recurring known one-offs and
standing decompositions, keyed by datasource and entity — never the variance figures, the commentary
or the outlook.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 3–5, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
