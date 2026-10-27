<!-- cash-flow-forecast-13-week · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Run Gates 0 → 1 → 2 → 3 in this order, before forecasting anything. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

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
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`. In a cash
  forecast an excluded entity is not a presentational issue: its payroll and its bills are real
  outflows, and omitting them makes a tight forecast look comfortable.

Settle the entity scenario — and here it matters more than in most skills:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and ask the critical follow-up: is cash actually pooled?**
  Entities may hold separate bank accounts with no ability to move money between them without a
  formal intercompany loan. **A group forecast that nets one entity's surplus against another's
  shortfall is wrong unless the cash can genuinely move.** Run the forecast **once per entity**,
  every call targeting exactly one `data_source_id`, then consolidate only on an explicit
  confirmation that funds are transferable. See the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

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
  some underscored, some hyphenated — and the receivables and payables agings frequently carry
  different policies in the same catalog, which would leave you with one side of the forecast
  automated and the other not.
- **A near-substitute is not a substitute.** A **balance report** gives totals with no due dates,
  and this forecast is **entirely about dates**. Without due dates there is no week to place
  anything in. If the aging is disabled, reconstruct from invoice- and bill-level data (labelled as
  reconstructed), or mark it `[manual]`.
- **Check whether payment history is readable**, because that is what makes the days-to-pay
  derivation possible. If it is not, collection timing falls back to due dates plus a **stated**
  assumption — and the forecast is materially weaker, which should be said.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency, fiscal calendar, country / region, and
**time zone** — which decides which week a receipt near a boundary falls into.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Opening cash balance** — by account, as of the start date | **Required — book balance [auto], bank balance [manual]** | Book balance pulled; **ask for the bank balance on the start date** and agree the two (Step 1). Confirm which accounts count as available cash, and **exclude restricted cash**. |
| **Forecast horizon** — default 13 weeks; can be 6, 8, 17, 26 | **Required** | Ask; see the seasonality edge case before defaulting to 13. |
| **AR / open invoices with expected collection timing** | **Required — [auto] for the invoices; timing [auto] to derive, [manual] to confirm** | Invoices and due dates pull; the expected pay date is derived from history and then confirmed. |
| **AP / open bills with payment timing** | **Required — [auto] for the bills, [manual] for the plan** | Due dates pull; **which bills you intend to pay when is a decision**, not data. |
| **Payroll schedule** — pay dates and amounts | **Required — [manual]** unless payroll is connected | Historical payroll outflows are visible and give the rhythm; the forward amounts are not. |
| **Recurring receipts and disbursements** — rent, debt service, taxes, subscriptions | **Required — partly [auto]** | Recurring patterns derive from history; **debt service and tax due dates are [manual]** and are exactly the lumpy items that breach a floor. |
| **Expected new sales / bookings cash timing** | Recommended — **[manual]** | |
| **Minimum cash threshold / covenant** — the floor to stay above | Recommended — **[manual]** | Ask for the covenant's **exact definition** of cash; see the edge case. |
| **Available credit facility** — undrawn revolver, etc. | Recommended — **[manual]** | Including borrowing-base mechanics and any clean-down requirement. |
| **Functional currency (and FX if multi-currency)** | Recommended — currency **[auto]**, rates **[manual]** | |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, **and whether cash is pooled**. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | Payroll, debt service, taxes, the floor and the facility will all be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the opening
balance, the floor, the payroll amounts, or the entity.

**On later runs** — and this forecast is meant to roll weekly — read stored preferences first
(Step 9), confirm in one line, and ask only what changed. The recurring schedule, the floor and the
facility terms should not be re-asked every week; **the collection-timing assumptions should be
re-derived**, because that is the whole point of the rolling discipline.

---
