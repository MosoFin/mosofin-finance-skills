<!-- cash-flow-forecast-13-week · method.md · read for: Stages 3–6 — every Step of the forecast (0–9), and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Set up the weekly grid
- Step 2 — Forecast cash receipts (cash in)
- Step 3 — Forecast cash disbursements (cash out)
- Step 4 — Compute the weekly cash position
- Step 5 — Flag liquidity risks
- Step 6 — Sensitivities and levers
- Step 7 — Reconcile to actuals (rolling discipline)
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence — and in a cash forecast an omitted outflow is not a presentational gap, it is a
forecast that will be wrong in the direction that hurts.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the cash
balances, the two agings, the payment history and the recurring spend do not depend on each other.
Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — identify the cash and bank accounts, and any restricted ones — usually
  **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **opening cash by account** — usually **[auto]**
- *`get_aged_receivables`* — open invoices with due dates — usually **[auto]**
- *`get_aged_payables`* — open bills with due dates — usually **[auto]**
- *`search_invoices`* / *`read_invoice`* — invoice dates and terms, for the days-to-pay derivation
  — usually **[auto]**
- *`search_payments`* — **when invoices were actually paid**, the other half of that derivation —
  usually **[auto]**
- *`search_bills`* / *`search_bill_payments`* — bill dates and when they were actually paid, giving
  the entity's own payment behaviour — usually **[auto]**
- *`get_vendor_expenses`* over several months — the **recurring disbursement** pattern — usually
  **[auto]**
- *`get_general_ledger`* on the cash accounts — **actual weekly cash movement**, for the tracker and
  for the payroll rhythm — usually **[auto]**
- *`get_cash_flow`* — historical cash generation as a sanity check — usually **[auto]**
- *`search_customers`* / *`search_vendors`* — counterparty names for the detail sheets — usually
  **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it **must never drive a liquidity
decision**. A forecast on fixtures can look perfectly healthy while a real business misses payroll.

## Step 1 — Set up the weekly grid

**Columns = weeks (Week 1 through Week 13, with dates). Rows = cash flow categories. Direct method:
actual cash movements, not accruals or non-cash items.**

**Establish each week's start and end dates and the opening cash balance for Week 1.** **[auto]** for
the opening balance; **[gated]** for which accounts count — **restricted cash is excluded**, and a
deposit account you cannot access this week is not liquidity.

Use the entity's time zone when a week boundary falls near a payment date.

## Step 2 — Forecast cash receipts (cash in)

**Collections from AR (the biggest forecasting judgment)** — and the one this workspace supports
best:

- **Take open invoices with due dates** — **[auto]** (*`get_aged_receivables`*, *`search_invoices`*)
- **Apply expected collection timing based on customer payment behavior — not just due dates,
  because customers pay late** — **[auto]** to derive, **[gated]** to confirm
- **Use historical days-to-pay per customer or per segment** — **[auto]**: for each customer, compare
  invoice dates against the dates their payments were received (*`search_invoices`* against
  *`search_payments`*) over the last several months, and compute the average and the spread. Show
  the sample size; a days-to-pay from two invoices is not a pattern
- **For example: a customer who pays on average 15 days late → forecast collection 15 days after the
  due date** — with the derived figure, this stops being an example and becomes the method
- **Probability-weight uncertain collections** — **[gated]**; disputed and at-risk invoices are
  `[manual]` to identify

**Other receipts** — mostly **[manual]**, since they are future events:

- **New sales expected to close and be paid within the window**
- **Interest income** — **[auto]** as a historical run-rate
- **Tax refunds**
- **Asset sale proceeds**
- **Financing draws (if planned)**
- **Other one-time inflows**

**Place each receipt in the week it's expected to hit the bank (cash basis, not invoice date).**

## Step 3 — Forecast cash disbursements (cash out)

**Payroll (usually the most certain and critical)** — **[manual]** for forward amounts,
**[auto]** for the historical rhythm and magnitude (*`get_general_ledger`* on payroll accounts):

- **Net pay on each pay date**
- **Payroll taxes on their remittance dates** — a separate, later outflow, and easy to omit
- **Benefits on their dates**
- **Place in the exact weeks they clear**

**AP / vendor payments** — **[auto]** for the population, **[manual]** for the plan:

- **Open bills by planned payment date** (per `ap-aging-and-payment-runs`)
- **Prioritized payment runs**
- **Place in the week payment will be made (considering payment method clearing time)**

**Recurring / fixed disbursements** — **[auto]** to detect the pattern from history
(*`get_vendor_expenses`*, *`search_bills`* across months), **[manual]** to confirm amounts change:

- **Rent / lease payments**
- **Debt service (principal + interest) on scheduled dates** — **[manual]** for the schedule
- **Insurance**
- **Software subscriptions**
- **Utilities**

**Periodic / lumpy disbursements** — **[manual]**, and the ones most likely to breach a floor:

- **Tax payments (income, sales / VAT, payroll) on their due dates**
- **Annual / quarterly payments**
- **Capex**
- **Distributions / dividends**

**Place each in the exact week of expected cash outflow.**

**[auto]** contribution worth running: scan the prior twelve months for **large one-off outflows**
(*`get_general_ledger`* on the cash accounts) and check whether an anniversary of each falls inside
the horizon. Annual insurance, tax instalments and licence renewals are the classic forgotten items,
and they are visible in last year's cash.

## Step 4 — Compute the weekly cash position

For each week — **[auto]** arithmetic:

```
Opening cash (= prior week's closing)
+ Total receipts
− Total disbursements
= Net cash flow for the week
= Closing cash
```

**The closing cash of one week is the opening of the next. Run the chain across all 13 weeks.**

## Step 5 — Flag liquidity risks

Against the minimum cash threshold / covenant — **[auto]** to compute once the floor is supplied:

- **Weeks where closing cash < minimum threshold** → **red flag**
- **Weeks where closing cash goes negative** → **critical (insolvency risk)**
- **The lowest projected cash point (and which week)** — **the binding constraint**, and the single
  most important number in the whole output
- **Cash runway**: if cash is declining, **how many weeks until it hits zero / the floor**

**If a revolver or facility is available, show the draw needed to stay above the floor and the
resulting facility utilization.** **[manual]** for the facility's terms and availability.

State plainly whether the floor came from a covenant or from management preference — they carry
very different consequences when breached.

## Step 6 — Sensitivities and levers

Show how the forecast responds to — **[auto]** arithmetic:

- **Collections slipping** (e.g. AR comes in one week later than expected) — **often the biggest
  risk**, and with derived days-to-pay you can slip by the *observed spread* rather than an
  arbitrary week
- **A large receipt failing to materialize** — **[auto]** to identify which single receipt matters
  most, by testing each of the largest against the floor
- **Deferring discretionary disbursements** — which payments could slip if cash is tight
- **Accelerating collections** — early-pay discounts offered to customers

**Identify the controllable levers to manage through a tight week.** Which payments are genuinely
deferrable is **[manual]** — see the payroll edge case.

## Step 7 — Reconcile to actuals (rolling discipline)

Each week, compare the prior forecast to actual cash flows — **[auto]** for the actuals
(*`get_general_ledger`* on the cash accounts, *`search_payments`*, *`search_bill_payments`*):

- **Forecast vs. actual receipts (collection accuracy)**
- **Forecast vs. actual disbursements**
- **Variance explanation**
- **Roll the forecast forward one week** (Week 1 drops off, a new Week 13 is added)

**This rolling discipline sharpens collection-timing assumptions over time.** In a connected
workspace it does so mechanically: each week's actual receipts feed straight back into the
days-to-pay derivation, so the forecast improves without anyone maintaining a spreadsheet of
assumptions.

## Step 8 — Output

Deliver an `.xlsx` cash forecast workbook.

**Sheet 1: 13-Week Cash Forecast**

| Category | Wk 1 | Wk 2 | ... | Wk 13 | Total |

- Opening cash
- Receipts (by category)
- Total receipts
- Disbursements (by category)
- Total disbursements
- Net cash flow
- Closing cash
- Minimum threshold
- Headroom / (shortfall)

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one
and why; **whether cash is pooled**; whether any figure rests on `mock` data.

**Sheet 2: AR Collection Detail**

| Customer | Invoice | Amount | Due Date | Expected Collection Week | Confidence |

**Add:** the customer's **derived days-to-pay** and the **sample size** it came from, so the
expected week is auditable rather than asserted.

**Sheet 3: AP / Disbursement Detail**

| Vendor / Item | Amount | Due Date | Planned Payment Week | Priority |

**Sheet 4: Liquidity Alerts**

Weeks below threshold; lowest cash point; runway; facility draws needed.

**Sheet 5: Sensitivities**

Collections-slip, missed-receipt, and lever scenarios.

**Sheet 6: Forecast vs. Actual Tracker**

Rolling accuracy of prior weeks.

**Sheet 7: Coverage — NEW, Mosofin-specific**

| Line or assumption | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Sample / periods used | Policy | `mock` | Gap — what could not be evidenced and who supplied it |

The rows for payroll, debt service, tax dates, the floor and the facility will read `manual`. **Those
are the lines that breach floors**, so their gaps must be visible, not buried.

**Build with live formulas so the chain recalculates as inputs change.** This matters more here than
almost anywhere: the forecast is used interactively in a meeting, with people asking "what if that
receipt slips a week?"

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `13Week_Cash_Forecast_[YYYY-MM-DD].xlsx`

In a multi-entity run: `13Week_Cash_Forecast_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus a group
file **only where cash is pooled**. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

This forecast rolls **weekly**, so the evolution step pays back faster here than in any other skill
in the pack.

On an explicit yes, persist the **decisions**:

- **The recurring schedule**: rent, debt service, insurance, subscriptions, tax instalment dates —
  with their amounts, dates and frequency. The single biggest time saving on every subsequent run
- **The payroll calendar**: pay dates, the tax remittance lag, and benefit payment dates
- **The minimum cash threshold**, whether it is a covenant or a management floor, and **the
  covenant's exact definition of cash**
- **The facility terms**: limit, borrowing-base mechanics, clean-down requirements, interest
- **Which accounts count as available cash** and which are restricted
- **Which disbursements are deferrable** and in what order — the lever list, agreed once when calm
  rather than improvised when tight
- **The days-to-pay derivation method** — the lookback window and the segmentation. **Not the
  derived values**: those are re-derived every week, which is the entire point
- The horizon, if not 13 weeks
- The replay recipe: the exact sequence of reads that produced this forecast

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist cash balances, the forecast itself, customer-level collection data, or facility
utilisation.** A distressed entity's cash position is highly sensitive, and a stale one is
misleading. Persist the *schedule, the thresholds and the method*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — floor $250k (covenant, tested weekly, cash net of restricted); payroll 15th and
last day; days-to-pay from trailing 6 months by customer" — not "floor $250k". Entities have
different covenants and different payroll calendars, and an unlabelled floor applied to the wrong
company file produces a false alarm or, worse, a missed one. Record the chosen **scenario** (single
vs multi, whether pooled, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and a cash balance is emphatically state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that
is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One grid, one floor, one runway.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every receipt and disbursement carrying that entity's `display_name`. Then:

- **Consolidate only if cash is genuinely pooled.** This is the decisive question, asked at Gate 1.
  Where entities hold separate accounts and cannot move money freely, **a group total is a fiction**:
  one entity can breach its floor while the group looks comfortable. Present per-entity forecasts
  first, always, and the group total only with an explicit statement that funds are transferable.
- **Where cash can move, model the transfer explicitly** — as an intercompany movement in a named
  week, out of one entity and into another, not as a silent netting. It has tax and legal
  consequences and someone must actually do it.
- **Each entity has its own floor and its own covenant.** Test each separately. A group headroom
  figure hides a component breach, and covenants are tested at the entity that signed them.
- **Intercompany payments between entities in scope are both an outflow and an inflow** in the same
  week. Include both legs or one entity's forecast is wrong.
- **Payroll is per entity.** It cannot be met from a sibling's account without a real transfer.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each line's verdict per
company file.

---
