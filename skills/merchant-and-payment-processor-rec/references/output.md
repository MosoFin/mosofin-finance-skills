<!-- merchant-and-payment-processor-rec · output.md · read for: Step 5 — before presenting results. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Gross-to-net decomposition is complete and tied**
- **Clearing balance roll-forward reconciles**
- **Payouts tied to bank deposits with explained variances**
- **Multi-currency entries show conversion methodology**
- **Tax handling explicit** — gross sales subject to output tax, fees with input tax if the jurisdiction
  allows
- **File naming consistent**
- **Per-transaction or aggregate approach declared**
- **No silent absorption of differences**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**;
  **whether the processor is connected or supplied by export is stated**
- The capability map was discovered **this run** via Gate 2, **for the processor as well as the accounting
  platform**
- **The net-revenue test was run**, and any sign that revenue is recorded net of fees is reported as a
  presentation finding with the estimated gross-up **and the output tax implication**
- **The clearing roll-forward ties to the clearing account**, with the difference reported including zero,
  and **the balance is aged**
- **Which balance definitions were compared is stated** — available, pending, reserve — so a definitional
  difference is not reported as an error
- **The payout tie-out states whether it was to recorded deposits or to the bank statement**, and the bank
  statement is recorded as `[manual]`
- **The charge-to-payout lag and the effective fee rate are trended**, so a pause or a rate drift is caught
  early
- **The posting approach in use is declared**, and the reconciliation is described at the level that
  approach supports
- **Every FX rate carries its source**, and the processor's own rate is identified as such rather than
  treated as a market rate
- In a multi-entity run, **the clearing roll-forward and the net-revenue test run per entity**, transactions
  are attributed by the stated rule, cross-entity payouts are raised as intercompany, and **output tax is
  attributed to the entity that made the supply**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported **on both sides**, and no reconciliation is presented as complete against mock
  data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No transaction data, balances, payout amounts, customer details or card information are persisted** —
  **cardholder data is never stored in any form**; every persisted preference states the datasource and
  `display_name` it covers
- Nothing was written back to any system — no entry posted, no payout initiated, no dispute actioned
