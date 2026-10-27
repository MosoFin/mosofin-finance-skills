<!-- invoice-data-extractor · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before validating anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

**Extraction itself can begin without the gates** — the document is the user's. **But nothing may be
validated, and no result reported as checked, until the workspace is confirmed.**

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

Settle the entity scenario — and here it matters immediately:

- **Single-entity** — one company file; the Bill-To should match it.
- **Multi-entity** — ask which set. **A batch of invoices frequently spans several group entities**, and
  **the Bill-To on each document decides which company file it belongs to.** See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md) —
  this is the defining multi-entity question for this skill.

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

**If the posted-bill read is `disabled`, the duplicate check cannot run** — and since that is the check most
likely to prevent a real loss, **say so prominently** rather than reporting a clean extraction.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A vendor name match is not vendor verification.** Names are easy to imitate.
  - **A remit-to comparison is not the bank-detail check.**
  - **No duplicate found is not proof there is none** — the invoice may be posted under a different vendor
    record, or with a differently formatted number. See `duplicate-invoice-detection`.
  - **An extracted field is not a verified field.** The document is the source; the ledger is the check.
- **There are no documents, no bank details and no vendor verification service on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: **legal name — the Bill-To validation target** — **base
currency**, which is a cue for ambiguous symbols, fiscal calendar, **country**, which helps resolve
ambiguous date formats.

**Ask the user** what actually changes the work — the original Inputs table, **minus the three the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Invoice document(s)** — PDF, PNG, JPG, or multi-page scan | **Required — [manual]** | **Not in the workspace.** The user supplies them. |
| ~~Entity being invoiced~~ | **Now [auto]** | Legal name from the profile; **the Bill-To is validated against it.** |
| **Output format** — xlsx / csv / JSON | Optional (default xlsx) | |
| ~~Vendor mapping file~~ | **Now [auto]** | **The coding history is the mapping** — see `gl-coding-assistant`. |
| ~~Currency assumption~~ | **Now [gated]** | The entity's currency and the vendor's history are cues; **never default silently.** |
| **Which entity each invoice belongs to**, in a batch | **Required if multi-entity — [gated]** | Proposed from Bill-To; confirmed by the user. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm manual evidence** | **Required** | The documents are `[manual]`; note their filenames and count. |

**If a non-invoice document is uploaded — receipt, statement, contract, quote — confirm with the user before
extracting.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a currency, a date
interpretation, or a vendor identity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only what changed.
The vendor naming conventions, the invoice-number formats and the validation tolerances persist; **every
document and every validation result is new each time.**

---
