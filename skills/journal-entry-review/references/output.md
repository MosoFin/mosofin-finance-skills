<!-- journal-entry-review · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Population profiled** — manual vs. system, by account / user / period
- **Risk criteria clearly defined and applied across the population**
- **Entries risk-scored and prioritized** — not all-or-nothing
- **High-priority entries analyzed with rationale and resolution**
- **Patterns and clusters identified, not just individual entries**
- **Management override and topside entries specifically considered**
- **Follow-up items classified** — legitimate / error / escalate
- **Control implications noted**
- **Objective documentation; anomalies flagged, not concluded as fraud**
- **File naming consistent**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; **every excluded entity is named as unscreened**,
  since JE testing is a required procedure
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The screen covered the entire population**, with the population size stated and completeness shown by
  the Step 1 tie-out to the period's ledger movement — "complete" only when the difference is nil
- **Every criterion carries its verdict**, and **criteria that could not run are listed in Sheet 8** with
  what they would have shown — **the four approval-based indicators named specifically**
- **The baseline was derived from prior periods**, not asserted, and "unusual" is defined against it
- **Whether topside entries are in the population is stated**
- **The scoring weights are stated**, and single-criterion flags are not presented as equivalent to
  multi-criterion ones
- **Patterns lead the summary**, including the reserves-versus-earnings test
- **Every flagged entry is presented as a question**, never as a conclusion about a person, and **the
  user-name caveat is stated wherever a user field is used**
- **Measurable control observations are quantified** — the proportion of entries with weak descriptions,
  the manual proportion, the concentration by user or account
- **Escalations follow fraud-investigation discipline** from the moment they are raised
- In a multi-entity run, **each entity is screened against its own baseline**, sensitive-account lists are
  per chart, and **flag rates are reported per entity as well as in total**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no anomaly is reported from mock data**
- Every flagged entry traces to a tool result in this conversation; the answer ends with a single **Data
  sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No flagged entries, risk scores, user names, explanations or anomalies are persisted** into a skill
  bundle — **the method is stored; the results never are**; every persisted preference states the datasource
  and `display_name` it covers
- Nothing was written back to any system — no entry corrected, reversed or reclassified
