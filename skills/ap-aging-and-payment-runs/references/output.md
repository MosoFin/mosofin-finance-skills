<!-- ap-aging-and-payment-runs · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Aging buckets total to the A/P control balance** (note the figure for the tie-out)
- Every overdue bill is flagged with its days past due
- Every discount opportunity shows its deadline, amount, and implied return
- Proposed payment run totals ≤ stated cash available
- No bill appears twice (duplicates surfaced separately)
- Currency clearly identified per bill
- File naming consistent

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The aging states whether it is report-native or reconstructed**, and a reconstructed aging
  is tied to the A/P control balance with any gap explained
- A vendor balance report is never presented as an aging
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no bill and no task is silently dropped
- **Cash available was confirmed by the user, never inferred from a bank balance**
- Any derived due date is labelled as derived and listed in the exceptions sheet
- `mock` status is reported wherever it applies, and **no payment run rests on mock data**
- The payment run is labelled a **proposal**; no line implies a payment was made or scheduled
- **No vendor bank details appear in any output or stored preference**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional
  term kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- Every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system, and no payment was sent, scheduled, or released
