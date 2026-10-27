<!-- payroll-clearing-reconciliation · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every payroll account has GL balance, expected balance, and explained difference**
- **YTD figures verified against payroll register**
- **Bank tie-out: net pay for each payroll cycle; tax and benefit remittances per deposit period**
- **Stale balances flagged with age and proposed treatment**
- **Multi-jurisdiction breakdown if applicable**
- **File naming consistent**
- **Cleanup JEs proposed for permanent differences**
- **No silent absorption of differences**

**Mosofin additions:**

- **No individual's payroll data appears anywhere in the output** — reconciling items refer to people by
  reference, and garnishments are reported as totals and counts
- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**;
  **whether a payroll platform is connected is stated**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every balance is aged**, with the profile reported by band and **the never-clearing residual identified
  explicitly**
- **Each account's behaviour was tested against its remittance cadence**, and accounts that only grow or
  never clear are reported as findings
- **The basis of every expected balance is stated** — payroll register, or payroll journal proxy — and where
  the proxy was used, **what the comparison proves is stated**
- **The bank tie-out states whether it was to recorded disbursements or to the bank statement**
- **The YTD test was run with the opening balance** — register withholdings tied to remittances + closing
  − opening liability, or stated to prove only ledger arithmetic without the register
- **Stale balances carry ages by the stated convention (FIFO unless memos say otherwise), item counts and
  probable causes**, and **escheatment is flagged as a
  compliance obligation** rather than a write-off option
- **Unclaimed pay is not proposed for write-off to income**
- **Recurring small write-offs are reported as a process fault**, not as immaterial residuals
- **The payroll account list was proposed from the chart** and confirmed, with accounts showing payroll
  movement but absent from the list flagged
- In a multi-entity run, **ageing and reconciliation run per entity**, shared payroll payments are allocated
  on a stated basis, cross-entity payments are raised as intercompany, and **escheatment positions are not
  carried between entities**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no conclusion that a liability was remitted rests on
  mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data of any kind is persisted**, and no balances, ageings or reconciling items are
  stored; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no entry posted, no remittance made, no balance written off
