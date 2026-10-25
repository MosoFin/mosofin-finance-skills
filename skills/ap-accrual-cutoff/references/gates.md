<!-- ap-accrual-cutoff · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before identifying any accrual. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** —
`list_workspaces`, `get_agent_datasources`, `get_datasource_tools`,
`invoke_datasource_api_tool`, `get_skills`, `get_my_skill`, `create_skill`. Do not add a
`mosofin_` prefix and do not hardcode a client-side `mcp__…` namespace; that string is
composed by whichever MCP client is running.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the
opaque `ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded** ("*Northwood Demo Books* is
  present but not active, so no accrual below draws on it"). A cutoff schedule that silently
  omits an entity understates the period's costs. Surface any `reconnect_url`.

A workspace can connect the **same platform several times** — several company files, plus
purchasing or payment platforms. Each is its own row with its own `data_source_id` and
`display_name`.

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and a combination step follows. Every accrual line
  carries its entity's `display_name`. Two entities' accrued liabilities are never added into
  one figure without that label.

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
map** — built this run, held for this run, written out as the coverage sheet, **never**
written into this file.

Rules that bite this skill in particular:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated. In this skill you will reach for both a
  purchase-order search and a single-bill read, and those two are often styled differently
  in the same catalog. Take the exact string from the Gate 2 listing.
- **A near-substitute is not a substitute.** If the purchase-order tool is disabled, a vendor
  *spend* report is not a stand-in: spend shows what was already billed, which is precisely
  the population that does **not** need accruing. GRNI is what is *missing* from spend. Mark
  it `[manual]` and say so.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** what the profile answers:

- **Functional currency** — the base currency the books are kept in. Ask about currency only
  if the transactions show more than one.
- **Fiscal calendar and year-end** — which tells you whether this cutoff is a routine month-end
  or the year-end one, and year-end usually carries a tighter materiality.
- Country / region and time zone.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being closed** — month or quarter, exact dates | **Required** | Never default the period. |
| **Open POs and receipts (GRNI candidates)** | **Required for GRNI accruals** | Purchase orders are usually **[auto]**; the **goods-receipt record is often [manual]** — see Step 1. Ask where receipts are logged. |
| **Recurring vendor schedule** — vendors with regular monthly bills | Recommended — largely **[auto]** | Normally derivable from spend history; ask the user to confirm and add anything the books do not show. |
| **Invoices received post-period** — bills dated after period end for in-period services | Recommended — usually **[auto]** | Normally pulled by searching bills after period end. |
| **Chart of accounts** — the accounts to post to | **Required — usually [auto]** | Pulled from the books; ask the user to confirm the specific accrued-liability account, since naming varies. |
| **Tax jurisdiction** | **Required if tax is recoverable** | Drives the Step 4 tax decision. Do not assume. |
| **Materiality threshold for accruals** | Recommended | If not given, accrue everything identified — and say that is what you did. |
| **Functional currency** | Recommended — usually derived | Ask only to resolve a contradiction or where several currencies appear. |
| **Subsequent-event window** — how many days after period end to look for late invoices | **Required** | Drives the Step 3 search range. Common answer is "up to the date the books close". |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's year-end does not match the period named. |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the
period, the accounting method, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only
what is new, changed, or contradicted. The interview shrinks; the gates never do.

---
