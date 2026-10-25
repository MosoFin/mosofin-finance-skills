<!-- month-end-close-checklist · method.md · read for: Stages 3–6 — Steps 0–2 at Stage 3, Steps 3–5 at Stage 4, Steps 6–8 at Stage 5, Step 9 at Stage 6, and the entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the scoping and status evidence (grounding) — Mosofin addition
- Step 1 — Build the close task list
- Step 2 — Customize to the entity
- Step 3 — Assign owners and deadlines
- Step 4 — Materiality and risk
- Step 5 — Track open items and review notes
- Step 6 — Tie-out workpaper at close
- Step 7 — Lessons learned and improvements
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** Most close tasks are performed by people using other
skills; this one coordinates them.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the scoping and status evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the chart, the balances, the entries and the prior period do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the full chart: the scoping instrument** — usually **[auto]**
- *`search_journal_entries`* **for the period** — **the status evidence for every entry-based task** —
  usually **[auto]**
- *`get_trial_balance`* at the period end **and at the prior period end** — **the tie-out and continuity
  check** — usually **[auto]**
- *`get_balance_sheet`* current and prior — usually **[auto]**
- *`get_profit_and_loss`* current and prior — **the reasonableness review** — usually **[auto]**
- *`get_general_ledger`* around the period boundary — **cutoff evidence** — usually **[auto]**
- *`search_classes`* / *`search_locations`* — segment structure — usually **[auto]**
- *`get_company_info`* — **industry, currency, period ends** — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that check to **[manual]** and record the gap — **the task stays on the
  checklist**, only its status verification is lost.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a close status board built on fixtures shows a
month closing that is not.**

## Step 1 — Build the close task list

**A comprehensive monthly close typically includes** — every task carries its Mosofin status-check verdict,
where **`[auto]` means the checklist can observe whether it was done**:

**Pre-Close (Day −5 to Day 0)** — **[manual]** throughout; these are communications and requests
- **Communicate close calendar and cut-off times to all functions**
- **Confirm subsystems are open through period-end**
- **Run final daily integrations** (subledger to GL feeds)
- **Bank statements requested / downloaded**
- **Vendor statements requested for material vendors**

**Day 1 — Subledger Cutoffs** — **[auto]** to check
- **AR cutoff**: final invoices posted; subsequent invoices held for next month — **[auto]**: invoices dated
  in the period but entered after it
- **AP cutoff**: final bill posting; subsequent bills held for next month — **[auto]**, same test
- **Inventory cutoff**: shipments and receipts dated through last business day — **[auto]**
- **Payroll cutoff**: confirm last payroll posted; accrue any partial-period — **[auto]** for the posting
- **Bank transactions imported through period-end** — **[auto]**: latest transaction date in the cash
  account

**Day 2 — Subledger Reconciliations and Initial Entries** — **[gated]**: **a reconciliation compares to
something outside the ledger, so completion cannot be confirmed from inside it**
- **AR aging run and review** (`ar-aging-and-collections`) — **[auto]** to produce, `[manual]` to review
- **AP aging run and review** (`ap-aging-and-payment-runs`) — same
- **Bank reconciliations** (`bank-reconciliation`) — **[manual]**: **no bank statement on this surface**
- **Credit card reconciliations** (`credit-card-reconciliation`) — **[manual]**, same reason
- **Merchant processor reconciliations** (`merchant-and-payment-processor-rec`) — **[gated]**
- **Cash application** (`cash-application`) — **[auto]** for unapplied balances
- **Inventory cycle count or roll-forward** (`inventory-to-gl-reconciliation`) — **[manual]** for the count
- **AP accrual cutoff entries** (`ap-accrual-cutoff`) — **[auto]** for the entry

**Day 3 — Adjusting Entries** — **[auto]** to check, **all of them**; this is where status pre-population
pays most
- **Prepaid amortization** (`prepaid-amortization-schedule`)
- **Depreciation** (`fixed-asset-register-and-depreciation`)
- **Amortization of intangibles**
- **Lease entries**
- **Stock-based compensation expense**
- **Accruals and deferrals** (`accruals-and-deferrals`)
- **Bad debt allowance true-up**
- **Inventory write-downs** (`inventory-to-gl-reconciliation`)
- **Revenue recognition entries**
- **Deferred revenue release**
- **Loan amortization** (interest + principal)
- **FX revaluation**

**Day 4 — Reconciliations** — **[gated]**
- **Balance sheet reconciliations** (`balance-sheet-reconciliations`) **for every BS account** — **[auto]**
  to list the accounts and their balances; **[manual]** to reconcile
- **Intercompany reconciliations** — **[auto]** where both sides are connected
- **Payroll clearing** (`payroll-clearing-reconciliation`) — **[auto]** for the clearing balance
- **Tax accounts reconciliation** — sales tax, VAT, withholding — **[gated]**
- **All other control accounts** — **[auto]** to enumerate

**Day 5 — Review and Variances** — **[auto]** for the analysis
- **Preliminary trial balance review** — **[auto]**
- **P&L variance to budget / forecast** (`budget-vs-actual-analysis`) — **[gated]**: actuals `[auto]`,
  budget where held
- **BS variance to prior month** — **[auto]**
- **Unusual fluctuations investigated** — **[auto]** to surface, **[manual]** to explain
- **KPI dashboards refreshed** — **[auto]**

**Day 6 — Consolidation (if multi-entity)** — **[gated]**; **drops out entirely for a single entity**
- **Sub-entity closes complete**
- **Currency translation** — each sub's functional currency → group reporting currency
- **Intercompany eliminations**
- **Consolidation adjustments**
- **Group trial balance review**

**Day 7 — Reports and Sign-Off** — **[gated]**
- **Financial statements built** (`financial-statement-builder`)
- **Management reporting pack**
- **Management review** — **[manual]**
- **Final adjustments** — **[auto]** to observe
- **Books locked** — **[gated]**; a system state
- **Distribution** — **[manual]**

**Adjust the daily allocation based on the entity's close target** — some entities close in 3 days, others
in 10.

## Step 2 — Customize to the entity

**Remove or downplay tasks that don't apply** — **[auto]** to determine, and this is the scoping step:

| Original question | How the workspace answers it |
|---|---|
| **No inventory? Skip inventory steps** | **No inventory account, or a nil balance** |
| **No fixed assets to speak of? Streamline FA steps** | **Fixed asset and accumulated depreciation balances** |
| **Single entity, single currency? Skip consolidation and FX revaluation** | **Gate 1's file count; the profile's currency; any foreign-currency balances** |
| **Cash basis entity? Remove most accruals** | **The accounting method on the reads, and whether accrual accounts carry balances** |
| **Nonprofit? Add fund-accounting steps** | **Net asset accounts split by donor restriction; fund or program classes** |

**Report the scoping conclusions with their evidence** — *"no inventory account in the chart, so the four
inventory tasks are removed"* — **so a task removed in error is visible and recoverable.**

**Add industry-specific tasks** — **[gated]**: the industry is `[auto]` from the profile, **the task set is
`[manual]` judgment**:

- **SaaS**: **deferred revenue release, ARR/MRR calculation, customer churn analysis** — *note*:
  **ARR and churn need the billing system**
- **Construction**: **percentage-of-completion calculations**, **retainage review, WIP roll-forward**
- **Real estate**: **rent roll, CAM reconciliation, depreciation**
- **Manufacturing**: **variance analysis (PPV, MUV, OHV), inventory roll**
- **E-commerce / retail**: **returns reserve, gift card liability, loyalty accrual**
- **Professional services**: **WIP unbilled, project profitability**
- **Healthcare**: **patient revenue, contractual adjustments, allowances**

**[auto]** corroboration: **the chart frequently confirms the industry pattern** — a gift card liability
account, a retainage account, a WIP account. **Where an industry task has an account behind it, the task is
clearly live.**

## Step 3 — Assign owners and deadlines

**For each task** — **[manual]**, and **the checklist is worth little without this**:

- **Owner** (person or role)
- **Due date / due time**
- **Dependencies** (other tasks that must complete first)
- **Estimated time**
- **Status** (Not Started / In Progress / Complete / Blocked)

**Build a dependency tree. Critical path tasks: any task whose delay would push the close.**

**Mosofin addition — a sixth column: Evidence.** For every task whose status is `[auto]`, **record what was
observed**: the entry, its date, its amount, its reference. **Status says what someone claims; Evidence says
what the books show.** Where the two disagree — a task marked Complete with no entry posted — **that is the
most useful line on the whole board.**

## Step 4 — Materiality and risk

**Apply materiality** — **[manual]** for the threshold:

- **Reconciliations below materiality threshold can be completed with less detail**
- **Above-materiality reconciliations get full scrutiny**
- **Year-end uses tighter materiality than monthly**
- **Auditor expectations affect what's documented**

**[auto]** application once a threshold exists: **list every balance sheet account above and below it**, so
the scrutiny split is a fact rather than a habit. **Accounts drift across the threshold between periods**,
and a list rebuilt from balances catches that.

**Flag risk areas** — each with its verdict:

- **New transactions or accounts in the period** — **[auto]**: **accounts used this period that were not
  used before**. A strong, cheap signal
- **Unusual fluctuations** — **[auto]**: period-over-period movement outside normal range
- **Estimates with high uncertainty** — allowances, accruals — **[auto]** to identify the accounts,
  **[manual]** to judge
- **Recently restated or audited areas** — **[manual]**
- **Items management has identified as risk areas** — **[manual]**

## Step 5 — Track open items and review notes

During close, track — **[gated]**:

- **Outstanding tasks** — **[gated]**: `[auto]` where status is observable
- **Variances under investigation** — **[auto]** to surface
- **Pending information from outside** — vendor statements, bank confirmations — **[manual]**, and
  **frequently the critical path**
- **Manager review comments** — **[manual]**
- **Audit-trail-worthy decisions** — **[manual]**

**The third item deserves attention**: **the tasks waiting on outside information are the ones the workspace
cannot see and cannot chase.** They are also, in most closes, what actually delays it. **Surface them
separately** so they are not buried among tasks that will complete themselves.

## Step 6 — Tie-out workpaper at close

**Final tie-out** — **[auto]** for most of it:

- **Trial balance balances (debits = credits)** — **[auto]**, **and note it is true by construction** from a
  double-entry platform. **It confirms the software works.** See `financial-statement-builder`
- **Each BS account reconciled** — **[gated]**: **[auto]** to list every account and its balance and flag
  any without a reconciliation recorded; **[manual]** for the reconciliations themselves
- **Income statement reasonable** — variance to expected within tolerance — **[auto]** to compute,
  **[manual]** for the tolerance
- **Inter-period continuity** — **this period's opening = last period's closing** — **[auto]**, ⭐ **and the
  most valuable item here.** **A break means a prior period was reopened and something changed after it was
  reported** — see `financial-statement-builder`, where the same check appears. **Almost nobody runs it manually, and it is one comparison**
- **All adjusting entries posted and approved** — **[auto]** for posted; **[manual]** for approved
- **Books are locked** — **[gated]**: a system state, not a balance
- **Reports distributed** — **[manual]**

**Run the continuity check across every balance sheet account**, not just in total. **A total that continues
while individual accounts do not means a prior-period reclassification** — which may be perfectly proper and
still needs to be known before this month's statements go out.

## Step 7 — Lessons learned and improvements

**Post-close review** — **[gated]**:

- **Where did the close slip?** — **[auto]** support: **the posting-date distribution shows when tasks
  actually completed**, which is more reliable than recollection. The same measurement anchors an IPO
  readiness assessment
- **What manual workarounds were used?** — **[manual]**
- **What can be automated?** — **[gated]**: **recurring identical entries are readable** and are the
  automation candidates
- **What recurring issues keep appearing?** — **[gated]**: **the same account reconciling late, or the same
  entry posting after the target date, is measurable across periods**

**Update the close calendar and template for next month.**

**This step is usually skipped, and the workspace makes it nearly free.** **Measured slip beats remembered
slip**, and the measurement is a by-product of reads already taken.

## Step 8 — Output

Deliver an `.xlsx` close workpaper:

**Sheet 1: Close Calendar**

| Day | Task | Sub-Process | Owner | Due Date/Time | Dependencies | Status | Time Estimate |

**Add three Mosofin columns**: **Applies?** (with the scoping evidence), **Status Verifiable?**
(`[auto]` / `[manual]`), and **Evidence** (what the books show). Plus the header block: workspace name; the
entity by `display_name`; excluded company files; **soft or hard close**; whether any read returned `mock`
data.

**Sheet 2: Task Detail** — **for each major task: scope, procedure reference, expected output, completion
criteria.** **The procedure reference is the linked skill.**

**Sheet 3: Open Items / Blockers**

| Item | Description | Impact | Owner | Action | Target Resolution |

**With external dependencies grouped separately** — they are the ones nobody here can advance.

**Sheet 4: Variance Tracker**

| Account | Period | Budget | Actual | Variance | Explanation Required Y/N | Explanation | Owner |

**Sheet 5: Materiality Application** — **threshold per the entity; areas above threshold flagged**, with
**every balance sheet account listed above or below**.

**Sheet 6: Final Tie-Out**
- **Trial balance balanced**
- **Each BS account status** (reconciled / variance / open)
- **Inter-period continuity check** — **per account, not only in total**
- **Books locked Y/N**
- **Sign-off**

**Sheet 7: Lessons Learned** — **issues encountered; improvements proposed**, **with the measured close
timing**.

**Sheet 8: Scoping — NEW, Mosofin-specific** — every task group, whether it applies to this entity, and the
evidence for the decision.

**Sheet 9: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `MonthEndClose_[YYYY-MM]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every observed status traces to a tool result in this conversation; every reported status
traces to its owner. End with a single **Data sources** line. Where a task's status could not be verified,
**say so** rather than reporting it as confirmed.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The scoped task list** for this entity — **which tasks apply, which were removed, and the industry
  additions.** The most valuable stored asset here
- **Owners and roles** per task — **by role wherever possible**
- **The dependency tree and the critical path**
- **The close calendar** — target date and day allocation
- **The materiality threshold and its basis**, with effective date
- **The status-check definitions** — **which account or entry proves each `[auto]` task was done**, so the
  evidence column is consistent between months
- **The account map** for the tie-out and the reconciliation list
- **Recurring open items** — expressed as rules: "the utility accrual always waits on the statement, due
  Day 4"
- **Soft versus hard close conventions** by period
- The replay recipe: the exact sequence of reads that produced scoping, status and tie-out

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist balances, variances, task statuses or close results.** All state — **and a close status
board is meaningful only for the period it describes.** **Persist the checklist and the definitions;
re-observe every status.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — no inventory, no FX, single entity so no Day 6; depreciation proven by JE to 6800; target close
Day 6; materiality 25k" — not "no inventory, no FX". **Scoping is entity-specific**, and applying one
entity's scoped checklist to another **removes tasks that entity genuinely needs.** Record the chosen
**scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. **Day 6 drops out**, and the checklist
is correspondingly shorter — **which is the scoping working, not a task being missed.**

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one `data_source_id`, every
task and status carrying its entity's `display_name`. Then:

- **Day 6 exists, and the group close is only as fast as its slowest entity.** **Track per-entity close
  status as a dependency** — the consolidation phase cannot start until every sub-entity is closed, and the
  board should show which one is holding it.
- **A group member that is not connected still closes.** Its tasks belong on the checklist with an owner;
  **their status simply cannot be observed from here.** Mark them, do not omit them.
- **Intercompany reconciliation is a Day 4 task that requires both sides**. **A pair whose counterparty has not closed cannot be reconciled**, which
  makes it a genuine dependency rather than a parallel task.
- **Scoping is per entity.** One subsidiary may have inventory and another none. **Never apply one entity's
  scoped list across the group.**
- **Materiality is usually set at group level and applied per entity**, which means **an amount immaterial
  to the group can be material to a small subsidiary's own statements.** Say which basis is in use.
- **Translation is a Day 6 task**, and **it depends on rates
  that are `[manual]`**, so it is frequently the item waiting on outside information.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
