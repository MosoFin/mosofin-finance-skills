---
name: payroll-reconciliation
description: "Reconciles payroll across its four sources of truth — register, general ledger, bank, and remittances and filings: register to GL, net pay to bank, each withholding and employer liability rolled forward, quarter- and year-end filings and wage statements, and each tax to its taxable wage base. Flags manual adjustments, negative liabilities and overdue remittances. Reads the GL side through a connected Mosofin workspace when the user agrees, or works from uploaded registers, GL detail, bank and remittance records, and reports the wage-base check as not performed without a register. Use when the user asks to reconcile payroll, tie the register to the GL or payroll to the bank, reconcile payroll liabilities, or do a quarter- or year-end payroll tie-out. Do not use for building the payroll journal (use payroll-journal-entry-builder) or clearing-account zeroing only (use payroll-clearing-reconciliation). Read-only: produces a reconciliation workpaper, proposed corrections and a coverage sheet, and posts nothing."
---

# Payroll reconciliation

Four systems should agree about what payroll cost and where the money went: the **payroll
register**, the **general ledger**, the **bank**, and what was **remitted and filed** with the tax
authority. This ties them to each other — register to GL, net pay to bank, each liability rolled
forward, the filings to the books — and catches mispostings, unremitted liabilities and
register-to-GL gaps **before they become filing or audit problems**.

The GL side alone surfaces three things worth having: **manual adjustments to payroll accounts**,
usually the reason the register-to-GL tie breaks; **negative liability balances**, always wrong; and
**the liability roll-forward's anchors at both ends**, so the roll-forward has to land. And it holds
one honest limit: **the GL does not hold taxable wage bases**, so the wage-base check needs the
register and is never approximated.

**Works with or without Mosofin.** With Mosofin connected, it reads every payroll expense and
liability account, the balances at both period ends, every movement and manual adjustment, the
payroll journals, and net pay and remittance payments by payee. **There is no payroll register, no
taxable wage base, no bank statement and no filing on this surface** — the register is read only if
a payroll platform is also connected, and the rest is supplied by you and labelled as such.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Payroll data is personal.** Reconciles **at account and total level, never employee by
  employee.** Individual pay, deductions and garnishments do not appear in the workpaper; an item
  that concerns one person is referred to **by reference number**; **never persists any
  individual's payroll data.**
- **Never substitutes a gross-based check for the wage-base reconciliation.** Without the register,
  Step 5 is reported **NOT PERFORMED**, with what it would have shown.
- **Never reports a tie against a source that was not obtained.** Each of the four sources is named
  as read or supplied; recorded disbursements are not a bank statement. **Never defaults a wage base
  rule, a due date or a remittance status.**

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
| **B** | *Which entity? In a group, does one payroll service run several entities?* | Each entity's GL holds only its share; filings are per employer | **Never auto-pick.** Run per entity, against that entity's slice of the register. |
| **C** | *Which period — month, quarter or year?* | The filing and wage-base steps apply at quarter and year end | **Required.** |
| **D** | *The payroll register(s) for the period, including off-cycle runs.* | The other side of Steps 1, 4 and 5, and the only source of taxable wage bases | **Required.** Read if a payroll platform is connected. Otherwise those steps are partial, and **Step 5 is NOT PERFORMED.** |
| **E** | *The bank statement, or the payment records, for net pay.* | Recorded disbursements prove the bookkeeping; the statement proves the money left | **Required.** Without the statement, the tie is to recorded disbursements, and the output says so. |
| **F** | *Liability remittance records — what was paid to each authority and provider.* | The "remitted" line of every liability roll-forward | **Required for the liability reconciliation.** On the Mosofin path, payments are read; the authority's receipt is not. |
| **G** | *The remittance due date for each liability.* | The overdue flag is arithmetic given the dates | **Required for the overdue flag. Never default it** — without it the flag cannot be raised. |
| **H** | *The taxable wage base rules per tax — pre-tax deductions, caps, ceilings.* | Each tax is charged on its own base, not on gross | **Required for Step 5. Never default it.** |
| **I** | *Does a third-party provider remit the taxes?* | The entity remains liable if the provider fails to remit | **Required.** Confirming actual remittance is manual, from the authority. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **payroll platform** is also connected — the single most consequential
  connection here. If one is, the register and the wage bases are read, and Steps 1, 4 and 5 become
  complete rather than partial.
- Confirm which payroll accounts are in scope.
- Still ask for the bank statement (E), the due dates (G), the wage base rules (H), the provider
  arrangement (I) and any filing figures — none of them is on this surface.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Payroll register(s)** for the period, every run — gross, withholdings, employer costs, net, taxable wage bases | **Required** — without it, Step 5 is reported NOT PERFORMED | CSV, XLSX or PDF |
| Your books: **GL activity for every payroll expense and liability account**, plus balances at both period ends (a trial balance works) | Required | CSV or XLSX |
| **Bank statement**, or payment records, for net pay | Required — the output states which was used | PDF or CSV |
| **Liability remittance records** | Required for the liability reconciliation | PDF, CSV or XLSX |
| Entity name, country, base currency, fiscal calendar; the period; whether a provider remits | Required | Type it in the chat |
| **Remittance due dates** per liability; **taxable wage base rules** per tax | Required for the overdue flag and for Step 5 | Type it in the chat |
| **Tax filing figures** and wage statement totals | Recommended — needed for the quarter- and year-end tie (Step 4) | PDF, CSV or XLSX |
| **Prior period reconciliation** | Recommended — the items carried forward | PDF, CSV or XLSX |

**Read back before starting, then wait for a yes:**

> *Reconciling payroll for **Northbrook Trading** for **the quarter ended 30 September** — register,
> GL, bank and filings — with the GL read from **your Mosofin connection**, and **the register and
> the quarterly filing you uploaded**. Net pay tied to **the bank statement you supplied**. PAYE due
> **22nd monthly**, pension due **19th**; wage base **gross less salary-sacrifice pension, no cap**.
> Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the totals or opening and closing balances. Never repeat an individual's line
back. Flag anything unreadable, or covering the wrong period or entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check for a payroll platform, settle single- or multi-entity, check which read tools
are enabled, and read the company profile: legal name, base currency, country and **fiscal
calendar, which sets the quarter and year ends where Steps 4 and 5 apply**. On a later run, read the
stored preferences first and ask only what changed. On the upload path, go straight to Stage 3.

## Stage 3 — Read the GL side

Batch the independent reads — accounts, wages and employer cost expense, both period-end balances,
the general ledger on every payroll account, payments by payee, payroll journals — and check the
`mock` flag: [`references/method.md`](references/method.md) Step 0.

## Stage 4 — Tie the four sources

Register to GL with a bridge, **listing every manual adjustment to a payroll account separately**;
net pay to bank, **stating which side of "bank" was used**; each liability rolled forward and agreed
to the GL, flagging overdue, should-be-zero and **negative balances**; at quarter and year end, the
GL to the filings and wage statements — **the GL holds gross, not taxable, so say so**; then each
tax to its wage base, or **NOT PERFORMED**: [`references/method.md`](references/method.md) Steps
1–5. Check [`references/edge-cases.md`](references/edge-cases.md) for pre-tax deductions, caps,
off-cycle runs, third-party providers, capitalised labour and group payrolls.

## Stage 5 — Resolve exceptions and present the result

Classify and quantify every reconciling item and name the correction — adjusting entry (via
`payroll-journal-entry-builder`, as a **proposal**), remittance or filing amendment — **ordered by
consequence, not by amount**. Then the workpaper, its summary naming which sources were read or
supplied and whether Step 5 was performed, ending with a **Data sources** line:
[`references/method.md`](references/method.md) Steps 6–7. Offer the `.xlsx` file only on a yes.
Before presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been seen and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist the account map, the wage base rules
with effective dates, the due dates and cadence, the reconciliation set, known recurring items as
rules, the provider arrangement and the tolerance — keyed by datasource and entity name. **Never any
individual's payroll data, and never balances, wage figures or exceptions.**

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
