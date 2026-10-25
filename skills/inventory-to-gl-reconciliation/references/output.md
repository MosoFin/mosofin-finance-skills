<!-- inventory-to-gl-reconciliation · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **GL, subledger, and physical (where applicable) reconciled with explained variances**
- **Shrinkage quantified and trended**
- **Write-downs documented with policy basis and authority**
- **Cut-off items identified and corrected**
- **In-transit items tracked**
- **File naming consistent**
- **No silent absorption of variances into COGS without classification**
- **Inventory reserve roll-forward present**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Whether the subledger is a separate system is established and stated**, and where it is not, the
  GL-to-subledger leg is reported as **nil by construction** rather than as agreement
- **The date of the last physical count is stated in the header**, and its absence is reported as the
  headline finding
- **The physical count is recorded as `[manual]` with an owner**, and no ledger evidence is presented as
  testing existence
- **Every negative quantity is listed**, since all of them are errors
- **Cut-off testing covers both transactions dated near the boundary and entries posted after period end**
- **Consignment-in on the balance sheet is checked for explicitly**
- **Where the chart does not separate inventory categories, that structural limitation is reported**
- **Shrinkage is only called shrinkage where a count supports it**, and it is trended against inventory and
  revenue
- **The reserve roll-forward ties to the reserve account**, with the difference reported
- **Each variance classification states whether it was corroborated from data or requires fieldwork**
- **Variance investigation is not reported as complete after the data steps alone**
- In a multi-entity run, **stock held for another entity is reported against its owner**, in-transit stock is
  checked on both sides, **shrinkage is computed per entity and per location**, and **count coverage is
  reported by location**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no reconciliation rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No quantities, balances, variance amounts, shrinkage figures, count results or item costs are
  persisted** into a skill bundle; every persisted preference states the datasource and `display_name` it
  covers
- Nothing was written back to any system — no adjustment, write-down or cut-off correction posted
