---
name: payroll-journal-entry-builder
description: "Builds the journal entries that record a payroll run from its payroll register: gross pay, employee withholdings, net pay, employer costs, net pay funding, department and cost-centre allocation, capitalised labour and the period-end accrual. Ties every line to the register's totals, the test that catches employer contributions mixed with employee deductions, and compares the run to prior runs before anything is posted. Reads the chart, dimensions and prior runs through a connected Mosofin workspace when the user agrees, or works from uploaded files — the register, a chart of accounts, prior journals. Use when the user asks to book the payroll journal, record a payroll run, accrue payroll, split payroll across departments, or turn a payroll register into entries. Do not use for reconciling payroll to the GL after posting (use payroll-reconciliation) or the payroll clearing account (use payroll-clearing-reconciliation). Read-only: produces proposed entries, a workpaper and a coverage sheet, and posts nothing."
---

# Payroll journal entry builder

Turns a **payroll register** into the journal entries that record the run: **gross pay** as the
expense, **withholdings** owed to third parties, **net pay** owed to staff, and the **employer's
own costs** on top — balanced, against the real chart of accounts, and split across departments
where the cost must be.

It catches the error the skill calls the single most common: **an employer contribution booked as
an employee deduction, or the reverse.** That entry balances perfectly and is wrong. Two separate
entries and **tying every line to the register's column totals** expose it. It also compares the run to prior
runs and checks that last period's accrual reversed, **before** anything is posted.

**Works with or without Mosofin.** With Mosofin connected, it reads the chart of accounts, the
department, class and location dimensions, prior payroll journals, the payroll liability and
clearing balances, payroll expense by department and headcount. **There is no payroll register, no
rate table and no benefit schedule on the books surface** — the register is read only if a payroll
platform is also connected, and is otherwise supplied by you and labelled as such. The allocation
basis and capitalised labour are always yours to state. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Payroll data is personal.** Builds and presents entries **at account and department level, not
  by employee** — the journal is a total; the register is the detail, and the detail stays in the
  payroll system. **Never itemises individual pay, deductions or garnishments**, and **never
  persists any individual's payroll data.**
- **Never invents an account.** An account not in the live chart is a hard stop; if the chart
  cannot be read, names are labelled **PLACEHOLDER — REMAP REQUIRED**. **Never defaults an account
  mapping, an allocation basis or a capitalisation decision.**
- **A balanced entry is not a correct entry.** The employer entry is kept separate from the
  employee entry, and every line is tied to the register's column totals.
- **One estimate only:** a period-end accrual for a run not yet processed, labelled **ESTIMATE**.

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
| **B** | *Which entity, and which run? In a group, which entity employs the people in this run?* | One journal per entity, against its own chart — the liabilities are owed by different legal entities | **Never auto-pick.** Confirm the entity by name before building anything. |
| **C** | *Pay period and pay date — both. And do you keep the books on a cash or accrual basis?* | The Step 6 accrual depends on the gap between them, and applies only on an accrual basis | **Required.** The basis is not readable from the books. |
| **D** | *The payroll register or report for the run.* | Every amount traces to it | **Required.** On the Mosofin path, check first whether a payroll platform is connected. Without it there is nothing to build from — say so; never estimate an amount. |
| **E** | *Employer contribution details — social contributions, retirement match, benefit costs.* | They are additional expense and liabilities, not deductions | **Required for full cost.** Usually in the register; if missing, say the employer entry and total cost are incomplete. |
| **F** | *Is a payroll clearing account used?* | Changes how net pay is credited (Step 5) and what `payroll-clearing-reconciliation` later reconciles | **Required.** On the Mosofin path, check whether one exists and carries payroll-cycle movement, then confirm. |
| **G** | *If cost is split by department or cost centre: on what basis — hours, headcount, direct assignment?* | A department dimension is not an allocation basis; the basis is a decision | **Never default it.** |
| **H** | *Any capitalised labour in this run — a self-constructed asset, capitalised software?* | Routes cost to an asset account, not expense | **Required if applicable. Never default it** — nothing in the register flags it. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **payroll platform** is also connected. If one is, the register — and
  with it gross-to-net, employer costs and department detail, if it carries them — is read, not
  asked for.
- Read the chart, and **confirm which account holds which liability**. Read the bank accounts for
  funding; the payment timing is still the user's.
- Still ask for the allocation basis (G) and capitalised labour (H); the books never answer them.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Payroll register / report** for the run, with totals by component — gross, each withholding, net pay | **Required** — every amount traces to it | CSV, XLSX or PDF |
| **Employer contribution details**, if not in the register | **Required for full cost** | CSV, XLSX or PDF |
| **Chart of accounts** — wages, each withholding and employer liability, net pay payable, clearing, accrued payroll | **Required for postable entries** — without it, account names are labelled PLACEHOLDER — REMAP REQUIRED | CSV or XLSX |
| Entity name, country or region, functional currency, fiscal calendar; pay period and pay date; cash or accrual basis; whether a clearing account is used | Required | Type it in the chat |
| **Allocation basis**, and any **capitalised labour** with its asset account | Required if applicable | Type it in the chat |
| **Prior payroll journals**, the **liability and clearing balances**, and **GL detail of the accrued payroll account** for the prior and current period | Recommended — enables the run-over-run comparison and the accrual-reversal check | CSV or XLSX |
| **Funding details** — bank account and timing; the provider's statement if a provider debits a lump sum | Recommended — the lump sum's composition comes only from the provider | PDF, CSV or XLSX |

**Read back before starting, then wait for a yes:**

> *Building the payroll journal for **Northbrook Trading**'s **monthly run for September** (pay
> period **1–30 September**, pay date **25 September**), from **the register you uploaded**, against
> the chart read from **your Mosofin connection**. Net pay through the **payroll clearing account**;
> wages and employer costs split by department on **headcount**; **no capitalised labour**. Shall I
> go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the register's totals by component. Report totals only, never an
individual's line. Flag anything unreadable, or covering the wrong period or entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check for a payroll platform, settle single- or multi-entity, check which read tools
are enabled — if the chart read is disabled, the placeholder fallback applies — and read the
company profile: legal name, functional currency, fiscal calendar and **country or region, which
determines which withholding and contribution types exist**. On a later run, read the stored
preferences first and ask only what changed. On the upload path, go straight to Stage 3.

## Stage 3 — Read the evidence and map the register

Batch the independent reads — chart, dimensions, prior runs, liability and clearing balances,
department P&L, headcount — and check the `mock` flag. Then take the register's totals by
component and map each to an account: **every component needs an account, and every payroll
account should receive something**; either gap is resolved before building:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Build the entries

The gross pay and withholding entry; the employer cost entry, **kept separate**; the expense-side
allocation by the stated basis, with capitalised labour routed to the asset account and flagged;
net pay funding — cash, clearing, or a provider lump sum **booked by component, never as one
expense**; and, on an accrual basis, the period-end accrual for wages earned by the period end and paid after, **including
employer costs** and set to reverse: [`references/method.md`](references/method.md) Steps 2–6.
Check [`references/edge-cases.md`](references/edge-cases.md) for bonus runs, benefits in kind,
garnishments, retro pay, shared liability accounts and group payrolls.

## Stage 5 — Validate, compare and present

Run the checks in Step 7 — among them balance, every line tied to the register's
column totals, total expense = gross + employer costs, every account in the live chart, the run
against prior runs by component and per head, and whether the prior accrual reversed. **A material movement without a
headcount change is a question before posting.** Then the entries marked **PROPOSED — NOT POSTED**
and the workpaper sheets, ending with a **Data sources** line:
[`references/method.md`](references/method.md) Steps 7–8. Offer the `.xlsx` file only on a yes.
Before presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been seen and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the decisions — account map, entry
template, allocation basis, clearing convention, funding model, pay calendar, capitalised labour
rule, comparison tolerances — keyed by datasource and entity name. **Never any individual's payroll
data, never amounts, never workspace state.**

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
