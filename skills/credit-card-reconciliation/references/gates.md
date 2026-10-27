<!-- credit-card-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

This gate matters here because card data names individual employees and their spending — reading the
wrong entity's card activity is a privacy problem, not only a data one.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check every connected row for a card or spend-management platform** — Brex, Ramp, Pleo, Spendesk and
similar. If one is connected, **the statement and often the receipts become `[auto]`**, and this skill
transforms from a review into a genuine two-sided reconciliation. That is the single most valuable check
in this gate.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting exactly
  one `data_source_id`, and every charge carries its entity's `display_name`. **A card issued to one
  entity but used for another's expenses** is a real and common pattern — see the cross-entity step under *Both entity scenarios* in [`method.md`](method.md),
  because it creates an intercompany balance rather than an expense.

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
- **Card charges usually post as purchase or expense transactions, not journals.** Check which search
  tool returns them; looking only at journal entries will find almost nothing.
- **A near-substitute is not a substitute.** **The card liability balance is not a statement.** It is
  what the books say you owe, which is exactly the figure the statement is meant to test. Comparing it
  to itself proves nothing. If no statement is available, say the tie-out could not be performed.
- **An attachment listing is not a receipt.** Where the connector exposes attachments, it can show that
  *a file exists* against a transaction — useful evidence of receipt capture, and **not** proof that the
  receipt supports the amount or shows a business purpose.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which determines which card transactions
count as foreign — fiscal calendar, country / region, time zone.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Credit card statement** — PDF, CSV or XLSX from the issuer | **Required — [manual]** unless a card platform is connected | Ask for it explicitly. Without it, say what the output will and will not be. |
| **Receipts for the period** | **Required for receipt matching — [manual]** | Or a receipt-tool export. Attachment metadata is not a receipt. |
| **Cardholder** (role; a name only if the user offers it) | **Required — [manual]** | Which role each card belongs to. |
| **Statement period** — date range | **Required** | Note whether it matches the accounting period — see the edge case. |
| **Statement balances** — opening, charges, payments, closing | **Required — [manual]** | From the statement. |
| **GL credit card liability balance at the statement closing date** (and at period end, for cut-off) | **Required for tie-out — usually [auto]** | Pulled from the GL or trial balance. Confirm which account. |
| **Chart of accounts** | **Required — usually [auto]** | Pulled. |
| **Tax jurisdiction** | Required if tax recoverability applies — **[manual]** | Drives Step 5. |
| **Receipt policy threshold** — below which no receipt is required | Recommended — **[manual]** | Needed to distinguish an acceptable missing receipt from an exception. |
| **Capitalization threshold** | Recommended — **[manual]** | Enables the capital-purchase test. |
| **Per-card-program quirks** | Optional — **[manual]** | Auto-categorisation from spend platforms needs verifying, not trusting. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The statement, the receipts and the thresholds will all be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the receipt
threshold, the capitalisation threshold, or the period.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The card list, the cardholders, the thresholds and the merchant-to-account coding map should not be
re-asked every month.

---
