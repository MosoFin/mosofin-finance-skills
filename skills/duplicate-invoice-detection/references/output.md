<!-- duplicate-invoice-detection · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every flagged cluster has a confidence level and a rule reason**
- **Side-by-side comparison shows why the records were matched**
- **Recovery action assigned for each flagged item**
- **Total exposure quantified by confidence**
- **Vendor-master merge candidates surfaced separately**
- File naming consistent
- **No silent suppression of legitimate same-amount recurring patterns**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**,
  with the unscanned-population consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **A rules-run sheet states which of the ten rules ran**, over how many records, and what each found —
  **including Rule 7 marked not run, with an owner**
- **The population scanned is stated against the population available**, and pagination was run to
  completion
- **Inactive vendor records and voided entries were included in the read**, then handled per their rules
- **The sensitivity setting is stated on the output**, so a clean result is interpretable
- **Fuzzy matches show their similarity score** and the alternatives considered
- **Unpaid duplicates are listed first** — they cost nothing to fix
- **Unapplied vendor credits are surfaced prominently** as money owed to the entity
- In a multi-entity run, **the cross-entity scan was run** with group entities excluded from the
  counterparty population
- Every rule carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no recovery request rests on mock data**
- Every figure traces to a tool result in this conversation; the answer ends with a single **Data sources**
  line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No vendor bank details, invoice-level data, or suspicion attached to a named person are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no record voided, no vendor merged, no recovery requested
