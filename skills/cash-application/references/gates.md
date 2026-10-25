<!-- cash-application · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before matching anything. This ordering is the contract. Do
not skip a gate because a previous conversation covered it — connections, permissions, and company
files change between runs.

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

**Check for a connected payment processor.** It converts the batch-settlement edge case from
`[manual]` guesswork into readable gross sales, fees, refunds and chargebacks — see
`merchant-and-payment-processor-rec`.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every payment, match and exception carries its entity's
  `display_name`. **Never apply one entity's receipt to another entity's invoice.** The legitimate
  version of that — a customer paying one lump sum covering invoices from several group companies —
  is handled explicitly in the cross-entity step, split and labelled.

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability map**
— built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled —
  some underscored, some hyphenated.
- **A near-substitute is not a substitute.** A **customer balance** report gives one total per
  customer; cash application needs the **invoice-level** open population, because the whole task is
  deciding *which* invoice. A balance report cannot support level-2 or level-3 matching at all. If
  the invoice search is disabled, this skill cannot run on live data — say so and request an open
  invoice export.
- **The invoice search usually requires a date range.** Old unpaid invoices are precisely the ones
  a payment may be settling, so a default recent window will silently exclude them. Use the aging
  report as the population where it is available, and state the window you searched.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency (which determines whether Step 5
applies at all), fiscal calendar, country / region, **time zone** — which decides which day a
receipt falls on.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Customer payments / receipts** — deposit listing, lockbox file, processor export | **Required** | **[auto]** for payments already recorded in the books; **[manual]** for a file of payments not yet entered. Ask which population you are working on — they are different jobs. |
| **Open A/R invoices** | **Required — usually [auto]** | Normally pulled. Confirm the as-of date. |
| **Remittance advice** — if separate from the payment data | Recommended — **[manual]** | The single biggest driver of match quality. Ask whether any exist and where. |
| **Customer master** — helps fuzzy-match payer names | Recommended — usually **[auto]** | Pulled. Ask only for known payer aliases the books do not hold. |
| **Tolerances for short / over pay** — currency amount or % | Optional — **[manual]** | **Default exact** if not supplied, and say that is what you did. |
| **Tax jurisdiction** | Optional — **[manual]** | Needed only where withholding at source applies. |
| **FX rates** at the receipt date | Required if currencies differ — **[manual]** | No accounting connector supplies a rate; ask for the rate and its source. |
| **Application order default** — oldest-first (FIFO) or otherwise | Recommended | Step 2 level 3 and 4 both depend on it. Confirm rather than assuming. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | Remittances, FX rates and tax certificates will be among them. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the FX rate,
the tolerance, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only what is
new, changed, or contradicted. The payer-alias map and the tolerance should not be re-asked daily.

---
