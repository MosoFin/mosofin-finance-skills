<!-- journal-entry-review · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before screening anything. This ordering is the contract. Do not
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

**An excluded entity is a scope limitation** in the audit sense — **and JE testing is a required audit
procedure**, so an entity whose entries could not be screened must be named as unscreened rather than
passed over.

**Check for a connected consolidation or reporting platform.** **Topside entries** — see the edge cases —
are frequently made above the subledgers in a separate system, and **they are the higher-risk population.**
If that system is not connected, **the topside entries are not in your population**, which is a material
limit on the review.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`.
- **Multi-entity** — ask which set. **Screen each entity separately**; see the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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

Resolve **every criterion in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**Check which fields the entry read actually returns.** **The criteria you can test depend entirely on the
fields available** — posting date versus effective date, user, description, source. **Establish the field
list before designing the screen**, and record which criteria are unavailable because a field is not
exposed.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A flag is not a finding.** The whole discipline.
  - **A user name is not a person.**
  - **Absence of approval data is not absence of approval.** The control may exist and simply not be
    exposed here.
  - **A system-source label is not proof an entry was system-generated.** See the edge cases.
  - **Entries visible here are not necessarily the whole population** — topside and consolidation entries
    may live elsewhere.
- **There is no approval workflow, no supporting document and no interview on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, **fiscal calendar and period
ends** — which the timing criteria depend on — country / region.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Journal entry population~~ | **Now [auto]** | **Full population, not a sample.** Confirm the field list. |
| **Period under review** | **Required** | |
| **Chart of accounts with risk-sensitive accounts noted** | Recommended — **[gated]** | **The chart is `[auto]`; which accounts are sensitive here is `[manual]`** — though revenue, reserves, equity and suspense are readable by type. |
| **Approval / workflow data** — who approved, approval status | Recommended — **[manual]**, usually | **Generally not on this surface.** Ask for the approval log. |
| **Expected posting patterns** — normal volumes, timing, sources | Recommended — **now [auto]** | **Derivable from history**, which is better than an expectation. |
| **Materiality threshold** | Recommended — **[manual]** | Needed for magnitude screening and the below-threshold test. |
| **Known risk areas** | Recommended — **[manual]** | Focuses the review. |
| **Authorization thresholds** | **Required for the just-below test — [manual]** | The test is meaningless without them. |
| **Whether topside entries exist and where** | **Required — Mosofin addition** | They may not be in this population at all. |
| **Who may see the output** | **Required — Mosofin addition** | It names people. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm manual evidence** | **Required** | Approval data, thresholds and known risk areas are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an authorization
threshold, a materiality level, or a conclusion about an entry.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The criteria set, the scoring weights, the sensitive-account list and the cleared-pattern rules persist;
**every flagged entry is re-derived**, and **no flag is carried forward.**

---
