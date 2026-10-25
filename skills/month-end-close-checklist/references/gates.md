<!-- month-end-close-checklist · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before building the checklist. This ordering is the contract. Do not
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

**This gate answers half of the entity profile the original asks for as an input**, and it drives Step 1's
Day 6:

- **One connected company file** → **no consolidation phase.** Day 6 drops out entirely.
- **Several** → **Day 6 applies**, and **the close is only as fast as its slowest entity.** See the
  cross-entity step under *Both entity scenarios* in [`method.md`](method.md).
- **Connected subledger platforms** — payroll, billing, inventory, expenses — **tell you which Day 1 and
  Day 2 tasks have a system behind them** and which are manual.

**A group member that is not connected still has to close.** Its tasks belong on the checklist with an owner
— **they simply cannot be status-checked from here.** Say which.

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
