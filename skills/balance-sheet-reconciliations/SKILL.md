---
name: balance-sheet-reconciliations
description: "Use this skill whenever the user wants to reconcile balance sheet accounts to supporting subledgers or external documents, working from their Mosofin workspace. Triggers include: 'reconcile our balance sheet accounts', 'reconcile [AR/AP/prepaid/accrued/intercompany/etc.] to GL', 'monthly BS rec workpaper', 'reconcile this account to its supporting schedule', 'identify unreconciled differences', or any task that involves tying a GL balance to its source. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then pulls the GL side from the live books and resolves each account's supporting side against the capability map — automatic where the subledger lives in the connected system, named as a gap where it does not. Do NOT use for bank reconciliation — use bank-reconciliation. Do NOT use for full period close — use month-end-close-checklist. Outputs a reconciliation workpaper per account with tie-out, identified items, unreconciled differences, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill works with or without Mosofin

**With Mosofin connected**, the skill reads your live accounting data through the
gateway: the figures come from your own books, it validates against the real chart of
accounts, and most steps run automatically.

**Without it, the skill still works.** No subscription, no connector, or a skill copied
on its own — you are not blocked and you are not asked to buy anything first. The
Mosofin gates are skipped and you are asked for what each step needs instead: a trial
balance, a statement, an export, the documents themselves. **The accounting logic, the
edge cases and the output standards are identical** — only where the numbers come from
changes, and the output always says which is which.

**You choose, and you are asked.** Where a connection exists, the skill asks at the
start whether to use it for this run or whether you would rather supply the data
yourself — **a connected gateway is not taken as consent to read your books.** Say no
and it runs manually without asking again.

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
# Balance Sheet Reconciliations (Mosofin)

Reconciles **general ledger (GL)** balance sheet account balances to supporting **subledgers**,
schedules, or external documents. Designed for the controllership function — the standard
monthly / quarterly procedure to support the trial balance.

**In plain words:** the balance sheet shows one number per account. Behind most of those numbers
there should be a detailed list that adds up to exactly that number — the customers who owe you,
the bills you haven't paid, the assets you own. **Reconciling** is proving the two agree, and
explaining every difference when they don't. It is the routine that catches errors before they
become audit findings.

This skill is **chart-of-accounts-agnostic** — it builds the same disciplined reconciliation
format for any account type.

It is **not** system-agnostic. It is **workspace-scoped**: every balance and account name comes
from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**The structural shape of this skill in a Mosofin workspace, stated up front.** A reconciliation
has two sides, and they behave very differently here:

- **The GL side is almost always `[auto]`.** The trial balance, the account balance, and the
  transactions behind it are all readable.
- **The supporting side is `[auto]` only where the subledger itself lives in the connected
  system.** In practice that means **accounts receivable, accounts payable, and any
  suspense / clearing account** — where the "subledger" is just a different view of the same
  books. For prepaid schedules, fixed asset registers, lease schedules, payroll registers, loan
  amortization schedules, tax filings and bank statements, **the supporting side is outside the
  connected books and is `[manual]`**.

So expect a workpaper where the GL column is complete and the support column is mixed. Say which
is which per account. **A reconciliation where both sides came from the same source is not a
reconciliation** — it is a total agreeing with itself, and presenting it as a tie-out asserts
assurance that was never obtained.

**One genuine multi-entity advantage:** where **both** sides of an intercompany balance are
connected company files in the same workspace, the counterparty's mirror balance *is* readable.
That reconciliation becomes `[auto]` on both sides — one of the few where it does.

**Mosofin is read-only.** It cannot post a correcting entry, clear a suspense account, or sign
off a reconciliation. Every correction below is a *proposal* for a human.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

<!-- shared:scope-protocol start -->
### First — ask whether to use Mosofin for this run

Two things decide how this skill runs, and they are settled **before Gate 0**.

**1. Are the Mosofin tools present at all?** — `list_workspaces` and the rest of the
gateway. Check before doing anything else.

**2. If they are present, ask the user. Once, in these terms:**

> Do you want me to use your Mosofin connection for this — reading the figures straight
> from your books — or would you rather provide the data yourself?

**Wait for the answer.** A connected gateway is **not** consent to read from it, and
this skill does not open with a data read. Never assume, never auto-pick.

- **Use Mosofin** → onboarding is required. Run Gates 0-1 to confirm the workspace and
  its data sources, then Part A explores what those sources expose.
- **Provide the data myself** → **skip Gates 0-2 entirely** and run manually, exactly as
  though no connector were present. **Do not ask again during the run.** Raise it once
  more only if the user asks for something their supplied data cannot answer, and then
  as an offer, not a demand.

**If the tools are not present, do not ask** — there is nothing to choose. The skill was
copied on its own, the connector was never added, or there is no subscription.
**Do not make connecting a condition of helping.** Say once, plainly, that Mosofin is
not connected and this run will be manual, then **carry on with the skill's normal
workflow**: ask for what each step needs — a trial balance, a statement, an export, the
documents themselves — and do the accounting work on what the user provides.

**In manual mode**, whether chosen or unavoidable:

- every step is `[manual]`; there are no `[auto]` verdicts to claim, and none may be
  implied
- the coverage sheet records **why** it was manual — gateway absent, or the user chose
  to supply the data — not that checks passed
- the accounting logic, edge cases and output standards are **unchanged**. That is the
  part of this skill that never depended on a connection
- mention **once** that connecting Mosofin would automate the manual steps, with a link
  to [docs.mosofin.com](https://docs.mosofin.com). Do not raise it again, and never
  withhold work to press the point

#### What a manual run actually does, gate by gate

| Gate | In a manual run |
|---|---|
| **Gate 0** — workspace | **Skipped.** There is no workspace to confirm. |
| **Gate 1** — data sources | **Skipped as a discovery step.** Still ask *which entity or company this work is for*, by name, so every output can be labelled — but record it as **user-asserted**, not confirmed against a connection. |
| **Gate 2** — capability map | **Skipped.** The map is not empty, it is uniform: **every task is `[manual]`.** |
| **Gate 3** — profile, then interview | **Runs, and grows.** The profile half cannot run — there is no company-profile tool — so everything it would have derived silently becomes a **question**: base currency, fiscal calendar, country or region, time zone. Then the interview runs in full, and **every row of the Inputs table that would have been `[auto]` becomes something to ask for.** |

Then **Part B runs unchanged** on what the user supplied.

**Ask the user to upload the data, and name the formats.** A manual run does not mean
retyping anything. Say plainly what to upload, in what form, and what each item is for —
then read it from the files they provide.

| Ask for | Upload as |
|---|---|
| Ledger detail, trial balance, transaction listings | **CSV** or **XLSX** export, or a pasted table |
| Statements and third-party documents | **PDF** or **CSV**, or a clear photo / scan |
| Invoices, bills, receipts, remittances | **PDF** or **image** — a single file or a batch |
| Short facts — a date, a balance, a policy | typed straight into the chat |

**Ask for the whole set up front, as a checklist, not drip-fed.** A person collecting
exports would rather be given one list than be interrupted six times. Mark which items
are strictly **required** and which merely improve the result, so they can decide how
much to gather.

**Confirm what actually arrived before starting the work.** Name each file, say what was
read from it — period covered, row count, opening and closing balances — and list what
is still outstanding. If a file is unreadable, covers the wrong period, or does not
contain what its name suggests, **say so at once**. Never work around a bad input
silently, and never guess at a column you cannot identify — ask.

**If something cannot be supplied, say what the output will and will not be — before
doing the work.** Never estimate a figure that was meant to come from the books, never
fill a gap with a plausible number, and never present a partial result as complete. An
honest partial answer, clearly labelled, is the correct outcome.

**Everything the user provides is evidence like any other.** Reconcile it, check it,
and challenge it where it does not tie. Manual input is not more trustworthy than a
ledger read — it is less, because nothing validated it on the way in.

**Present but not authenticated is not the same as absent.** If the tools are there and
a call returns a `reconnect_url` or an auth error, surface it and let the user choose —
reconnect, or continue manually. Do not silently fall back.

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
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Two things to look for specifically here:**

- **Are both sides of any intercompany relationship connected?** If so, that reconciliation is
  `[auto]` on both sides. If only one side is connected, the counterparty balance is `[manual]`
  and must be requested. This single check changes the verdict on one of the hardest accounts.
- **Is a payroll, inventory, or payments platform connected?** Each one converts a normally
  `[manual]` supporting side into an `[auto]` one. Check every row, not just the accounting one.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every account, balance and reconciling item carries its
  entity's `display_name`. **Never reconcile one entity's GL balance to another entity's
  subledger** — except deliberately, for the intercompany mirror check, which is exactly that
  comparison done on purpose and labelled as such.

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

| `effective_policy` | The reconciliation becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every account in Step 1's table** against these buckets — **separately for its GL side
and its supporting side**. That two-column resolution *is* the capability map for this skill.
It is built this run, held for this run, written out as the coverage sheet, and **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated — and the receivables and payables aging reports
  frequently carry *different* policies in the same catalog, which means A/R may reconcile
  automatically while A/P does not.
- **A near-substitute is not a substitute.** A **vendor balance** report is not an **A/P aging**
  and a **customer balance** report is not an **A/R aging** — they give totals with no aging
  detail, so they can confirm a total but cannot evidence *which items make it up*. For a
  reconciliation that distinction is the whole point: an unexplained total agreeing is luck, not
  a tie-out.
- **Do not reconcile a balance to itself.** If the only available "support" is another view of
  the same GL, say so and mark the supporting side `[manual]`.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: legal name, base / functional currency, fiscal
calendar and period-end, country / region, industry.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Account(s) being reconciled** — number + name | **Required — partly [auto]** | The chart of accounts pulls; ask **which** accounts are in scope, or confirm "all balance sheet accounts". |
| **Reporting period** — date range | **Required** | Never default the period. |
| **GL balance at period end** | **Required — usually [auto]** | Pulled from the trial balance. |
| **Supporting subledger / schedule / external doc** | **Required — mixed** | Per account: `[auto]` for A/R, A/P and clearing; **[manual]** for prepaid, fixed assets, leases, payroll, debt, tax and bank. Ask where each `[manual]` schedule lives. |
| **Prior period reconciliation** | Recommended — **[manual]** | Needed for the carry-forward check in Step 8. Ask for it; without it, say the carry-forward could not be performed. |
| **Materiality threshold for unreconciled differences** | Recommended | **Ask the user. Do not silently assume** — see the edge case for how to suggest one. |
| **Chart of accounts** — for posting cleanup JEs | **Required — usually [auto]** | Confirm the cleanup / suspense account by its real name. |
| **Who prepares and who reviews** | Recommended | The workpaper header needs both, and they should not be the same person. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's period-end does not match the period named. |
| **Confirm manual evidence** | **Required** | For each account whose supporting side is `[manual]`, ask whether the schedule can be supplied, and how. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the materiality threshold, or the entity.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what
is new, changed, or contradicted. The account-to-source map and the materiality threshold should
not be re-asked every month.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop an account because no tool covers its supporting side.** An account whose support is
`[manual]` is an account with a *named gap and a named owner*, not an account that reconciled.
Omitting it from the workpaper implies a tie-out that never happened.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the trial
balance, the agings, and the general ledger extracts do not depend on each other. Never
serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* — every account's GL balance at period end — usually **[auto]**
- *`get_balance_sheet`* — the same balances as presented, including current / non-current split —
  usually **[auto]**
- *`search_accounts`* — the chart of accounts, to identify account types and find suspense /
  clearing accounts — usually **[auto]**
- *`get_general_ledger`* — transaction detail behind any account, and the raw material for every
  roll-forward — usually **[auto]**
- *`get_aged_receivables`* / *`get_customer_balance`* — the A/R supporting side — usually **[auto]**
- *`get_aged_payables`* / *`get_vendor_balance`* — the A/P supporting side — policies often differ
  from the receivables one
- *`search_journal_entries`* — manual entries, a frequent source of reconciling items — usually
  **[auto]**
- *`get_company_info`* — period-end and base currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that side of the reconciliation to **[manual]** and record the
  gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the workpaper's
format but **cannot support a signed reconciliation**. A reconciliation is a control; performing
it on fixture data records a control as operating when it did not.

## Step 1 — Identify the right reconciliation method per account type

Different balance sheet accounts reconcile to different sources. The verdict column below is the
**typical** case — confirm each against your Gate 2 capability map, since a connected payroll or
inventory platform changes several rows at once.

| GL Account | Reconcile to | Typical GL side | Typical support side |
|---|---|---|---|
| Cash / Bank | Bank statement (use `bank-reconciliation` skill) | **[auto]** | **[manual]** — the statement is outside the books |
| Accounts Receivable | A/R sub-ledger / open invoice listing | **[auto]** | **[auto]** — *`get_aged_receivables`*, *`search_invoices`* |
| Allowance for Doubtful Accounts | Allowance calculation (see `bad-debt-and-write-offs`) | **[auto]** | **[manual]** — the calculation is a schedule |
| Inventory | Inventory subledger / physical count (see `inventory-to-gl-reconciliation`) | **[auto]** | **[gated]** — *`search_items`* gives the master; counts and valuation usually **[manual]** |
| Prepaid Expenses | Prepaid amortization schedule (see `prepaid-amortization-schedule`) | **[auto]** | **[manual]** |
| Input Tax / VAT Receivable | Tax filing detail | **[auto]** | **[manual]** — *`search_tax_codes`* / *`search_tax_rates`* help identify, not evidence |
| Fixed Assets (gross) | Fixed Asset Register (see `fixed-asset-register-and-depreciation`) | **[auto]** | **[manual]** |
| Accumulated Depreciation | Fixed Asset Register depreciation summary | **[auto]** | **[manual]** |
| Intangible Assets | Intangibles register (see `intangibles-and-amortization`) | **[auto]** | **[manual]** |
| Right-of-Use Assets | Lease schedules (see `lease-accounting-asc842-ifrs16`) | **[auto]** | **[manual]** |
| Goodwill | Acquisition history + impairment tests | **[auto]** | **[manual]** |
| Accounts Payable | A/P sub-ledger / open bill listing | **[auto]** | **[auto]** — *`get_aged_payables`*, *`search_bills`* |
| Accrued Expenses | Accruals schedule (see `ap-accrual-cutoff`, `accruals-and-deferrals`) | **[auto]** | **[gated]** — booked entries **[auto]**, the calculations behind them **[manual]** |
| Customer Deposits / Deferred Revenue | Contract / customer schedule (see `revenue-recognition-asc606`) | **[auto]** | **[gated]** — receipts **[auto]**, the service periods **[manual]** |
| Sales Tax / VAT / GST Payable | Tax filing return + post-period activity | **[auto]** | **[manual]** for the return; post-period activity **[auto]** |
| Payroll Liabilities | Payroll register + remittances (see `payroll-clearing-reconciliation`) | **[auto]** | **[manual]** unless a payroll platform is connected |
| Income Tax Payable | Tax provision workpaper | **[auto]** | **[manual]** |
| Lease Liability | Lease schedule | **[auto]** | **[manual]** |
| Long-Term Debt | Loan amortization schedule + lender confirmation | **[auto]** | **[manual]** |
| Intercompany Accounts | Counterparty entity's mirror balance (see `intercompany-reconciliation`) | **[auto]** | **[auto] if the counterparty is a connected company file**, otherwise **[manual]** |
| Equity Accounts | Stock register / capital movements log | **[auto]** | **[manual]** |
| Suspense / Clearing | Should be zero or near-zero; investigate every line | **[auto]** | **[auto]** — *`get_general_ledger`*; fully supported, and the highest-value quick win here |

**If the user's account type isn't listed, ask what the supporting source is.** Do not guess a
source — a reconciliation to the wrong support is worse than none, because it looks complete.

## Step 2 — Pull the GL balance and the supporting balance

Capture:

- **GL balance** at period end (from the trial balance) — **[auto]**
  (*`get_trial_balance`*, *`get_balance_sheet`*)
- **Supporting balance** (sum of subledger detail, schedule total, external statement balance) —
  per the verdict in Step 1's table

**State each clearly with source and date.** In a Mosofin run that means: the tool name, the
parameters, the as-of timestamp, and the `mock` status for anything `[auto]`; the document name,
its date and who supplied it for anything `[manual]`. A balance without a source cannot be
reviewed.

## Step 3 — Identify reconciling items

The standard rec formula:

```
GL balance                                              $X
Plus/Less: reconciling items
  - Item 1 (e.g., timing differences, GL not yet in subledger, subledger not yet in GL)
  - Item 2
  - Item 3
Equals: Adjusted GL balance                             $Y

Supporting balance                                      $Z
Plus/Less: reconciling items on the subledger side (rare)
Equals: Adjusted supporting balance                     $W

Reconciled?  Y = W ?
  Yes  → tied
  No   → unreconciled difference of $(Y − W)
```

**Categorize each reconciling item by type:**

- **Timing** — legitimate timing differences that will clear next period (e.g. a bank deposit in
  transit, an invoice posted after the subledger cut). These are *expected* and need no
  correction, only monitoring
- **Permanent** — differences that should be corrected via a JE (e.g. a misposting). These need
  fixing
- **Investigating** — not yet identified; requires research. Honest and normal, provided it has
  an owner and a date

## Step 4 — Investigate unreconciled differences

For any difference — each of these is **[auto]** or **[gated]** where the GL side is readable:

- **Compare the prior-period rec — was the difference already there?** **[manual]** unless the
  prior rec was supplied; **[auto]** as a proxy by checking whether the same balance persisted
  (*`get_general_ledger`* across periods)
- **Cross-check posting cutoffs — did the GL and subledger close at the same time?** **[auto]**:
  look for transactions dated in the period but entered after it
- **Cross-check for misposted entries** (right account but wrong subledger / dimension) —
  **[auto]** (*`get_general_ledger`*, *`search_journal_entries`*, *`search_classes`*,
  *`search_departments`*)
- **Cross-check for FX revaluation differences** (the subledger may not have been revalued) —
  **[gated]**: multi-currency activity is visible, the revaluation policy is not
- **Cross-check rounding** (sum of many sub-items vs the GL total) — **[auto]**

**Document the investigation steps and results** — including the checks that found nothing. A
reconciliation that lists only what was found does not show what was looked for.

## Step 5 — Propose corrections

For **permanent** differences, propose a JE to clear (hand off to `journal-entry-builder`).
Examples:

- **Reclass between accounts** if posted incorrectly
- **Write off small immaterial residuals** to a cleanup account
- **Reverse and rebook** if a prior JE is wrong

For **timing** differences, **document but do not adjust** — they'll clear naturally. Adjusting a
timing difference creates a second error next period when the original clears.

For **investigating** items, log them with an **owner and target resolution date**. An
investigating item with no owner is an item nobody is investigating.

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**). **Mosofin proposes; a human posts.**

## Step 6 — Roll-forward (for activity-based accounts)

For accounts with significant activity (A/R, A/P, Inventory, Fixed Assets, Accruals), show a
roll-forward — **[auto]** wherever the GL side is readable (*`get_general_ledger`*):

```
Opening balance
+ Additions (purchases, billings, accruals booked)
- Reductions (payments, releases, write-offs)
+/- Other adjustments
= Closing balance
```

**The closing balance should tie to the GL. Movements should tie to the relevant activity**
(sales register, payment register, etc.) — **[auto]** for the comparison where the activity lives
in the connected books (*`search_invoices`*, *`search_payments`*, *`search_bills`*,
*`search_bill_payments`*), which makes this one of the strongest automated checks available.

## Step 7 — Materiality and aging

For each reconciling item:

- **Amount** — against the entity's materiality
- **Age** — how long has this item been open? **[auto]** where the item is a GL transaction:
  its posting date is readable

**Items aged > 3 months should escalate. Items above the materiality threshold require immediate
resolution.**

Age matters independently of size: a small item open for a year usually indicates that nobody
owns the account, which is a bigger problem than the amount.

## Step 8 — Output

Deliver an `.xlsx` workpaper, ideally **one tab per account** being reconciled.

**Standard tab structure per account:**

**Section 1: Header**
- Account number and name
- Period
- GL balance (and source)
- Supporting balance (and source)
- Difference
- Preparer / Reviewer
- Materiality threshold
- **Added:** entity `display_name`; the tool and timestamp behind each `[auto]` balance; the
  document and supplier behind each `[manual]` one; `mock` status

**Section 2: Reconciliation**

| Type | Description | Amount | Direction (Add / Less) |

Sub-totaled to the adjusted balance, ending in:

| Reconciled difference | $X | Status (Tied / Within tolerance / Investigating) |

**Section 3: Reconciling Items Detail**

| # | Description | Type (Timing / Permanent / Investigating) | Amount | Age | Owner | Target Resolution | Status |

**Section 4: Roll-Forward** (if activity-based)

Opening + activity = closing.

**Section 5: Proposed JEs**

Pass-through to `journal-entry-builder` for any permanent corrections, marked as **proposals**.

**Section 6: Prior Period Carry-Forward Check**

| Item from Prior Rec | Status This Period | If Still Open: New Target Date |

**Section 7: Coverage — NEW, Mosofin-specific**

| Account | Entity (`display_name`) | GL side (auto / gated / manual) | Support side (auto / gated / manual) | Tool used per side | Policy | `mock` | Gap — what could not be evidenced and who owns it |

**The two-sided verdict is the point.** An account with an `[auto]` GL side and a `[manual]`
support side that was never supplied is **not reconciled**, and this sheet is what makes that
visible.

Optionally, a **master workbook** listing all account reconciliations with:

- Account, GL balance, status (tied / within tolerance / unreconciled), materiality breach Y/N
- **Added:** support-side coverage, so the controller can see at a glance how much of the balance
  sheet is genuinely evidenced

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `BS_Recs_[YYYY-MM]_[EntityName].xlsx`

In a multi-entity run, `[EntityName]` is the company file's `display_name`, one per entity plus a
combined view. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This skill runs every month, so the evolution step pays for itself faster here than almost
anywhere.

On an explicit yes, persist the **decisions**:

- **The account-to-source map** — for every balance sheet account in this entity's chart: what it
  reconciles to, where that support lives, and who owns it. This is the single highest-value
  artefact, and it is exactly what makes month two faster than month one
- **The materiality threshold** and the escalation ages
- **Preparer and reviewer** per account, or per account group
- **Known recurring timing items** and the window in which each normally clears — so a familiar
  deposit-in-transit is recognised rather than re-investigated every month
- The cleanup / suspense account to use for immaterial residuals, and the limit above which
  nothing may be written off
- Accounts that must always be zero, so a non-zero balance is escalated immediately
- The replay recipe: the exact sequence of reads that produced this period's workpaper

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Do not persist balances, reconciling item detail, or the workpaper itself.** Those are the
period's evidence and belong in the close file, which is a controlled record. Persist the *map,
the thresholds, and the owners*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Prepaid Expenses reconciles to the prepaid schedule held by the financial
controller; materiality $500" — not "Prepaid reconciles to the schedule". Different entities keep
different schedules in different places, and an unlabelled map sends someone to the wrong file.
Record the chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to
the workspace and are re-discovered by Gates 1–2 every run — which matters here, because a tool
that was enabled last month may be disabled this month, flipping an account from `[auto]` to
`[manual]` without warning. **Decisions are the user's; state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One workpaper, one master
summary.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every account and reconciling item carrying that entity's `display_name`. Then
one cross-entity step:

- **The intercompany mirror check**, which is the genuine cross-entity reconciliation and the one
  worth doing deliberately: entity A's receivable from entity B against entity B's payable to
  entity A. Where both are connected company files, **both sides are `[auto]`** — pull each
  entity's balance separately, compare, and report the mismatch. See
  `intercompany-reconciliation`.
- **A group master summary** showing, per entity, how many accounts tied, how many are
  unreconciled, and **how much of the balance sheet has an evidenced supporting side**. The last
  column is the one that reveals a weak component.
- **Never merge two entities' subledger detail** into one reconciliation. Reconcile per entity,
  then compare.

Capability is checked **per entity** at Gate 2: the same account can be `[auto]` on both sides at
one company file and `[manual]` on support at another.

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
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| GL balance per account at period end | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Balances as presented (current / non-current) | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Transaction detail behind a balance; roll-forwards | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Chart of accounts; find suspense / clearing accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| A/R supporting side | `get_aged_receivables` / `get_customer_balance` | `report_date`, `customer`, `aging_method`, `num_periods` |
| A/P supporting side | `get_aged_payables` / `get_vendor_balance` | `report_date`, `vendor`, `aging_method`, `num_periods` |
| A/R activity for the roll-forward | `search_invoices` / `search_payments` / `search_credit_memos` | `start_date`, `end_date` (required), `customer_id` |
| A/P activity for the roll-forward | `search_bills` / `search_bill_payments` / `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Manual entries (a frequent reconciling item) | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Deferred revenue receipts | `search_deposits` / `search_sales_receipts` | `start_date`, `end_date` (required) |
| Movements between own accounts | `search_transfers` | `start_date`, `end_date` (required) |
| Inventory item master | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| Dimensions, for misposting checks | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Tax codes and rates | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Attachment metadata (a schedule exists) | `search_attachables` / `get_attachable` | `query`/`name`; `id` |
| Period-end and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **General ledger (GL)** — the complete record of every transaction, summarised into accounts.
- **Subledger** — the detailed list behind one GL account (e.g. every unpaid invoice behind the
  A/R balance).
- **Control account** — the GL account a subledger must agree with.
- **Reconciliation** — proving the GL balance and its supporting detail agree, and explaining
  every difference.
- **Tie-out** — the proof that two numbers agree.
- **Reconciling item** — a legitimate reason the two sides differ.
- **Timing difference** — a difference that will clear by itself next period.
- **Permanent difference** — a difference caused by an error; it needs correcting.
- **Deposit in transit** — money banked but not yet showing on the statement.
- **Cutoff** — the point at which a period stops accepting transactions.
- **Misposting** — a transaction recorded in the wrong account or dimension.
- **Dimension** — an extra coding tag on a transaction (department, class, project).
- **FX revaluation** — restating foreign-currency balances at the period-end exchange rate.
- **Roll-forward** — opening balance, movements, closing balance.
- **Suspense / clearing account** — a temporary holding account; it should return to zero.
- **Reclass** — moving a balance from one account to another without changing the total.
- **Plug** — an unexplained figure inserted to force a total to agree. **Never acceptable.**
- **Right-of-use asset** — the asset recorded when you lease something.
- **Prior-period adjustment** — a correction to a period already reported.
- **Materiality** — the size above which a difference matters to a reader of the accounts.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Subledger that doesn't tie to its own control** (a system bug or data issue): flag it and
require system reconciliation. **The GL / subledger rec is meaningless if the subledger is
internally inconsistent.**

**GL balance is correct but presented in two accounts** (e.g. a classification error between
current and non-current portions): reclass via JE. The total is right, the presentation is not.

**Account that should always be zero** (e.g. Suspense, Clearing): any non-zero balance requires
immediate investigation. **Don't roll forward an open clearing balance.** *Mosofin note*: this
account is fully `[auto]` — both sides come from the GL — so it is the fastest genuine win in
the whole workpaper. Run it first.

**Multi-currency accounts**: reconcile in the functional currency for the GL, but **also
reconcile in the original currency** where applicable (e.g. a foreign-currency bank account). FX
revaluation may explain differences.

**Intercompany account that's not netting to zero against the counterparty's mirror balance**:
that is an intercompany mismatch, handed to `intercompany-reconciliation`. *Mosofin note*: if
both entities are connected company files, **pull both sides and quantify the mismatch here**
rather than only flagging it.

**Account with timing-related items at every period end** (e.g. deposits in transit always
present): build the pattern into the standard procedure; **verify each period that they clear
within the expected window.** An item that stops clearing has stopped being a timing difference.

**Large or unusual roll-forward items**: investigate. **A 10× spike in monthly accruals deserves
an explanation, not just a roll-forward.** *Mosofin note*: comparing several periods of movement
is `[auto]`, so this check should always be performed rather than skipped.

**No prior period rec available**: do the current period as fully as possible; document the lack
of carry-forward and recommend establishing the prior-period baseline.

**Adjustments to the opening balance**: typically prior-period adjustments — flag for
`restatement-and-prior-period-adjustment`.

**Account that's been merged or split mid-period**: rebuild the reconciliation respecting the
merge or split, with a memo explaining. *Mosofin note*: a renamed or merged account may return a
different identifier than last period; match on the account's own history, not a remembered id.

**Account where the supporting source itself is unaudited / informal** (e.g. a
manually-maintained accrual schedule): document the source and its limitations. Recommend
systematizing.

**Tolerance threshold not provided**: **ask the user.** Suggest a reasonable basis — for example
the entity's overall financial-reporting materiality divided across the number of accounts — **but
do not silently assume.**

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
which accounts are therefore unreconciled. Surface any `reconnect_url`.

**Both sides came from the same source** — *Mosofin-specific, and the subtlest failure here*. If
the "supporting balance" is just another view of the same GL, the account has not been
reconciled. Mark the support side `[manual]` and say what independent evidence is needed.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
workpaper format but cannot support a signed reconciliation, because the reconciliation is itself
a control.

**A tool flipped from enabled to disabled since last period** — *Mosofin-specific*. An account
that reconciled automatically last month may need a manual schedule this month. Re-discover at
Gate 2 every run and tell the user what changed.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag
it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every account has its GL balance, supporting balance, and difference clearly shown
- Every reconciling item categorized by type (Timing / Permanent / Investigating)
- Every item has an age, an owner, and a target resolution date
- Roll-forward ties: opening + activity = closing
- Proposed JEs hand off to `journal-entry-builder`
- Prior period items carried forward and their status updated
- Materiality threshold applied explicitly
- File naming consistent
- **No silent absorption of differences into a "Plug" line**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **Every account carries a two-sided verdict** — GL side and support side, each with its tool
  and policy, in the coverage sheet
- **An account whose supporting side was never supplied is reported as not reconciled**, never as
  tied
- **No account is reconciled to another view of itself**; where that is all that is available, it
  is said plainly
- Every balance states its source: tool, parameters and timestamp for `[auto]`; document, date
  and supplier for `[manual]`
- Investigation steps are documented including the checks that found nothing
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no reconciliation is signed off on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No balances, reconciling-item detail, or workpapers are persisted into a skill bundle; every
  persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every correction is a proposal for a human to post
