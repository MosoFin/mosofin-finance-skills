---
name: payroll-clearing-reconciliation
description: "Reconciles the payroll control accounts — payroll clearing, payroll suspense, and each withholding, employer-charge, benefit and garnishment liability — at month end: rolls each forward, compares it to its expected balance, ages every balance, tests whether it behaves like its remittance cadence, and finds the stale balances that never clear, including unclaimed pay that may be escheatable. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded GL detail, payroll registers and remittance records, treating the register as external unless a payroll platform is connected. Use when the user asks to reconcile payroll clearing or suspense, clear payroll liabilities, or why payroll clearing is not zero. Do not use for the payroll journal itself (use payroll-journal-entry-builder) or a full register-to-GL and bank tie-out (use payroll-reconciliation). Read-only: produces a reconciliation workpaper, proposed cleanup entries and a coverage sheet, and posts nothing."
---

# Payroll clearing reconciliation

When payroll runs, the business owes several parties at once — the staff, the tax authority, the
pension provider, sometimes a court — and each obligation sits in its own **payroll control
account** until it is paid. This checks that every one of them was paid: it rolls each account
forward, compares it to the balance it should carry, and explains the difference.

The real findings are usually **stale balances**: a clearing account that never returns to nil, or a
withholding account that only grows. The **never-clearing residual** often hides genuine obligations
— unclaimed pay, garnishments awaiting direction, disputed final settlements — and **some of it is
escheatable**, a legal obligation with penalties, not housekeeping.

**Works with or without Mosofin.** With Mosofin connected, it reads every payroll account, its
balances at both period ends, every movement and its age, remittances out by payee and date, the
payroll journals and headcount. **There is no payroll register, no benefit provider statement, no
court order and no bank statement on this surface** — the register is read only if a payroll
platform is also connected, and the remittance cadence is always yours to state. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Payroll data is personal.** Works at account level — **reconcile the balance, not the people.**
  **Never itemises individual garnishments, pay or deductions**: reports counts and totals; an item
  that concerns one employee is referred to **by reference number, not by name**; **never persists
  any individual's payroll detail.**
- **Never writes off what is owed to a person.** Unclaimed pay is not proposed for write-off to
  income; escheatment is flagged as a compliance obligation. **Never defaults a remittance cadence,
  a write-off or an escheatment treatment.**
- **A nil balance is not a reconciled account.** States the basis of every expected balance —
  register, or payroll journal proxy — and whether the bank tie-out was to recorded disbursements or
  to the bank statement.

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
| **B** | *Which entity, and which payroll accounts — clearing, suspense, each withholding and employer liability?* | One reconciliation per account; the clearing account is per entity | On the Mosofin path, **read the chart and present the payroll accounts found** for the user to confirm. Never auto-pick an entity. |
| **C** | *Which period is being reconciled?* | Sets every read and every roll-forward | **Required.** |
| **D** | *The remittance cadence for each liability — monthly, semi-weekly, quarterly?* | The expected-balance pattern depends on it entirely | **Required. Never default it** — without it the behaviour test has no benchmark. |
| **E** | *The payroll register(s) for the period.* | The "accrued" half of each roll-forward | **Required.** Read if a payroll platform is connected; **otherwise ask the user to upload it**. Only if they cannot, the payroll journal's posting is used as a proxy, **stated as one** — and the comparison then proves only that the account moved as the journals say. |
| **F** | *The bank statement for the period.* | Tying to the statement proves the money left; tying to recorded disbursements proves the bookkeeping | The tie-out is to recorded disbursements, and the output says so. |
| **G** | *Your materiality threshold for write-offs, and who approves one.* | Separates a small residual from one that needs correction | **Never default a write-off.** |
| **H** | *The tax authority, pension or benefit provider statement of account, if you will want any balance cleared.* | An unexplained residual on a withholding or contribution account is usually a remittance to make or a refund to claim, not a write-off | Recommended; **required before any write-off** on those accounts. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **payroll platform** is also connected. If one is, the register — the
  accrual half, the YTD figures, the by-component detail — is read. **If none is, say so**, and say
  which steps therefore rely on supplied data.
- Propose the payroll account list from the chart, and **confirm it with the user**.
- Remittances are read from payments; the **authority's acknowledgement is not**. Still ask for the
  cadences (D), the register (E) if no payroll platform is connected, the bank statement (F) and the
  statements of account (H).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **GL detail for each payroll account** — clearing, suspense, every liability — for the period and the **prior twelve months**, plus balances at this and the prior period end (a trial balance works) | **Required** — the prior periods give the ageing and the behaviour test their pattern | CSV or XLSX |
| **Payroll register(s)** for the period | **Required** — without it, the payroll journal posting is the stated proxy | CSV, XLSX or PDF |
| **Remittance / payment records** — payee, date, amount | **Required** | CSV or XLSX |
| Entity name, country or region, base currency; the period; the **account list**; the **remittance cadence per liability** | Required | Type it in the chat |
| **Bank statement** for the period | Recommended — without it, the tie-out is to recorded disbursements only, and the output says so | PDF or CSV |
| **Benefit provider statements**; **prior period reconciliation** | Recommended — provider timing; the items carried forward | PDF, CSV or XLSX |
| **Materiality threshold** for write-offs | Recommended | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Reconciling the payroll control accounts of **Northbrook Trading** for **September** — payroll
> clearing, PAYE, pension and benefits payable — with the books read from **your Mosofin
> connection**. No payroll platform is connected, so the accrual side uses **the payroll journal
> postings, stated as a proxy**. PAYE remitted **monthly on the 22nd**, pension **monthly**, benefits
> invoiced **quarterly**. No bank statement, so the tie-out is to **recorded disbursements**. Shall I
> go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the opening and closing balances. Never repeat an individual's line back.
Flag anything unreadable, or covering the wrong period or entity, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check for a payroll platform, settle single- or multi-entity — **the clearing account
is per entity** — check which read tools are enabled, and read the company profile: legal name,
base currency, fiscal calendar and **country or region, which drives which liability accounts
exist**. On a later run, read the stored preferences first and ask only what changed. On the upload
path, go straight to Stage 3.

## Stage 3 — Read the books, age every balance, settle the account list

Batch the reads — accounts, both period-end balances, the general ledger on each payroll account,
payments out, payroll journals — across **several prior periods**, and check the `mock` flag. Then,
**before anything else**, age every balance by band, test each account's behaviour against its
cadence, and identify **the never-clearing residual**: the trough after each remittance over twelve
cycles, less what the cadence carries — or the lowest running balance of a clearing account. Then confirm the account list, flagging accounts with payroll movement that are not on it:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Roll forward, compare, itemise and investigate

For each account: expected closing = opening + accrued − remitted, **with its basis stated**; the
difference to the GL reported for every account, including zero; reconciling items classified from
the movement pattern, then confirmed; the bank tie-out — net pay per cycle, remittances per deposit period; the YTD test, with the opening
balance and against the register; and every clearing balance over **60 days**, and every liability
amount older than one remittance cycle plus its lag, investigated with its age by the stated
convention, item count and probable cause:
[`references/method.md`](references/method.md) Steps 2–7. Check
[`references/edge-cases.md`](references/edge-cases.md) for garnishments, severance, benefits in
arrears, direct deposit reversals, a mid-year system change and group payrolls.

## Stage 5 — Propose cleanup entries and present the result

Construct reclasses, true-ups and **small immaterial** write-offs per policy as **proposals** for
`journal-entry-builder`; timing differences are documented, not adjusted. **A small write-off that
recurs every period is a process fault.** Then the workpaper — one tab per account, the master
summary, the bank tie-out, stale balances and the coverage sheet — ending with a **Data sources**
line: [`references/method.md`](references/method.md) Steps 8–9. Offer the `.xlsx` file only on a
yes. Before presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been seen and approved, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 10. Persist the account list, the cadences, the
expected-balance patterns, the payroll calendar, the tolerance, the escheatment position by
reference, known recurring items as rules, and the payees — keyed by datasource and entity name.
**Never any individual's payroll data — this is absolute — and never balances, ageings or
reconciling items.**

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
