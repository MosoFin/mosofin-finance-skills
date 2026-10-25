<!-- payroll-reconciliation · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Register ties to GL** (gross and employer cost), **with a documented bridge**
- **Net pay ties to bank disbursements**
- **Each liability rolled forward** (opening + accrued − remitted = closing) **and agreed to GL**
- **Overdue, anomalous, or negative liabilities flagged**
- **Quarter / year-end: GL, filings, and wage statements reconciled to each other**
- **Each tax reconciled to its correct taxable wage base** — pre-tax deductions, caps applied
- **Every exception classified, quantified, and assigned a correction**
- **Account references from the entity's COA**
- **File naming consistent**
- **No naive single-base comparison where multiple wage bases apply**

**Mosofin additions:**

- **No individual's payroll data appears anywhere in the output**
- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**;
  **whether a payroll platform is connected is stated**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Each of the four sources is identified as read or supplied**, and **no reconciliation is reported as
  tied against a source that was not obtained**
- **Step 5 is reported as NOT PERFORMED where the register is unavailable**, with what it would have shown
  — **never substituted by a gross-based check**
- **Manual adjustments to payroll accounts are listed separately** in the register-to-GL bridge
- **Negative liability balances are listed explicitly**, since all of them are errors
- **The overdue flag names the due date and its source**, and its consequence — penalties, interest,
  personal liability — is stated
- **The net pay tie states whether it was to recorded disbursements or to the bank statement**
- **Where a third-party provider remits, the entity's continuing liability is stated**, and confirmation of
  actual remittance is marked `[manual]`
- **Exceptions are ordered by consequence**, not by amount
- **A nil difference derived from common postings is identified as such**
- In a multi-entity run, **the register-to-GL tie runs against each entity's slice**, filings are reconciled
  per employer, negative-balance and overdue checks run per entity, and **mid-year inter-entity moves are
  flagged for cap effects**
- Every reconciliation carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source
  used, and its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no filing or wage statement rests on a mock-based
  tie**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data, balances, wage figures or exceptions are persisted** into a skill bundle;
  every persisted preference states the datasource and `display_name` it covers, **and wage base rules carry
  effective dates**
- Nothing was written back to any system — no correction posted, no liability remitted, no filing amended
