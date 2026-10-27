<!-- financial-statement-builder · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before building anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

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

**This gate matters more here than almost anywhere else in the pack.** Financial statements have a
**reporting entity**, and the reporting entity is defined by which company files are in scope. **A
disconnected subsidiary is not a gap in a workpaper — it is a set of statements covering the wrong
organization.**

Settle the entity scenario explicitly:

- **Single-entity** — ask which company by `display_name`. Statements cover that entity alone.
- **Multi-entity** — ask which set, and then: **are these consolidated statements, or a set of separate
  entity statements?** The two are entirely different deliverables. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute**, and in this skill the substitutes are unusually seductive
  because they look like finished statements:
  - **The platform's balance sheet is not a framework balance sheet.** It is a report in the platform's own
    groupings.
  - **An account type is not a current / non-current classification.** "Long Term Liability" as a type does
    not tell you the portion due within twelve months.
  - **The ledger's prior year is not the filed prior year** — see above.
  - **Retained earnings on the balance sheet is not proof the equity statement ties**; it is one of the two
    numbers you are comparing.
  - **A cash balance is not the cash flow statement's closing cash** until you have proved they agree.
- If `get_trial_balance` is `disabled` but `get_balance_sheet` and `get_profit_and_loss` are enabled, **you
  can still build** — say that the source was the statements rather than the TB, and note that account-level
  detail is coarser.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: **legal name** — which is what goes on the statement header —
**functional currency**, **fiscal calendar and year-end**, country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the five the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Trial balance, current period~~ | **Now [auto]** | `get_trial_balance` at the period end. |
| ~~Comparative period TB~~ | **Now [auto]** | Same call, prior period end. **But see the published-comparative warning.** |
| **Reporting framework** — US GAAP / IFRS / local GAAP | **Required — [manual]** | **Ask first.** It decides ordering, terminology and format throughout. |
| ~~Functional / presentation currency~~ | **Now [auto]** | From the profile. **Ask only if presentation currency differs from functional.** |
| ~~Entity name and reporting period~~ | **Now [auto]** | Legal name from the profile; confirm the period. |
| ~~Chart of accounts with type mapping~~ | **Now [auto]** | From `search_accounts`. |
| **Classification rules** — current / non-current criteria | Recommended — **[gated]** | **The current portion of debt and leases is the hard part**; it needs the amortization schedules. |
| **Special presentation elements** — discontinued ops, extraordinary items, segments | If applicable — **[manual]** | Nothing in the ledger flags a disposal group. |
| **Prior-year audited financials** — for continuity | Recommended — **[manual]**, and **more important than the original implies** | The check that catches unposted audit adjustments. |
| **Presentation currency**, if different from functional | If applicable — **[manual]** | Translation per ASC 830 / IAS 21. |
| **Rounding basis** | Recommended — **[manual]** | Whole units, thousands, millions. |
| **Share count for EPS**, if EPS is required | If applicable — **[manual]** | **Weighted average shares are not in the ledger.** |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, **and whether the package is consolidated or separate**. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. a year-end that disagrees with the period requested. |
| **Confirm manual evidence** | **Required** | The framework, the prior-year financials, the debt schedules and any EPS data are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a framework, a
current / non-current split, a rounding basis, or a share count.

**On later runs**, read stored preferences first (Step 12), confirm in one line, and ask only what changed.
The framework, the account-to-line mapping, the classification rules and the rounding basis persist; **the
balances are re-obtained every period**.

---
