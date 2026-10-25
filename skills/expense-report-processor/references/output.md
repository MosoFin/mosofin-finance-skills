<!-- expense-report-processor · output.md · read for: Stage 5 — check the workpaper against these standards before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every line has a GL account suggestion** (from the user's COA) **and a policy check** — or a
  "no policy provided" note
- **Currency normalization is documented** — FX rate, source, date
- **Exceptions categorized by severity**
- **Reimbursement calculation reconciles line-by-line**
- **Receipt status tracked per line**
- **All policy assumptions explicitly listed on the Summary tab**
- **GL posting balances to the penny** (verified via `journal-entry-builder`)
- **File naming consistent**: `[Employee or Batch]_ExpenseReport_[YYYY-MM].xlsx`
- **No invented rates, thresholds, or account numbers**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Coding is to real accounts from the connected COA**; placeholders appear only when the COA read is
  unavailable, and the degradation is stated
- **Every claim line was checked against transactions already posted**, and matches are reported as
  rejections with the matched transaction named
- **The match tolerances used** — date window and amount tolerance — **are stated**
- **The Corporate Card Clearing residual is reported with its ageing**, and the Employee Reimbursement
  Payable is reconciled to outstanding claims
- **Each coding suggestion carries its historical support**, and inconsistent history is flagged rather
  than resolved silently
- **Claimants with no employee record are flagged before coding**
- Where **no policy was supplied**, Step 2 is reported as **not performed** — never as passed
- Receipt status is reported **as per the report**, never as verified, since images are not on this surface
- In a multi-entity run, **the employing entity and the bearing entity are distinguished**, the duplicate
  check runs against the entity whose card paid, and cross-entity charges are raised as intercompany
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no duplicate check is reported as clean against mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No employee names, individual claims, amounts, card numbers, addresses or itineraries are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers, and
  stored rates carry effective dates
- Nothing was written back to any system — no claim approved, rejected, paid or posted
