<!-- payroll-clearing-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path (Gates 0–3, including the Gate 3 interview). Edit here, not in SKILL.md. -->

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

**Check specifically for a connected payroll platform.** **If one is live, the payroll register becomes
`[auto]`** — the accrual half of every roll-forward, the YTD figures, the by-component detail. **That
converts this skill's largest manual input.** **If none is, say so**, and say which steps therefore rely on
supplied data.

Settle the entity scenario:

- **Single-entity** — one company file, one set of payroll accounts.
- **Multi-entity** — ask which set. **A shared payroll service running several entities** is common, and
  **the clearing account is per entity.** See the cross-entity step.

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
  - **A GL payroll balance is not a payroll register.** It is a total posted by a journal.
  - **A payment out of the bank account is not proof of remittance to the right authority** — the payee and
    the memo are evidence, and the tax authority's acknowledgement is not here; it sits with the payroll tax filings.
  - **A recorded disbursement is not a bank statement.** The same limit as `bank-reconciliation` and
    `merchant-and-payment-processor-rec`.
  - **A nil balance is not a reconciled account.** Two errors can offset.
- **There is no payroll register, no benefit provider statement, no court order and no bank statement on
  this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar, **country /
region — which drives which liability accounts exist.**

**Ask the user** what actually changes the work — the original Inputs table, **minus the parts the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being reconciled** | **Required** | |
| ~~GL balances for each payroll account~~ | **Now [auto]** | **Confirm which accounts are in scope.** |
| **Payroll register(s) for the period** | **Required — [gated]** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise.** |
| **Remittance / payment evidence** | **Required — [gated]** | **Payments are `[auto]`; the authority's acknowledgement is not.** |
| ~~Chart of accounts~~ | **Now [auto]** | |
| ~~Tax jurisdiction~~ | **Now [auto]** | Country from the profile. **The remittance cadence is `[manual]`.** |
| **Benefit provider statements** | Recommended — **[manual]** | |
| **Prior period reconciliation** | Recommended — **[gated]** | **Opening balances `[auto]`; carried items `[manual]`.** |
| **The remittance cadence per liability** | **Required — Mosofin addition** | **Monthly, semi-weekly, quarterly.** **The expected-balance pattern depends on it entirely.** |
| **Materiality threshold** for write-offs | Recommended — **[manual]** | |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the accounts covered. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. withholding accounts for a jurisdiction the entity does not operate in. |
| **Confirm manual evidence** | **Required** | The register, provider statements and cadences are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a remittance cadence,
a write-off, or an escheatment treatment.

**On later runs**, read stored preferences first (Step 10), confirm in one line, and ask only what changed.
The account list, the cadences, the expected-balance patterns and the tolerance persist; **every balance and
every ageing is re-obtained.**

---
