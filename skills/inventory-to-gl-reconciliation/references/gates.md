<!-- inventory-to-gl-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the contract. Do not
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

**This gate answers the one-system-or-two question.** **Check specifically for a connected inventory, WMS,
manufacturing or 3PL platform.** If one is live alongside the accounting platform, **both sides of the
subledger-to-GL comparison are readable and the reconciliation is genuine.** If only the accounting platform
is connected, **the item module is almost certainly the same database as the GL** — say so.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`.
- **Multi-entity** — ask which set. **Stock held for another group entity, and stock in transit between
  entities, are the recurring cross-entity issues.** See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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
- **A near-substitute is not a substitute:**
  - **A same-system agreement is not a reconciliation.** The central point above.
  - **Quantity on hand is not physical quantity.** **Only a count proves existence.**
  - **A location field is not proof of location.** It records where the system thinks the goods are.
  - **A consignment flag is not a title determination** — ownership turns on the contract.
  - **A variance account balance is not an explained variance.** It is where unexplained differences have
    been accumulating.
- **There is no physical count, no 3PL statement, no Incoterms and no warehouse team on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar and year-end,
country / region.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Inventory subledger / system extract~~ | **[auto]** if an items module exists — **but see the one-system question** | Confirm whether it is a separate system. |
| ~~GL inventory balance(s) at period end~~ | **Now [auto]** | From the trial balance, by account. |
| **Physical count results** — counted SKUs, quantity, location | **Required for the count comparison — [manual]**, always | **The only leg that tests existence.** Ask when it was last done. |
| **Period being reconciled** | **Required** | |
| ~~Chart of accounts~~ | **Now [auto]** | Including which accounts are which inventory category. |
| **Inventory locations / warehouses** | Recommended — **[gated]** | Readable where location tracking is used. |
| **Standard cost vs. actual cost variance accounts** | Recommended — **[auto]** where they exist | Their balances are readable; **the absorption policy is `[manual]`.** |
| **In-transit / consignment inventory** — quantity and value | Recommended — **[manual]** | **Title terms are contractual.** |
| **Inventory reserve / write-down policy** | Recommended — **[manual]** | Setting the reserve itself is an inventory obsolescence task. |
| **Whether the subledger is a separate system** | **Required — Mosofin addition** | **Decides what this reconciliation proves.** |
| **When the last physical count was performed** | **Required — Mosofin addition** | If never, that is the finding. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The count, the 3PL statement and the title terms are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a count result, a
title determination, or a variance explanation.

**On later runs**, read stored preferences first (Step 10), confirm in one line, and ask only what changed.
The account map, the location structure, the known reconciling items and the count cadence persist; **every
balance, quantity and variance is re-obtained each period.**

---
