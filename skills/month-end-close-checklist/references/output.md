<!-- month-end-close-checklist · output.md · read for: Stage 5 — check the workpaper against these standards before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every task has owner, due date, dependencies, status**
- **Critical-path tasks identified**
- **Materiality threshold applied consistently**
- **Variance investigation documented**
- **Final tie-out demonstrates books are reportable**
- **Lessons-learned captured for next cycle**
- **File naming consistent**
- **No silent skips of mandatory tasks**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**, and
  **its tasks remain on the checklist with owners, marked unverifiable**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The checklist was scoped from the chart of accounts**, and **every removal is reported with its
  evidence**, so a wrong removal is visible
- **Every task carries a Status Verifiable column and an Evidence column**, and **observed evidence is
  distinguished from reported status**
- **Any task marked Complete with no supporting evidence is flagged before the books lock**
- **No reconciliation task is reported as verified from the ledger**, since reconciliation compares to
  something outside it
- **The trial balance check is noted as true by construction**, not presented as proof the month is closed
- **Inter-period continuity was checked per balance sheet account**, and any break reported as a possible
  undocumented re-open
- **External dependencies are grouped separately** as the items nobody here can advance
- **Materiality was applied to a listed set of accounts above and below the threshold**, rebuilt from
  current balances
- **New accounts used this period are flagged** as a risk area
- **Close timing was measured rather than recalled** for the lessons-learned step
- In a multi-entity run, **per-entity close status is tracked as a dependency for Day 6**, scoping is per
  entity, intercompany reconciliation is treated as requiring both sides, and **the materiality basis is
  stated as group or entity**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no close is signed off on mock data**
- Every observed status traces to a tool result in this conversation; every reported status traces to its
  owner; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No balances, variances, statuses or close results are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted, no task marked complete, no books locked**
