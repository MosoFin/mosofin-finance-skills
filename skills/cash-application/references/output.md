<!-- cash-application · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every payment is either applied, parked as credit, or flagged as unidentified**
- **Application logic is documented per payment (match type)**
- Short pays show the reason or **"unknown — needs follow-up"**
- **JE balances and reflects all sub-components (discount, fee, WHT, FX) separately**
- Customer credit balances surfaced
- File naming consistent
- **No silent absorption of short / over pays**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The output states which population was processed** — payments already recorded, or a supplied
  file of payments not yet entered
- **Every match records its hierarchy level (1–6)**, and every fuzzy match its similarity score and
  the alternatives considered
- **No fuzzy match below the threshold is auto-accepted**
- Matching uses the invoice **open balance**, never the original amount, and states the search
  window used
- Every short pay was checked against outstanding credit memos and against the invoice's own terms
  before its reason was assigned
- Every overpay was checked for a duplicate payment before a credit was proposed
- Every FX conversion states its rate and the rate's source
- Withholding tax receivables state whether a certificate has been received
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and no application or write-off rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No bank account numbers, payment-level data or remittance contents are persisted into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every application, credit and write-off is a proposal for
  a human to post
