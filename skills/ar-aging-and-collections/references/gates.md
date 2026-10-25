<!-- ar-aging-and-collections · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, and the guardrails that hold throughout. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

## Contents

- ONBOARDING — Confirm the workspace and its data sources
  - Gate 0 — Confirm the workspace
  - Gate 1 — Discover live datasources and settle the entity scenario
- PART A — Explore the confirmed sources, and personalise this run
  - Gate 2 — Discover enabled tools → build the capability map
  - Gate 3 — Profile the entity, then interview the user
  - Guardrails


# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before any data read. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a
client-side `mcp__…` namespace; that string is composed by whichever MCP client is running.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace

1. Call `list_workspaces` with **no arguments**.
2. If **multiple** workspaces are returned, ask whether this is a single- or multi-workspace
   task, ask which workspace(s) **by name**, confirm them with `workspace_ids=[…]` and
   `mode="single"` / `mode="multi"`, and use only the returned opaque `ws_…` handle(s).
   **Never expose internal numeric IDs.**
3. If **one** workspace is returned, read its name back and **wait for explicit user
   confirmation** before continuing.

## Gate 1 — Discover live datasources and settle the entity scenario

4. Call `get_agent_datasources` for the confirmed workspace. Require an **ACTIVE** datasource
   (`connected: true`). Rows with `connected: false` are **excluded and named as excluded** —
   an aging that silently omits an entity understates what the group is owed.
5. If **multiple company files are active**, ask the user to choose by `display_name`. Pass
   the chosen `data_source_id` on every subsequent Mosofin call; **never show that ID**.

**If the datasource is disconnected, expired, or not ACTIVE, stop.** Show the Mosofin
`reconnect_url`, tell the user to reconnect in Mosofin, and wait for confirmation before
retrying. **Do not substitute CSVs or guessed numbers while the user is asking for live
Mosofin data.**

Settle the entity scenario:

- **Single-entity** — one company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and every aging row, metric and draft carries its
  entity's `display_name`. Two entities' receivables are never blended into one figure
  without that label — and DSO in particular is meaningless when blended, because each
  entity has its own sales base.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map

*The write-tool guardrail that belongs here is in [`mosofin-protocol.md`](mosofin-protocol.md) under "Write tools — the Gate 2 guardrail". It applies in full at this gate.*

6. Call `get_datasource_tools` for each in-scope datasource — and **per company file** when
   several are live, since **permissions are per company**. Bucket every tool by
   `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Use only tools whose effective policy is `enabled` or `permission`; **never use `disabled`
tools.** Resolve **every task in Part B** against these buckets. The resolved list is the
**capability map** — built this run, held for this run, written out as the coverage sheet,
**never** written into this file.

**The connector catalog is authoritative for exact `tool_name` values. Do not invent a tool
name.** Names are not uniformly styled — some underscored, some hyphenated — so take the exact
string from the Gate 2 listing. On an `UNKNOWN_TOOL` error, read the valid names from the
error itself.

Two capability judgments specific to this skill:

- **Aging summary versus aging detail are different capabilities.** A summary gives totals per
  customer per bucket; a detail gives one row per invoice. **If no complete A/R detail
  capability is listed, do not claim that an invoice search is a complete historical aging
  population** — most invoice searches default to a recent date range and will silently omit
  old unpaid invoices, which are precisely the ones collections cares about. Request the
  smallest equivalent export for the tie-out instead.
- **A customer balance report is not an aging.** It gives one total per customer with no
  due-date buckets, so it cannot say what is overdue or by how long. Never present it as an
  aging. Where the aging report is unavailable but invoice-level data is complete, you may
  **reconstruct** the aging from invoices, payments and credits — label it as reconstructed
  and tie it back.

7. Route every data read through `invoke_datasource_api_tool` with the confirmed
   `workspace_id` and the selected `data_source_id` when required. Reads are live and
   read-only; **check each response's `mock` field and say when a result is fixture data.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`).

**Derive silently** what the profile answers — and confirm the company before reporting:

- Company name and address — **confirm the company before reporting**; if it is not the
  expected one, ask the user to reconnect or select the correct company
- Base / functional currency
- Fiscal calendar and year-end, time zone

**Ask the user**, as **one consolidated question**, only for missing inputs that change the
requested output. See Step 4 — core aging does not require dispute flags, payment history,
DSO, or collection policy.

### Input plan

| Input | Typical read | Rule | If unavailable |
|---|---|---|---|
| **Company** | Company profile / datasource connection | Confirm company before reporting | Ask user to reconnect or select the correct company |
| **As-of date** | User request or current date | Pass a concrete `YYYY-MM-DD` date | Ask only if ambiguous. **Never silently default it** |
| **Open invoices** | A/R aging **detail** capability if exposed; otherwise the catalog's invoice search / report | Prefer a complete as-of report; **do not rely on a recent-only invoice query** | Ask for an A/R Aging Detail export after explaining the missing connector capability |
| **Independent totals** | A/R aging **summary** capability | Pull unfiltered for the same date | Derive from detail and **disclose that there is no independent tie-out** |
| **Credits / payments** | A/R detail without a transaction-type filter, or payment / credit search tools | Pull only when invoice detail does not reconcile | Ask for unapplied credits / payments or a full detail export |
| **Invoice enrichment** | Invoice search / single-invoice read | Query selected IDs or document numbers only | Leave unavailable enrichment fields blank |
| **Currency** | Report / invoice response | **Preserve each currency separately** | Ask before presenting unlabeled consolidated totals |
| **Exact DSO denominator** | Credit sales and period | **Require explicit credit sales** | Ask the user; offer a labeled total-income proxy only with approval |
| **Disputes, credit holds, strategic tier, payment history** | Not reliably exposed by aging reads — **[manual]** | **Never infer** | Ask only when needed for the requested prioritization |
| **Collection policy / brand voice** | User-provided policy — **[manual]** | Apply only supplied terms | Use neutral language without fees or threats |
| **Confirm scope** | — | Read back in-scope and excluded company files by `display_name` | — |
| **Confirm manual evidence** | — | For each `[manual]` gap, ask whether the user can supply it, and how | — |

**On later runs**, read stored preferences first (Step 7), confirm them in one line, and ask
only what is new, changed, or contradicted. Strategic tiers, collection policy and brand voice
in particular should not be re-asked every cycle.

## Guardrails

- **Never** create / update records, apply payments, write off balances, or send reminders.
- **Mark all correspondence `REVIEW REQUIRED - NOT SENT`.**
- **Do not invent** disputes, credit holds, payment promises, late fees, service suspension,
  or legal action.
- **The A/R aging may be accrual-only in the available connector.** If cash basis is
  requested, explain the limitation and **ask whether accrual basis is acceptable before
  reading data** — do not read first and caveat afterwards.
- End a live-data response with **one `Data sources` line** naming the Mosofin calls used and
  their retrieval time.

---
