<!-- balance-sheet-reconciliations · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Two things to look for specifically here:**

- **Are both sides of any intercompany relationship connected?** If so, that reconciliation is
  `[auto]` on both sides. If only one side is connected, the counterparty balance is `[manual]`
  and must be requested. This single check changes the verdict on one of the hardest accounts.
- **Is a payroll, inventory, or payments platform connected?** Each one converts a normally
  `[manual]` supporting side into an `[auto]` one. Check every row, not just the accounting one.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every account, balance and reconciling item carries its
  entity's `display_name`. **Never reconcile one entity's GL balance to another entity's
  subledger** — except deliberately, for the intercompany mirror check, which is exactly that
  comparison done on purpose and labelled as such.

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

| `effective_policy` | The reconciliation becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every account in Step 1's table** against these buckets — **separately for its GL side
and its supporting side**. That two-column resolution *is* the capability map for this skill.
It is built this run, held for this run, written out as the coverage sheet, and **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated — and the receivables and payables aging reports
  frequently carry *different* policies in the same catalog, which means A/R may reconcile
  automatically while A/P does not.
- **A near-substitute is not a substitute.** A **vendor balance** report is not an **A/P aging**
  and a **customer balance** report is not an **A/R aging** — they give totals with no aging
  detail, so they can confirm a total but cannot evidence *which items make it up*. For a
  reconciliation that distinction is the whole point: an unexplained total agreeing is luck, not
  a tie-out.
- **Do not reconcile a balance to itself.** If the only available "support" is another view of
  the same GL, say so and mark the supporting side `[manual]`.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: legal name, base / functional currency, fiscal
calendar and period-end, country / region, industry.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Account(s) being reconciled** — number + name | **Required — partly [auto]** | The chart of accounts pulls; ask **which** accounts are in scope, or confirm "all balance sheet accounts". |
| **Reporting period** — date range | **Required** | Never default the period. |
| **GL balance at period end** | **Required — usually [auto]** | Pulled from the trial balance. |
| **Supporting subledger / schedule / external doc** | **Required — mixed** | Per account: `[auto]` for A/R, A/P and clearing; **[manual]** for prepaid, fixed assets, leases, payroll, debt, tax and bank. Ask where each `[manual]` schedule lives. |
| **Prior period reconciliation** | Recommended — **[manual]** | Needed for the carry-forward check in Step 8. Ask for it; without it, say the carry-forward could not be performed. |
| **Materiality threshold for unreconciled differences** | Recommended | **Ask the user. Do not silently assume** — see the edge case for how to suggest one. |
| **Chart of accounts** — for posting cleanup JEs | **Required — usually [auto]** | Confirm the cleanup / suspense account by its real name. |
| **Who prepares and who reviews** | Recommended | The workpaper header needs both, and they should not be the same person. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's period-end does not match the period named. |
| **Confirm manual evidence** | **Required** | For each account whose supporting side is `[manual]`, ask whether the schedule can be supplied, and how. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the materiality threshold, or the entity.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what
is new, changed, or contradicted. The account-to-source map and the materiality threshold should
not be re-asked every month.

---
