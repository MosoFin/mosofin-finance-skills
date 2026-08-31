---
name: financial-statement-builder
description: "Use this skill whenever the user wants to build a complete set of financial statements from their Mosofin workspace — Balance Sheet, Income Statement, and Statement of Cash Flows, with comparatives. Triggers include: 'build financial statements from this TB', 'produce a P&L and balance sheet', 'monthly financials package', 'GAAP financial statements', 'IFRS financial statements', 'investor financials', or uploading a trial balance and asking for statements. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then pulls the trial balance and the comparative period directly, reclassifies into framework presentation, and proves the seven cross-statement tie-outs on the statements it built. Do NOT use for just the cash flow statement — use cash-flow-statement-indirect-method. Do NOT use for footnotes — use notes-to-financial-statements. Outputs a complete statement package with comparatives, classifications, tie-outs, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** in the onboarding linked below — but every step becomes manual.

### Strict rule — this skill never changes your data

**This skill will never write, update or delete existing data in any data source.**
Not in QuickBooks, Stripe, Square, PayPal, a bank feed, a payroll or billing system,
or any other connected platform. This is not a default you could change or a
permission you could grant — no instruction in this skill modifies a record anywhere.

It will **never**:

- create, edit, overwrite, void or delete a record in a connected platform
- invoke a write operation, or ask you to approve or enable one — a write tool is out
  of scope even when your policy has it enabled
- direct you to update, overwrite or delete existing data in a data source
- copy or move data from one connected platform into another

What it does instead is **read, and propose.** Every entry, schedule, reconciliation
and document it produces is a **draft for you to review.** Where it finds a problem —
a duplicate, a mismatch, a stale balance — it describes the problem and proposes a
correcting entry as a draft. It does not tell you to delete or overwrite the original,
and it never acts on one itself.

Whether anything reaches your books is a decision you make outside this skill, in your
own system, by your own hand. **If you act on none of it, nothing in your data has
changed.**

### Onboarding — required whenever Mosofin is connected

**If the Mosofin gateway is connected, onboarding is not optional and not per-skill.**
Before any skill reads anything, the workspace and the data sources in it must be
confirmed with you. It is the same sequence for every Mosofin skill, so it is kept in
one place rather than repeated in each:

- in this repo: [`shared/onboarding.md`](../../shared/onboarding.md)
- installed on its own, or you would rather read the product docs:
  [docs.mosofin.com/start-here/quickstart](https://docs.mosofin.com/start-here/quickstart)

**Already onboarded this workspace?** Then you have answered it once and will not be
asked again from scratch — but **the confirmation itself still happens every run.**
Gate 0 reads your workspace back and waits for an explicit yes; Gate 1 settles which
company file. Those are not skippable, and no data is read before them.

**No Mosofin connector? The skill still works.** If the gateway is not present at all,
there is nothing to onboard: the gates are skipped, every step becomes `[manual]`, and
you are asked for what each step needs — a trial balance, a statement, an export.
**The accounting work is unchanged**; only the data source is. You will be told this
once, and you will not be asked to install anything before being helped.

What follows in **Part A** is not more onboarding. It is this skill exploring what your
confirmed workspace and data sources can actually do — which tools exist, which serve
this particular request — so the run is shaped around your books rather than a generic
template.

---
<!-- shared:onboarding-inline end -->
# Financial Statement Builder (Mosofin)

Assembles a complete set of financial statements from a **trial balance** — **Balance Sheet**, **Income
Statement**, and **Statement of Cash Flows**. Adds comparatives, applies proper classification, and ties
everything together.

**In plain words:** the accounting system holds a long list of account balances. This turns that list into
the three statements a bank, an investor or an auditor expects to see — in the order, the groupings and the
wording their framework requires — and then proves the statements agree with each other.

This skill is **framework-aware** (US GAAP, IFRS, local GAAP). **The TB drives the content; the framework
drives the presentation.**

It is **workspace-scoped**: the trial balance, the comparative period, the account types and the entity
details come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart of accounts and account types rather than accepting any TB shape. That is a narrowing, and it is
stated rather than left implied.

## What this skill is actually for, given the platform already prints statements

**The connected accounting platform will hand you a balance sheet and a profit and loss on request.** So it
is worth being precise about what this skill adds, because "fetch the numbers" is not it:

1. **Classification.** The platform groups by its own account types. **A framework requires current versus
   non-current**, in a specific order, under specific headings. Nothing in the ledger knows which portion of
   a loan falls due within twelve months.
2. **Framework presentation.** US GAAP leads with current; IFRS commonly leads with non-current. IFRS says
   "trade and other receivables". By-function versus by-nature. **None of this is a data question.**
3. **The comparative basis.** Pulling last year is one call. **Confirming that last year, as it now sits in
   the ledger, is what was actually published is not** — see the warning below.
4. **The seven cross-statement tie-outs.** The real deliverable. They are what turns three reports into a
   statement package.
5. **Everything the ledger has no field for**: discontinued operations, OCI, EPS, restated comparatives.

**And one warning that shapes the whole skill:**

> **The system-generated balance sheet always balances.** Double-entry software enforces it. So **tie-out 1
> proves the software works — it does not prove your statements are right.** The moment you reclassify a
> current portion of debt, split a deferred tax balance, or reclassify a comparative, **you are looking at
> statements the system did not produce, and the balance must be re-proved on those.** Run tie-out 1 against
> your own presentation, never against the platform's report.

> **The ledger's prior year is not necessarily the published prior year.** If audit adjustments were agreed
> but never posted, or were posted to a later period, **the comparative you read will differ from the
> comparative that was filed.** Compare against the prior-year financials as issued — that comparison is
> `[manual]`, and it is one of the most valuable checks in this skill.

**Mosofin is read-only.** It cannot post a reclassification, an adjustment or a closing entry. Every
proposed change below is a *proposal*.

---

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

<!-- shared:scope-protocol start -->
### First — is Mosofin connected at all?

**Before Gate 0, check whether the Mosofin tools are present** — `list_workspaces` and
the rest of the gateway.

**If they are not present** — the skill was copied on its own, the connector was never
added, or there is no subscription — **skip Gates 0-2 entirely.**
**Do not make connecting a condition of helping.** Say once, plainly, that Mosofin is not connected
and this run will be manual, then **carry on with the skill's normal workflow**: ask
for what each step needs — a trial balance, a statement, an export, the documents
themselves — and do the accounting work on what the user provides.

In that mode:

- every step is `[manual]`; there are no `[auto]` verdicts to claim, and none may be
  implied
- the coverage sheet records that **the gateway was absent** — not that checks passed
- the accounting logic, edge cases and output standards are **unchanged**. That is the
  part of this skill that never depended on a connection
- mention **once** that connecting Mosofin would automate the manual steps, with a link
  to [docs.mosofin.com](https://docs.mosofin.com). Do not raise it again, and never
  withhold work to press the point

**Present but not authenticated is not the same as absent.** If the tools are there and
a call returns a `reconnect_url` or an auth error, surface it and let the user choose —
reconnect, or continue manually. Do not silently fall back.

**If the tools are present, onboarding is required** and the gates below run as written.

### Confirming scope — workspace, then data sources, then tools

**Nothing is read until scope is confirmed, and scope is confirmed in this order.**
Each step depends on the answer to the one before it, so none of them may be skipped,
merged, or guessed at.

| # | Question to the user | How it is settled |
|---|---|---|
| 1 | **Which workspace?** | `list_workspaces` with **no arguments**. Read the workspace back **by name** and wait for an explicit yes. On `selection_required`, ask whether this is single- or multi-workspace, then which **by name**, then call again with `workspace_ids=[…]` and `mode="single"`/`"multi"`. |
| 2 | **Which data sources, in that workspace?** | `get_agent_datasources` with the confirmed `workspace_id`. `connected: true` is in scope; `connected: false` is **excluded and named as excluded**, with any `reconnect_url` surfaced. Then settle the entity scenario — single-entity: which company; multi-entity: which set — always by `display_name`. |
| 3 | **Which tools do those sources actually expose?** | `get_datasource_tools` per in-scope datasource, **and per company file when several are live — permissions are per company.** This is discovery, not a question: read what is there before promising anything. |

**Never auto-pick.** Not the workspace, not the company file, not the entity scenario.
**Silence is not a yes**, and an answer to one question is not an answer to the next.

**Names, never internal ids.** Name the workspace and refer to companies by
`display_name`. Never print an internal numeric tenant id, and never show a raw
`data_source_id` — pass the opaque handle, show the name.

**Only then does the work begin.** Once the workspace, the data sources and their tools
are confirmed, resolve every task against what was actually found: what is available
now decides which steps are `[auto]`, which are `[gated]` and which fall to `[manual]`.
Where the confirmed tools cannot answer the request, say so and ask — do not substitute
an assumption for a capability.

**The catalogue is authoritative.** Take exact `tool_name` values from the Gate 2
listing — names are not uniformly styled, some underscored, some hyphenated.
**Do not invent a tool name.** On `UNKNOWN_TOOL`, read the valid names from the error
and retry.
**Never call a tool whose `effective_policy` is `disabled`.**

**This map is built fresh every run** and held only for this run. It is written out in
the coverage sheet, never written back into this file.
<!-- shared:scope-protocol end -->

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

**This gate matters more here than almost anywhere else in the pack.** Financial statements have a
**reporting entity**, and the reporting entity is defined by which company files are in scope. **A
disconnected subsidiary is not a gap in a workpaper — it is a set of statements covering the wrong
organization.**

Settle the entity scenario explicitly:

- **Single-entity** — ask which company by `display_name`. Statements cover that entity alone.
- **Multi-entity** — ask which set, and then: **are these consolidated statements, or a set of separate
  entity statements?** The two are entirely different deliverables. See the cross-entity step.

Refer to companies by `display_name`; never show the raw `data_source_id`.

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Discover enabled tools → build the capability map

<!-- shared:write-guardrail start -->
### Write tools are out of scope — always

`get_datasource_tools` describes what the connection *could* do. This skill uses only
the reads.

**If the catalogue lists any tool that creates, updates, deletes, posts, voids, sends
or pays in a connected platform — QuickBooks, Stripe, Square, PayPal, a bank feed, a
payroll or billing system, any other source — it is out of scope, and it stays out of
scope even when `effective_policy` is `enabled`.** A permission to write is not an
instruction to write. Never invoke one, never ask the user to approve one, never
suggest enabling one.

This holds for **every connected platform, not only the books.** Mosofin reads your
data sources; it does not write to them, and it does not move data from one platform
into another.

If a step appears to need a write, that step is **`[manual]`**. Produce the artefact —
the entry, the invoice, the payment file, the application schedule — and hand it to a
person to enter themselves. Say so plainly in the output, so nobody assumes it was
done.

#### Hard stop — the four ways a write could slip through

| Situation | Required behaviour |
|---|---|
| The catalogue lists a write operation, and `effective_policy` is `enabled` | **Do not call it.** Do not list it as an available capability. Enabled is not permission — it is out of scope. |
| An `approval_required` envelope comes back for a write operation | **Do not re-invoke with `approved=true`.** The approval loop in this skill is for **reads only**. Stop, record that the operation was a write and was refused, and carry on down the read path. |
| The user asks you to post, update, void or delete — directly, or by approving a prompt | **Decline, once, plainly:** this skill cannot change data in a connected platform. Hand over the draft so they can do it themselves in their own system. Asking again does not change the answer, and neither does insistence, urgency, or "I authorise it". |
| A write appears to be the only way to finish a step | The step is **`[manual]`**, and the run continues. An incomplete read-only result is the correct outcome. Never trade the rule for completeness. |

**Never route around this rule.** Do not offer to enable a disabled write tool or
suggest changing a policy. Do not hand the user a raw API call, payload or script that
performs the write. Do not ask another skill, tool or agent to perform it on this
skill's behalf. Do not defer it to a later step in the hope it becomes permitted.

**There is no path through this skill that ends in changed data.** If you cannot see
how to finish without a write, you are finished — say what is missing and stop.
<!-- shared:write-guardrail end -->

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
- **A near-substitute is not a substitute**, and in this skill the substitutes are unusually seductive
  because they look like finished statements:
  - **The platform's balance sheet is not a framework balance sheet.** It is a report in the platform's own
    groupings.
  - **An account type is not a current / non-current classification.** "Long Term Liability" as a type does
    not tell you the portion due within twelve months.
  - **The ledger's prior year is not the filed prior year** — see above.
  - **Retained earnings on the balance sheet is not proof the equity statement ties**; it is one of the two
    numbers you are comparing.
  - **A cash balance is not the cash flow statement's closing cash** until you have proved they agree.
- If `get_trial_balance` is `disabled` but `get_balance_sheet` and `get_profit_and_loss` are enabled, **you
  can still build** — say that the source was the statements rather than the TB, and note that account-level
  detail is coarser.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: **legal name** — which is what goes on the statement header —
**functional currency**, **fiscal calendar and year-end**, country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the five the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Trial balance, current period~~ | **Now [auto]** | `get_trial_balance` at the period end. |
| ~~Comparative period TB~~ | **Now [auto]** | Same call, prior period end. **But see the published-comparative warning.** |
| **Reporting framework** — US GAAP / IFRS / local GAAP | **Required — [manual]** | **Ask first.** It decides ordering, terminology and format throughout. |
| ~~Functional / presentation currency~~ | **Now [auto]** | From the profile. **Ask only if presentation currency differs from functional.** |
| ~~Entity name and reporting period~~ | **Now [auto]** | Legal name from the profile; confirm the period. |
| ~~Chart of accounts with type mapping~~ | **Now [auto]** | From `search_accounts`. |
| **Classification rules** — current / non-current criteria | Recommended — **[gated]** | **The current portion of debt and leases is the hard part**; it needs the amortization schedules. |
| **Special presentation elements** — discontinued ops, extraordinary items, segments | If applicable — **[manual]** | Nothing in the ledger flags a disposal group. |
| **Prior-year audited financials** — for continuity | Recommended — **[manual]**, and **more important than the original implies** | The check that catches unposted audit adjustments. |
| **Presentation currency**, if different from functional | If applicable — **[manual]** | Translation per `foreign-currency-translation-asc830`. |
| **Rounding basis** | Recommended — **[manual]** | Whole units, thousands, millions. |
| **Share count for EPS**, if EPS is required | If applicable — **[manual]** | **Weighted average shares are not in the ledger.** |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, **and whether the package is consolidated or separate**. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. a year-end that disagrees with the period requested. |
| **Confirm manual evidence** | **Required** | The framework, the prior-year financials, the debt schedules and any EPS data are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a framework, a
current / non-current split, a rounding basis, or a share count.

**On later runs**, read stored preferences first (Step 12), confirm in one line, and ask only what changed.
The framework, the account-to-line mapping, the classification rules and the rounding basis persist; **the
balances are re-obtained every period**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** EPS and discontinued operations are legitimately
`[manual]`, and recording that is the honest result.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the current TB, the comparative TB, the accounts and the
profile do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* at the **current period end** — the primary source — usually **[auto]**
- *`get_trial_balance`* at the **comparative period end** — usually **[auto]**
- *`search_accounts`* — **account names, numbers and types** — usually **[auto]**
- *`get_balance_sheet`* current and comparative — usually **[auto]**
- *`get_profit_and_loss`* current and comparative — usually **[auto]**
- *`get_cash_flow_statement`* where the platform offers one — usually **[auto]**
- *`get_general_ledger`* — for the movement detail behind any line that needs analysis — usually **[auto]**
- *`get_company_info`* — **legal name, currency, year-end** — usually **[auto]**

**Pull both periods on the same basis.** Where the platform offers an `accounting_method` argument
(cash / accrual), **pass the same value for both periods** — a comparative pulled on a different basis is
not a comparative, and the difference is invisible once it reaches a spreadsheet.

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data. **Financial statements are the most consequential
output in this pack** — they go to banks, investors and auditors. **A statement package built on fixture
data must say so on the face of every statement**, not in a footnote.

## Step 1 — Validate the TB

Before building statements — **[auto]** throughout:

- **Sum of debits = sum of credits** (the TB balances)
- **Every account has a type** — Asset / Liability / Equity / Revenue / Expense
- **Every revenue and expense account is on the P&L side**
- **Every BS account is on the BS side**
- **No type mismatches** — a liability with a perpetual debit balance, and so on

**If the TB is unbalanced, fix that first via `closing-entries-and-trial-balance` review.** *Mosofin note*:
a TB pulled from a live double-entry platform **will balance**, so this check is a formality on
platform-sourced data and a real check on anything supplied by hand. **The type-mismatch test is the one
that still earns its place** — a liability account sitting in debit is a genuine finding the software will
happily report.

**If the period is mid-year** — P&L accounts hold **YTD balances**, no closing yet — **build statements
directly from those YTD balances.** **If post-closing**, all P&L accounts are zero **and you need the
period's activity elsewhere** — *`get_profit_and_loss`* for the period, or *`get_general_ledger`*.

**[auto]** to detect which case you are in: read the P&L accounts. All zero at a year-end date means
post-closing. See `closing-entries-and-trial-balance` for the auto-close behaviour some platforms apply
without an explicit entry.

## Step 2 — Build the Balance Sheet

### Classification — Current vs. Non-current

**US GAAP and IFRS both use current / non-current with similar criteria. Current assets are expected to be
realized or consumed within 12 months** — or **one operating cycle if longer**. **Current liabilities are
due within 12 months.**

**[gated]**: account types are `[auto]`, but the twelve-month test is judgment plus schedules. **The
current portion of long-term debt is the classic case** — the ledger usually carries one loan balance, and
splitting it needs the amortization schedule (see `debt-and-covenant-tracking`). The same applies to lease
liabilities and to deferred revenue.

### Balance Sheet structure

Most common; framework variations noted:

```
ASSETS
  Current Assets
    Cash and cash equivalents
    Short-term investments / marketable securities
    Accounts receivable, net of allowance
    Inventory
    Prepaid expenses
    Input tax recoverable (current portion)
    Other current assets
  Total Current Assets

  Non-current Assets
    Property, plant & equipment, net (cost less accumulated depreciation)
    Right-of-use assets (under ASC 842 / IFRS 16)
    Intangible assets, net
    Goodwill
    Long-term investments
    Deferred tax assets (non-current portion)
    Other non-current assets
  Total Non-current Assets

  TOTAL ASSETS

LIABILITIES
  Current Liabilities
    Accounts payable
    Accrued expenses
    Current portion of long-term debt
    Current portion of lease liabilities
    Customer deposits / current deferred revenue
    Sales tax / VAT / GST payable
    Income tax payable
    Other current liabilities
  Total Current Liabilities

  Non-current Liabilities
    Long-term debt (net of current portion)
    Lease liabilities (net of current portion)
    Deferred revenue (non-current)
    Deferred tax liabilities
    Other non-current liabilities
  Total Non-current Liabilities

  TOTAL LIABILITIES

EQUITY
  Common stock (par value)
  Additional paid-in capital
  Retained earnings
  Treasury stock (contra)
  Accumulated other comprehensive income / (loss)
  Total Equity attributable to shareholders of the parent
  Non-controlling interests (if multi-entity consolidation)
  TOTAL EQUITY

  TOTAL LIABILITIES AND EQUITY
```

**Validation: Total Assets = Total Liabilities + Total Equity, to the penny.** **Prove this on the
statement you built**, after reclassification — not on the platform's report, which balances by
construction.

**IFRS differences:**

- **IFRS typically presents non-current items first** (assets, then liabilities, then equity) **and current
  items second — opposite of US GAAP**
- **IFRS requires "Trade and other receivables" / "Trade and other payables" terminology**
- **Property, plant & equipment may be revalued under IFRS** — revaluation surplus in OCI

**Local GAAP may have other variations — apply per the user's framework.**

**Mosofin mapping note.** Map each ledger account to a statement line **explicitly, and keep the mapping**
(Step 12). **Every account in the TB must land on exactly one line**, and the sum of mapped accounts must
equal the TB total. **An unmapped account is the commonest way a statement quietly stops balancing** —
check for it rather than trusting that the totals happened to agree.

## Step 3 — Build the Income Statement

**Two formats are common** — **[manual]** to choose, `[auto]` to populate:

**By Function** — typical for many entities, especially under US GAAP:
```
Revenue
Cost of Revenue / Cost of Goods Sold
  Gross Profit
Operating Expenses:
  Research and Development
  Sales and Marketing
  General and Administrative
  (Other operating expenses)
  Operating Income
Other Income / (Expense):
  Interest income
  Interest expense
  Foreign currency gain / (loss)
  Other income / expense, net
  Income before tax
Income tax expense
NET INCOME / (LOSS)
```

**By Nature** — common under IFRS, especially in continental Europe:
```
Revenue
Other income
Changes in inventories of finished goods and WIP
Raw materials and consumables used
Employee benefit expense
Depreciation and amortization expense
Other expenses
  Operating Profit
Finance income
Finance costs
  Profit before tax
Income tax expense
PROFIT FOR THE PERIOD
```

**Both formats arrive at the same net income. Apply the user's policy or framework norm.**

**Single-step vs. multi-step**: **most accrual entities use multi-step** — gross profit shown separately.
**Single-step** — one block of revenue minus expenses — **is rarer.**

*Mosofin note*: **by-function requires the entity to have tracked function.** If departments or classes were
never used, a by-function P&L is a reallocation exercise, not a read. **[auto]** to check
(*`search_departments`*, *`search_classes`*, *`get_profit_and_loss`* with a summarize argument) — and worth
checking before promising the format.

## Step 4 — Add comparative period

**Standard practice is to present:**

- **Current period and one comparative period** — this year versus last year
- **For 10-K / annual filings: 2 prior years for the IS and 1 prior year for the BS** — per SEC; **varies
  by jurisdiction**

**Comparatives must be on a consistent basis with the current period. If a reclassification was made in the
current period, restate the prior period's comparatives to match — and disclose.**

**[auto]** to fetch, **[manual]** to validate — and the validation is the part that matters. Two Mosofin
checks:

1. **Same basis.** Both periods pulled with the same `accounting_method` and the same reporting parameters.
2. **Agreement with what was published.** Compare the ledger's prior year to the **prior-year financial
   statements as issued**. **A difference means audit adjustments were never posted, or the prior year was
   reopened and something changed.** Both are findings; neither is rare. Report the difference and ask
   which version governs before building comparatives on it.

## Step 5 — Add the Statement of Comprehensive Income

**Required under both US GAAP (ASC 220) and IFRS (IAS 1). Can be:**

- **A single statement of Profit or Loss AND OCI together**
- **Or two statements**: P&L, then a separate Statement of Comprehensive Income

**OCI items — closed to AOCI, not RE:**

- **Foreign currency translation adjustments (CTA)** — **[gated]**; arises on translation, see
  `foreign-currency-translation-asc830`
- **Available-for-sale debt securities — unrealized gains / losses** — **[manual]**; needs market values
- **Cash flow hedge gains / losses (effective portion)** — **[manual]**; see
  `derivatives-and-hedging-asc815`
- **Defined benefit plan actuarial gains / losses** (per framework) — **[manual]**; actuarial
- **Revaluation surplus on PP&E (IFRS only)** — **[manual]**; needs a valuation

```
Net Income
  Other Comprehensive Income, net of tax:
    Foreign currency translation
    Unrealized gains/losses on securities
    Cash flow hedges
    Pension actuarial gains/losses
  Total Other Comprehensive Income
Total Comprehensive Income
```

**Four of the five OCI items need data the accounting system does not hold.** Where an AOCI balance exists
in the ledger but no supporting analysis is available, **report the balance and name the analysis
required** — do not present a movement you cannot explain.

## Step 6 — Build the Statement of Cash Flows

**Hand off to `cash-flow-statement-indirect-method` for the full procedure. The result fits in the package
as the third primary statement.** **[gated]** — that skill has its own capability map; the balance-sheet
movements it needs are `[auto]`, the non-cash and financing detail often is not.

Where the platform offers its own cash flow report (*`get_cash_flow_statement`*), **it is a useful
cross-check, not a substitute** — platform cash flow reports classify by their own rules and frequently
misclassify financing and investing items.

## Step 7 — Build the Statement of Changes in Equity / Statement of Stockholders' Equity

**Hand off to `statement-of-equity-changes`. This shows the roll-forward of each equity component.**
**[gated]** — the balances are `[auto]`, the movements need attribution.

## Step 8 — Cross-statement validations

**Critical tie-outs.** This is the heart of the skill — **[auto]** to compute, and each one must be
**reported with its actual difference**, not merely asserted:

1. **Balance Sheet balances** — **Assets = Liabilities + Equity.** *On your statements, post-reclassification.*
2. **Net Income on IS = Net Income line on Cash Flow Statement** — the start of operating activities under
   the indirect method
3. **Net Income + OCI on Statement of CI = Net Income on Statement of Equity Changes**
4. **Cash at end of period on Cash Flow Statement = Cash on Balance Sheet**
5. **Closing Retained Earnings on Statement of Equity = Retained Earnings on BS**
6. **Comparative period figures = prior year's filed financials** — or restated comparatives if
   reclassified, **with disclosure**. *This is the `[manual]` one, and the one most often skipped.*
7. **Inter-statement currency consistency** — if reporting in USD, **every statement says USD**

**Report each tie-out as pass / fail with the difference**, even when it is zero. **"Balances" without a
number is an assertion; "balances, difference 0.00" is evidence.** A rounding-driven difference is still a
difference and belongs in Step 9, not hidden here.

## Step 9 — Apply rounding and presentation

**Common rounding** — **[manual]** choice:

- **Thousands ($000s)** for small / mid entities
- **Millions** for large entities
- **Whole dollars** for very small / startup

**Whatever rounding is used, it must be consistent within the document. Rounding can create $1 line-item
differences in totals; either re-balance or footnote.**

**Other presentation choices:**

- **Comparatives shown side by side** (current | prior)
- **Negative numbers in parentheses or with a minus sign**
- **Subtotals bolded or in lines**
- **Page footers with company name, period, currency, rounding basis**

**Mosofin addition to the footer**: also state **the entity by `display_name`, the source datasource, and
whether any figure rests on `mock` data.** The footer travels with the statements after they leave this
conversation, which is exactly when someone needs to know where the numbers came from.

## Step 10 — Quality checks

Final review:

- **Math**: every subtotal and total — **[auto]**
- **Cross-references**: **every line ties to a TB account or sum** — **[auto]**, and this is where the
  explicit mapping from Step 2 pays for itself
- **Comparability**: **no line in current that's missing in prior** (or vice versa) **without explanation**
  — **[auto]**
- **Trend reasonableness**: **large period-over-period changes should be explainable** — **[gated]**;
  the movement is readable, the explanation is not
- **Sign conventions**: **contra accounts displayed with brackets or as deductions** — **[auto]**
- **Materiality**: **nothing misclassified to the point of misleading** — **[manual]** judgment

## Step 11 — Output

Deliver an `.xlsx` workpaper with statements ready for presentation:

**Sheet 1: Trial Balance (source)** — **with a column for statement line mapping.** Add the Mosofin
provenance: the tool call, the entity `display_name`, the as-at date and the accounting method used.

**Sheet 2: Balance Sheet** — with current period and comparative.

**Sheet 3: Income Statement** — with current period and one or more comparatives.

**Sheet 4: Statement of Comprehensive Income** — if material OCI items exist.

**Sheet 5: Statement of Cash Flows** — from `cash-flow-statement-indirect-method`.

**Sheet 6: Statement of Changes in Equity** — from `statement-of-equity-changes`.

**Sheet 7: Cross-Statement Tie-Outs** — **the 7 critical validations from Step 8**, each with its computed
difference.

**Sheet 8: Reclassifications and Restated Prior Period** — if applicable. **Every reclassification listed
as a proposal**, since Mosofin posts nothing.

**Sheet 9: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Accounting method | Policy | `mock` | Gap |

Include a row for **each of the seven tie-outs**, since tie-out 6 is `[manual]` and its absence otherwise
looks like a pass.

**Optionally a clean PDF render** — read `/mnt/skills/public/pdf/SKILL.md` if creating PDF.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Financial_Statements_[YYYY-MM]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`, or the group name for a consolidated package. Every
file states which datasource and `display_name` it covers, **and whether it is consolidated or separate**.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — EPS, discontinued operations, the published comparative — **name the source required**
instead of estimating.

## Step 12 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The framework** and every presentation election within it: by-function or by-nature, single or two
  statements for OCI, current-first or non-current-first ordering
- **The account-to-statement-line mapping** — **the single most valuable asset this skill produces.**
  Rebuilding it every quarter is the whole cost of the exercise
- **The classification rules**: what counts as current here, how the current portion of debt and leases is
  determined, and from which schedule
- **The rounding basis** and presentation conventions, including the footer content
- **The accounting method** (cash / accrual) used for both periods — so comparatives stay on one basis
- **The comparative policy**: how many prior periods, and whether prior-year figures come from the ledger
  or from the issued financials
- **Which OCI items apply** to this entity, and where each one's data comes from
- **The consolidation choice** — consolidated or separate — and the entities in the reporting group
- The replay recipe: the exact sequence of reads that produced both periods

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist balances, statement figures or the trial balance itself.** A published statement is a
point-in-time representation that must be rebuilt from live data, never recalled. **Persist the mapping and
the presentation decisions; never the numbers.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Holdings — IFRS, by-nature, non-current first, thousands, accrual basis, mapping v3" — not "IFRS,
by-nature". **The mapping is chart-specific and therefore entity-specific**, and applying one company
file's mapping to another produces statements where accounts land on the wrong lines and the totals still
foot. Record the chosen **scenario** (single vs multi, consolidated vs separate) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and every balance on every statement is state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere. **For consolidated
statements this is not a warning but a stop condition**: a missing group member means the statements do not
cover the reporting entity.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One TB, one comparative, one package.

**Multi-entity.** Steps 0–11 run **once per entity**, each call targeting exactly one `data_source_id`,
every statement carrying its entity's `display_name`. Then the decision that defines the deliverable:

- **Consolidated statements.** Each entity's TB is consolidated per `consolidation-and-eliminations`, **then
  the statements are built from the consolidated TB.** The consolidation eliminates intercompany items.
  **Do not build statements per entity and add them together** — that double-counts intercompany balances
  and revenue, and the result will still balance, which is what makes the error so durable.
- **Separate statements.** A package per entity, each labelled with its own `display_name`. **Never present
  a separate-entity package as if it covered the group**, and never mix the two in one file without saying
  so on every sheet.
- **Non-controlling interests** appear in equity only on consolidated statements, and only where a
  subsidiary is partly owned.
- **Multi-currency**: **each entity in its functional currency; group reporting currency requires
  translation per ASC 830 / IAS 21. CTA flows to OCI.** See `foreign-currency-translation-asc830`.
- **Parent-only statements** may be required in some jurisdictions **in addition to** consolidated ones.
  **Use the same procedure on the parent-only TB** — and label the two unmistakably.
- **The tie-outs run on whichever set you present.** Consolidated tie-outs prove the consolidated package;
  they say nothing about the separate ones.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file. **An entity whose TB could not be read cannot be silently omitted from a consolidation** — say so on
the face of the statements.

---

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on discovery; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 12. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The trial balance, both periods** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Account names, numbers and types** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Balance sheet, current and comparative | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Income statement, current and comparative | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `accounting_method` |
| Platform cash flow report — **cross-check only** | `get_cash_flow_statement` | `start_date`, `end_date` |
| Movement detail behind any line | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Whether function tracking exists | `search_departments` / `search_classes` | `query`/`name`, `active_only` |
| **Legal name, currency, year-end** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no share register, no debt amortization schedule, no valuation and no prior-year audited file on
this surface.**

---

## Plain-language glossary

- **Trial balance (TB)** — the list of every account and its balance; the raw material of the statements.
- **Balance Sheet** — what the business owns and owes at a moment in time. **IFRS calls it the statement of
  financial position.**
- **Income Statement / P&L** — what it earned and spent over a period. **IFRS: statement of profit or
  loss.**
- **Statement of Cash Flows** — where the cash actually came from and went.
- **Current vs. non-current** — due or expected within twelve months, or later.
- **Operating cycle** — how long it takes to turn inventory into cash; for a few businesses it is longer
  than a year and replaces the twelve-month test.
- **By function** — grouping costs by what they were for (selling, admin). **By nature** — grouping by what
  they were (wages, materials).
- **Multi-step vs. single-step** — whether gross profit is shown as its own subtotal.
- **Comparative** — the prior period shown alongside, so the reader can see movement.
- **Restated comparative** — a prior period redrawn on the current basis after a reclassification or a
  correction.
- **OCI (other comprehensive income)** — gains and losses parked in equity rather than run through profit.
  **AOCI** is where they accumulate.
- **CTA (cumulative translation adjustment)** — the OCI item created by translating a foreign subsidiary.
- **Contra account** — an account that reduces another, such as accumulated depreciation or an allowance.
  **Shown as a deduction, never as a positive.**
- **Non-controlling interest (NCI)** — the share of a subsidiary owned by someone other than the group.
- **Discontinued operations** — a business being disposed of, shown on one line net of tax.
- **EPS** — profit per share. **Basic** uses shares actually outstanding; **diluted** assumes options and
  convertibles are exercised.
- **Tie-out** — proving two figures in different places agree.
- **Presentation vs. functional currency** — the currency the statements are shown in, versus the currency
  the entity actually operates in.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Mid-year statements with no closing entries**: **P&L accounts hold YTD balances directly. Don't post
closing entries to build the IS — just use the YTD balances.**

**Post-closing TB with all P&L accounts at zero**: **cannot build an IS from this alone. Need the period's
activity** — general ledger transactions or a pre-closing snapshot. *Mosofin note*: *`get_profit_and_loss`*
for the period supplies it directly, which is easier than the original assumes.

**Multi-entity consolidated statements**: **each entity's TB consolidated per
`consolidation-and-eliminations`, then statements built from the consolidated TB. The consolidation
eliminates intercompany items.**

**Multi-currency**: **each entity in its functional currency; group reporting currency requires translation
per ASC 830 / IAS 21. CTA flows to OCI.**

**Discontinued operations** (US GAAP — ASC 205-20; IFRS 5): **presented separately on the IS, net of tax, on
a single line. Assets and liabilities of a disposal group held for sale separately on the BS. Prior periods
restated to reflect.** *Mosofin note*: **nothing in the ledger flags a disposal group** — `[manual]`, always.

**Investment company / specialized industry presentation**: **certain industries have specific statement
formats** — banks, insurance, REITs, registered investment companies. **Apply industry guidance.**

**Going-concern doubt**: **doesn't change the statements themselves but requires disclosure** — see
`notes-to-financial-statements`.

**Restated comparatives**: **if the prior period was restated** (correction of an error per
`restatement-and-prior-period-adjustment`), **present restated comparatives with disclosure.**

**Materially different from the auditor's expected statements**: **if the auditor's adjustments materially
change the statements, ensure those adjustments are in the TB before building.** *Mosofin note*: **this is
the single most important check in the skill, and it is `[manual]`.** The ledger will happily give you a
prior year that no longer matches what was filed.

**Reverse-stock-split or other capital restructurings**: **retrospective adjustment to all per-share data in
comparatives** — typically presented in the EPS section and notes.

**EPS (Earnings Per Share)**:
- **Required under US GAAP for public entities and IFRS for entities with listed equity**
- **Basic EPS = (Net income − preferred dividends) / weighted average common shares outstanding**
- **Diluted EPS = same numerator with dilutive securities effect; same denominator with dilutive securities
  added**
- **Hand off detail to a separate computation; result shown on the IS face**
- *Mosofin note*: **weighted average shares are not in the ledger** — `[manual]`, from the share register.

**Single-entity vs. consolidated presentation**: **parent-only statements may be required in some
jurisdictions in addition to consolidated. Use the same procedure on the parent-only TB.**

**The platform's balance sheet is presented as the finished statement** — *Mosofin-specific, and the
commonest shortcut*. It is a report in the platform's groupings, not framework presentation. **Reclassify,
then re-prove the balance on what you built.**

**Tie-out 1 is reported as a pass without reclassification** — *Mosofin-specific*. A system-sourced balance
sheet balances by construction. **The test only means something on your own statements.**

**The two periods were pulled on different accounting methods** — *Mosofin-specific, and invisible
downstream*. Pass the same `accounting_method` for both, and record it on the TB sheet.

**An account in the TB maps to no statement line** — *Mosofin-specific*. The commonest cause of a package
that stops footing. Check mapping completeness explicitly rather than trusting the totals.

**A by-function P&L is requested but the entity never tracked function** — *Mosofin-specific*. Say that it
is a reallocation, not a read, and ask for the basis.

**An AOCI balance exists with no supporting analysis** — *Mosofin-specific*. Report the balance and name
the analysis required; never present an unexplained movement.

**A company file is connected but not active** — *Mosofin-specific*. For a consolidated package this is a
**stop condition**, not a footnote: the statements would not cover the reporting entity.

**A result comes back with `mock: true`** — *Mosofin-specific*. **These statements go to banks, investors
and auditors.** Say so on the face of every statement, not in a footnote.

**A stored trial balance or statement figure is reused** — *Mosofin-specific*. All of it is state. Persist
the mapping and the presentation decisions; rebuild the numbers.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it, and stop
if the package is consolidated.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Balance Sheet balances** (Assets = Liabilities + Equity)
- **Net income consistent across IS, OCI, equity changes, cash flow**
- **Cash on BS = end-of-period cash on the CF statement**
- **Comparatives consistent with prior period filings or restated**
- **Classification rules applied consistently**
- **Currency and rounding declared and consistent**
- **Cross-statement tie-outs documented**
- **Framework-appropriate format and terminology**
- **File naming consistent**
- **No silent reclassifications between comparable periods**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**; the
  package states **whether it is consolidated or separate**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The balance test was proved on the statements as presented**, after reclassification — not on the
  platform's own report
- **All seven tie-outs are reported with their computed difference**, including zero, and **tie-out 6 is
  marked `[manual]`** rather than implied to have passed
- **Both periods were pulled on the same accounting method**, and the method is recorded on the TB sheet
- **The ledger's prior year was compared to the prior-year financials as issued**, and any difference — the
  signature of unposted audit adjustments — is reported before comparatives are built on it
- **Every TB account maps to exactly one statement line**, and mapping completeness was checked explicitly
- The **current / non-current split is supported**, with the source named for the current portion of debt
  and leases
- Where a by-function P&L was produced without function tracking, **it is stated as a reallocation**
- **AOCI balances without supporting analysis are reported as such**, and EPS and discontinued operations
  are marked `[manual]` with their source named
- In a multi-entity run, **consolidated statements are built from the consolidated TB**, never by adding
  entity packages together, and an unreadable group member is a stop condition
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported **on the face of every statement** wherever it applies
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- The footer carries the entity `display_name`, the source datasource, the currency, the rounding basis and
  the `mock` status, so provenance travels with the statements
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No balances, statement figures or trial balances are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no reclassification, adjustment or closing entry posted
