<!-- financial-statement-builder · method.md · read for: Stages 3–6 — Steps 0–1 at Stage 3, Steps 2–7 at Stage 4, Steps 8–11 at Stage 5, Step 12 at Stage 6, and the entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Validate the TB
- Step 2 — Build the Balance Sheet
- Step 3 — Build the Income Statement
- Step 4 — Add comparative period
- Step 5 — Add the Statement of Comprehensive Income
- Step 6 — Build the Statement of Cash Flows
- Step 7 — Build the Statement of Changes in Equity / Statement of Stockholders' Equity
- Step 8 — Cross-statement validations
- Step 9 — Apply rounding and presentation
- Step 10 — Quality checks
- Step 11 — Output
- Step 12 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** EPS and discontinued operations are legitimately
`[manual]`, and recording that is the honest result.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the current TB, the comparative TB, the accounts and the
profile do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* at the **current period end** — the primary source — usually **[auto]**
- *`get_trial_balance`* at the **comparative period end** — usually **[auto]**
- *`search_accounts`* — **account names, numbers and types** — usually **[auto]**
- *`get_balance_sheet`* current and comparative — usually **[auto]**
- *`get_profit_and_loss`* current and comparative — usually **[auto]**
- *`get_cash_flow_statement`* where the platform offers one — usually **[auto]**
- *`get_general_ledger`* — for the movement detail behind any line that needs analysis — usually **[auto]**
- *`get_company_info`* — **legal name, currency, year-end** — usually **[auto]**

**Pull both periods on the same basis.** Where the platform offers an `accounting_method` argument
(cash / accrual), **pass the same value for both periods** — a comparative pulled on a different basis is
not a comparative, and the difference is invisible once it reaches a spreadsheet.

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data. **Financial statements are the most consequential
output in this pack** — they go to banks, investors and auditors. **A statement package built on fixture
data must say so on the face of every statement**, not in a footnote.

## Step 1 — Validate the TB

Before building statements — **[auto]** throughout:

- **Sum of debits = sum of credits** (the TB balances)
- **Every account has a type** — Asset / Liability / Equity / Revenue / Expense
- **Every revenue and expense account is on the P&L side**
- **Every BS account is on the BS side**
- **No type mismatches** — a liability with a perpetual debit balance, and so on

**If the TB is unbalanced, fix that first via `closing-entries-and-trial-balance` review.** *Mosofin note*:
a TB pulled from a live double-entry platform **will balance**, so this check is a formality on
platform-sourced data and a real check on anything supplied by hand. **The type-mismatch test is the one
that still earns its place** — a liability account sitting in debit is a genuine finding the software will
happily report.

**If the period is mid-year** — P&L accounts hold **YTD balances**, no closing yet — **build statements
directly from those YTD balances.** **If post-closing**, all P&L accounts are zero **and you need the
period's activity elsewhere** — *`get_profit_and_loss`* for the period, or *`get_general_ledger`*.

**[auto]** to detect which case you are in: read the P&L accounts. All zero at a year-end date means
post-closing. See `closing-entries-and-trial-balance` for the auto-close behaviour some platforms apply
without an explicit entry.

## Step 2 — Build the Balance Sheet

### Classification — Current vs. Non-current

**US GAAP and IFRS both use current / non-current with similar criteria. Current assets are expected to be
realized or consumed within 12 months** — or **one operating cycle if longer**. **Current liabilities are
due within 12 months.**

**[gated]**: account types are `[auto]`, but the twelve-month test is judgment plus schedules. **The
current portion of long-term debt is the classic case** — the ledger usually carries one loan balance, and
splitting it needs the amortization schedule. The same applies to lease
liabilities and to deferred revenue.

### Balance Sheet structure

Most common; framework variations noted:

```
ASSETS
  Current Assets
    Cash and cash equivalents
    Short-term investments / marketable securities
    Accounts receivable, net of allowance
    Inventory
    Prepaid expenses
    Input tax recoverable (current portion)
    Other current assets
  Total Current Assets

  Non-current Assets
    Property, plant & equipment, net (cost less accumulated depreciation)
    Right-of-use assets (under ASC 842 / IFRS 16)
    Intangible assets, net
    Goodwill
    Long-term investments
    Deferred tax assets (non-current portion)
    Other non-current assets
  Total Non-current Assets

  TOTAL ASSETS

LIABILITIES
  Current Liabilities
    Accounts payable
    Accrued expenses
    Current portion of long-term debt
    Current portion of lease liabilities
    Customer deposits / current deferred revenue
    Sales tax / VAT / GST payable
    Income tax payable
    Other current liabilities
  Total Current Liabilities

  Non-current Liabilities
    Long-term debt (net of current portion)
    Lease liabilities (net of current portion)
    Deferred revenue (non-current)
    Deferred tax liabilities
    Other non-current liabilities
  Total Non-current Liabilities

  TOTAL LIABILITIES

EQUITY
  Common stock (par value)
  Additional paid-in capital
  Retained earnings
  Treasury stock (contra)
  Accumulated other comprehensive income / (loss)
  Total Equity attributable to shareholders of the parent
  Non-controlling interests (if multi-entity consolidation)
  TOTAL EQUITY

  TOTAL LIABILITIES AND EQUITY
```

**Validation: Total Assets = Total Liabilities + Total Equity, to the penny.** **Prove this on the
statement you built**, after reclassification — not on the platform's report, which balances by
construction.

**IFRS differences:**

- **IFRS typically presents non-current items first** (assets, then liabilities, then equity) **and current
  items second — opposite of US GAAP**
- **IFRS requires "Trade and other receivables" / "Trade and other payables" terminology**
- **Property, plant & equipment may be revalued under IFRS** — revaluation surplus in OCI

**Local GAAP may have other variations — apply per the user's framework.**

**Mosofin mapping note.** Map each ledger account to a statement line **explicitly, and keep the mapping**
(Step 12). **Every account in the TB must land on exactly one line**, and the sum of mapped accounts must
equal the TB total. **An unmapped account is the commonest way a statement quietly stops balancing** —
check for it rather than trusting that the totals happened to agree.

## Step 3 — Build the Income Statement

**Two formats are common** — **[manual]** to choose, `[auto]` to populate:

**By Function** — typical for many entities, especially under US GAAP:
```
Revenue
Cost of Revenue / Cost of Goods Sold
  Gross Profit
Operating Expenses:
  Research and Development
  Sales and Marketing
  General and Administrative
  (Other operating expenses)
  Operating Income
Other Income / (Expense):
  Interest income
  Interest expense
  Foreign currency gain / (loss)
  Other income / expense, net
  Income before tax
Income tax expense
NET INCOME / (LOSS)
```

**By Nature** — common under IFRS, especially in continental Europe:
```
Revenue
Other income
Changes in inventories of finished goods and WIP
Raw materials and consumables used
Employee benefit expense
Depreciation and amortization expense
Other expenses
  Operating Profit
Finance income
Finance costs
  Profit before tax
Income tax expense
PROFIT FOR THE PERIOD
```

**Both formats arrive at the same net income. Apply the user's policy or framework norm.**

**Single-step vs. multi-step**: **most accrual entities use multi-step** — gross profit shown separately.
**Single-step** — one block of revenue minus expenses — **is rarer.**

*Mosofin note*: **by-function requires the entity to have tracked function.** If departments or classes were
never used, a by-function P&L is a reallocation exercise, not a read. **[auto]** to check
(*`search_departments`*, *`search_classes`*, *`get_profit_and_loss`* with a summarize argument) — and worth
checking before promising the format.

## Step 4 — Add comparative period

**Standard practice is to present:**

- **Current period and one comparative period** — this year versus last year
- **For 10-K / annual filings: 2 prior years for the IS and 1 prior year for the BS** — per SEC; **varies
  by jurisdiction**

**Comparatives must be on a consistent basis with the current period. If a reclassification was made in the
current period, restate the prior period's comparatives to match — and disclose.**

**[auto]** to fetch, **[manual]** to validate — and the validation is the part that matters. Two Mosofin
checks:

1. **Same basis.** Both periods pulled with the same `accounting_method` and the same reporting parameters.
2. **Agreement with what was published.** Compare the ledger's prior year to the **prior-year financial
   statements as issued**. **A difference means audit adjustments were never posted, or the prior year was
   reopened and something changed.** Both are findings; neither is rare. Report the difference and ask
   which version governs before building comparatives on it.

## Step 5 — Add the Statement of Comprehensive Income

**Required under both US GAAP (ASC 220) and IFRS (IAS 1). Can be:**

- **A single statement of Profit or Loss AND OCI together**
- **Or two statements**: P&L, then a separate Statement of Comprehensive Income

**OCI items — closed to AOCI, not RE:**

- **Foreign currency translation adjustments (CTA)** — **[gated]**; arises on translation
- **Available-for-sale debt securities — unrealized gains / losses** — **[manual]**; needs market values
- **Cash flow hedge gains / losses (effective portion)** — **[manual]**; hedge accounting
- **Defined benefit plan actuarial gains / losses** (per framework) — **[manual]**; actuarial
- **Revaluation surplus on PP&E (IFRS only)** — **[manual]**; needs a valuation

```
Net Income
  Other Comprehensive Income, net of tax:
    Foreign currency translation
    Unrealized gains/losses on securities
    Cash flow hedges
    Pension actuarial gains/losses
  Total Other Comprehensive Income
Total Comprehensive Income
```

**Four of the five OCI items need data the accounting system does not hold.** Where an AOCI balance exists
in the ledger but no supporting analysis is available, **report the balance and name the analysis
required** — do not present a movement you cannot explain.

## Step 6 — Build the Statement of Cash Flows

**Build it by the indirect method, which is a full procedure of its own. The result fits in the package
as the third primary statement.** **[gated]** — the balance-sheet movements it needs are `[auto]`, the
non-cash and financing detail often is not.

Where the platform offers its own cash flow report (*`get_cash_flow_statement`*), **it is a useful
cross-check, not a substitute** — platform cash flow reports classify by their own rules and frequently
misclassify financing and investing items.

## Step 7 — Build the Statement of Changes in Equity / Statement of Stockholders' Equity

**Prepare it as a procedure of its own. This shows the roll-forward of each equity component.**
**[gated]** — the balances are `[auto]`, the movements need attribution.

## Step 8 — Cross-statement validations

**Critical tie-outs.** This is the heart of the skill — **[auto]** to compute, and each one must be
**reported with its actual difference**, not merely asserted:

1. **Balance Sheet balances** — **Assets = Liabilities + Equity.** *On your statements, post-reclassification.*
2. **Net Income on IS = Net Income line on Cash Flow Statement** — the start of operating activities under
   the indirect method
3. **Net Income + OCI on Statement of CI = Net Income on Statement of Equity Changes**
4. **Cash at end of period on Cash Flow Statement = Cash on Balance Sheet**
5. **Closing Retained Earnings on Statement of Equity = Retained Earnings on BS**
6. **Comparative period figures = prior year's filed financials** — or restated comparatives if
   reclassified, **with disclosure**. *This is the `[manual]` one, and the one most often skipped.*
7. **Inter-statement currency consistency** — if reporting in USD, **every statement says USD**

**Report each tie-out as pass / fail with the difference**, even when it is zero. **"Balances" without a
number is an assertion; "balances, difference 0.00" is evidence.** A rounding-driven difference is still a
difference and belongs in Step 9, not hidden here.

## Step 9 — Apply rounding and presentation

**Common rounding** — **[manual]** choice:

- **Thousands ($000s)** for small / mid entities
- **Millions** for large entities
- **Whole dollars** for very small / startup

**Whatever rounding is used, it must be consistent within the document. Rounding can create $1 line-item
differences in totals; either re-balance or footnote.**

**Other presentation choices:**

- **Comparatives shown side by side** (current | prior)
- **Negative numbers in parentheses or with a minus sign**
- **Subtotals bolded or in lines**
- **Page footers with company name, period, currency, rounding basis**

**Mosofin addition to the footer**: also state **the entity by `display_name`, the source datasource, and
whether any figure rests on `mock` data.** The footer travels with the statements after they leave this
conversation, which is exactly when someone needs to know where the numbers came from.

## Step 10 — Quality checks

Final review:

- **Math**: every subtotal and total — **[auto]**
- **Cross-references**: **every line ties to a TB account or sum** — **[auto]**, and this is where the
  explicit mapping from Step 2 pays for itself
- **Comparability**: **no line in current that's missing in prior** (or vice versa) **without explanation**
  — **[auto]**
- **Trend reasonableness**: **large period-over-period changes should be explainable** — **[gated]**;
  the movement is readable, the explanation is not
- **Sign conventions**: **contra accounts displayed with brackets or as deductions** — **[auto]**
- **Materiality**: **nothing misclassified to the point of misleading** — **[manual]** judgment

## Step 11 — Output

Deliver an `.xlsx` workpaper with statements ready for presentation:

**Sheet 1: Trial Balance (source)** — **with a column for statement line mapping.** Add the Mosofin
provenance: the tool call, the entity `display_name`, the as-at date and the accounting method used.

**Sheet 2: Balance Sheet** — with current period and comparative.

**Sheet 3: Income Statement** — with current period and one or more comparatives.

**Sheet 4: Statement of Comprehensive Income** — if material OCI items exist.

**Sheet 5: Statement of Cash Flows** — by the indirect method, from Step 6.

**Sheet 6: Statement of Changes in Equity** — from Step 7.

**Sheet 7: Cross-Statement Tie-Outs** — **the 7 critical validations from Step 8**, each with its computed
difference.

**Sheet 8: Reclassifications and Restated Prior Period** — if applicable. **Every reclassification listed
as a proposal**, since Mosofin posts nothing.

**Sheet 9: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Accounting method | Policy | `mock` | Gap |

Include a row for **each of the seven tie-outs**, since tie-out 6 is `[manual]` and its absence otherwise
looks like a pass.

**Optionally a clean PDF render** — offer it, and create it only if the user says yes.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Financial_Statements_[YYYY-MM]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`, or the group name for a consolidated package. Every
file states which datasource and `display_name` it covers, **and whether it is consolidated or separate**.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — EPS, discontinued operations, the published comparative — **name the source required**
instead of estimating.

## Step 12 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The framework** and every presentation election within it: by-function or by-nature, single or two
  statements for OCI, current-first or non-current-first ordering
- **The account-to-statement-line mapping** — **the single most valuable asset this skill produces.**
  Rebuilding it every quarter is the whole cost of the exercise
- **The classification rules**: what counts as current here, how the current portion of debt and leases is
  determined, and from which schedule
- **The rounding basis** and presentation conventions, including the footer content
- **The accounting method** (cash / accrual) used for both periods — so comparatives stay on one basis
- **The comparative policy**: how many prior periods, and whether prior-year figures come from the ledger
  or from the issued financials
- **Which OCI items apply** to this entity, and where each one's data comes from
- **The consolidation choice** — consolidated or separate — and the entities in the reporting group
- The replay recipe: the exact sequence of reads that produced both periods

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist balances, statement figures or the trial balance itself.** A published statement is a
point-in-time representation that must be rebuilt from live data, never recalled. **Persist the mapping and
the presentation decisions; never the numbers.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Holdings — IFRS, by-nature, non-current first, thousands, accrual basis, mapping v3" — not "IFRS,
by-nature". **The mapping is chart-specific and therefore entity-specific**, and applying one company
file's mapping to another produces statements where accounts land on the wrong lines and the totals still
foot. Record the chosen **scenario** (single vs multi, consolidated vs separate) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and every balance on every statement is state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere. **For consolidated
statements this is not a warning but a stop condition**: a missing group member means the statements do not
cover the reporting entity.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One TB, one comparative, one package.

**Multi-entity.** Steps 0–11 run **once per entity**, each call targeting exactly one `data_source_id`,
every statement carrying its entity's `display_name`. Then the decision that defines the deliverable:

- **Consolidated statements.** Each entity's TB is consolidated first, **then
  the statements are built from the consolidated TB.** The consolidation eliminates intercompany items.
  **Do not build statements per entity and add them together** — that double-counts intercompany balances
  and revenue, and the result will still balance, which is what makes the error so durable.
- **Separate statements.** A package per entity, each labelled with its own `display_name`. **Never present
  a separate-entity package as if it covered the group**, and never mix the two in one file without saying
  so on every sheet.
- **Non-controlling interests** appear in equity only on consolidated statements, and only where a
  subsidiary is partly owned.
- **Multi-currency**: **each entity in its functional currency; group reporting currency requires
  translation per ASC 830 / IAS 21. CTA flows to OCI.**
- **Parent-only statements** may be required in some jurisdictions **in addition to** consolidated ones.
  **Use the same procedure on the parent-only TB** — and label the two unmistakably.
- **The tie-outs run on whichever set you present.** Consolidated tie-outs prove the consolidated package;
  they say nothing about the separate ones.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file. **An entity whose TB could not be read cannot be silently omitted from a consolidation** — say so on
the face of the statements.

---
