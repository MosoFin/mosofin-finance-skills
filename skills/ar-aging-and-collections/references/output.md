<!-- ar-aging-and-collections · output.md · read for: Stage 5 — check the deliverable against these before presenting. Edit here, not in SKILL.md. -->

## Completion checks

- **Mosofin workspace and company file are confirmed before reads**, by name, with an explicit
  user yes
- **Every call carries the current workspace and company scope** — `data_source_id` on every
  call, including retries
- **Response provenance and `mock` status are checked** and reported
- **A/R Detail is the invoice population and is reconciled to Summary, or the missing tie-out
  is disclosed**
- **Connector-supplied, calculated, user-supplied, and unavailable fields are distinguished**
  in every output
- **Unsupported fields are requested only when material**
- **No data was changed and no reminder was sent**

**Mosofin additions:**

- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- Every task in Steps 1–5 carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool
  used, and that tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no task is silently dropped
- **No tool name was invented**; every one came from the Gate 2 catalog
- A customer balance report was never presented as an aging; any reconstructed aging is labeled
  as reconstructed and tied back
- Aging totals use **open balance**, not original amount
- Each currency is preserved separately; no unlabeled consolidated total
- DSO states its denominator; any proxy is labeled `Approximate DSO (total-income proxy)`
- Every draft is marked `REVIEW REQUIRED - NOT SENT` and contains no invented dispute, hold,
  promise, fee, suspension, or legal threat
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No customer contact details, balances, or draft correspondence are persisted into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
