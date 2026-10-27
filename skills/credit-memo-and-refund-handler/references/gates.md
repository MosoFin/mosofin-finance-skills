<!-- credit-memo-and-refund-handler · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, and the Gate 3 interview. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before processing anything. This ordering is the contract. Do not
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

**Check for a connected payment processor.** Chargebacks originate there, and a connected processor
supplies the processor fee and the reference that the accounting system usually lacks.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting exactly
  one `data_source_id`, and every credit carries its entity's `display_name`. **A credit must be applied
  against an invoice at the same entity that issued it** — crediting one entity's customer against
  another's invoice is an intercompany transaction, not an application. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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
- **There are four distinct document types and four distinct tools.** Customer **credit memos**, customer
  **refund receipts**, **vendor credits**, and the underlying **invoices** and **bills** each have their
  own search. Using the wrong one silently returns nothing, which reads as "no credits exist" rather than
  "wrong query".
- **A near-substitute is not a substitute.** A **customer balance** shows the net position; it cannot
  tell you which credits are unapplied or which invoice a credit relates to. Both of those are the point
  of this skill. If the credit-level tool is disabled, say the credit register could not be built.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which determines whether the currency check
in Step 2 can ever fail — fiscal calendar and **year-end**, which matters for the closed-period edge case,
country / region.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Credit memo type** — customer credit / customer refund / vendor credit / chargeback | **Required — [auto]** for the document type; **[manual]** for the reason | Often inferable from the document type already recorded; **confirm it**, since the accounting differs materially by type. |
| **Original invoice reference** — number, date, amount | **Required if applicable — [auto] to verify** | Ask for the number; **the existence, amount, balance, period and currency are then all checkable**. |
| **Credit memo amount** | **Required** | |
| **Reason for credit** — return, pricing dispute, goodwill, damage, error | **Required — [manual]** | Drives the accounting: a return hits inventory, a goodwill credit or pricing error reduces revenue, a write-off of an unpaid balance goes to bad debt. Never infer it. |
| **Chart of accounts** | **Required for GL posting — usually [auto]** | Confirm the sales returns, chargeback fee and write-off accounts by their real names. |
| **Tax jurisdiction** | Required if tax was on the original invoice — **[manual]** | Drives the write-off recoverability question in Step 4. |
| **Original tax code(s)** — from the related invoice | Required if tax involved — **usually [auto]** | Readable from the original invoice; confirm rather than ask. |
| **Functional currency** | Optional — default same as original; usually **[auto]** | |
| **Approval for credits exceeding the original invoice amount** | **Required if that check fails** | **[manual]** — and the check itself is **[auto]**. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the reason, the
credit type, or the tax treatment.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The account map, the reason-code set and the approval thresholds persist; **the open credit register is
always re-read**.

---
