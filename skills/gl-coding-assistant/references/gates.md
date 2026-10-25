<!-- gl-coding-assistant · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before coding anything. This ordering is the contract. Do not
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

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and confirm which entity each batch of transactions belongs to before
  coding any of them.** Coding is entity-specific: the same vendor may map to different accounts in
  different company files, because the charts differ. See the cross-entity step.

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
  - **Coding history is not correctness.** The central caution above.
  - **A vendor's default account on its master record is not how it has actually been coded** — defaults
    are set once and then overridden transaction by transaction. **Read the history, not the default.**
  - **A tax code applied previously is not proof of recoverability.** The code is a setting.
  - **Two matching amounts are not a transfer** until both legs are seen in the entity's own accounts.
- **If the COA read is `disabled`, the original's fallbacks apply in full** — category names only, or an
  explicitly authorized placeholder labelled **PLACEHOLDER — REMAP REQUIRED BEFORE POSTING**. **Say which
  fallback is in use and why.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar, **country /
region** — the jurisdiction — and **industry**.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Transactions to code** | **Required** — **[auto]** if already in the system, **[manual]** if a bank or card export | **Offer to find them**: uncategorized and suspense accounts are readable. |
| ~~Chart of accounts~~ | **Now [auto]** | From `search_accounts`. **No placeholders unless the read is unavailable.** |
| ~~Entity jurisdiction~~ | **Now [auto]** | Country from the profile — **but the tax *rules* remain `[manual]`.** |
| ~~Entity industry~~ | **Now [auto]** | From the profile where set. |
| ~~Vendor-to-account mappings (prior coding)~~ | **Now [auto], and promoted** | **Derived from ledger history with counts.** The strongest evidence available. |
| **Coding policy / rules** | Optional — **[manual]** | Any house rules that override history. |
| **Capitalization threshold** | Optional, **ask if relevant** — **[manual]** | **Do not pick a threshold.** Needed for the Tier 4 and Step 4 checks. |
| **Tax code list** | Required for tax codes — **[gated]** | **The codes configured here are `[auto]`;** which one applies is `[manual]`. |
| **Confirm scope** | **Required** | Read back the entity by `display_name` and the batch being coded. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. transactions in a currency the entity does not use. |
| **Confirm manual evidence** | **Required** | The policy, the threshold and the tax rules are `[manual]`. |

**If no chart of accounts is available**, the original's rule stands: **stop and ask. Do not invent account
numbers.** Two acceptable fallbacks:

1. **The user provides a category list** (description only) and coding is to category names with no numbers.
2. **The user explicitly authorizes a placeholder COA** — output clearly labelled **"PLACEHOLDER — REMAP
   REQUIRED BEFORE POSTING"**.

**If no jurisdiction is available and the user asks for tax codes, ask. Do not assume.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a capitalization
threshold or a tax treatment.

**On later runs**, read stored preferences first (Step 6), confirm in one line, and ask only what changed.
**See the Learning Loop below — it and the evolution step are the same mechanism.**

---
