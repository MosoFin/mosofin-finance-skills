<!-- budget-vs-actual-analysis · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path (the budget tool decides two-sided or one-sided), and the Gate 3 interview. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

## Contents

- ONBOARDING — Confirm the workspace and its data sources
  - Gate 0 — Confirm the workspace
  - Gate 1 — Discover live datasources and settle the entity scenario
- PART A — Explore the confirmed sources, and personalise this run
  - Gate 2 — Discover enabled tools → build the capability map
  - Gate 3 — Profile the entity, then interview the user


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

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

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
  underspend at another tells management nothing. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

Refer to companies by `display_name`; never show the raw `data_source_id`.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map

*The write-tool guardrail that belongs here is in [`mosofin-protocol.md`](mosofin-protocol.md) under "Write tools — the Gate 2 guardrail". It applies in full at this gate.*

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
