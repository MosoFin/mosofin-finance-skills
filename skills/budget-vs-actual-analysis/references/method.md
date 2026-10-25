<!-- budget-vs-actual-analysis · method.md · read for: Stages 3–6 — Steps 0–10: reading both sides, alignment, variances, F/U, materiality, drivers, timing, full-year impact, commentary, the workbook, saving; and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Align actuals and budget
- Step 2 — Compute variances
- Step 3 — Classify favorable / unfavorable
- Step 4 — Apply materiality filter
- Step 5 — Decompose variances into drivers
- Step 6 — Distinguish timing from permanent variances
- Step 7 — Roll up and assess full-year impact
- Step 8 — Draft commentary
- Step 9 — Output
- Step 10 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*,
not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the actuals,
the budget, the prior year and the driver data do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_profit_and_loss`* with a **monthly** breakdown for the current year — the actuals — usually
  **[auto]**
- *`get_profit_and_loss`* for the **prior year**, same granularity — the YoY column — usually
  **[auto]**
- *`search_budgets`* — **the budget itself**, by account and period — usually **[auto]**. Read the
  *list* first to see which budgets exist before pulling detail
- *`search_accounts`* — the chart of accounts and the reporting hierarchy — usually **[auto]**
- *`search_classes`* / *`search_departments`* — the groupings management reads by — usually
  **[auto]**
- *`get_general_ledger`* — the transactions behind any material variance, for decomposition and
  one-off detection — usually **[auto]**
- *`search_journal_entries`* — accrual true-ups and reclassifications that distort a month —
  usually **[auto]**
- *`get_customer_sales`* / *`search_invoices`* / *`search_items`* — units, prices and mix for
  revenue decomposition — usually **[auto]**
- *`get_vendor_expenses`* — spend by supplier behind a cost variance — usually **[auto]**
- *`get_company_info`* — fiscal calendar and base currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the report's structure
but **cannot support commentary presented to management**, who will act on it.

## Step 1 — Align actuals and budget

Before any subtraction, make sure you are subtracting like from like. Most bad variance reports
fail here, not in the arithmetic.

Ensure both are on the same basis — **[auto]** to test each of these:

- **Same chart of accounts / line structure** — compare the account sets in the budget and the
  actuals (*`search_budgets`*, *`search_accounts`*) and **list any account present in one and not
  the other**. A budget line with no matching actual account produces a 100% favourable variance
  that means nothing
- **Same period definition** — confirm the budget's periods align to the fiscal calendar
- **Same currency**
- **Same accounting treatment** — if the budget was on a simplified basis, reconcile. **[gated]**:
  a budget built on cash assumptions compared to accrual actuals will show timing noise on every
  line

**Map actual accounts to budget lines where they differ**, and **show the mapping** rather than
applying it silently — a mapping is a judgment that changes the answer.

## Step 2 — Compute variances

For each line, at each level (month, QTD, YTD) — **[auto]**:

```
Variance ($) = Actual − Budget
Variance (%) = (Actual − Budget) / |Budget|   (handle zero-budget lines)
```

The absolute value in the denominator matters: without it, a negative budget flips the sign of the
percentage and reverses the story. **Zero-budget lines** are handled in the edge cases — show the
dollar variance and flag "no budget" rather than dividing by zero.

## Step 3 — Classify favorable / unfavorable

The sign of "favorable" depends on the line type — **[auto]** once each line's type is known from
the chart of accounts:

| Line type | Actual > Budget means |
|-----------|----------------------|
| Revenue | **Favorable** |
| Other income | **Favorable** |
| COGS / expenses | **Unfavorable** (spent more) |
| Cost ratios (e.g., COGS %) | **Unfavorable** if higher |
| Net income / profit | **Favorable** |
| Margins (%) | **Favorable** if higher |

**Always label F/U explicitly so a "+$50K" on an expense line isn't misread as good.** This is the
single most common way a variance report misleads its reader, and it costs one column to prevent.

Take each line's type from the connected chart of accounts (*`search_accounts`*, **[auto]**) rather
than inferring it from the account's name — a "Recovery" or "Discount" account can sit on either
side.

## Step 4 — Apply materiality filter

Not every variance needs commentary; a report that explains everything gets read for nothing.

Apply the threshold:

- **Variances above the $ threshold AND/OR the % threshold → require explanation**
- **Below threshold → noted but not explained**

**Use both an absolute and a relative threshold** (a $5K variance on a $10K line is 50% and worth
explaining; a $5K variance on a $5M line is noise). **The user sets thresholds; if not provided,
ask — don't assume.**

**[auto]** to apply once set; **[manual]** to set. If the user declines to set thresholds, say so
and explain everything above zero rather than picking a figure.

## Step 5 — Decompose variances into drivers

**For material variances, break down the cause rather than just stating the gap.** This is the step
that separates a variance report from a subtraction.

**Revenue variance decomposition** — **[gated]**: the arithmetic is **[auto]**, and the actual
units, prices and mix are readable where items are tracked (*`search_invoices`*, *`search_items`*,
*`get_customer_sales`*); the **budgeted** units and prices come from the budget's own detail or
from the user:

```
Total revenue variance = Volume variance + Price variance + Mix variance + FX variance

Volume variance = (Actual units − Budget units) × Budget price
Price variance = (Actual price − Budget price) × Actual units
Mix variance = effect of selling a different product mix than budgeted
FX variance = effect of currency movement vs. budgeted rates
```

**Cost variance decomposition**:

```
For variable costs:
Volume-driven = (Actual volume − Budget volume) × Budget unit cost
Rate/efficiency = (Actual unit cost − Budget unit cost) × Actual volume

For personnel:
Headcount variance = (Actual heads − Budget heads) × Budget avg cost
Rate variance = (Actual avg cost − Budget avg cost) × Actual heads
Timing variance = hires earlier/later than budgeted
```

**[gated]** for personnel: actual headcount is often readable (*`search_employees`*), actual
average cost usually is not without a payroll connection.

**Spend variance** (discretionary):

- **One-time vs. recurring** — **[gated]**: a single large transaction in the ledger
  (*`get_general_ledger`*) is strong evidence of a one-off, but whether it recurs is a judgment
- **Timing (spend shifted between periods) vs. permanent (genuinely more / less)**

**Decomposition turns "marketing was $80K over" into "marketing was $80K over: $50K from pulling
forward the Q3 campaign (timing, will reverse), $30K from higher-than-planned CAC (permanent, needs
attention)."** The first version starts an argument; the second starts a decision.

## Step 6 — Distinguish timing from permanent variances

A critical FP&A distinction:

- **Timing variances**: the spend or revenue **will** happen, just in a different period.
  Self-correcting over the year.
- **Permanent variances**: a genuine departure from plan. Affects the full-year outlook.

**Flag which is which. Timing variances shouldn't trigger the same concern as permanent ones, but
cumulative timing variances can mask trends.**

**[gated]**: the ledger gives strong signals — a bill dated in one month for a service in another,
an accrual reversing, a deal invoiced a few days after period end (*`search_bills`*,
*`search_invoices`*, *`search_journal_entries`*) — but the classification is a judgment the user
confirms. **[auto]** to support it: check the *following* period's actuals where they exist, since
a timing variance that has already reversed is proven, not asserted.

## Step 7 — Roll up and assess full-year impact

For each material **permanent** variance, assess the full-year implication — **[gated]**:

- **Will this variance persist?** → update the full-year outlook
- **Is a re-forecast warranted?** → raise it as a re-forecasting task
- **Does it threaten annual targets?** → escalate

**[auto]** to compute the arithmetic of extrapolation — the run-rate implication of a monthly
permanent variance across the remaining months — but the *persistence* judgment is the user's, and
a mechanical extrapolation presented as an outlook is a forecast nobody agreed to.

## Step 8 — Draft commentary

For each material variance, write concise commentary:

- **The variance ($ and %, F/U)**
- **The driver(s)**
- **Timing vs. permanent**
- **Full-year implication**
- **Action (if any)**

Example: *"G&A was $42K (12%) unfavorable to budget. Driven by $35K of legal fees for the [matter]
(one-time, not recurring) and $7K higher software costs from the [tool] renewal at a higher tier
(permanent; full-year impact ~$84K). No action on legal; software tier under review."*

**[gated]**: the figures, the accounts and the transactions are **[auto]**; **why** a cost was
incurred, and what will be done about it, come from the business. **Never invent a cause.** If the
ledger shows a large payment to a law firm, say that — do not narrate a lawsuit nobody mentioned.
Where the driver is unknown, write the variance, name the transactions behind it, and mark the
cause as **to be confirmed** with an owner. An honest open item beats a plausible fiction, because
this commentary goes to management verbatim.

## Step 9 — Output

Deliver an `.xlsx` variance report.

**Sheet 1: Variance Summary (P&L)**

| Line | Actual | Budget | Variance $ | Variance % | F/U | Prior Year | YoY % | Commentary Required Y/N |

For **Month, QTD, and YTD** columns.

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one
and why; **which budget version this compares to, by name**; the thresholds applied; whether any
figure rests on `mock` data.

**Sheet 2: Variance Commentary**

| Line | Variance $ | F/U | Driver Decomposition | Timing or Permanent | Full-Year Impact | Action | Owner |

**Sheet 3: Driver Decomposition Detail**

The volume / price / mix / rate breakdowns for material lines.

**Sheet 4: Full-Year Outlook**

Original budget vs. revised outlook based on permanent variances.

**Sheet 5: Waterfall Data**

Budget → Actual bridge by driver, for visualization. A **waterfall** shows how you got from one
number to the other in steps, so the reader sees the composition rather than just the gap.

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Line or variance | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Cause confirmed? | Gap — what could not be evidenced and who owns it |

The **"cause confirmed?"** column is the one that matters most in this skill: it separates a
variance whose driver was evidenced in the ledger from one where the explanation came from a
person — and from one still awaiting an answer.

In a multi-entity run this sheet is **per entity**.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `BvA_Analysis_[YYYY-MM]_[EntityName].xlsx`

In a multi-entity run, `[EntityName]` is the company file's `display_name`, one per entity plus a
consolidated file. Every file states which datasource, `display_name` and budget version it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something — most often *why* a variance happened — **say so and name the
owner** instead of estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This skill runs every month, so the evolution step pays back immediately.

On an explicit yes, persist the **decisions**:

- **The materiality thresholds** — absolute and relative — which are otherwise re-asked every month
- **The budget version convention**: which budget management compares to, by name, and when it
  switches to a revised one
- **The reporting hierarchy**: how lines roll up for management reporting, and which grouping they
  actually read
- **The account-mapping table** where budget lines and actual accounts differ
- **Line owners** — who explains which variance. Commentary without an owner does not get written
- **Recurring known one-offs** — the annual insurance renewal, the quarterly bonus accrual — so
  each is recognised as expected rather than re-investigated every year
- **Standing decompositions**: which lines are decomposed by volume/price, which by
  headcount/rate, which are simply spend
- The replay recipe: the exact sequence of reads that produced this month's report

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist the variance figures, the commentary, or the outlook.** They are one month's
results and belong in the reporting pack. Persist the *thresholds, the structure and the owners*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — thresholds $5,000 and 10%, compares to FY25 Board Budget, G&A owned by the
financial controller" — not "thresholds $5,000 and 10%". Entities are materially different sizes,
and an unlabelled threshold applied to the wrong company file either buries the reader in noise or
hides a real miss. Record the chosen **scenario** (single vs multi, and which set) as a preference
too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that
is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One variance report, one
commentary set.

**Multi-entity.** Steps 0–9 run **once per entity**, each call targeting exactly one
`data_source_id`, every variance and commentary line carrying that entity's `display_name`. Then one
cross-entity step:

- **Report variances per entity first, then the group.** A group total that nets a large overspend
  at one entity against an underspend at another **reports zero and hides two problems**. This is
  the single most important multi-entity rule in this skill: show the gross, not just the net.
- **Apply materiality at both levels.** A variance immaterial at each entity may be material to the
  group if it runs the same way everywhere — a supplier price rise hitting all three locations, for
  instance. Test for common-direction variances across entities; they usually have one cause and one
  fix.
- **Eliminate intercompany lines before the group comparison**, or intercompany charges appear as
  both a cost overrun and a revenue beat. The elimination itself is a consolidation task.
- **Each entity is compared to its own budget version**, and any entity on a different version is
  labelled — comparing one entity to a revised budget and another to the original makes the group
  number meaningless.

Capability is checked **per entity** at Gate 2: the budget tool may be enabled for one company file
and not its sibling, so the same analysis can be two-sided for one entity and one-sided for
another.

---
