<!-- ap-aging-and-payment-runs · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before any aging work. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a
client-side `mcp__…` namespace; that string is composed by whichever MCP client is running.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the
opaque `ws_…` handle.

This gate carries real money risk in this skill: a payment run proposed from the wrong
entity's books is a list of payments the entity does not owe.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded** ("*Northwood Demo Books* is
  present but not active, so nothing it owes appears in this aging"). An aging that silently
  omits an entity understates what the group owes. Surface any `reconnect_url`.

A workspace can connect the **same platform several times** — several company files, plus
payment platforms. Each is its own row with its own `data_source_id` and `display_name`.
Payments are made **per legal entity from that entity's bank**, so the entity question here
decides whose money is being spent.

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`. Every aging line and every proposed payment carries
  its entity's `display_name`, **and each entity's payment run is constrained by its own
  cash** — never a pooled figure, unless the user explicitly confirms a shared treasury.

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

**The aging report deserves a specific note in this skill.** Whether a dedicated A/P aging
report is `enabled`, `permission`-gated, or `disabled` varies by workspace and by company
file, and it is common for the payables aging to carry a different policy from the
receivables one in the same catalog. Check it; never assume it from a sibling report.

There are then two very different fallbacks, and confusing them is the trap:

- **A legitimate reconstruction.** If the aging *report* is unavailable but bill-level data
  is not, you can **rebuild the aging from the underlying bills, payments and credits**
  (*`search_bills`*, *`search_bill_payments`*, *`search_vendor_credits`*). This is the same
  evidence the report is made from, so the result is genuine — but **label it as
  reconstructed**, and tie the total back to the A/P control balance
  (*`get_balance_sheet`*) so any gap is visible.
- **A near-substitute, which is not a substitute.** A **vendor balance** report is *not* an
  aging. It gives one total per vendor with no due-date buckets, so it cannot tell you what
  is overdue, what is due this week, or which discount expires on Friday — the three things
  this skill exists to answer. Never present a vendor balance report as an aging. If neither
  the aging report nor bill-level data is available, the task is `[manual]`: name the tool
  and ask for an open-bill export.

Also: **read the real tool name from the catalog, never from memory.** Names are not
uniformly styled — some underscored, some hyphenated — and in this skill you will reach for
both a bill search and a single-bill read, which are often styled differently in the same
catalog.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** what the profile answers:

- **Functional currency** — the base currency the books are kept in. Ask about currency only
  if the bills show more than one.
- Fiscal calendar, country / region, time zone — the time zone matters here, because a
  discount deadline is a date in *someone's* local time.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Open A/P / unpaid bills** | **Required — usually [auto]** | Normally pulled from the connected books. Ask what sits outside them (a bill not yet entered, another entity's ledger). |
| **As-of date for the aging** | **Required** | Never default it. The aging changes materially day to day. |
| **Cash available for the payment run** | **Required for payment-run mode** | **[gated]**: bank balances are usually readable, but *available* cash is a decision — it nets off committed payments, floats, and any minimum the business keeps back. Ask; do not read a bank balance and call it available. |
| **Vendor master / payment terms** | Recommended — usually **[auto]** | Terms are normally on the vendor record or the bill; ask only for what is missing. |
| **Vendor priority tier** (critical / standard / discretionary) | Optional — **[manual]** | The books do not know which supplier stops serving you first. Ask, and store it in Step 8. |
| **Early-pay discount terms** | Optional — usually **[auto]** | Normally derivable from the terms record; ask where terms are held outside the books. |
| **Payment method per vendor** (ACH / wire / cheque / card) | Recommended | Method names are often **[auto]**; the per-vendor mapping is usually **[manual]**. |
| **Aging buckets** | Recommended | Defaults are in Step 2; confirm if the entity uses different ones. |
| **Functional currency** | Recommended — usually derived | Ask only to resolve a contradiction or where several currencies appear. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

**Minimum bill fields** — whatever the source, each bill needs:

- Vendor name
- Bill / invoice number
- Bill date
- Due date (or payment terms from which to compute it)
- Open amount (original − payments − credits applied)
- Currency

Where a pulled bill is missing one of these, it goes to the exceptions sheet — it is not
silently dropped from the aging.

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the
as-of date, the cash available, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only
what is new, changed, or contradicted. The vendor tiers and payment methods in particular
should not be re-asked every week.

---
