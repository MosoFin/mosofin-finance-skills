<!-- budget-vs-actual-analysis · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every variance computed ($ and %) with **correct F/U classification by line type**
- Materiality filter applied (thresholds from the user)
- **Material variances decomposed into drivers, not just restated**
- Timing vs. permanent distinguished
- Full-year implications assessed for permanent variances
- Commentary is concise and driver-based
- YoY context included where available
- FX and one-time items isolated
- File naming consistent
- **No meaningless % on zero-budget lines; no assumed materiality thresholds**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The budget version being compared to is named on the face of the report**
- **Prior-year actuals are never presented as a budget**
- Accounts present in one side and not the other are listed **before** variances are computed
- Any account mapping between budget lines and actual accounts is **shown, not applied silently**
- Every variance carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- **Every commentary line records whether its cause was evidenced in the ledger, supplied by a
  person, or is still to be confirmed** — and no cause is invented
- `mock` status is reported wherever it applies, and no commentary presented to management rests on
  mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No variance figures, commentary or outlook are persisted into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every revision and reclassification is a proposal for a
  human
