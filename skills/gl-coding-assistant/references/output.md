<!-- gl-coding-assistant · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every transaction has a Confidence rating**
- **Every "Needs Review" item has a reason**
- **Account numbers and names come from the user's COA only — never invented**
- **Tax codes only when jurisdiction + tax code list provided**
- **Reasoning is one sentence**
- **Output naming**: `[EntityName]_Coded_Transactions_[YYYY-MM-DD].xlsx`

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**; **the
  entity each transaction belongs to was confirmed before coding**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Coding is to real accounts from the connected chart**; a fallback is used only when the read is
  unavailable, and **which fallback is in use is stated**
- **Every Tier 1 match carries its evidence** — the account, the count and the recency — rather than
  asserting a prior mapping
- **Inconsistent history is reported as inconsistent**, not resolved by picking the commonest or the most
  recent
- **Frequency is never presented as correctness**, and a supplied policy overrides history with the conflict
  reported
- **Vendor-type gaps are stated as facts** — whether a matching account exists in this chart, and what the
  nearest is
- **Transfer detection names both legs** and the accounts they sit in
- **Related-party and personal flags are surfaced, never concluded**, and the basis for each is stated
- **The uncoded population is reported** — uncategorized and suspense balances with ages
- **Duplicate vendor records are flagged** where they split a history
- In a multi-entity run, **no Tier 1 match is carried across company files**, and vendors matching another
  group entity are raised as intercompany
- Every suggestion carries its verdict (`[auto]` / `[gated]` / `[manual]`) and its evidence, in the coverage
  sheet
- `mock` status is reported wherever it applies, and **history-based confidence is downgraded on mock data**
- Every suggestion traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No transaction lists, amounts or coding history are persisted** into a skill bundle, and **no personal
  or related-party flag against a named individual is ever stored**; every persisted preference states the
  datasource and `display_name` it covers
- Nothing was written back to any system — no transaction coded, recoded or posted
