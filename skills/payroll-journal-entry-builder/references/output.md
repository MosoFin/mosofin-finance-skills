<!-- payroll-journal-entry-builder · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every entry balances (debits = credits)**
- **Gross = net + employee withholdings; total expense = gross + employer costs**
- **Employer and employee contributions correctly separated**
- **Liabilities match amounts to be remitted** (feeds tax filings)
- **Department / cost-center allocations sum to total; capitalized labor routed correctly**
- **Period-end accrual booked and set to reverse where applicable**
- **Account numbers / names from the entity's COA only** — none invented
- **Clearing-account mechanics handled where used**
- **File naming consistent**

**Mosofin additions:**

- **Every entry is labelled a proposal**, and nothing is described as posted
- **No individual's payroll data appears anywhere in the output** — the journal is built from register
  totals by component
- The workspace was confirmed **by name** and the entity confirmed by `display_name` before the entry was
  built
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every account was confirmed to exist in the live chart**, and a missing account is a hard stop; where
  the chart could not be read, the placeholder fallback is stated
- **Every line of the entry was tied to the register's column totals**, and the employer / employee mixing
  error reported on any difference; the register's own gross-to-net identity was checked
- **The employer entry is kept separate from the employee entry**, and any shared-account limitation stated
- **Every register component maps to an account**, and unmapped components or unused accounts are flagged
- **The run was compared to prior runs** by component and per head, with material movements reported for
  explanation **before posting**
- **Whether the prior period's accrual reversed was verified**, so this run cannot double-count
- **Whether an accrual is required was determined from the pay calendar**, and any accrual includes employer
  costs
- **The allocation sums to the total** and is compared to the prior run
- **A third-party provider lump sum is booked by component**, never as a single expense
- In a multi-entity run, **one journal is produced per entity against its own chart**, cross-entity payments
  are raised as intercompany, and **the comparison runs per entity**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no entry is offered for posting on fixture-validated
  accounts**
- Every account traces to the live chart, every validation to a tool result, and every amount to the
  register; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data and no amounts are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted**
