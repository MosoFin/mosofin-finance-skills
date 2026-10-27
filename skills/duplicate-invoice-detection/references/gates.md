<!-- duplicate-invoice-detection · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before scanning anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between runs.

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

Settle the entity scenario — and here it produces a genuinely additional detection pattern:

- **Single-entity** — ask which company by `display_name`; the scan runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The scan runs **once per entity**, every call targeting exactly one
  `data_source_id`. **Then run the cross-entity scan**: the same supplier invoice paid by two group
  entities is a duplicate that neither entity's own scan can see, and it is a well-known pattern in
  groups with shared suppliers and decentralised AP. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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

Resolve **every rule in Step 2** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated, and this skill uses both a bill *search* and a single-bill *read*.
- **Pull the whole population, not a page of it.** Duplicate detection is a comparison across every record;
  a truncated result set produces **false negatives that look like clean results**. Use pagination
  deliberately, and **state the record count scanned** — a scan of 500 bills out of 4,000 is not a scan.
- **A near-substitute is not a substitute.** A **vendor spend summary** is a total per supplier; it cannot
  compare individual invoices, which is the entire task. If the bill-level search is disabled, this skill
  cannot run — say so rather than reporting no duplicates found.
- **There is no vendor bank detail on this surface.** Rule 7 is `[manual]`; do not look for a substitute.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which tells you whether the multi-currency
caution in Rule 3 and the edge cases applies at all — fiscal calendar and year-end, which matters for the
cross-period pattern.

**Ask the user** what actually changes the work — the original Inputs table, minus what the connected books
already answer:

| What to confirm | Required? | Notes |
|---|---|---|
| **AP / payment register** | **Required — [auto]** | **Do not ask for an export; read it.** Confirm the population and the record count. |
| **Period to scan** | **Required** | Never default it. **Scan wider than the current period** — duplicates frequently straddle a boundary. |
| **Vendor master** | Recommended — **[auto]** | Read. Needed for the alias rules. |
| **Prior duplicate-detection results** | Optional — **[manual]** | So previously cleared clusters are not re-raised. |
| **Sensitivity setting** — Strict / Standard / Permissive | Optional — **[manual]**, default Standard | See Step 3. |
| **N for Rule 3** — the date window | Optional | Default 7 days; confirm if the entity's invoicing pattern is unusual. |
| **Known legitimate recurring suppliers** | Recommended | Rent, subscriptions and retainers legitimately repeat at identical amounts. Naming them up front removes most false positives. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and whether a cross-entity scan applies. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | Rule 7 is `[manual]`. Say so before reporting results. |

Ask as **one short batch**. Propose defaults where reasonable — the sensitivity and the date window have
sensible defaults and can be stated rather than asked — but **never** default the period or the entity.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The cleared-cluster list, the recurring-supplier list and the sensitivity setting persist; **the scan is
always re-run**.

---
