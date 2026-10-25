<!-- payroll-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path (Gates 0–3, including the Gate 3 interview). Edit here, not in SKILL.md. -->

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

**Check for a connected payroll platform.** **If one is live, the register and the taxable wage bases become
`[auto]`** — which converts Steps 1, 4 and 5 from partial to complete. **This is the single most
consequential connection for the payroll skills**, and it is worth saying so.

Settle the entity scenario:

- **Single-entity** — one company file, one register.
- **Multi-entity** — ask which set. **A shared payroll service across entities** means the register covers
  several and **each entity's GL holds only its share.** See the cross-entity step.

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

Resolve **every reconciliation in Part B** against these buckets. The resolved list is the **capability
map** — built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **Gross wages are not a taxable wage base.** The central limit above.
  - **A payment to a tax authority is not proof of remittance of the right amount for the right period** —
    and **with a third-party provider, it is not even proof the provider remitted at all.**
  - **A recorded disbursement is not a bank statement.** Consistent with `bank-reconciliation`.
  - **A nil difference is not a reconciliation** where both sides came from the same postings.
- **There is no payroll register, no wage base, no bank statement and no filing on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, **fiscal calendar** — which sets the
quarter and year ends where Steps 4 and 5 bite — **country / region**.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| **Payroll register(s) for the period** | **Required — [gated]** | **`[auto]` if a payroll platform is connected.** |
| ~~GL payroll accounts activity~~ | **Now [auto]** | Confirm which accounts are in scope. |
| **Bank statement / payment records** | **Required — [gated]** | **Recorded disbursements `[auto]`; the statement `[manual]`.** |
| **Liability remittance records** | **Required for liability rec — [gated]** | **Payments `[auto]`; the authority's receipt `[manual]`.** |
| **Period** — month / quarter / year | **Required** | **Steps 4 and 5 apply at quarter and year end.** |
| **Tax filing figures** | Recommended — **[manual]** | Prepared with the payroll tax filings. |
| **Prior period reconciliation** | Recommended — **[gated]** | **Opening balances `[auto]`; carried items `[manual]`.** |
| **The taxable wage base rules** per tax | **Required for Step 5 — [manual]** | Pre-tax deductions, caps, ceilings. **Not derivable here.** |
| **Remittance due dates** per liability | **Required for the overdue flag — [manual]** | |
| **Whether a third-party provider handles remittance** | **Required — Mosofin addition** | **The entity remains liable**; see the edge cases. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The register, wage bases, filings and bank statement are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a wage base rule, a due
date, or a remittance status.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only what changed.
The account map, the wage base rules, the due dates and the known reconciling items persist; **every balance
and every tie-out is re-performed.**

---
