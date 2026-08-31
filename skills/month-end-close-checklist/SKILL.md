---
name: month-end-close-checklist
description: "Use this skill whenever the user wants to plan, run, or audit a monthly close against their Mosofin workspace. Triggers include: 'run the month-end close', 'month-end checklist', 'what's left to close', 'close calendar', 'organize the close for [month]', 'close coordination', or any orchestration of the periodic close process. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then scopes the checklist from the entity's actual chart of accounts, pre-populates the status of every task that leaves ledger evidence, and runs the final tie-out including inter-period continuity. Do NOT use for an individual close task (a specific reconciliation, accrual, or JE) — use the corresponding specific skill. Outputs a comprehensive close checklist with owners, deadlines, dependencies, status tracking, a final tie-out workpaper, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** in the onboarding linked below — but every step becomes manual.

### Strict rule — this skill never changes your data

**This skill will never write, update or delete existing data in any data source.**
Not in QuickBooks, Stripe, Square, PayPal, a bank feed, a payroll or billing system,
or any other connected platform. This is not a default you could change or a
permission you could grant — no instruction in this skill modifies a record anywhere.

It will **never**:

- create, edit, overwrite, void or delete a record in a connected platform
- invoke a write operation, or ask you to approve or enable one — a write tool is out
  of scope even when your policy has it enabled
- direct you to update, overwrite or delete existing data in a data source
- copy or move data from one connected platform into another

What it does instead is **read, and propose.** Every entry, schedule, reconciliation
and document it produces is a **draft for you to review.** Where it finds a problem —
a duplicate, a mismatch, a stale balance — it describes the problem and proposes a
correcting entry as a draft. It does not tell you to delete or overwrite the original,
and it never acts on one itself.

Whether anything reaches your books is a decision you make outside this skill, in your
own system, by your own hand. **If you act on none of it, nothing in your data has
changed.**

### Onboarding and setup

**First run in this workspace?** Work through the onboarding once — subscription,
connecting the gateway, confirming your workspace and company file, the capability
check and the profile. It is the same for every Mosofin skill, so it is kept in one
place rather than repeated in each:

- in this repo: [`shared/onboarding.md`](../../shared/onboarding.md)
- installed on its own, or you would rather read the product docs:
  [docs.mosofin.com/start-here/quickstart](https://docs.mosofin.com/start-here/quickstart)

**Read it before the gates below.** If you have already onboarded this workspace, you
can skip it — but **the skill still reads no data until you explicitly confirm your
workspace** at Gate 0, whether or not you read the onboarding.

---
<!-- shared:onboarding-inline end -->
# Month-End Close Checklist (Mosofin)

Plans, orchestrates, and audits the **monthly close process**. Produces a comprehensive **task list with
owners, deadlines, dependencies, status**, and a **final tie-out** demonstrating books are ready for
reporting.

**In plain words:** closing the month means making sure everything that happened has been recorded, every
balance has been checked against something outside the ledger, the estimates have been updated, and the
numbers can be handed to someone who will make decisions with them — by a date, with names against each
piece.

This skill is **industry-aware** — it adjusts the task list to the entity's industry, size, and
complexity.

It is **workspace-scoped**: the scoping evidence, the task status and the final tie-out come from tool calls
against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## This is the orchestration hub — and three things the workspace changes

**Almost every task in this checklist hands off to another skill.** This one coordinates; the others do the
work. **Three things change when the coordinator can read the books.**

**1. The checklist scopes itself.** Step 2 asks you to customise: *"No inventory? Skip inventory steps. No
fixed assets to speak of? Streamline FA steps. Single entity, single currency? Skip consolidation and FX
revaluation."*

> **Every one of those questions is answerable from Gate 1 and the chart of accounts.** **[auto]**: no
> inventory account, no fixed asset account, one connected company file, one currency, no restricted-fund
> accounts. **A checklist that arrives already scoped to this entity is worth far more than a generic one**,
> and the scoping costs one read.

**2. Many tasks are self-verifying.** The tedious part of running a close is chasing status — *has
depreciation been posted? did the accrual go in? is the FX revaluation done?*

> **Every task that produces a journal entry leaves evidence.** **[auto]**: **pre-populate the status
> column** for depreciation, amortisation, prepaid release, accruals, FX revaluation, deferred revenue
> release and lease entries. **"Posted 2026-08-04, £14,208, JE-2608-011" is a status; "Complete" ticked by
> whoever remembered is not.**
>
> **Be precise about what this proves**: it shows **an entry exists**, not that it is **correct** or
> **complete**. The task owner still owns the task. **But knowing what has and has not been posted, at any
> moment during the close, is exactly the coordination this skill exists to provide.**

**3. The final tie-out is nearly all `[auto]`** — including **inter-period continuity**, which is the one
almost nobody checks by hand and the one that catches a reopened prior period.

**What the workspace cannot do:** **it cannot lock the books, post an entry, or mark a task complete.**
**Mosofin is read-only.** It observes evidence and reports it; **the close is run by people.**

---

# PART A — Prerequisites: confirm scope, discover the capability map

Run Gates 0 → 1 → 2 → 3 in this order, before building the checklist. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

<!-- shared:scope-protocol start -->
### Confirming scope — workspace, then data sources, then tools

**Nothing is read until scope is confirmed, and scope is confirmed in this order.**
Each step depends on the answer to the one before it, so none of them may be skipped,
merged, or guessed at.

| # | Question to the user | How it is settled |
|---|---|---|
| 1 | **Which workspace?** | `list_workspaces` with **no arguments**. Read the workspace back **by name** and wait for an explicit yes. On `selection_required`, ask whether this is single- or multi-workspace, then which **by name**, then call again with `workspace_ids=[…]` and `mode="single"`/`"multi"`. |
| 2 | **Which data sources, in that workspace?** | `get_agent_datasources` with the confirmed `workspace_id`. `connected: true` is in scope; `connected: false` is **excluded and named as excluded**, with any `reconnect_url` surfaced. Then settle the entity scenario — single-entity: which company; multi-entity: which set — always by `display_name`. |
| 3 | **Which tools do those sources actually expose?** | `get_datasource_tools` per in-scope datasource, **and per company file when several are live — permissions are per company.** This is discovery, not a question: read what is there before promising anything. |

**Never auto-pick.** Not the workspace, not the company file, not the entity scenario.
**Silence is not a yes**, and an answer to one question is not an answer to the next.

**Names, never internal ids.** Name the workspace and refer to companies by
`display_name`. Never print an internal numeric tenant id, and never show a raw
`data_source_id` — pass the opaque handle, show the name.

**Only then does the work begin.** Once the workspace, the data sources and their tools
are confirmed, resolve every task against what was actually found: what is available
now decides which steps are `[auto]`, which are `[gated]` and which fall to `[manual]`.
Where the confirmed tools cannot answer the request, say so and ask — do not substitute
an assumption for a capability.

**The catalogue is authoritative.** Take exact `tool_name` values from the Gate 2
listing — names are not uniformly styled, some underscored, some hyphenated.
**Do not invent a tool name.** On `UNKNOWN_TOOL`, read the valid names from the error
and retry.
**Never call a tool whose `effective_policy` is `disabled`.**

**This map is built fresh every run** and held only for this run. It is written out in
the coverage sheet, never written back into this file.
<!-- shared:scope-protocol end -->

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with `workspace_ids=[…]`
  and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**This gate answers half of the entity profile the original asks for as an input**, and it drives Step 1's
Day 6:

- **One connected company file** → **no consolidation phase.** Day 6 drops out entirely.
- **Several** → **Day 6 applies**, and **the close is only as fast as its slowest entity.** See the
  cross-entity step.
- **Connected subledger platforms** — payroll, billing, inventory, expenses — **tell you which Day 1 and
  Day 2 tasks have a system behind them** and which are manual.

**A group member that is not connected still has to close.** Its tasks belong on the checklist with an owner
— **they simply cannot be status-checked from here.** Say which.

Refer to companies by `display_name`; never show the raw `data_source_id`.

## Gate 2 — Discover enabled tools → build the capability map

<!-- shared:write-guardrail start -->
### Write tools are out of scope — always

`get_datasource_tools` describes what the connection *could* do. This skill uses only
the reads.

**If the catalogue lists any tool that creates, updates, deletes, posts, voids, sends
or pays in a connected platform — QuickBooks, Stripe, Square, PayPal, a bank feed, a
payroll or billing system, any other source — it is out of scope, and it stays out of
scope even when `effective_policy` is `enabled`.** A permission to write is not an
instruction to write. Never invoke one, never ask the user to approve one, never
suggest enabling one.

This holds for **every connected platform, not only the books.** Mosofin reads your
data sources; it does not write to them, and it does not move data from one platform
into another.

If a step appears to need a write, that step is **`[manual]`**. Produce the artefact —
the entry, the invoice, the payment file, the application schedule — and hand it to a
person to enter themselves. Say so plainly in the output, so nobody assumes it was
done.

#### Hard stop — the four ways a write could slip through

| Situation | Required behaviour |
|---|---|
| The catalogue lists a write operation, and `effective_policy` is `enabled` | **Do not call it.** Do not list it as an available capability. Enabled is not permission — it is out of scope. |
| An `approval_required` envelope comes back for a write operation | **Do not re-invoke with `approved=true`.** The approval loop in this skill is for **reads only**. Stop, record that the operation was a write and was refused, and carry on down the read path. |
| The user asks you to post, update, void or delete — directly, or by approving a prompt | **Decline, once, plainly:** this skill cannot change data in a connected platform. Hand over the draft so they can do it themselves in their own system. Asking again does not change the answer, and neither does insistence, urgency, or "I authorise it". |
| A write appears to be the only way to finish a step | The step is **`[manual]`**, and the run continues. An incomplete read-only result is the correct outcome. Never trade the rule for completeness. |

**Never route around this rule.** Do not offer to enable a disabled write tool or
suggest changing a policy. Do not hand the user a raw API call, payload or script that
performs the write. Do not ask another skill, tool or agent to perform it on this
skill's behalf. Do not defer it to a later step in the hope it becomes permitted.

**There is no path through this skill that ends in changed data.** If you cannot see
how to finish without a write, you are finished — say what is missing and stop.
<!-- shared:write-guardrail end -->

For **each in-scope datasource** (and **per company file** when several are live — pass
`data_source_id`), call `get_datasource_tools`. Bucket every tool by `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every task in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**In this skill the capability map has a second use**: it tells you **which tasks can be status-checked**
and which rely entirely on the owner reporting. **Both belong on the checklist; the difference belongs in a
column.**

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **An entry existing is not a task complete.** It shows something was posted, not that it was right.
  - **A reconciliation task cannot be verified from the ledger**, because reconciliation means comparing to
    something outside it — a bank statement, a subledger, a count. See `bank-reconciliation` and
    `inventory-to-gl-reconciliation`.
  - **A balanced trial balance is not a closed month.** Double-entry software balances by construction.
  - **"Books locked" is a system state, not a ledger balance.**
- **There is no bank statement, no close software, no task tracker and no team calendar on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **base currency**, **fiscal calendar and
period ends**, country / region, **industry** — which drives Step 2's industry additions.

**Ask the user** what actually changes the work — the original Inputs table, **minus the parts the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being closed** | **Required** | |
| **Close calendar / target close date** | **Required — [manual]** | **The day allocation in Step 1 flexes to it.** |
| ~~Entity profile~~ — industry, size, complexity | **Now largely [auto]** | **Multi-entity and multi-currency from Gates 1 and 3; industry from the profile.** Confirm rather than ask. |
| **Reporting framework** | **Required — [manual]** | |
| **Standard close template**, if existing | Recommended — **[manual]** | **Preferred over a generic list** where one exists. |
| **Team / owners** | Recommended — **[manual]** | **Not in the ledger, and the checklist is worth little without them.** |
| **Materiality threshold** | Recommended — **[manual]** | **Do not assume one**; see the startup edge case. |
| ~~Sub-processes in scope~~ | **Now [gated]** | **Scoped from the chart**; confirm the result. |
| **Prior month's close** | Recommended — **[gated]** | **Carry-forward items are `[manual]`; whether last month's entries posted is `[auto]`.** |
| **Whether this is a soft or hard close** | **Required — Mosofin addition** | Different rigour; see the edge cases. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. a monthly close for an entity whose periods are quarterly. |
| **Confirm manual evidence** | **Required** | Owners, materiality and the calendar are `[manual]`. |

Ask as **one short batch** — **and present the scoped checklist with the questions**, so the user is
confirming a tailored list rather than answering abstract ones.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The task list, the owners, the dependencies, the materiality basis and the scoping decisions persist;
**every status and every tie-out is re-observed.**

---

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

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
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
- **Amortization of intangibles** (`intangibles-and-amortization`)
- **Lease entries** (`lease-accounting-asc842-ifrs16`)
- **Stock-based compensation expense** (`equity-compensation-accounting`)
- **Accruals and deferrals** (`accruals-and-deferrals`)
- **Bad debt allowance true-up** (`bad-debt-and-write-offs`)
- **Inventory write-downs** (`inventory-to-gl-reconciliation`)
- **Revenue recognition entries** (`revenue-recognition-asc606`)
- **Deferred revenue release**
- **Loan amortization** (interest + principal)
- **FX revaluation** (`multicurrency-fx-revaluation`)

**Day 4 — Reconciliations** — **[gated]**
- **Balance sheet reconciliations** (`balance-sheet-reconciliations`) **for every BS account** — **[auto]**
  to list the accounts and their balances; **[manual]** to reconcile
- **Intercompany reconciliations** (`intercompany-reconciliation`) — **[auto]** where both sides are
  connected
- **Payroll clearing** (`payroll-clearing-reconciliation`) — **[auto]** for the clearing balance
- **Tax accounts reconciliation** — sales tax, VAT, withholding — **[gated]**
- **All other control accounts** — **[auto]** to enumerate

**Day 5 — Review and Variances** — **[auto]** for the analysis
- **Preliminary trial balance review** — **[auto]**
- **P&L variance to budget / forecast** (`budget-vs-actual-analysis`) — **[gated]**: actuals `[auto]`,
  budget where held
- **BS variance to prior month** — **[auto]**
- **Unusual fluctuations investigated** — **[auto]** to surface, **[manual]** to explain
- **KPI dashboards refreshed** (`kpi-dashboard-builder`) — **[auto]**

**Day 6 — Consolidation (if multi-entity)** — **[gated]**; **drops out entirely for a single entity**
- **Sub-entity closes complete**
- **Currency translation** — each sub's functional currency → group reporting currency
  (`foreign-currency-translation-asc830`)
- **Intercompany eliminations** (`consolidation-and-eliminations`)
- **Consolidation adjustments**
- **Group trial balance review**

**Day 7 — Reports and Sign-Off** — **[gated]**
- **Financial statements built** (`financial-statement-builder`)
- **Management reporting pack** (`management-reporting-pack`)
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
| **Nonprofit? Add fund-accounting steps** (`nonprofit-fund-accounting`) | **Net asset accounts split by donor restriction; fund or program classes** |

**Report the scoping conclusions with their evidence** — *"no inventory account in the chart, so the four
inventory tasks are removed"* — **so a task removed in error is visible and recoverable.**

**Add industry-specific tasks** — **[gated]**: the industry is `[auto]` from the profile, **the task set is
`[manual]` judgment**:

- **SaaS**: **deferred revenue release, ARR/MRR calculation, customer churn analysis** — *note*:
  **ARR and churn need the billing system**; see `kpi-dashboard-builder`
- **Construction**: **percentage-of-completion calculations**
  (`construction-percentage-of-completion`), **retainage review, WIP roll-forward**
- **Real estate**: **rent roll, CAM reconciliation, depreciation**
- **Manufacturing**: **variance analysis (PPV, MUV, OHV), inventory roll**
- **E-commerce / retail**: **returns reserve, gift card liability, loyalty accrual**
- **Professional services**: **WIP unbilled, project profitability**
- **Healthcare**: **patient revenue, contractual adjustments, allowances** — see
  `healthcare-revenue-cycle-accounting`

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
  reported** — see `ipo-readiness-accounting` and `financial-statement-builder`, where the same check
  appears. **Almost nobody runs it manually, and it is one comparison**
- **All adjusting entries posted and approved** — **[auto]** for posted; **[manual]** for approved
- **Books are locked** — **[gated]**: a system state, not a balance
- **Reports distributed** — **[manual]**

**Run the continuity check across every balance sheet account**, not just in total. **A total that continues
while individual accounts do not means a prior-period reclassification** — which may be perfectly proper and
still needs to be known before this month's statements go out.

## Step 7 — Lessons learned and improvements

**Post-close review** — **[gated]**:

- **Where did the close slip?** — **[auto]** support: **the posting-date distribution shows when tasks
  actually completed**, which is more reliable than recollection. See `ipo-readiness-accounting`, where the
  same measurement anchors a readiness assessment
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

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

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
- **Intercompany reconciliation is a Day 4 task that requires both sides** — see
  `intercompany-reconciliation`. **A pair whose counterparty has not closed cannot be reconciled**, which
  makes it a genuine dependency rather than a parallel task.
- **Scoping is per entity.** One subsidiary may have inventory and another none. **Never apply one entity's
  scoped list across the group.**
- **Materiality is usually set at group level and applied per entity**, which means **an amount immaterial
  to the group can be material to a small subsidiary's own statements.** Say which basis is in use.
- **Translation is a Day 6 task** — see `foreign-currency-translation-asc830` — and **it depends on rates
  that are `[manual]`**, so it is frequently the item waiting on outside information.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on discovery; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The chart — the scoping instrument** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Status evidence for every entry-based task** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **The tie-out and inter-period continuity check** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Balance sheet, current and prior | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| **Reasonableness review and variance** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` |
| **Cutoff evidence around the period boundary** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Subledger cutoff populations | `search_invoices` / `search_bills` | `start_date`, `end_date` (required) |
| Segment structure | `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| **Industry, currency, period ends** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no bank statement, no close software, no task tracker and no team calendar on this surface.**

---

## Plain-language glossary

- **Close** — finishing a period's accounts so they can be reported.
- **Cutoff** — the line between this period and the next. **Getting it wrong moves profit between
  months.**
- **Subledger** — the detailed records behind a summary account: receivables, payables, inventory, fixed
  assets.
- **Adjusting entry** — an entry made at period end to record something no transaction captured:
  depreciation, an accrual, a release.
- **Reconciliation** — comparing a ledger balance to something outside the ledger. **That "outside" is why
  most reconciliations cannot be confirmed from the books alone.**
- **Control account** — a summary account fed by a subledger.
- **Soft close** — locked for reporting, still adjustable. **Hard close** — final, as at quarter or year
  end.
- **Critical path** — the chain of tasks whose delay delays everything.
- **Dependency** — a task that must finish before another can start.
- **Materiality** — the size below which an error would not change anyone's decision.
- **Inter-period continuity** — this period's opening balances equalling last period's closing ones. **A
  break means history changed after it was reported.**
- **Tie-out** — the final set of proofs that the books are reportable.
- **Books locked** — the period is closed in the system and no further posting is allowed.
- **Re-open** — unlocking a closed period. **Always a documented decision, never a quiet one.**
- **Topside adjustment** — an entry made above the subledgers, usually at consolidation.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Soft close vs. hard close**: **monthly closes are typically "soft" — books locked for reporting but
adjustments can still be made before audit. Quarter-end and year-end are "hard". Different rigor levels.**

**Three-day close** (high-performance close): **everything in parallel, automation heavy, real-time data.
Requires the entity's systems and processes to support it.** *Mosofin note*: **status pre-population helps
most here**, because chasing status is what a compressed close cannot afford.

**Late information** — a vendor statement arriving Day 7 with a material correction: **policy decision —
adjust the closed period (re-open) or true up in the next period. Materiality and audit considerations
matter.**

**Multi-time-zone teams**: **clarify whether deadlines are in entity HQ time or local time.**

**Year-end close vs. monthly**: **year-end adds audit prep (`audit-prep-pbc-list`), tax provision
(`corporate-tax-provision-asc740`), 1099/T4A (`1099-and-t4a-prep`), and other tasks. Use `year-end-close`
for the full procedure.**

**Close while implementing a system change**: **doubles the work. Plan for parallel running of old + new
system data. Flag and resource appropriately.**

**Auditor presence during close**: **certain procedures may need to align with audit timing.**

**Close failures / re-opens**: **if a material error is discovered after books locked, document the re-open
with management approval. Don't quietly tweak.** *Mosofin note*: **the inter-period continuity check finds
an undocumented re-open in the following month**, which is precisely why it belongs in the tie-out.

**Materiality in a startup with small revenue**: **even small amounts may be material. Don't apply
enterprise materiality to a startup.**

**Process documentation for SOX-eligible companies** (`sox-controls-design-and-testing`): **each close task
is potentially a control. Ensure documentation, evidence, and review/approval trails.** *Mosofin note*: **the
Evidence column is the beginning of that trail**, though **an observed entry is not an approval**.

**Holidays / weekends within the close window**: **extend the calendar.**

**A task marked Complete with no entry posted** — *Mosofin-specific, and the most useful line on the board*.
Status and evidence disagree. **Ask before the books lock.**

**An entry posted read as a task complete** — *Mosofin-specific, and the inverse error*. **It proves
something was posted, not that it was right or complete.** The owner still owns the task.

**A reconciliation reported as verified from the ledger** — *Mosofin-specific*. **Reconciliation compares to
something outside.** Bank, statement, count, subledger. **The books cannot confirm it.**

**A balanced trial balance presented as a closed month** — *Mosofin-specific*. **True by construction.**

**Inter-period continuity broken** — *Mosofin-specific*. A prior period was reopened and changed after
reporting. **Run it per account, not only in total.**

**A task removed by scoping that the entity actually needs** — *Mosofin-specific risk*. **Report the scoping
evidence** so a wrong removal is visible.

**External dependencies buried among self-completing tasks** — *Mosofin-specific*. **They are usually the
critical path**, and nobody here can advance them. Group them separately.

**One entity's scoped checklist applied across a group** — *Mosofin-specific*. Scoping is per entity.

**A group close tracked without per-entity status** — *Mosofin-specific*. **The group is as fast as its
slowest entity**, and the board should show which.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A status board built on fixtures shows a
month closing that is not.**

**A stored status is reused** — *Mosofin-specific*. Statuses are state and describe one period only.
**Re-observe.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; its tasks
still exist and simply cannot be verified.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every task has owner, due date, dependencies, status**
- **Critical-path tasks identified**
- **Materiality threshold applied consistently**
- **Variance investigation documented**
- **Final tie-out demonstrates books are reportable**
- **Lessons-learned captured for next cycle**
- **File naming consistent**
- **No silent skips of mandatory tasks**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**, and
  **its tasks remain on the checklist with owners, marked unverifiable**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The checklist was scoped from the chart of accounts**, and **every removal is reported with its
  evidence**, so a wrong removal is visible
- **Every task carries a Status Verifiable column and an Evidence column**, and **observed evidence is
  distinguished from reported status**
- **Any task marked Complete with no supporting evidence is flagged before the books lock**
- **No reconciliation task is reported as verified from the ledger**, since reconciliation compares to
  something outside it
- **The trial balance check is noted as true by construction**, not presented as proof the month is closed
- **Inter-period continuity was checked per balance sheet account**, and any break reported as a possible
  undocumented re-open
- **External dependencies are grouped separately** as the items nobody here can advance
- **Materiality was applied to a listed set of accounts above and below the threshold**, rebuilt from
  current balances
- **New accounts used this period are flagged** as a risk area
- **Close timing was measured rather than recalled** for the lessons-learned step
- In a multi-entity run, **per-entity close status is tracked as a dependency for Day 6**, scoping is per
  entity, intercompany reconciliation is treated as requiring both sides, and **the materiality basis is
  stated as group or entity**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no close is signed off on mock data**
- Every observed status traces to a tool result in this conversation; every reported status traces to its
  owner; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No balances, variances, statuses or close results are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted, no task marked complete, no books locked**
