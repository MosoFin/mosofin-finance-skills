---
name: month-end-close-checklist
description: "Plans, runs and audits a monthly close: builds the close task list with owners, deadlines, dependencies and status, scopes it to the entity (no inventory, single entity, cash basis, industry tasks), applies materiality, tracks open items and runs the final tie-out, including an inter-period continuity check per balance sheet account. Reads the books through a connected Mosofin workspace when the user agrees, using posted entries as evidence of what has and has not been done, or works from uploaded exports such as a trial balance. Use when the user asks to run the month-end close, wants a month-end checklist or close calendar, asks what is left to close, or wants to organise or coordinate the close for a month. Do not use for an individual close task: a bank reconciliation (use bank-reconciliation), an accrual (use accruals-and-deferrals) or a single journal entry (use journal-entry-builder). Read-only: produces a close workpaper, a final tie-out and a coverage sheet, and posts nothing."
---

# Month-end close checklist

Builds and runs the **monthly close**: every task that has to happen before the month's numbers
can be handed to someone who will decide with them, each with an **owner, a due date, its
dependencies and a status**, ending in a **final tie-out** that shows the books are reportable.
It is the coordination hub: almost every task hands off to another skill, and this one tracks them.

The mistake it catches is a status board that reports what people claim rather than what the books
show: a task ticked **Complete with no entry posted**, a **reconciliation "verified" from the
ledger**, a balanced trial balance taken for a closed month, and a **prior period quietly reopened**,
which only the per-account **inter-period continuity** check finds.

**Works with or without Mosofin.** With Mosofin connected, it reads the chart of accounts to scope
the checklist (no inventory account, one company file, one currency), reads the period's journal
entries to **pre-populate the status of every task that leaves an entry**, and runs most of the
tie-out. **It can never read a bank statement, close software, a task tracker or a team calendar,
and it cannot lock the books, post an entry or mark a task complete.** Owners, the calendar and
materiality always come from you. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **An entry posted is not a task complete**, a **reconciliation is never reported as verified
  from the ledger**, and a **balanced trial balance is noted as true by construction**, never as
  proof the month is closed.
- **Never drops a task because no tool covers it.** A task removed by scoping is reported with its
  evidence; a group member that is not connected keeps its tasks, marked unverifiable.
- **Never assumes a materiality threshold**, never persists a status or a close result, and never
  signs off a close on `mock` data.

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
| **B** | *Which period is being closed?* | Sets every read, the tie-out and the continuity check against the prior period | **Required.** |
| **C** | *What is the close calendar, or the target close date?* | The day allocation in Step 1 flexes to it; some entities close in 3 days, others in 10 | **Required — `[manual]`.** Not in the ledger. |
| **D** | *Is this a soft close or a hard close?* | Monthly closes are usually soft, quarter- and year-end hard; different rigour | **Required.** |
| **E** | *Which reporting framework?* | The basis the close reports on | **Required — `[manual]`.** |
| **F** | *Who owns each task? By role is fine.* | Not in the ledger, and the checklist is worth little without them; every task needs an owner | Recommended. Ask, and record owners by role wherever possible. |
| **G** | *What materiality threshold applies?* | Splits reconciliations into full scrutiny and less detail | Recommended. **Never assume one** — a startup with small revenue is not an enterprise. Without it, the Step 4 split is not applied. |
| **H** | *Do you have a standard close template, and last month's close?* | A template is preferred over a generic list; last month's carry-forward items are `[manual]` | Recommended. Without them, build from Step 1's list. |
| **I** | *Industry, number of entities and currencies, fiscal calendar, time zone* | Drives the scoping in Step 2 and the industry additions | **Upload path only.** On the Mosofin path these come from Gate 1 and the company profile: confirm, don't ask. |
| **J** | *Do you report on a cash or an accrual basis?* | Decides whether most Day 1 and Day 3 tasks apply, and which TB the tie-out uses | **Required.** Passed on every read and stated in the workpaper header. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file(s) **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Count the connected company files at Gate 1: **one means no consolidation phase (Day 6 drops
  out)**; several means Day 6 applies. Name any group member that is not connected: it still closes.
- Note which subledger platforms are connected (payroll, billing, inventory, expenses); they show
  which Day 1 and Day 2 tasks have a system behind them.
- At Gate 3, **present the scoped checklist with the remaining questions**, so the user confirms a
  tailored list rather than answering abstract ones. Confirm any profile contradiction, such as a
  monthly close for an entity whose periods are quarterly.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Trial balance** at the period end **and** at the prior period end, plus **last month's TB as reported** (from last month's close pack) | **Required for the final tie-out**; the reported TB for the inter-period continuity check, which is otherwise not performed | CSV or XLSX |
| **Journal entries** posted in the period | Recommended — the status evidence for every entry-based task; without it, every status is owner-reported | CSV or XLSX |
| **Chart of accounts** | Recommended — the scoping instrument; without it, Step 2's questions are asked instead | CSV or XLSX |
| **Balance sheet** and **P&L**, current and prior | Recommended — the variance and reasonableness review | CSV, XLSX or PDF |
| **GL detail** around the period boundary | Recommended — cutoff evidence | CSV or XLSX |
| **Budget or forecast** | Recommended — P&L variance to budget, where one is held | CSV or XLSX |
| Close template, last month's close, owners list | Recommended | XLSX, or type it in the chat |
| Period, close calendar, soft or hard close, framework, materiality | Required (materiality recommended) | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Planning the **August 2026** close for **Northbrook Trading**, a single entity in one currency,
> so no consolidation day, with the books read from **your Mosofin connection**. Target close
> **Day 6**, a **soft close**, US GAAP, materiality **$25,000**, owners from **your July template**.
> Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the opening and closing balances. Flag anything unreadable, or covering
the wrong period or a different entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, build the capability map — which also says **which tasks can be status-checked and
which rely on the owner reporting** — and read the company profile for base currency, fiscal
calendar and industry. On the upload path, go straight to Stage 3.

## Stage 3 — Read the evidence, build the list and scope it

Pull the chart, the period's journal entries, the trial balance at this and the prior period end,
the balance sheet, P&L and GL around the boundary in one batch; check the `mock` flag. Build the
task list, Pre-Close through Day 7, each task with its status-check verdict, then **scope it to the
entity** and add the industry tasks, reporting every removal with its evidence:
[`references/method.md`](references/method.md) Steps 0–2. For a group, see "Both entity scenarios"
in method.md: Steps 0–8 run once per entity, and scoping is per entity.

## Stage 4 — Assign owners, apply materiality, track open items

Give every task an owner, due date, dependencies, time estimate and status, build the dependency
tree and critical path, and add the **Evidence** column: what the books show beside what the owner
claims. Apply the materiality threshold to a listed set of balance sheet accounts, flag risk areas
(new accounts used this period, unusual fluctuations), and **group the tasks waiting on outside
information separately**: [`references/method.md`](references/method.md) Steps 3–5. Check
[`references/edge-cases.md`](references/edge-cases.md) for late information, re-opens, a three-day
close, a system change, year-end, and a task marked Complete with no entry posted.

## Stage 5 — Tie out, review the close, and present

Run the final tie-out — trial balance balanced (true by construction), each balance sheet account's
reconciliation status, income statement reasonableness, **inter-period continuity per account**,
adjusting entries posted, books locked — then the lessons learned, using the measured entry-created
times rather than recollection, and build the workpaper with its scoping and coverage sheets:
[`references/method.md`](references/method.md) Steps 6–8. Ask before creating the `.xlsx`. Before
presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the scoped task list, owners by role,
the dependency tree, the close calendar, the materiality threshold and its basis, the status-check
definitions and recurring open items, keyed to the entity — **never balances, variances, task
statuses or close results.**

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
