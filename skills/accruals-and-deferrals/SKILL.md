---
name: accruals-and-deferrals
description: "Use this skill whenever the user wants to book period-end accruals or deferrals from their Mosofin workspace, beyond AP-specific accruals. Triggers include: 'book accruals for the period', 'accrue bonuses', 'accrue interest', 'defer revenue', 'defer the prepayment', 'accrued payroll', 'commission accrual', 'utility accrual', 'period-end adjustments', or any task where revenue or expense recognition timing requires an entry independent of an invoice or payment. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then computes each accrual from live ledger evidence plus whatever the user supplies. Do NOT use for AP-specific GRNI accruals — use ap-accrual-cutoff. Do NOT use for full close — use month-end-close-checklist. Outputs an accrual / deferral schedule with reasoning, the proposed JEs, the reversing entries, and a coverage sheet showing what was pulled automatically versus supplied by hand."
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
# Accruals and Deferrals (Mosofin)

Identifies and books period-end **accruals** (expenses incurred but not invoiced, revenue
earned but not invoiced) and **deferrals** (revenue received but not earned, expenses paid
but not consumed), so the financials line up with the **accrual basis of accounting**.

**In plain words:** your books should show costs and income in the month they actually
*happened*, not the month the paperwork or the money showed up. An **accrual** records
something that already happened but hasn't been billed yet — you used electricity in March,
the bill comes in April, but March should carry the cost. A **deferral** does the opposite —
a customer paid you in January for a whole year of service, so you can't call it all January
income; you spread it out. This skill finds those items, works out the amounts, and writes
the entries for a human to post.

This skill covers categories beyond AP-specific cutoff (which is handled by
`ap-accrual-cutoff`). Examples: bonus accruals, commission accruals, interest accruals,
vacation accruals, utility / service period-end accruals, revenue accruals, and deferrals.

This skill remains **chart-of-accounts-agnostic** and **jurisdiction-agnostic** — it uses
whatever account structure and rules the workspace and the user present.

It is **not** system-agnostic. It is **workspace-scoped**: every balance, transaction, and
account name comes from a tool call against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled
as such.

**Mosofin is read-only.** Nothing here posts a journal entry. Every entry below is a
*proposal* — a human reviews it and posts it in the accounting system.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before computing any accrual. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** —
`list_workspaces`, `get_agent_datasources`, `get_datasource_tools`,
`invoke_datasource_api_tool`, `get_skills`, `get_my_skill`, `create_skill`. Do not add a
`mosofin_` prefix and do not hardcode a client-side `mcp__…` namespace; that string is
composed by whichever MCP client is running and differs between clients.

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

- **One workspace** → the tool auto-confirms it. Read the workspace **name** back to the
  user and **wait for an explicit yes** before reading any data.
- **Two or more** (`selection_required`) → ask **in chat**: "Is this a single-workspace or
  a multi-workspace job?" Then ask which workspace(s) **by name**, and call
  `list_workspaces` again with `workspace_ids=[…]` and `mode="single"` or `mode="multi"`.

Never auto-pick a workspace. Never print an internal numeric tenant id — refer to a
workspace by its human name, and pass the opaque `ws_…` handle between tools.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- Rows with `connected: true` are **in scope**.
- Rows with `connected: false` are **excluded — and you must name them as excluded**
  ("*Northwood Demo Books* is present but not active, so no accrual below draws on it").
  A dead connection that goes unmentioned makes the accrual schedule look complete when it
  is not. If the envelope offers a `reconnect_url`, surface it.

A workspace can connect the **same platform several times** — several company files, plus
payment or payroll platforms. Each is its own row with its own `data_source_id` and
`display_name`.

When more than one entity is live, ask the user which scenario applies:

- **Single-entity** — ask which company by `display_name`. The whole workflow runs against
  that one `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and a combination step follows (see "Both entity
  scenarios"). Every accrual, balance, and roll-forward is **labelled with its datasource
  and `display_name`**. Two entities' accrued liabilities are never added into one figure
  without that label.

Refer to companies by `display_name`. Never show the raw `data_source_id` — pass it between
tools.

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

For **each in-scope datasource** (and, when several company files are live, **per company
file** — pass `data_source_id`), call `get_datasource_tools`. Bucket every returned tool by
its `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Then resolve **every task in Part B** against these buckets. That resolved list is the
**capability map**. It is built this run, held for this run, written out as the coverage
sheet — and **never** written into this file. Policies differ per workspace *and* per
company file, and change between periods.

Two rules that bite this skill in particular:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated. Take the exact string from the Gate 2 listing.
- **A near-substitute is not a substitute.** If the detailed transaction-level ledger tool
  is disabled, a summary balance report is *not* a stand-in: a balance tells you the accrued
  liability account's total, not which items make it up, and a roll-forward you cannot
  itemise is not a roll-forward. Mark the task `[manual]` and say so.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** everything the profile answers, and do not ask about it:

- **Functional currency** — the base currency the books are kept in. Only ask about currency
  if the transactions show more than one.
- **Fiscal calendar and year-end** — which tells you where the period sits in the year, and
  therefore the year-to-date fraction used in a bonus accrual.
- Country / region and time zone.
- Industry, which hints at which accrual categories are likely to matter.

**Ask the user** only what changes the work. This is where the original Inputs table lives,
minus what the profile already answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being closed** — exact start and end dates | **Required** | Never default the period. |
| **Categories of accruals / deferrals in scope** — compensation, interest, utilities, revenue, etc. | **Required** | Offer the Step 1 / Step 2 category lists as a checklist rather than an open question. |
| **Supporting data per category** — bonus pool, interest rate, contract terms, time sheets | **Required per category** | Much of this is **[manual]**; ask only for what the connected books cannot show. Say which is which. |
| **Chart of accounts** — the accounts to post to | **Required — usually [auto]** | Normally pulled from the connected books; ask the user to confirm the specific accrued-liability, accrued-revenue and deferred-revenue accounts, since naming varies. |
| **Materiality threshold** — the dollar size below which an item isn't worth accruing | Recommended | Ask; do not invent a figure. If declined, accrue everything found and say so. |
| **Reporting framework** — US GAAP / IFRS / other | Recommended | Affects presentation and some measurement. |
| **Tax jurisdiction** | Recommended | For tax recoverability and employer-side payroll tax on compensation accruals. |
| **Functional currency** | Recommended — usually derived | Ask only to confirm a profile contradiction, or if several currencies appear. |
| **Reversal policy** | **Required** | Do accruals reverse automatically on day one of the next period, or does the incoming invoice post straight against the accrual account? Both are valid; the answer changes Step 5. |
| **Confirm scope** | **Required** | Read back which company files are in scope and which are excluded, by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's year-end does not match the period the user named. |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

Ask these as **one short batch**. Propose sensible defaults where reasonable — but **never**
default the period, the accounting method, or the entity.

**On later runs**, read the stored preferences first (see Step 9), confirm them in one line,
and ask only what is new, changed, or contradicted. The interview shrinks. The gates never do.

---

# PART B — The domain work

Everything below is the professional procedure, unchanged in step count, order, or
substance. What has been added is the plain-language wording, the `[auto]` / `[gated]` /
`[manual]` verdict per task, and the tool that typically evidences it.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence. Many accruals here are inherently manual — a bonus pool lives in a
compensation committee's decision, not in the ledger — and saying so is the honest answer.

Tool names in *italics* are the **typical** evidence tool. Resolve the real name and its
policy from your Gate 2 catalog — the italic name is a pointer, not a promise.

## Step 0 — Fetch the evidence (grounding)

Before Step 1, pull the reads the capability map marked `[auto]` or `[gated]`. **Batch
independent reads into one message** — the chart of accounts, the trial balance, the prior
period's journal entries, and a vendor spend report do not depend on each other. Never
serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — the chart of accounts, to locate the accrued-liability,
  accrued-revenue and deferred-revenue accounts — usually **[auto]**
- *`get_trial_balance`* — every account's balance at period end, the starting point for each
  roll-forward — usually **[auto]**
- *`get_balance_sheet`* — accrued liabilities and deferred revenue as presented — usually
  **[auto]**
- *`get_general_ledger`* — the transaction-level detail behind those balances — usually
  **[auto]**
- *`search_journal_entries`* — last period's accruals and their reversals — usually **[auto]**
- *`get_profit_and_loss`* — expense run-rates used to sanity-check estimates — usually
  **[auto]**
- *`get_company_info`* — fiscal calendar and base currency — usually **[auto]**

Handle the envelopes you get back:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true`.
- `entity_required` → more than one company file is live and you passed none. Ask by
  `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error itself; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag** on every result. `mock: true` is fixture data — it can show the
shape of a schedule but **cannot support a booked entry**. If any proposed accrual rests on
mock data, say so at the top and do not present the entry as ready to post.

## Step 1 — Identify accrual categories

Work out what already happened in the period that the books haven't caught yet.

Common accruals:

**Compensation-related** — **[manual]** for the amounts (pay rates, bonus plans and accrual
policies generally live in payroll or HR systems, not the ledger), **[auto]** for the
population and for what has already been booked (*`search_employees`*,
*`get_general_ledger`* on the payroll accounts):

- **Bonus accrual** — annual bonuses earned through period-end but not yet paid
- **Commission accrual** — sales commissions earned but not yet paid
- **Vacation / PTO accrual** — vacation ("paid time off") employees have earned but not used;
  you owe it whether or not they take it
- **Severance / restructuring accrual**
- **Payroll accrual for partial pay periods crossing the cutoff** — the days worked before
  period-end in a pay period that pays out after it

**Interest-related** — **[auto]** for the loan balance carried on the balance sheet and for
interest already posted (*`get_balance_sheet`*, *`get_general_ledger`*, *`search_accounts`*);
**[manual]** for the rate, the day-count convention and the last payment date, which come
from the loan agreement:

- Interest accrued on loans where the entity is the **borrower**
- Interest accrued on loans / investments where the entity is the **lender**
- Interest on overdue A/R or A/P, if applicable

**Service / utility** — **[auto]**: the last invoice and the historical run-rate are in the
books (*`search_bills`*, *`get_vendor_expenses`*, *`get_general_ledger`*):

- **Utilities** (electricity, gas, water) — service received through period-end, bill arrives
  later
- **Internet / telecom** — same pattern
- **Cleaning, security, maintenance** — typically billed monthly **in arrears** (after the
  service, not before)

**Revenue accruals** (earned but not invoiced) — **[auto]** where the work is tracked in the
connected books (*`search_time_activities`* for unbilled hours, *`search_estimates`* for
contracted work, *`search_invoices`* to see what has already been billed), **[gated]** where
the earned fraction is a judgment:

- Service performed but invoice not yet issued
- Subscription services consumed but billed in arrears
- Royalty income earned but not received
- Interest income from investments

**Other** — **[gated/manual]**: the population is visible (*`get_vendor_expenses`*,
*`search_bills`*), the estimate of unbilled work is not:

- **Audit fees** — services rendered through period-end, invoice may arrive after close
- **Legal fees** — services rendered, invoice may not arrive
- **Professional fees** in general
- **Tax accruals** — income tax, property tax accrued

## Step 2 — Identify deferral categories

Now the mirror image: money already in hand that you haven't earned yet.

Common deferrals:

**Deferred revenue (a liability — you owe the customer service, not money)** — **[auto]** for
the balance and the underlying receipts (*`get_balance_sheet`*, *`search_accounts`*,
*`search_payments`*, *`search_deposits`*, *`search_sales_receipts`*), **[manual/gated]** for
the service period each receipt covers, which comes from the contract:

- Customer payments received **in advance** of service delivery
- Annual subscription paid upfront, recognised over the year
- Pre-paid **retainers** from customers (money held against future work)
- **Gift cards** sold and not yet redeemed — and not yet **escheated** (handed to the state
  as unclaimed property)
- **Loyalty points liability** — points customers have earned and can still spend

**Deferred expense (an asset)** — these are **prepaid expenses** (you paid ahead for
something you'll consume later); handled by `prepaid-amortization-schedule`. Mentioned here
for completeness so the category isn't lost.

## Step 3 — Compute each accrual / deferral

For each item, use the relevant basis. The arithmetic is **[auto]** once the inputs exist;
the verdict below is about where the *inputs* come from.

**Bonus accrual** — **[manual]** inputs:
- Annual target bonus pool × the year-to-date portion of the year ÷ 12 (or per the bonus
  plan's own structure)
- Apply the **payout probability** if the plan is performance-based — management's best
  estimate of how likely the bonus is to be paid
- Apply **employer-side payroll taxes** that will be paid along with the bonus

**Commission accrual** — **[gated]**: closed deals through period-end are visible in the
books (*`search_invoices`*, *`get_customer_sales`*), the plan's terms are not:
- Commissions earned per the commission plan on deals closed through period-end
- Track whether commissions are payable on **booking** (deal signed), **billing** (invoice
  issued), or **collection** (cash received) — the plan decides, and it changes the amount

**Vacation / PTO accrual** — **[manual]**:
- For each employee: earned vacation days × daily pay rate
- Some entities have payroll software compute this automatically; others track it separately
- The liability typically also includes the payroll taxes due when the vacation is paid out

**Interest accrual** — **[gated]**: balance **[auto]**, terms **[manual]**:
- For loans with monthly interest payments, accrue interest from the last payment date to
  period end:
  - `Interest = Principal × Annual Rate × (Days since last interest period ÷ Days in year)`
  - Use the **day-count convention** specified in the loan — the agreed rule for counting
    days, e.g. actual/365, actual/360, or 30/360 (which pretends every month has 30 days).
    Different conventions give different answers on the same loan.
- For loans with periodic **compounding** (interest charged on unpaid interest), compute per
  the compounding schedule

**Utility / service accrual** — **[auto]**: all three bases can be derived from the connected
books:
- Estimate the period-end portion using either:
  - The last invoice's daily rate × days through period-end, less days already invoiced
  - The contracted monthly amount × the proportion of days
  - The prior year's same period — less reliable, but used when there is no other data

**Revenue accrual (services performed)** — **[auto/gated]**:
- **Time-and-materials** engagements (billed by hours worked): unbilled hours × rate —
  *`search_time_activities`* gives the hours where time is tracked in the connected books
- **Milestone** projects: progress earned through period-end × contract value (per
  `revenue-recognition-asc606`)
- **Subscription** services billed in arrears: pro-rated revenue

**Audit / legal / professional fee accrual** — **[manual]**:
- Estimate based on engagement letters and work done
- For ongoing matters, ask the provider how much work has been done

## Step 4 — Construct the JEs (hand off to journal-entry-builder)

A **journal entry (JE)** is the two-sided record that moves the numbers. `DR` is a debit and
`CR` a credit; every entry balances. `BS` means the balance sheet. **Mosofin does not post
these** — it drafts them for a human.

**Accrual (expense)**:
```
DR  Expense account                                  $accrual amount
    CR  Accrued Liabilities (BS, per user's COA)        $accrual amount
Memo: Accrue [category] for [period]
```

Reverses on the first day of the next period.

**Accrual (revenue)**:
```
DR  Accrued Revenue / Unbilled Receivables           $accrual amount
    CR  Revenue                                          $accrual amount
Memo: Accrued revenue for [service/period]
```

Reverses on the first day of the next period (or the entry is cleared when the invoice is
issued). *Unbilled receivables* = work you've done and can bill for, but haven't yet.

**Deferral (revenue)**:
```
At receipt:
DR  Cash / AR                                        $gross
    CR  Deferred Revenue (BS, per user's COA)           $net (excl. tax)
    CR  Output Tax Payable (if applicable)               $tax

Each period as earned:
DR  Deferred Revenue                                 $period revenue
    CR  Revenue                                          $period revenue
Memo: Recognize earned portion — [contract] — [period]
```

*Output tax* is sales tax / VAT / GST you collected on the customer's behalf — it was never
your revenue, so it is split out at receipt.

This is typically built as a schedule (similar to prepaid amortisation but on the revenue
side). For ASC 606 / IFRS 15 compliance, use `revenue-recognition-asc606`.

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which account you chose.

## Step 5 — Reversing entries

Most accruals **reverse** on the first day of the next period — the entry is undone so that
when the real invoice arrives it can post normally without double-counting.

When the actual invoice / payment arrives in the new period, it posts cleanly to the expense
or revenue account, cancelling against the reversal.

For accruals where the actual invoice / payment will hit the accrual account **directly**
(without first reversing), no reversal is needed. **State the policy** — this is the reversal
policy confirmed at Gate 3.

Hand off the full set of reversing entries to `journal-entry-builder`, dated the first day of
the new period. **[auto]** to check whether last period's reversals actually posted
(*`search_journal_entries`* on the first days of the current period) — an accrual that was
never reversed is the most common cause of the compounding problem flagged in Step 6.

## Step 6 — Roll-forward by category

A **roll-forward** shows how a balance got from where it started to where it ended. It is
the proof that nothing is stuck.

For each accrual category — **[auto]** where the accrual account is identifiable in the
ledger (*`get_general_ledger`*, *`get_trial_balance`*, *`search_journal_entries`*):

```
Opening accrual balance
+ Current period accrual booked
- Reversal of prior period accrual
- Settlement of accrual (e.g., bonus paid)
+/- Adjustments / true-ups
= Closing balance
```

A **true-up** is the correction you make when the real amount turns out different from what
you estimated.

The closing balance should equal the current period accrual, assuming reversals and
settlements cleared the prior balance.

**If the closing balance grows beyond just the current period's accrual, investigate —
accruals shouldn't compound.** A balance that keeps climbing usually means a reversal never
posted, or an accrual is being booked twice.

## Step 7 — Materiality

**Materiality** is the size below which a difference isn't worth chasing. Apply the threshold
from Gate 3. Items below it can be skipped (or accrued at zero). **Track the cumulative
total of the immaterial items** — individually small, collectively they can still matter, and
the total is what an auditor asks for.

If the user declined to set a threshold, say so and apply none, rather than picking one.

## Step 8 — Output

Deliver an `.xlsx` workpaper. If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Sheet 1: Summary**

| Category | Period Accrual | Reversal of Prior | Net Period Impact | Closing Balance |

Add a header block: workspace name; each in-scope company file by `display_name`; each
excluded company file and why; whether any figure rests on `mock` data.

**Sheet 2: Category Detail**

For each category:
- Computation methodology
- Inputs and supporting data — **and where each input came from**: a named tool, or the user
- Result
- JE entry

**Sheet 3: Period JEs**

All accrual / deferral entries for the period, marked clearly as **proposals**.

**Sheet 4: Reversal Entries**

All reversing entries for the next period.

**Sheet 5: Deferred Revenue Roll-Forward**

Specifically for deferred revenue, which often has a structured schedule.

**Sheet 6: Roll-Forward by Category**

**Sheet 7: Materiality / Excluded Items**

List of items below threshold not accrued, with the cumulative total.

**Sheet 8: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus estimated. One row per accrual and deferral
item in Steps 1–7:

| Item | Category | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: a tool enabled for one company file may
be disabled for its sibling, so the same accrual can be `[auto]` for one and `[manual]` for
another.

**File naming:** `Accruals_Deferrals_[YYYY-MM].xlsx`

In a multi-entity run: `Accruals_Deferrals_[YYYY-MM]_[EntityDisplayName].xlsx`, plus one
combined file named for the set. Every file states, on its summary sheet, exactly which
datasource and which `display_name` it covers.

**Grounding:** every figure must trace to a tool result in this conversation or to labelled
user-supplied evidence. Do not tag individual figures with citations; end the answer with a
single **Data sources** line grouping the calls by datasource. Where the data does not cover
something, **name the tool that would have covered it** instead of estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** The first run discovered the workspace and interviewed
you. That does not need to happen again.

After the user has **seen the results** and approved them, ask — explicitly, at that point,
not earlier — whether to save this as their own customized version. A general "yes, go ahead"
from the start of the conversation does not count.

On an explicit yes, persist the **decisions**:

- The Gate 3 answers: accrual and deferral categories in scope, materiality threshold,
  reporting framework, tax jurisdiction, reversal policy
- The account mapping: which specific accrued-liability, accrued-revenue, deferred-revenue
  and expense accounts each category posts to, by their real names in the chart of accounts
- The computation basis chosen per category (e.g. "utilities: last invoice's daily rate";
  "bonus: 1/12 of pool per month at 80% probability"), including the day-count convention
  used for interest
- Recurring items that accrue every period, so they are proposed automatically next time
- Standing exclusions and why
- The replay recipe: the exact sequence of reads that produced this period's schedule

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
and asset files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files.
Or write them as preference files alongside the installed skill, per the user's setup.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — materiality $500, bonus accrual 1/12 of $240k pool, reverses day 1" —
not "materiality $500". One location's bonus plan is not another's, and an unlabelled
preference is ambiguous the moment a second company file connects. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace, not to the user's decisions. They change between runs and are re-discovered
by Gates 1–2 every time. **Decisions are the user's; state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged to the user** — never silently dropped, never applied
to a different entity.

---

## Both entity scenarios

**Single-entity.** The workflow above, exactly as written, against one `data_source_id`. One
schedule, one set of JEs, one workpaper.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every accrual and roll-forward carrying that entity's `display_name`. Then
one cross-entity step:

- **A roll-up** — accruals aggregate cleanly across entities in a way that information
  returns do not, so a combined accrued-liabilities figure is meaningful. But it is only
  meaningful if each contributing entity is shown on its own line first.
- Watch for the accrual that belongs to **one** entity but was estimated from **another's**
  run-rate — label it, and do not let a shared-service cost get accrued twice.
- Where entities transact with each other, an accrual in one may be a deferral in the other;
  flag the pair rather than netting them silently (see `intercompany-reconciliation`).

Capability is checked **per entity** at Gate 2, and the coverage sheet shows each item's
verdict per company file.

---

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays them as:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on the discovery call; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists a datasource's read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several company files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools for this skill — **resolve the real names and policies from your Gate 2
catalog**; names and policies vary by workspace:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Chart of accounts (find the accrual accounts) | `search_accounts` | `query`/`name`, `active_only`, `max_results` |
| One account's detail | `get_account` | `id` |
| Every balance at period end | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Accrued liabilities / deferred revenue as presented | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Transaction detail behind a balance (roll-forward) | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Prior accruals and their reversals | `search_journal_entries` | `start_date`, `end_date` (required), `max_results` |
| Expense run-rate for estimates | `get_profit_and_loss` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Utility / service billing history | `search_bills` / `get_vendor_expenses` | `start_date`, `end_date` (required); `vendor`, `accounting_method` |
| What has already been billed to customers | `search_invoices` | `start_date`, `end_date` (required), `customer_id` |
| Unbilled hours for revenue accrual | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Contracted but unbilled work | `search_estimates` | `start_date`, `end_date` (required), `customer_id` |
| Customer money received in advance | `search_payments` / `search_deposits` / `search_sales_receipts` | `start_date`, `end_date` (required) |
| Sales by customer (commission basis) | `get_customer_sales` | `start_date`, `end_date`, `customer` |
| Employee population | `search_employees` | `query`/`name`, `active_only` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accrual basis of accounting** — record income and costs when they happen, not when cash
  moves. **Cash basis** is the opposite.
- **Accrual** — an entry for something that has happened but hasn't been billed or paid yet.
- **Deferral** — an entry that pushes income or cost *forward*, because the money moved before
  the thing was earned or used.
- **GRNI** — "goods received, not invoiced": stock or supplies you've received but haven't
  been billed for. Handled by `ap-accrual-cutoff`.
- **PTO** — paid time off; holiday and leave employees have earned.
- **Deferred revenue** — money customers paid you for work you still owe them. A liability.
- **Unbilled receivables / accrued revenue** — work you've done and could bill for, but
  haven't.
- **Escheat** — handing unclaimed money (e.g. a never-redeemed gift card) to the state.
- **In arrears** — billed after the service, rather than before.
- **Day-count convention** — the agreed rule for counting days in an interest calculation
  (actual/365, actual/360, 30/360). The same loan gives different interest under each.
- **Compounding** — charging interest on unpaid interest.
- **True-up** — correcting an estimate once the real number is known.
- **Clawback** — a contract term letting the company take back money already paid, if
  conditions fail.
- **Vesting** — the point at which someone's entitlement to a payment or share becomes
  unconditional.
- **Materiality threshold** — the size below which a difference isn't worth chasing.
- **Functional currency** — the main currency the entity's books are kept in.
- **Chart of accounts (COA)** — the list of every account the books use.
- **Journal entry (JE)** — the balanced two-sided record that moves numbers between accounts.
  **DR** = debit, **CR** = credit, **BS** = balance sheet.
- **Reversing entry** — an entry that undoes an accrual at the start of the next period.
- **Roll-forward** — a table showing how a balance moved from opening to closing.
- **Restatement** — formally correcting a prior period's published figures.
- **Current vs non-current** — due within twelve months, versus later.
- **Output tax** — sales tax / VAT / GST collected from a customer on the authority's behalf;
  never your revenue.
- **OPEB** — other post-employment benefits, e.g. retiree healthcare.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Bonus accrual where payout is uncertain**: use management's best estimate of the probable
payout. Adjust as the year progresses. This is a judgment the ledger cannot supply — record
it as **[manual]** with the estimate's owner named.

**Vacation accrual policy variations**: some entities use "use it or lose it" (lower accrual);
others allow carry-forward. The vacation liability reflects the actual unused balance × pay
rate — so the policy has to be confirmed before the number means anything.

**Multi-currency accruals**: accrue in the functional currency at the period-end FX rate. The
reversal uses the same rate, or the current rate, per policy — see
`multicurrency-fx-revaluation`. If the connected books hold only one currency but the
underlying obligation is in another, that conversion is **[manual]**; say so.

**Bonus / commission with deferral or clawback features**: only the **vested** portion is a
current accrual; deferred portions accrue gradually as conditions are met. Clawback
contingencies are disclosed but typically do not reduce the accrual unless the clawback is
probable.

**Interest accrual on variable-rate debt**: use the rate in effect for the accrual period; if
the rate changed mid-period, weight it by days. The rate history is **[manual]** — the ledger
shows what was paid, not what the rate was.

**Tax on accruals**: payroll-related accruals (bonus, commission, vacation) typically include
the employer-side payroll tax accrual. Add a separate line to the JE rather than burying it
in the gross figure.

**Catch-up / true-up of prior period accruals**: when the actual amount comes in differently
from what was accrued, true it up in the current period. If the variance is material and
relates to a prior period, consider whether a **restatement** is needed — see
`restatement-and-prior-period-adjustment`.

**Reclass of deferred revenue between current and non-current**: at each period end, the
portion expected to be earned within twelve months is current; beyond that is non-current.

**Accruals that may turn out not to be owed**: e.g. an expected vendor service that never
happens. Reverse it without an expense — do not leave it sitting on the balance sheet.

**Stock-based comp expense**: accrued via the entity's vesting schedule — separate from this
skill; see `equity-compensation-accounting`.

**Pension / OPEB accruals**: actuarially determined. This skill summarises the result but does
not compute the actuarial liability.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say which accruals are therefore unsupported. Surface any `reconnect_url`. Do not present a
schedule that looks complete.

**The transaction-level ledger tool is `disabled` in this workspace** — *Mosofin-specific*.
Do not substitute a summary balance: it gives the accrual account's total but not the items
inside it, and a roll-forward you cannot itemise is not a roll-forward. Mark those tasks
`[manual]`, name the tool, and ask for a ledger export.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate
the schedule's shape but cannot support a posted entry. Flag it at the top of the deliverable.

**The books are kept on a cash basis** — *Mosofin-specific and common in small workspaces*.
Accruals and deferrals are precisely the entries a cash-basis ledger does not carry, so the
opening balances may legitimately be zero. Say that explicitly rather than reporting "no
accruals found", and confirm with the user whether they are converting to accrual basis.

**The accrued-liability account cannot be identified in the chart of accounts** —
*Mosofin-specific*. Do not guess from an account name that merely looks plausible. Ask the
user to name the account, and record the answer as a preference in Step 9.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity, never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke the same
tool with `approved=true` after an explicit yes, and record the task as `[gated]` rather than
`[auto]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every accrual has a computation, its supporting data, and its expense / revenue account
- Reversals dated the first day of the next period
- Roll-forwards by category present
- Tax components broken out
- Materiality applied transparently — including the cumulative total of excluded items
- Multi-currency entries documented
- File naming consistent
- No accrual unsupported by an underlying basis

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- Every item in Steps 1–7 carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool
  used, and that tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no item is silently dropped
- Account names in every proposed JE are the **real names from the connected chart of
  accounts**, not generic placeholders
- `mock` status is reported wherever it applies, and no proposed entry rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional
  term kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- Every persisted preference and generated asset states the datasource and `display_name` it
  covers
- Nothing was written back to any system — every JE is a proposal for a human to post
