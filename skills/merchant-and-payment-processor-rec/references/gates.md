<!-- merchant-and-payment-processor-rec · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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
onboard: say so once, then run the skill manually on data the user supplies — the
upload checklist in Stage 1 of `SKILL.md`. The precondition check is in
[`mosofin-protocol.md`](mosofin-protocol.md).


Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

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

**This gate decides what this skill can do.** **Look specifically for a connected payment processor**
alongside the accounting platform.

- **Processor connected** → **both sides are `[auto]`**, and this becomes a genuine two-sided
  reconciliation performed live, with no export and no version skew.
- **Processor not connected** → **the processor side is `[manual]`**, supplied as an export. **The GL side
  is still fully readable**, and **the clearing roll-forward, the ageing and the net-revenue test all still
  run** — which is worth saying, because they are the checks most likely to find something.

**Resolve the real tool names from Gate 2** if a processor is connected; **do not assume a processor's tool
names or its export shape.**

Settle the entity scenario:

- **Single-entity** — one company file, one clearing account per processor.
- **Multi-entity** — ask which set. **One processor account serving several group entities is a listed edge
  case and is common**; each transaction must be attributed, and **the clearing account is per entity.** See
  the cross-entity step under *Both entity scenarios* in [`method.md`](method.md).

Refer to companies by `display_name`; never show the raw `data_source_id`.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map


For **each in-scope datasource** — accounting **and processor** — and **per company file** when several are
live (pass `data_source_id`), call `get_datasource_tools`. Bucket every tool by `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every task in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated — and **this applies to the processor's tools as much as the accounting
  platform's.**
- **A near-substitute is not a substitute:**
  - **A recorded deposit is not a bank statement.** It is what someone entered. See `bank-reconciliation`.
  - **The processor's "available balance" is not the clearing balance** — pending, in-transit and reserve
    amounts are defined differently by every processor. **Read the definition, do not assume it.**
  - **A payout amount is not revenue**, and **net payouts are not gross sales.** The central error above.
  - **A transaction date is not a settlement date**, and neither is necessarily the revenue recognition
    date.
- **There is no bank statement and no processor contract on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency** — which matters for the
multi-currency step — fiscal calendar, **country**, which bears on tax treatment.

**Stage 1 has already asked most of this. Confirm those answers in one line; do not ask them again.**
Then **ask the user** only what Stage 1 did not cover — the rows below not marked as answered. What actually changes the work — the original Inputs table, **minus the two the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Processor activity export** — transaction and/or settlement level | **Required — [gated]** | **Answered in Stage 1 — confirm, don't re-ask.** **`[auto]` if the processor is connected.** |
| **Processor settlement / payout records** | **Required — [gated]** | **Answered in Stage 1 — confirm, don't re-ask.** Same. |
| **Period being reconciled** | **Required** | **Answered in Stage 1 — confirm, don't re-ask.**  |
| **Bank statement for the period** | **Required — [manual]**, always | **Answered in Stage 1 — confirm, don't re-ask.** **Not on this surface.** The ledger's deposits are readable; the bank's are not. |
| ~~GL balances~~ — cash, revenue, fees, refunds, chargebacks, clearing | **Now [auto]** | Confirm **which account is the clearing account**. |
| ~~Chart of accounts~~ | **Now [auto]** | |
| **Tax jurisdiction** | Recommended — **[gated]** | **Country `[auto]`; recoverability on fees is `[manual]`.** |
| **Multi-currency / multi-entity setup** | Recommended — **[gated]** | **Currency `[auto]`; the settlement currency and the processor's rate are `[manual]`.** |
| **Posting approach** — per-transaction or periodic aggregate | **Required — Mosofin addition** | **Answered in Stage 1 — confirm, don't re-ask.** **The original offers both; the reconciliation differs.** Ask which is in use. |
| **Whether a reserve or hold applies** | Recommended — **[manual]** | **Answered in Stage 1 — confirm, don't re-ask.** It is the entity's asset; see the edge cases. |
| **Confirm scope** | **Required** | Read back in-scope company files and processors by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. no clearing account for a processor clearly in use. |
| **Confirm manual evidence** | **Required** | The bank statement, the contract and any export are `[manual]`. |

Ask what remains as **one short batch**. Propose defaults where reasonable — but **never** default a fee rate, a
settlement currency, or a tax treatment.

**On later runs**, read stored preferences first (Step 10), confirm in one line, and ask only what changed.
The account map, the posting approach, the payout schedule and the fee rate persist; **every balance and
every transaction is re-obtained.**

---
