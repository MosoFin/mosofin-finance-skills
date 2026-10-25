<!-- closing-entries-and-trial-balance · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before computing anything. This ordering is the contract. Do
not skip a gate because a previous conversation covered it — connections, permissions, and company
files change between periods.

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

Settle the entity scenario — and here the domain rule is unusually clean:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. **Each entity closes its own books.** The workflow runs **once
  per entity**, every call targeting exactly one `data_source_id`, and every entry, trial balance and
  tie-out carries that entity's `display_name`. **There is no such thing as a group closing entry** —
  consolidation is a separate procedure performed on already-closed
  entity books. Never combine trial balances before closing.

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
built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled —
  some underscored, some hyphenated.
- **The account-search tool carries the account *types*, and those types decide the whole procedure.**
  Temporary versus permanent is a function of account type, not of account name — a "Gain on
  Disposal" account is temporary, a "Treasury Stock" account is permanent, and neither is obvious
  from wording alone. If the account tool is disabled, classification becomes `[manual]` and must be
  confirmed account by account.
- **A near-substitute is not a substitute.** A **balance sheet plus a P&L** is not a **trial
  balance**: the reports are already classified and totalled, so they cannot show whether debits
  equal credits at the account level, which is the entire point of Step 1. If the trial balance tool
  is disabled, say the balance check could not be performed.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers:

- **Fiscal year end** — which defines the closing date and the first day of the new year. **The most
  important field in this skill**; a closing run against the wrong year-end closes the wrong twelve
  months
- **Functional currency**
- Legal name, country / region, industry

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Fiscal year end date** | **Required — usually [auto]** | Derived from the profile; **read it back and confirm**, since a changed year-end is common and the profile may lag. |
| **Pre-closing trial balance** | **Required — usually [auto]** | Pulled at the year-end date. Confirm it is the **final** TB, after adjusting entries. |
| **Entity type** — corporation / partnership / LLC / sole proprietor / nonprofit | **Required — [gated]** | Legal form is not a ledger field, but the **equity account names are a strong signal** (Owner's Draw, Member Capital, Net Assets). Propose what the accounts suggest and **have the user confirm** — Step 5's entry differs entirely by type. |
| **Chart of accounts with account types** | **Required — usually [auto]** | Pulled. This drives the temporary / permanent split. |
| **Functional currency** | **Required — usually [auto]** | Derived. |
| **Dividends / distributions declared during the year** | If applicable — usually **[auto]** | Readable as movement on the dividends or draws account. |
| **Prior year's retained earnings** (closing balance) | **Required for continuity — usually [auto]** | Pulled from the balance sheet at the prior year end. |
| **Reporting framework** — US GAAP / IFRS / Local GAAP / Other | Recommended — **[manual]** | Affects OCI treatment. |
| **Other comprehensive income items** | Recommended — **[gated]** | OCI accounts are readable where they exist; whether an item belongs in OCI is **[manual]**. |
| **Whether the platform auto-closes the year** | **Required** | See the banner above and Step 0b. **Test it, then confirm with the user.** |
| **Whether the audit is complete** | Recommended | Determines preliminary versus final close — see the edge case. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the fiscal
year end, the entity type, or the framework.

**On later runs** — this is annual — read stored preferences first (Step 11), confirm in one line,
and ask only what changed. The entity type, the closing method and the account classification should
not be rebuilt each year.

---
