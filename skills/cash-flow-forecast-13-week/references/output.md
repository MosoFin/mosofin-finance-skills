<!-- cash-flow-forecast-13-week · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Direct method**: actual cash in / out by week, no accruals or non-cash items
- **Receipts timed to expected bank dates (using payment behavior, not just due dates)**
- Disbursements timed to actual clearing weeks
- **Weekly chain ties (closing = next opening)**
- **Lowest cash point and runway identified**
- Threshold / covenant headroom shown each week
- Sensitivities on collection timing and key levers
- Rolling forecast-vs-actual tracking
- Live formulas
- File naming consistent
- **No optimistic collection assumptions that ignore payment behavior**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **Collection timing is derived from the entity's own payment history where readable**, and each
  customer's days-to-pay is shown **with its sample size**; where it was assumed instead, that is
  stated
- **Opening cash names the accounts included and excludes restricted cash explicitly**
- Lumpy annual outflows were checked against the prior year's cash for anniversaries inside the
  horizon
- Every line carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and the periods
  it drew on, in the coverage sheet
- **`[manual]` lines — payroll, debt service, taxes, the floor, the facility — are listed
  prominently**, because those are the lines that breach floors
- The floor states whether it is a covenant or a management preference, and covenants state their
  exact cash definition
- **No lever list includes payroll or statutory remittances**
- In a multi-entity run, **the group total appears only where cash is confirmed pooled**, and every
  transfer is modelled explicitly
- `mock` status is reported wherever it applies, and **no liquidity decision rests on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No cash balances, forecasts, customer collection data or facility utilisation are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every draw, deferral and transfer is a proposal for a
  human
