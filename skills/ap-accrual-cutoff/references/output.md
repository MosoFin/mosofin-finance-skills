<!-- ap-accrual-cutoff · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every accrual line shows its source (GRN, recurring, subsequent invoice)
- Every accrual has a corresponding reversing entry for the next period
- The accrual amount's basis is documented
- Variance from the prior period is flagged where notable
- Tax handling is documented (accrued or not, per jurisdiction)
- File naming consistent
- **No double-counting: an item is GRNI, a subsequent invoice or a recurring accrual — only one**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- Every accrual candidate carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool
  used, and that tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no candidate is silently dropped
- **Receipt evidence is stated per GRNI line** — an open PO is never treated as received
  without evidence
- **PO-to-bill matches state whether they were linked or inferred**
- Account names in every proposed JE are the **real names from the connected chart of
  accounts**, not generic placeholders
- `mock` status is reported wherever it applies, and no proposed entry rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional
  term kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- Every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every JE is a proposal for a human to post
