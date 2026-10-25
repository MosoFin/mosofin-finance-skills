<!-- financial-statement-builder · output.md · read for: Stage 5 — check the package against these standards before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Balance Sheet balances** (Assets = Liabilities + Equity)
- **Net income consistent across IS, OCI, equity changes, cash flow**
- **Cash on BS = end-of-period cash on the CF statement**
- **Comparatives consistent with prior period filings or restated**
- **Classification rules applied consistently**
- **Currency and rounding declared and consistent**
- **Cross-statement tie-outs documented**
- **Framework-appropriate format and terminology**
- **File naming consistent**
- **No silent reclassifications between comparable periods**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**; the
  package states **whether it is consolidated or separate**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The balance test was proved on the statements as presented**, after reclassification — not on the
  platform's own report
- **All seven tie-outs are reported with their computed difference**, including zero, and **tie-out 6 is
  marked `[manual]`** rather than implied to have passed
- **Both periods were pulled on the same accounting method**, and the method is recorded on the TB sheet
- **The ledger's prior year was compared to the prior-year financials as issued**, and any difference — the
  signature of unposted audit adjustments — is reported before comparatives are built on it
- **Every TB account maps to exactly one statement line**, and mapping completeness was checked explicitly
- The **current / non-current split is supported**, with the source named for the current portion of debt
  and leases
- Where a by-function P&L was produced without function tracking, **it is stated as a reallocation**
- **AOCI balances without supporting analysis are reported as such**, and EPS and discontinued operations
  are marked `[manual]` with their source named
- In a multi-entity run, **consolidated statements are built from the consolidated TB**, never by adding
  entity packages together, and an unreadable group member is a stop condition
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported **on the face of every statement** wherever it applies
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- The footer carries the entity `display_name`, the source datasource, the currency, the rounding basis and
  the `mock` status, so provenance travels with the statements
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No balances, statement figures or trial balances are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no reclassification, adjustment or closing entry posted
