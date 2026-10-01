---
name: budget-vs-actual-analysis
description: "Use this skill whenever the user wants to compare actual results to budget or forecast and explain the variances, working from their Mosofin workspace. Triggers include: 'budget vs actual', 'variance analysis', 'explain the variances this month', 'why are we over/under budget', 'BvA report', 'flux analysis', 'plan vs actual', or uploading actuals alongside a budget. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then reads BOTH sides — actuals and the budget held in the accounting system — and decomposes each material variance into its drivers. Do NOT use for building the budget — use budget-builder. Do NOT use for period-over-period MD&A narrative — use management-discussion-and-analysis. Outputs a variance report with favorable/unfavorable classification, driver decomposition, commentary, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill works with or without Mosofin

**With Mosofin connected**, the skill reads your live accounting data through the
gateway: the figures come from your own books, it validates against the real chart of
accounts, and most steps run automatically.

**Without it, the skill still works.** No subscription, no connector, or a skill copied
on its own — you are not blocked and you are not asked to buy anything first. The
Mosofin gates are skipped and you are asked for what each step needs instead: a trial
balance, a statement, an export, the documents themselves. **The accounting logic, the
edge cases and the output standards are identical** — only where the numbers come from
changes, and the output always says which is which.

**You choose, and you are asked.** Where a connection exists, the skill asks at the
start whether to use it for this run or whether you would rather supply the data
yourself — **a connected gateway is not taken as consent to read your books.** Say no
and it runs manually without asking again.

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

### Onboarding — required whenever Mosofin is connected

**If the Mosofin gateway is connected, onboarding is not optional and not per-skill.**
Before any skill reads anything, the workspace and the data sources in it must be
confirmed with you. It is the same sequence for every Mosofin skill, so it is kept in
one place rather than repeated in each:

- in this repo: [`shared/onboarding.md`](../../shared/onboarding.md)
- installed on its own, or you would rather read the product docs:
  [docs.mosofin.com/start-here/quickstart](https://docs.mosofin.com/start-here/quickstart)

**Already onboarded this workspace?** Then you have answered it once and will not be
asked again from scratch — but **the confirmation itself still happens every run.**
Gate 0 reads your workspace back and waits for an explicit yes; Gate 1 settles which
company file. Those are not skippable, and no data is read before them.

**No Mosofin connector? The skill still works.** If the gateway is not present at all,
there is nothing to onboard: the gates are skipped, every step becomes `[manual]`, and
you are asked for what each step needs — a trial balance, a statement, an export.
**The accounting work is unchanged**; only the data source is. You will be told this
once, and you will not be asked to install anything before being helped.

What follows in **Part A** is not more onboarding. It is this skill exploring what your
confirmed workspace and data sources can actually do — which tools exist, which serve
this particular request — so the run is shaped around your books rather than a generic
template.

---
<!-- shared:onboarding-inline end -->
# Budget vs. Actual Analysis (Mosofin)

Compares actual financial results to budget (or forecast), classifies variances as
**favorable / unfavorable**, decomposes them into drivers, and drafts explanatory commentary. The
core monthly **FP&A** (financial planning and analysis) deliverable.

**In plain words:** you said the month would look one way; it looked another. This skill measures
the gap on every line, works out *why* — was it volume, or price, or timing, or a one-off? — and
writes the explanation someone can take to a management meeting. The hard part is never the
subtraction; it is saying what caused it.

This skill is **chart-of-accounts-agnostic** — it works on whatever line structure the entity uses.

It is **not** system-agnostic. It is **workspace-scoped**: every actual and every budget figure
comes from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**A note on how well this particular skill fits a connected workspace.** Most skills in this pack
have one side of a comparison living outside the accounting system — a bank statement, a goods
receipt, an actuarial report. **This one has both sides inside it.** Actuals are readable by month
and by line; and where the accounting platform holds the budget, that is readable too, by account
and by period. So a budget-versus-actual analysis is one of the few workflows here that can run
**almost entirely `[auto]`**, end to end, with the entity's own numbers on both sides.

What stays `[manual]`: the materiality thresholds, the *explanation* of a driver where it depends
on business events the ledger cannot see, and the judgment of timing versus permanent. Those are
where the human value is, and pushing everything else to `[auto]` is precisely what frees time for
them.

**Mosofin is read-only.** It cannot revise a budget, post a reclassification, or update a forecast.
Every recommendation below is a *proposal* for a human.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before comparing anything. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

<!-- shared:scope-protocol start -->
### First — ask whether to use Mosofin for this run

Two things decide how this skill runs, and they are settled **before Gate 0**.

**1. Are the Mosofin tools present at all?** — `list_workspaces` and the rest of the
gateway. Check before doing anything else.

**2. If they are present, ask the user. Once, in these terms:**

> Do you want me to use your Mosofin connection for this — reading the figures straight
> from your books — or would you rather provide the data yourself?

**Wait for the answer.** A connected gateway is **not** consent to read from it, and
this skill does not open with a data read. Never assume, never auto-pick.

- **Use Mosofin** → onboarding is required. Run Gates 0-1 to confirm the workspace and
  its data sources, then Part A explores what those sources expose.
- **Provide the data myself** → **skip Gates 0-2 entirely** and run manually, exactly as
  though no connector were present. **Do not ask again during the run.** Raise it once
  more only if the user asks for something their supplied data cannot answer, and then
  as an offer, not a demand.

**If the tools are not present, do not ask** — there is nothing to choose. The skill was
copied on its own, the connector was never added, or there is no subscription.
**Do not make connecting a condition of helping.** Say once, plainly, that Mosofin is
not connected and this run will be manual, then **carry on with the skill's normal
workflow**: ask for what each step needs — a trial balance, a statement, an export, the
documents themselves — and do the accounting work on what the user provides.

**In manual mode**, whether chosen or unavoidable:

- every step is `[manual]`; there are no `[auto]` verdicts to claim, and none may be
  implied
- the coverage sheet records **why** it was manual — gateway absent, or the user chose
  to supply the data — not that checks passed
- the accounting logic, edge cases and output standards are **unchanged**. That is the
  part of this skill that never depended on a connection
- mention **once** that connecting Mosofin would automate the manual steps, with a link
  to [docs.mosofin.com](https://docs.mosofin.com). Do not raise it again, and never
  withhold work to press the point

#### What a manual run actually does, gate by gate

| Gate | In a manual run |
|---|---|
| **Gate 0** — workspace | **Skipped.** There is no workspace to confirm. |
| **Gate 1** — data sources | **Skipped as a discovery step.** Still ask *which entity or company this work is for*, by name, so every output can be labelled — but record it as **user-asserted**, not confirmed against a connection. |
| **Gate 2** — capability map | **Skipped.** The map is not empty, it is uniform: **every task is `[manual]`.** |
| **Gate 3** — profile, then interview | **Runs, and grows.** The profile half cannot run — there is no company-profile tool — so everything it would have derived silently becomes a **question**: base currency, fiscal calendar, country or region, time zone. Then the interview runs in full, and **every row of the Inputs table that would have been `[auto]` becomes something to ask for.** |

Then **Part B runs unchanged** on what the user supplied.

**Ask the user to upload the data, and name the formats.** A manual run does not mean
retyping anything. Say plainly what to upload, in what form, and what each item is for —
then read it from the files they provide.

| Ask for | Upload as |
|---|---|
| Ledger detail, trial balance, transaction listings | **CSV** or **XLSX** export, or a pasted table |
| Statements and third-party documents | **PDF** or **CSV**, or a clear photo / scan |
| Invoices, bills, receipts, remittances | **PDF** or **image** — a single file or a batch |
| Short facts — a date, a balance, a policy | typed straight into the chat |

**Ask for the whole set up front, as a checklist, not drip-fed.** A person collecting
exports would rather be given one list than be interrupted six times. Mark which items
are strictly **required** and which merely improve the result, so they can decide how
much to gather.

**Confirm what actually arrived before starting the work.** Name each file, say what was
read from it — period covered, row count, opening and closing balances — and list what
is still outstanding. If a file is unreadable, covers the wrong period, or does not
contain what its name suggests, **say so at once**. Never work around a bad input
silently, and never guess at a column you cannot identify — ask.

**If something cannot be supplied, say what the output will and will not be — before
doing the work.** Never estimate a figure that was meant to come from the books, never
fill a gap with a plausible number, and never present a partial result as complete. An
honest partial answer, clearly labelled, is the correct outcome.

**Everything the user provides is evidence like any other.** Reconcile it, check it,
and challenge it where it does not tie. Manual input is not more trustworthy than a
ledger read — it is less, because nothing validated it on the way in.

**Present but not authenticated is not the same as absent.** If the tools are there and
a call returns a `reconnect_url` or an auth error, surface it and let the user choose —
reconnect, or continue manually. Do not silently fall back.

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
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`. A group
  variance report missing an entity will show a favourable cost variance that is simply absence.

A workspace can connect the **same platform several times** — several company files. Each is its
own row with its own `data_source_id` and `display_name`.

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every variance and commentary line carries its entity's
  `display_name`. **Never compare one entity's actuals to another's budget** — and be careful of
  the subtler version: a group total variance that nets a large overspend at one entity against an
  underspend at another tells management nothing. See the cross-entity step.

Refer to companies by `display_name`; never show the raw `data_source_id`.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability
map** — built this run, held for this run, written out as the coverage sheet, **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated.
- **Check the budget-reading tool first.** It decides whether this skill runs two-sided or
  one-sided. If it is `enabled`, read the budget from the system. If it is `disabled` or absent,
  the budget is **[manual]** and must be supplied — and a "variance report" produced without a
  budget is not a variance report at all.
- **A near-substitute is not a substitute.** **Prior-year actuals are not a budget.** Comparing
  this year to last year is a useful *additional* column (and the original asks for it) but it
  answers a different question: it measures change, not performance against plan. Never present a
  year-on-year comparison as a budget variance.
- **Monthly granularity matters.** An annual report cannot produce a monthly variance. If the
  report tool will not break down by month, say so rather than deriving monthly figures.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers:

- **Functional currency**
- **Fiscal calendar and year-end** — which defines what "QTD" and "YTD" actually mean. An entity
  with a June year-end has a very different year-to-date in September than a calendar-year one
- Country / region, industry

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Actual results for the period** — by line, by month | **Required — usually [auto]** | Normally pulled. |
| **Budget / forecast for the same period** — by line, by month | **Required — [auto] if the system holds it, otherwise [manual]** | **Ask which budget by name.** See the mid-year-revision edge case: comparing to the original budget, a revised budget, or the latest forecast tells three different stories. |
| **Period and granularity** — month, QTD, YTD | **Required** | Never default it. Confirm against the profile's year-end. |
| **Materiality threshold for commentary** — $ and/or % | Recommended — **[manual]** | **The user sets thresholds; if not provided, ask — don't assume.** Both an absolute and a relative one; see Step 4. |
| **Prior year actuals** — for YoY context | Recommended — usually **[auto]** | Normally pulled alongside. |
| **Driver data** — units, headcount, price, for decomposition | Recommended — **partly [auto]** | Units, prices and billable hours are often readable; headcount cost and planned drivers are usually **[manual]**. |
| **Account groupings / reporting hierarchy** — how lines roll up | Recommended — usually **[auto]** | The chart of accounts, classes and departments pull; confirm which grouping management actually reads. |
| **Known one-time items** in the period | Recommended — **[manual]** | Saves misattributing a legal settlement to run-rate cost. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | Especially the thresholds and any budget not held in the system. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the materiality thresholds, which budget version is being compared to, or the entity.

**On later runs** — and this skill runs monthly — read stored preferences first (Step 10), confirm
in one line, and ask only what is new, changed, or contradicted. The thresholds, the reporting
hierarchy and the budget version should not be re-asked every month.

---

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

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
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
- **Is a re-forecast warranted?** → hand to `rolling-forecast`
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

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

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
  both a cost overrun and a revenue beat. See `consolidation-and-eliminations`.
- **Each entity is compared to its own budget version**, and any entity on a different version is
  labelled — comparing one entity to a revised budget and another to the original makes the group
  number meaningless.

Capability is checked **per entity** at Gate 2: the budget tool may be enabled for one company file
and not its sibling, so the same analysis can be two-sided for one entity and one-sided for
another.

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
| `create_skill` | Persists the evolved skill. Step 10. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Actuals by line, by month** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` (Month), `accounting_method`, `department`, `class`, `customer` |
| **The budget, by account and period** | `search_budgets` | `name`, `active`/`limit`, `include_details`, `detail_start_date`, `detail_end_date`, `detail_account`, `detail_rollup` |
| Chart of accounts and line types | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Reporting groupings | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Transactions behind a variance; one-off detection | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Accrual true-ups and reclassifications | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Revenue by customer (mix, concentration) | `get_customer_sales` | `start_date`, `end_date`, `customer`, `summarize_column_by` |
| Units, prices and product mix | `search_invoices` / `read_invoice` / `search_items` | `start_date`, `end_date` (required); `id`; `query`/`name` |
| Spend by supplier behind a cost variance | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Bills and their dates (timing variances) | `search_bills` / `get-bill` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Headcount for personnel decomposition | `search_employees` | `query`/`name`, `active_only` |
| Billable hours (services volume) | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Balance-sheet context for accrual movements | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Budget vs. actual (BvA)** — comparing what happened to what you planned.
- **Variance** — the gap between them.
- **Favorable / unfavorable (F/U)** — whether the gap is good or bad, which depends on the line
  type, not the sign.
- **FP&A** — financial planning and analysis: the function that plans, forecasts and explains.
- **Materiality threshold** — the size below which a variance isn't worth explaining.
- **Decomposition** — breaking a variance into the reasons for it.
- **Volume variance** — the effect of selling or using a different quantity.
- **Price / rate variance** — the effect of a different price or unit cost.
- **Mix variance** — the effect of a different blend of products or customers.
- **Efficiency variance** — using more or less input per unit of output than planned.
- **FX variance** — the effect of exchange rates moving.
- **Constant currency** — restating at one exchange rate so currency movement is stripped out.
- **Timing variance** — it will still happen, just in a different period.
- **Permanent variance** — a real departure from plan.
- **Run-rate** — the annualised level implied by a recent period.
- **True-up** — correcting an earlier estimate once the real figure is known.
- **Phasing** — how an annual budget is spread across months.
- **Waterfall / bridge** — a chart showing how you got from one number to another in steps.
- **QTD / YTD** — quarter to date / year to date, measured against the *fiscal* year.
- **YoY** — year on year.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Zero or near-zero budget line with actual spend**: the % variance is undefined or huge. **Show the
dollar variance and flag "no budget"** rather than a meaningless %. *Mosofin note*: an account
present in the actuals but absent from the budget is directly detectable at Step 1 — list them
before computing anything.

**Reclassification between actual and budget**: if a cost was budgeted in one line but booked in
another, the variance is misleading — one line is over and another under by the same amount.
**Reclassify to compare like with like, and note it.** *Mosofin note*: paired equal-and-opposite
variances are a strong signal of exactly this; test for them.

**Budget not phased monthly (annual / 12)**: if the budget was crudely spread evenly but the
business is seasonal, monthly variances will be noise. **Flag the phasing issue; compare YTD which
is more meaningful.** *Mosofin note*: detectable — a budget with identical monthly values is
evenly spread by construction. Say so rather than explaining twelve months of seasonal noise.

**Mid-year budget revision**: clarify whether comparing to the original budget, a revised budget, or
the latest forecast. **Each tells a different story; label clearly.** *Mosofin note*: where the
system holds several budgets, **list them and ask which one** — never pick the most recent by
default, and always name the chosen one on the face of the report.

**FX-driven variances**: separate operational performance from currency translation.
**Constant-currency variance isolates the real performance.**

**One-time items in actuals**: large one-offs (legal settlement, asset sale gain, restructuring)
distort the variance. **Call them out separately so the underlying run-rate is visible.**

**Accrual catch-ups**: a true-up of a prior accrual hits one month, distorting that month's
variance. Note it. *Mosofin note*: journal entries around period end are directly readable and are
where these live.

**New initiatives not in the original budget**: if the board approved spend after the budget was
set, the variance to the original budget is **"expected."** Compare to the revised plan and say so.

**Cumulative immaterial variances adding up**: several small unfavorable variances can aggregate to
a material full-year miss. **Watch the YTD trend, not just the month.**

**Revenue timing vs. permanent**: a deal slipping from this month to next is timing; **a lost deal
is permanent.** Treat them differently — and note that the ledger cannot tell them apart, so this
one always needs the business.

**No budget is available in the system** — *Mosofin-specific*. Ask for it. **Do not substitute
prior-year actuals and call the result a variance report** — that measures change, not performance
against plan.

**A cause was written that the ledger does not evidence** — *Mosofin-specific, and the most
important discipline in this skill*. Commentary goes to management verbatim. Name the transactions,
mark unknown causes as **to be confirmed** with an owner, and never narrate a business event nobody
mentioned.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded. Its
absence will read as a favourable cost variance if not stated. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data cannot support
commentary that management will act on.

**A stored threshold no longer suits the entity's scale** — *Mosofin-specific*. A business that has
doubled needs a bigger threshold, or the report becomes unreadable. Revisit thresholds when the
count of commentary-required lines jumps.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every variance computed ($ and %) with **correct F/U classification by line type**
- Materiality filter applied (thresholds from the user)
- **Material variances decomposed into drivers, not just restated**
- Timing vs. permanent distinguished
- Full-year implications assessed for permanent variances
- Commentary is concise and driver-based
- YoY context included where available
- FX and one-time items isolated
- File naming consistent
- **No meaningless % on zero-budget lines; no assumed materiality thresholds**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The budget version being compared to is named on the face of the report**
- **Prior-year actuals are never presented as a budget**
- Accounts present in one side and not the other are listed **before** variances are computed
- Any account mapping between budget lines and actual accounts is **shown, not applied silently**
- Every variance carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- **Every commentary line records whether its cause was evidenced in the ledger, supplied by a
  person, or is still to be confirmed** — and no cause is invented
- `mock` status is reported wherever it applies, and no commentary presented to management rests on
  mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No variance figures, commentary or outlook are persisted into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every revision and reclassification is a proposal for a
  human
