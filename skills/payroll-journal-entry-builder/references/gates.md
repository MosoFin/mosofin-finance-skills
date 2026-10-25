<!-- payroll-journal-entry-builder · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path (Gates 0–3, including the Gate 3 interview). Edit here, not in SKILL.md. -->

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

**When invoked as a handoff from `month-end-close-checklist`**, the gates have usually run in the same
conversation. **Confirm the entity in one line** rather than repeating the sequence.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check for a connected payroll platform.** **If one is live, the register becomes `[auto]`** — and with it
the gross-to-net detail, the employer costs and the department allocation, if the platform carries them.
**If not, the register is supplied and labelled as such.**

Settle the entity scenario:

- **Single-entity** — one company file; the entry is built against its chart.
- **Multi-entity** — ask which set, **and which entity employs the people in this run.** **A payroll run
  covering several group entities produces one journal per entity**, not one journal split by class. See
  the cross-entity step.

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

**If the chart read is `disabled`, the same fallback applies as in `journal-entry-builder`** — descriptive
account names labelled **PLACEHOLDER — REMAP REQUIRED**, and **say so**. Do not invent account numbers.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A balanced entry is not a correct entry.** Employer contributions credited to an employee withholding
    account balance perfectly and are wrong.
  - **A prior period's entry is not a template for this one** — rates change, headcount changes, and
    jurisdictions add liabilities.
  - **A department dimension is not a cost allocation basis.** The dimension records where a cost was
    tagged; the basis is a decision.
  - **The payroll journal's total is not the register's total** until they have been compared.
- **There is no payroll register, no rate table and no benefit schedule on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar, **country
/ region — which determines which withholding and contribution types exist.**

**Ask the user** what actually changes the work — the original Inputs table, **minus the parts the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Payroll register / report for the run** | **Required — [gated]** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise.** |
| **Pay period and pay date** | **Required** | **Both**, since the accrual in Step 6 depends on the gap. |
| ~~Chart of accounts mapping~~ | **Now [auto]** | **Real accounts.** Confirm which account holds which liability. |
| ~~Department / cost center allocation~~ | **Now [gated]** | **The dimensions are `[auto]`; the allocation basis is `[manual]`.** |
| ~~Accounting basis~~ — cash or accrual | **Now [auto]** | Readable from the reads; **whether a period-end accrual is needed follows from the dates.** |
| **Funding / payment details** — bank account, timing | Recommended — **[gated]** | **The bank accounts are `[auto]`;** the timing is the user's. |
| **Employer contribution details** | **Required for full cost — [gated]** | **In the register if connected; `[manual]` otherwise.** |
| **Whether a payroll clearing account is used** | **Required — Mosofin addition** | It changes Step 5 and feeds `payroll-clearing-reconciliation`. |
| **Any capitalized labor in this run** | **Required if applicable — [manual]** | Nothing in the register flags it. |
| **Confirm scope** | **Required** | Read back the entity by `display_name`, the pay period and the run. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. withholding types for a country the entity does not operate in. |
| **Confirm manual evidence** | **Required** | The register and the allocation basis are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an account mapping, an
allocation basis, or a capitalisation decision.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The account map, the allocation basis, the clearing convention and the entry template persist; **the
register and every amount are new each run.**

---
