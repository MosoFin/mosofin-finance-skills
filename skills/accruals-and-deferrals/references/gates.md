<!-- accruals-and-deferrals · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before computing any accrual. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** —
`list_workspaces`, `get_agent_datasources`, `get_datasource_tools`,
`invoke_datasource_api_tool`, `get_skills`, `get_my_skill`, `create_skill`. Do not add a
`mosofin_` prefix and do not hardcode a client-side `mcp__…` namespace; that string is
composed by whichever MCP client is running and differs between clients.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → the tool auto-confirms it. Read the workspace **name** back to the
  user and **wait for an explicit yes** before reading any data.
- **Two or more** (`selection_required`) → ask **in chat**: "Is this a single-workspace or
  a multi-workspace job?" Then ask which workspace(s) **by name**, and call
  `list_workspaces` again with `workspace_ids=[…]` and `mode="single"` or `mode="multi"`.

Never auto-pick a workspace. Never print an internal numeric tenant id — refer to a
workspace by its human name, and pass the opaque `ws_…` handle between tools.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- Rows with `connected: true` are **in scope**.
- Rows with `connected: false` are **excluded — and you must name them as excluded**
  ("*Northwood Demo Books* is present but not active, so no accrual below draws on it").
  A dead connection that goes unmentioned makes the accrual schedule look complete when it
  is not. If the envelope offers a `reconnect_url`, surface it.

A workspace can connect the **same platform several times** — several company files, plus
payment or payroll platforms. Each is its own row with its own `data_source_id` and
`display_name`.

When more than one entity is live, ask the user which scenario applies:

- **Single-entity** — ask which company by `display_name`. The whole workflow runs against
  that one `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and a combination step follows (see "Both entity
  scenarios"). Every accrual, balance, and roll-forward is **labelled with its datasource
  and `display_name`**. Two entities' accrued liabilities are never added into one figure
  without that label.

Refer to companies by `display_name`. Never show the raw `data_source_id` — pass it between
tools.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map

*The write-tool guardrail that belongs here is in [`mosofin-protocol.md`](mosofin-protocol.md) under "Write tools — the Gate 2 guardrail". It applies in full at this gate.*

For **each in-scope datasource** (and, when several company files are live, **per company
file** — pass `data_source_id`), call `get_datasource_tools`. Bucket every returned tool by
its `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Then resolve **every task in Part B** against these buckets. That resolved list is the
**capability map**. It is built this run, held for this run, written out as the coverage
sheet — and **never** written into this file. Policies differ per workspace *and* per
company file, and change between periods.

Two rules that bite this skill in particular:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated. Take the exact string from the Gate 2 listing.
- **A near-substitute is not a substitute.** If the detailed transaction-level ledger tool
  is disabled, a summary balance report is *not* a stand-in: a balance tells you the accrued
  liability account's total, not which items make it up, and a roll-forward you cannot
  itemise is not a roll-forward. Mark the task `[manual]` and say so.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** everything the profile answers, and do not ask about it:

- **Functional currency** — the base currency the books are kept in. Only ask about currency
  if the transactions show more than one.
- **Fiscal calendar and year-end** — which tells you where the period sits in the year, and
  therefore the year-to-date fraction used in a bonus accrual.
- Country / region and time zone.
- Industry, which hints at which accrual categories are likely to matter.

**Ask the user** only what changes the work. This is where the original Inputs table lives,
minus what the profile already answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being closed** — exact start and end dates | **Required** | Never default the period. |
| **Categories of accruals / deferrals in scope** — compensation, interest, utilities, revenue, etc. | **Required** | Offer the Step 1 / Step 2 category lists as a checklist rather than an open question. |
| **Supporting data per category** — bonus pool, interest rate, contract terms, time sheets | **Required per category** | Much of this is **[manual]**; ask only for what the connected books cannot show. Say which is which. |
| **Chart of accounts** — the accounts to post to | **Required — usually [auto]** | Normally pulled from the connected books; ask the user to confirm the specific accrued-liability, accrued-revenue and deferred-revenue accounts, since naming varies. |
| **Materiality threshold** — the dollar size below which an item isn't worth accruing | Recommended | Ask; do not invent a figure. If declined, accrue everything found and say so. |
| **Reporting framework** — US GAAP / IFRS / other | Recommended | Affects presentation and some measurement. |
| **Tax jurisdiction** | Recommended | For tax recoverability and employer-side payroll tax on compensation accruals. |
| **Functional currency** | Recommended — usually derived | Ask only to confirm a profile contradiction, or if several currencies appear. |
| **Reversal policy** | **Required** | Do accruals reverse automatically on day one of the next period, or does the incoming invoice post straight against the accrual account? Both are valid; the answer changes Step 5. |
| **Confirm scope** | **Required** | Read back which company files are in scope and which are excluded, by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's year-end does not match the period the user named. |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

Ask these as **one short batch**. Propose sensible defaults where reasonable — but **never**
default the period, the accounting method, or the entity.

**On later runs**, read the stored preferences first (see Step 9), confirm them in one line,
and ask only what is new, changed, or contradicted. The interview shrinks. The gates never do.

---
