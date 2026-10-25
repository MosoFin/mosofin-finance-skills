<!-- balance-sheet-reconciliations · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every account has its GL balance, supporting balance, and difference clearly shown
- Every reconciling item categorized by type (Timing / Permanent / Investigating)
- Every item has an age, an owner, and a target resolution date
- Roll-forward ties: opening + activity = closing
- Proposed JEs hand off to `journal-entry-builder`
- Prior period items carried forward and their status updated
- Materiality threshold applied explicitly
- File naming consistent
- **No silent absorption of differences into a "Plug" line**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **Every account carries a two-sided verdict** — GL side and support side, each with its tool
  and policy, in the coverage sheet
- **An account whose supporting side was never supplied is reported as not reconciled**, never as
  tied
- **No account is reconciled to another view of itself**; where that is all that is available, it
  is said plainly
- Every balance states its source: tool, parameters and timestamp for `[auto]`; document, date
  and supplier for `[manual]`
- Investigation steps are documented including the checks that found nothing
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no reconciliation is signed off on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No balances, reconciling-item detail, or workpapers are persisted into a skill bundle; every
  persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every correction is a proposal for a human to post
