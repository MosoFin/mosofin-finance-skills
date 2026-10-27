<!-- credit-memo-and-refund-handler · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every credit memo references the original invoice** (or explicitly documents why none)
- **Tax reversal mirrors the original tax exactly** (or proportionally for partial)
- **The JE balances to the penny**
- **Application tracking shows the open balance at all times**
- **No silent absorption of timing or currency differences**
- File naming consistent

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **All four Step 2 validations were run against the live original** — existence, balance, period,
  currency — and every failure is listed, across the whole period rather than only the credit at hand
- **The tax reversal was checked against the original invoice's tax codes**, not merely computed
- **The reason is recorded and supplied**, never inferred from the document type
- **Vendor credits are posted back to the account the original cost was booked to**, read from the
  original bill
- **No second journal is proposed on application**
- **The unapplied credit register is produced in both directions**, with vendor credits listed first by
  value
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no refund is proposed on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No counterparty names with credit amounts, reasons or dispute detail are persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no credit was issued, no refund sent, no credit applied
