<!-- bank-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

## Contents

- ONBOARDING — Confirm the workspace and its data sources
-   - Gate 0 — Confirm the workspace
-   - Gate 1 — Discover live datasources and settle the entity scenario
- PART A — Explore the confirmed sources, and personalise this run
-   - Gate 2 — Discover enabled tools → build the capability map
-   - Gate 3 — Profile the entity, then interview the user


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

**Check every connected row for a banking or payments platform.** This is the highest-value check
in the whole gate for this skill: a connected bank feed converts the reconciliation from
`[manual]` to genuinely two-sided. Do not assume the workspace is accounting-only without
looking.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every balance, unmatched item and proposed entry carries its
  entity's `display_name`. **Never reconcile one entity's GL cash to another entity's statement.**
  Where several entities genuinely share one bank account, that is a specific and awkward case —
  see the edge case.

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
map** — built this run, held for this run, written out as the coverage sheet, **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated.
- **A near-substitute is not a substitute, and here it is the central trap.** A **balance sheet**
  cash figure, a **cash flow statement**, and a **deposit listing** are all views of the *book*
  side. None of them is the bank's view. Assembling them into something that looks like a
  two-column reconciliation produces a document that asserts a control was performed when it was
  not. If the statement is absent, the output is a *book-side preparation*, and it must be
  labelled that way.
- **The connected books may not expose a "cleared" or "reconciled" flag.** Most read-only
  connectors do not. That means **outstanding cheques and deposits in transit cannot be
  identified with certainty from the books alone** — only proposed as candidates by date. Say
  "candidate", not "outstanding".

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency (which determines whether an FX line
belongs in the bridge at all), fiscal calendar, country / region, and **time zone** — which
matters here, because whether a transaction falls on the statement's last day can depend on it.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Bank account(s) in scope** — account name(s), **account numbers masked** | **Required — partly [auto]** | The chart of accounts pulls the cash accounts; ask which are in scope. **Never display or store a full account number.** |
| **Reconciliation period** — start / end dates | **Required** | Never default the period. |
| **Bank statement** — PDF/CSV, or the ending balance plus statement lines | **Required — [manual]**, always | Ask for it explicitly and early. If it cannot be supplied, say what the output will and will not be before doing the work. |
| **GL activity for cash account(s)** — date, description, amount, counterparty, reference | **Required — usually [auto]** | Pulled from the connected books. |
| **Prior month reconciliation status** — prior recon report or last reconciled date | Recommended — **[manual]** | Without it, opening outstanding items are unknown and the bridge starts blind. Ask for at least the last reconciled date. |
| **Cutoff policy** — posting cutoffs, deposit processing, cheque clearing | Recommended — **[manual]** | Sets the date windows in Step 3 and the escalation ages in Quality checks. |
| **Materiality threshold** | Recommended | Ask; do not assume. Note that the final tie is **to the cent** regardless — materiality governs which *items* get chased, not whether the bridge balances. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the accounts in scope by name. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The statement and the prior recon will both be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the account, or the entity.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what
is new, changed, or contradicted. The account list, cutoff policy and escalation ages should not
be re-asked every month.

---
