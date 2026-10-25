<!-- expense-report-processor · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

**Check specifically for a connected T&E or spend-management platform** — Concur, Expensify, Brex, Ramp,
Pleo, Spendesk, Soldo. **If one is live, the expense report itself becomes `[auto]`**, which converts the
skill's largest manual input. If none is, the report is supplied by hand and labelled as such. Either way
the accounting datasource still supplies the COA, the employees and the posted transactions.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. **The employee-to-entity question is the one that matters**: staff are
  employed by one entity but may incur costs on behalf of another. See the cross-entity step.

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
  - **A posted expense transaction is not a submitted claim.** The ledger shows what was recorded, not what
    an employee asked for and a manager approved.
  - **A receipt-attached flag is not a receipt.** It is a field in another system.
  - **The tax code on a transaction is not proof of recoverability.** The code is a setting; the entitlement
    is a rule.
  - **An employee record is not an approval hierarchy.** Who may approve whose claim is not in the ledger.
- **If the COA read is `disabled`, the skill degrades to the original's placeholder behaviour** — say so
  explicitly rather than quietly coding to invented accounts.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar,
country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Expense report** | **Required — [manual]** unless a T&E platform is connected | The claims themselves. |
| **T&E policy document or parameters** | **Required for meaningful policy validation — [manual]** | **Without it, Step 2 does not run.** Say so rather than inventing limits. |
| **Receipts** | Recommended — **[manual]** | Images are not on this surface. |
| ~~Employee details~~ | **Now [auto]** | From `search_employees`; confirm only if a claimant is not found. |
| ~~Chart of accounts~~ | **Now [auto]** | From `search_accounts`. **No placeholder coding.** |
| **Tax jurisdiction** | Recommended — **[manual]** for the rules | The **codes in use** are `[auto]`; the entitlement rules are not. |
| **Mileage rate** (per-km or per-mi) | Required if mileage claims present — **[manual]** | **Never supply a prevailing rate from memory.** |
| **Per-diem table** | Required if per-diems are claimed — **[manual]** | Same rule. |
| ~~Functional currency~~ | **Now [auto]** | From the company profile. |
| **FX rate source** | Required if multi-currency — **[manual]** | Central bank close, accounting system rate, or report-date rate. **Do not assume a source.** |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the report period. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. claims in a currency the entity does not transact in. |
| **Confirm manual evidence** | **Required** | The policy, the rates and the receipts are `[manual]`. Record what was supplied and as at when. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a mileage rate, a
per-diem, a receipt threshold, a deductibility split, a gift cap, or an FX source.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The policy parameters, the category-to-account map, the rates in force and the FX source persist; **the
claims and the balances are re-obtained every run**.

---
