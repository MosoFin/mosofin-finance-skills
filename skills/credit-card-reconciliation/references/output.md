<!-- credit-card-reconciliation · output.md · read for: what to deliver and how to name it; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Statement closing balance ties to GL ± reconciling items**
- **Every transaction has a GL account suggestion** (from the user's COA)
- **Receipt status documented per transaction**
- Exceptions categorized by severity
- Multi-currency transactions show original and converted amounts
- Tax handling per the user's jurisdiction
- File naming consistent
- **No silent absorption of reconciling differences**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The output states whether a statement was supplied**, and where it was not, is labelled a
  posted-charge review rather than a reconciliation
- **"A file is attached" and "a receipt was matched and verified" are reported as separate facts**
- **The duplicate, recurring-subscription and capitalisation-threshold tests were run** and their results
  stated, including when nil
- **Charges in suspense or uncategorised accounts are listed**
- **Recoverable tax claimed with no supporting receipt is flagged**
- The posting option actually in use (A or B) is identified from the ledger and stated
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no exception is raised against a named employee on
  mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No card numbers, individual cardholder spending, receipt images or transaction detail are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every entry is a proposal for a human to post
