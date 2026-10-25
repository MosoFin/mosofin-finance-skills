<!-- journal-entry-builder · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before building anything. This ordering is the contract. Do not
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

**When this skill is invoked as a handoff from another skill**, the gates have usually run already in the
same conversation. **Confirm the entity in one line rather than repeating the sequence** — but **never build
against an entity that was not confirmed.**

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**This gate answers the original's "Accounting system" input.** **The connected platform is known** — so the
import format in Step 7 is determinable rather than a question. **Ask only when the platform's import
template is itself the uncertainty.**

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; **the entry is built against that chart.**
- **Multi-entity** — ask which set, **and which entity this entry belongs to, before building it.** For an
  **intercompany** entry, **both entities are in scope** and both sides are built. See the cross-entity step.

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

Resolve **every validation in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**If the chart read is `disabled`, the original's fallback applies in full** — descriptive account names
labelled **"PLACEHOLDER — REMAP REQUIRED"**. **Say which fallback is in use and why**; do not invent numbers.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A validated entry is not a posted entry.** Nothing here records anything.
  - **An account existing is not an account being appropriate.** The chart says it exists; judgment says it
    fits.
  - **An open period in the system is not an open period for reporting.** Statements may already be issued
    even where the software permits posting.
  - **A balance in an accrual account is not proof the accrual covers this item** — it is a prompt to
    check.
- **There is no posting capability, no materiality policy and no tax rule engine on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar and
year-end, country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Transaction or event to record** | **Required — [manual]** | The user's. |
| **Posting date** | **Required** | **[gated]** to validate against period status. |
| ~~Chart of accounts~~ | **Now [auto]** | Real accounts, real types. **No placeholders unless the read fails.** |
| ~~Entity / company~~ | **Now [auto]** | Confirmed by `display_name`. |
| ~~Functional currency~~ | **Now [auto]** | From the profile. |
| **Reference / source document** | Recommended — **[gated]** | Findable where the document is in the system. |
| ~~Accounting system~~ | **Now [auto]** | From Gate 1. **Ask only for the import template if needed.** |
| **Reversal flag** | Optional | |
| **Tax jurisdiction** | Required if tax effects involved — **[gated]** | **Country `[auto]`; the rules `[manual]`.** |
| **Materiality threshold** | Recommended — **[manual]** | Needed for the large-entry flag; **do not assume one.** |
| **Confirm scope** | **Required** | Read back the entity by `display_name` and the period. |
| **Confirm manual evidence** | **Required** | The event, the tax rules and the threshold are `[manual]`. |

**If no chart of accounts is available**: **ask the user for the specific account names and numbers they
use. Do not invent.** Acceptable fallback: **descriptive account names with a clear "PLACEHOLDER — REMAP
REQUIRED" label.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an account, a tax
treatment, or a materiality threshold.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The account map, the entry templates, the import format and the numbering convention persist; **balances and
validation results are re-obtained every time.**

---
