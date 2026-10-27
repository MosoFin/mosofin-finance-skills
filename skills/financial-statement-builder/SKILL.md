---
name: financial-statement-builder
description: "Builds a complete set of financial statements from a trial balance: Balance Sheet, Income Statement, Comprehensive Income, Cash Flows and Changes in Equity, with comparatives, current and non-current classification and US GAAP, IFRS or local GAAP format, then proves the seven cross-statement tie-outs on the statements it built, each with its difference. Reads the trial balance and comparative period through a connected Mosofin workspace when the user agrees, or works from an uploaded trial balance. Never defaults the framework, the current portion of debt, rounding or a share count. Use when the user asks to build financial statements from a TB, produce a P&L and balance sheet, a monthly financials package, GAAP, IFRS or investor financials, or uploads a trial balance and asks for statements. Do not use to fix an unbalanced trial balance (use closing-entries-and-trial-balance) or for footnotes. Read-only: produces a statement package, tie-outs and a coverage sheet, and posts nothing."
---

# Financial statement builder

Turns the **trial balance** — the long list of account balances — into the statements a bank, an
investor or an auditor expects: **Balance Sheet, Income Statement, Comprehensive Income, Cash
Flows and Changes in Equity**, with comparatives, in the order, groupings and wording the
**framework** requires. **The TB drives the content; the framework drives the presentation.** Then
it proves the statements agree with each other.

The mistake it catches is taking the platform's own balance sheet for a finished statement. That
report **always balances by construction**, so it proves the software works, not that your
statements are right: once a current portion of debt is reclassified, **the balance must be
re-proved on what you built**. It also catches **a ledger prior year that is not the published
prior year**, where audit adjustments were agreed but never posted.

**Works with or without Mosofin.** With Mosofin connected, it reads the trial balance at both
period ends on the same accounting method, the chart with account types, the platform's balance
sheet, P&L and cash flow report as cross-checks, the general ledger and the company's legal name,
currency and year-end. **It can never read a share register, a debt amortization schedule, a
valuation or the prior-year audited financials** — those come from you. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Proves the balance on the statements it built**, after reclassification, never on the
  platform's report, and **reports all seven tie-outs with their difference**, even zero —
  tie-out 6, against the prior-year financials as issued, is `[manual]` and never implied to pass.
- **Never defaults** a framework, a current / non-current split, a rounding basis or a share count.
- **Never adds entity packages together** for a group: consolidated statements come from the
  consolidated TB, and an unreadable group member is a stop condition. `mock` data is stated on
  the face of every statement.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–12" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which reporting framework: US GAAP, IFRS, a local GAAP, or a special-purpose basis (income tax, cash / modified cash, FRF for SMEs)? And the entity's legal form?* | Decides ordering, terminology, format and statement titles throughout; legal form decides the equity section | **Required. Ask first; never default.** |
| **C** | *Which period (month, quarter, year) and which columns — month, YTD, prior year, budget?* | Sets every read; a month-end TB is YTD, not the month; comparatives must be on the same basis | **Required.** Confirm the period. |
| **D** | *For a group: consolidated statements, or separate entity statements?* | Entirely different deliverables | **Required** whenever more than one company file is in scope. |
| **E** | *The prior-year financial statements as issued.* | The check that catches unposted audit adjustments (tie-out 6) | Recommended. Without them, tie-out 6 is marked `[manual]`, not passed. |
| **F** | *How is the current portion of debt and leases determined — the amortization schedules?* | No ledger account knows what falls due within twelve months | Recommended. **Never default the split**; name the source required. |
| **G** | *Rounding basis: whole units, thousands or millions?* | Must be consistent throughout the document | Recommended. **Never default it.** |
| **H** | *Income statement by function or by nature?* | Both reach the same net income; by function needs function tracking | Apply your policy or the framework norm, and check function tracking first (Step 3). |
| **I** | *Anything special: discontinued operations, segments, a different presentation currency, EPS?* | Nothing in the ledger flags them; weighted average shares are not in the ledger | If applicable — `[manual]`. **Never default a share count.** |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file(s) **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). The company files in scope define
  the **reporting entity**: a disconnected subsidiary means statements for the wrong organization.
- The legal name for the header, functional currency and year-end come from the company profile;
  confirm rather than ask, and raise any contradiction, such as a year-end that disagrees with the
  period requested.
- If the trial balance read is disabled but the balance sheet and P&L are enabled, you can still
  build: say the source was the statements, and that account-level detail is coarser.
- Still ask for the **framework** (B), the **issued prior-year financials** (E) and the
  **schedules** (F).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Trial balance** at the current period end, with account types | **Required** — the primary source | CSV or XLSX |
| **Trial balance** at each comparative period end, on the same basis | **Required for comparatives** | CSV or XLSX |
| **Prior-year financial statements as issued** | Recommended — tie-out 6 | PDF or XLSX |
| **Debt and lease amortization schedules** | Recommended — the current portion | CSV, XLSX or PDF |
| **P&L or GL activity** for the period | If the TB is post-closing, with every P&L account at zero, or for a month's figures | CSV or XLSX |
| **Balance sheet (or TB) at the start of the period** — last month end for a monthly package | **Required for cash flows** | CSV or XLSX |
| **GL detail for fixed asset, loan and equity accounts** | **Required for cash flows and changes in equity** | CSV or XLSX |
| Share count, segment data, disposal-group details | If applicable | Type it in the chat, or a file |
| Framework, period, rounding, consolidated or separate, entity legal name and currency | Required (rounding recommended) | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Building **IFRS** statements for **Northbrook Trading** for the year to **30 June 2026**, with
> one comparative year, from the trial balance read through **your Mosofin connection** on the
> accrual basis. By nature, non-current items first, in **thousands**; the current portion of the
> loan from **your amortization schedule**, and comparatives checked against **the FY2025
> financials you uploaded**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period end,
the row count, whether debits equal credits. Flag anything unreadable, or covering the wrong
period or a different entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, settle single, consolidated or separate, build the capability map — the platform's
balance sheet is not a framework balance sheet, and an account type is not a current / non-current
classification — and read the company profile. On the upload path, go straight to Stage 3.

## Stage 3 — Read both periods and validate the TB

Pull the trial balance at both period ends **on the same accounting method**, with the accounts,
the platform statements and the profile, in one batch; check the `mock` flag. Validate the TB —
debits equal credits, every account typed, no type mismatches such as a liability in debit — and
decide whether it is mid-year (use the YTD balances) or post-closing (get the period's activity
elsewhere): [`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Build the statements

Classify current and non-current and build the Balance Sheet, **mapping every TB account to
exactly one line**; build the Income Statement in the chosen format; add comparatives, checked
against the prior year as issued; add comprehensive income, naming the analysis required for any
AOCI balance; then the cash flow statement by the indirect method and the changes in equity:
[`references/method.md`](references/method.md) Steps 2–7. Check
[`references/edge-cases.md`](references/edge-cases.md) for discontinued operations, EPS, restated
comparatives, going concern, specialised industry formats and parent-only statements.

## Stage 5 — Tie out, present and deliver

Run the **seven cross-statement tie-outs**, each pass or fail with its difference; apply rounding
and presentation, with a footer naming the entity, source, currency, rounding and `mock` status;
run the quality checks; and build the workpaper, with each reclassification marked presentation only
or a proposed entry, and the coverage sheet: [`references/method.md`](references/method.md) Steps 8–11. Ask before creating the
`.xlsx` or a PDF render. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 12. Persist the framework and its presentation
elections, the **account-to-line mapping**, the classification rules, rounding, the accounting
method, the comparative policy, the OCI items that apply and the consolidation choice, keyed to the
entity — **never balances, statement figures or the trial balance.**

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
