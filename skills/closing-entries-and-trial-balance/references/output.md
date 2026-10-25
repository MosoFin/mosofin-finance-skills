<!-- closing-entries-and-trial-balance · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Pre-closing TB balances**
- **All temporary accounts close to zero**
- **Post-closing TB balances**
- **Net income per P&L = increase in RE from closing**
- Dividends / distributions closed correctly **per entity type**
- **OCI items routed to AOCI separately from net income to RE**
- Period lock assigned to a named person — Mosofin cannot lock a period, so it is never reported as done (Step 9)
- New year opens with the post-closing TB as its opening balance
- File naming consistent
- **No silent ignoring of imbalances or unposted adjustments**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The closed-state test (Step 0b) was run and its finding stated** before any entry was proposed —
  not closed, auto-closed, or already closed by an explicit entry
- **Accounts are classified as temporary or permanent on their type, never their name**, and every
  name / type mismatch is listed as an exception
- **The computed net income is cross-checked against the P&L** before closing
- Closing entries list **every account individually**, using the real names from the connected chart
- **The period lock is reported as a manual step with a named owner** — never as done
- Each entity closes separately; **no combined trial balance is produced before closing**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no closing entry rests on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No balances, net income or trial balances are persisted into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every closing entry is a proposal, and no period was locked
