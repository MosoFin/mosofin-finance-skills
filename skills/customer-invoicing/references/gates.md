<!-- customer-invoicing · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, and the Gate 3 interview. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before drafting anything. This ordering is the contract. Do not
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

Confirming carefully matters here: **the entity issuing the invoice is the entity whose legal name and
tax registration go on it.** Drafting from the wrong company file produces a document that is legally
wrong on its face.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and ask which entity is actually selling**. This is not a
  presentational question: **each entity has its own legal name, its own tax registration and its own
  invoice number sequence.** Draft from that entity's file only. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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
- **No write tool exists on this surface**, and none will be substituted. Mosofin is read-only by design.
  If the user expects the invoice to appear in their system, say clearly that it will not.
- **A near-substitute is not a substitute.** **A customer record is not a validated tax registration.**
  The tax ID on file is what someone typed; whether it is currently valid is a check against the tax
  authority's own service, which is not available here. For cross-border B2B and reverse charge that
  validity is the whole basis of the treatment — flag it as `[manual]`.
- **The invoice search usually needs a date range.** To find the highest number in the sequence you may
  need to search recent periods deliberately rather than relying on a default window.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for the selling entity.

**Derive silently** what the profile answers — and here it fills a Required input directly:

- **Seller's legal name and address** — which goes on the invoice face
- **Base currency**
- Fiscal calendar, country / region — which **suggests** the jurisdiction but does not settle it

**Ask the user** what actually changes the work — the original Inputs table, minus what the connected
books already answer:

| What to confirm | Required? | Notes |
|---|---|---|
| **Customer** — name, address, tax ID | **Required — usually [auto]** | Pulled from the customer record. **Confirm the tax ID is current**; the record holds what was typed. |
| **Entity (seller)** — legal name, address, tax registration | **Required — [auto]** for name and address; **[manual]** for the registration number if not in the profile | |
| **Line items** — description, qty, unit price, tax code | **Required — [manual]** what to bill; **[auto]** descriptions, prices, tax codes | **What to bill is [manual]**; descriptions, standard prices and tax codes pull from the item list. |
| **Invoice date** | **Required** | Never default it. Note the tax point may differ — see Step 1. |
| **Payment terms** | **Required — usually [auto]** | The customer's terms pull; confirm. |
| **Currency** | **Required — usually [auto]** | From the customer or the entity. |
| **Jurisdiction** | **Required — [manual]** | Drives mandatory fields and tax. **Never infer from the profile's country** — where you are registered and where the supply takes place can differ. |
| **Customer PO / reference** | Recommended — **[auto]** from prior invoices | Prior invoices to this customer show whether they require one. |
| **Sales tax / VAT / GST rates per line** | Required if tax applies — **usually [auto]** | The tax catalogue in use pulls; **whether a rate is correct for this supply is [manual]**. |
| **Invoice numbering scheme** | **Required — usually [auto]** | **The next number in sequence is readable.** Confirm the scheme (prefixes, resets, per-entity sequences). |
| **Chart of accounts** | **Required — usually [auto]** | For the revenue, tax and deferred revenue accounts. |
| **Mode** — prepare new invoices, or validate existing ones | **Required** | They are different jobs; see above. |
| **Confirm scope** | **Required** | Read back the selling entity by `display_name` and any excluded company files. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The jurisdiction's mandatory-field list and any exemption certificate will be `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the jurisdiction, a
tax rate, the invoice date, or the numbering scheme.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The jurisdiction's field list, the numbering scheme and the account map persist; **the next invoice number
is always re-read**.

---
