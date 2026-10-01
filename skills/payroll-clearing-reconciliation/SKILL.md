---
name: payroll-clearing-reconciliation
description: "Use this skill whenever the user wants to reconcile payroll clearing, payroll suspense, payroll liability, or any payroll-related control account against their Mosofin workspace. Triggers include: 'reconcile payroll clearing', 'payroll suspense balance', 'clear payroll liabilities', 'why is payroll clearing not zero', 'reconcile payroll to bank', or any task involving the payroll control accounts at month-end. Workspace-scoped: it confirms the workspace, discovers which company files and payroll platforms are connected and which read-only tools are enabled, then rolls forward every payroll control account, ages the stale balances that are the real findings here, and tests whether each balance behaves like its remittance cadence — while treating the payroll register as external unless a payroll system is connected. Do NOT use for the payroll JE itself — use payroll-journal-entry-builder. Do NOT use for payroll tax filings — use payroll-tax-filings. Outputs a payroll clearing reconciliation with itemized differences, clearing JEs, and a coverage sheet."
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
# Payroll Clearing Reconciliation (Mosofin)

Reconciles **payroll clearing / suspense / liability accounts** to ensure all payroll obligations have been
properly remitted and the control accounts close to expected balances. Designed for **periodic review of
payroll-related GL accounts**.

**In plain words:** when payroll runs, the business owes several different people money at once — the staff,
the tax authority, the pension provider, sometimes a court. Each of those obligations sits in its own
account until it is paid. This checks that every one of them was paid, and finds the ones that have been
sitting there since nobody quite knows when.

This skill is **jurisdiction-agnostic**.

It is **workspace-scoped**: the payroll account balances, their movements and their ageing come from tool
calls against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## Payroll data is personal — handle it accordingly

**Payroll records concern identifiable people and are among the most sensitive data an employer holds.**
**Garnishments and wage attachments are more sensitive still** — they reveal court judgments, child support
obligations and personal debts.

**Rules for this skill:**

- **Work at account level.** Every step below is an account-level question. **Reconcile the balance, not the
  people.**
- **Never itemise individual garnishments, individual pay, or individual deductions** in a workpaper, a
  summary or a message. **Report counts and totals.**
- **Never persist any individual's payroll detail.** See Step 10.
- **Where a reconciling item genuinely concerns one employee** — an unclaimed final payment, a returned
  deposit — **refer to it by reference number, not by name.**

## The shape: the register is the missing half — and the ageing is the finding

**The general ledger holds every payroll control account and every movement through it.** **The payroll
register does not live here** — the by-employee, by-component detail is in the payroll system, and **the
`accrued during the period` half of Step 2's formula comes from there.**

**So check at Gate 1 whether a payroll platform is connected.** If one is, both halves are readable and this
becomes a genuine two-sided reconciliation. **If not, the GL side is still fully readable — and three things
follow that are worth having on their own:**

1. **The stale-balance test is entirely `[auto]`, and it is where the real findings are.** ⭐ **Step 7's
   sixty-day threshold is ledger arithmetic.** **A payroll clearing account that never clears is the single
   most common finding in this area**, and it hides genuine obligations: **unclaimed pay, garnishments
   awaiting direction, disputed final settlements.** **Some of it is escheatable** — a legal obligation with
   penalties, not a housekeeping matter.
2. **The behaviour test.** **[auto]**: Step 2 says the expected balance follows the remittance cadence —
   **a monthly-remitted withholding account should carry roughly one month's withholdings and drop to near
   nil after each remittance.** **You can test whether the balance behaves that way without the register at
   all.** A withholding account that never drops, or that drops to a residual that grows, is a finding.
3. **Remittances are readable.** **[auto]**: payments out of the bank account, by payee and date, **give the
   remittance side of every roll-forward** even where the register is absent.

**What stays outside:** the payroll register, benefit provider statements, court orders behind garnishments,
the bank statement itself, and every remittance schedule set by a tax authority.

**Mosofin is read-only.** It cannot post a clearing entry, remit anything or write off a balance. Every
entry below is a *proposal*.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

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
  multi-workspace, then which workspace(s) **by name**, then call again with `workspace_ids=[…]`
  and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check specifically for a connected payroll platform.** **If one is live, the payroll register becomes
`[auto]`** — the accrual half of every roll-forward, the YTD figures, the by-component detail. **That
converts this skill's largest manual input.** **If none is, say so**, and say which steps therefore rely on
supplied data.

Settle the entity scenario:

- **Single-entity** — one company file, one set of payroll accounts.
- **Multi-entity** — ask which set. **A shared payroll service running several entities** is common, and
  **the clearing account is per entity.** See the cross-entity step.

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
- **A near-substitute is not a substitute:**
  - **A GL payroll balance is not a payroll register.** It is a total posted by a journal.
  - **A payment out of the bank account is not proof of remittance to the right authority** — the payee and
    the memo are evidence, and the tax authority's acknowledgement is not here. See `payroll-tax-filings`.
  - **A recorded disbursement is not a bank statement.** The same limit as `bank-reconciliation` and
    `merchant-and-payment-processor-rec`.
  - **A nil balance is not a reconciled account.** Two errors can offset.
- **There is no payroll register, no benefit provider statement, no court order and no bank statement on
  this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar, **country /
region — which drives which liability accounts exist.**

**Ask the user** what actually changes the work — the original Inputs table, **minus the parts the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being reconciled** | **Required** | |
| ~~GL balances for each payroll account~~ | **Now [auto]** | **Confirm which accounts are in scope.** |
| **Payroll register(s) for the period** | **Required — [gated]** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise.** |
| **Remittance / payment evidence** | **Required — [gated]** | **Payments are `[auto]`; the authority's acknowledgement is not.** |
| ~~Chart of accounts~~ | **Now [auto]** | |
| ~~Tax jurisdiction~~ | **Now [auto]** | Country from the profile. **The remittance cadence is `[manual]`.** |
| **Benefit provider statements** | Recommended — **[manual]** | |
| **Prior period reconciliation** | Recommended — **[gated]** | **Opening balances `[auto]`; carried items `[manual]`.** |
| **The remittance cadence per liability** | **Required — Mosofin addition** | **Monthly, semi-weekly, quarterly.** **The expected-balance pattern depends on it entirely.** |
| **Materiality threshold** for write-offs | Recommended — **[manual]** | |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the accounts covered. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. withholding accounts for a jurisdiction the entity does not operate in. |
| **Confirm manual evidence** | **Required** | The register, provider statements and cadences are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a remittance cadence,
a write-off, or an escheatment treatment.

**On later runs**, read stored preferences first (Step 10), confirm in one line, and ask only what changed.
The account list, the cadences, the expected-balance patterns and the tolerance persist; **every balance and
every ageing is re-obtained.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The register and the provider statements are legitimately
`[manual]` where their systems are not connected.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the movements and the payments do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **every payroll liability, clearing and suspense account, plus the payroll expense
  accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* at period end **and prior period end** — **the roll-forward
  anchors** — usually **[auto]**
- *`get_general_ledger`* on **each payroll account** — **every movement, and the ageing of what remains** —
  usually **[auto]**. **The central read of this skill**
- *`search_payments`* / *`search_checks`* — **remittances out**, by payee and date — usually **[auto]**
- *`search_journal_entries`* — **the payroll journals themselves, and any manual entries to clearing** —
  usually **[auto]**
- *`get_profit_and_loss`* — payroll expense by period, for reasonableness — usually **[auto]**
- *`search_employees`* — **headcount only**, for scale — usually **[auto]**
- *`get_company_info`* — legal name, **country**, currency — usually **[auto]**

**Pull several prior periods.** **The behaviour test in Step 0b needs the pattern**, not one balance.

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **payroll liabilities are amounts owed to people
and to tax authorities**, and a fixture-based conclusion that they were remitted is worse than no
conclusion.

## Step 0b — Age every balance and test its behaviour (Mosofin addition)

**Run before Step 1's account identification is finalised**, because it tells you which accounts are
actually behaving as intended. **[auto]**, and this is the skill's strongest contribution.

**1. Age every payroll account balance.** **[auto]** from the account history: **how long has each component
of the closing balance been sitting there?** Report by band — current period, 1–2 periods, 3–6 periods,
**over 6 periods**.

**2. Test the behaviour against the cadence.** For each liability account, given its remittance cadence:

| Expected behaviour | What a failure looks like |
|---|---|
| **Accrues on each payroll, clears on each remittance** | **A residual that survives every remittance** |
| **Peaks at one period's withholdings** | **A balance that only ever grows** |
| **Returns to nil after the cycle** — clearing and suspense accounts | **A permanent balance in a clearing account** |

**3. Identify the never-clearing residual.** **[auto]**: **the minimum balance the account has reached over
the last twelve periods** is, in effect, **a permanent balance masquerading as a payroll liability.** **That
figure is the finding**, and it is usually the sum of several old items nobody has looked at.

**Report all three before anything else.** A reconciliation that explains this period's movement while a
four-year-old residual sits underneath it has explained the wrong thing.

## Step 1 — Identify the payroll accounts in scope

**Common payroll-related accounts** — the specific accounts depend on the COA and jurisdiction —
**[auto]** to enumerate:

**Liability accounts:**
- **Net pay payable / payroll clearing** — between booking the payroll JE and disbursing cash
- **Income tax withheld** — federal, state / provincial, local, **per jurisdiction**
- **Social charges withheld** — **FICA / EI / CPP / NI / equivalent**
- **Employer-side social charges payable**
- **Benefits withheld** — health insurance, dental, vision
- **Retirement contributions withheld** — **401(k), RRSP, pension**
- **Employer-match retirement payable**
- **Garnishments / wage assignments**
- **Union dues**
- **Other withholdings**

**Suspense / clearing:**
- **Payroll clearing**
- **Payroll suspense**

**P&L accounts** — not reconciled in the same way, but referenced:
- **Salaries & wages expense**
- **Employer tax expense**
- **Benefits expense**
- **Stock-based compensation expense** (see `equity-compensation-accounting`)

**Ask the user for their specific account list.** **[auto]** to propose it: **read the chart and present the
payroll accounts found**, so the user confirms a list rather than assembling one.

**[auto]** completeness check worth running: **an account with payroll-cycle movement that is not on the
supplied list**, and **a listed account with no movement at all** — the first is a scope gap, the second is
either dormant or a jurisdiction the entity has exited.

## Step 2 — Pull the expected balance for each account

**For each liability account, the expected balance at period end equals:**

```
Opening balance
+ Accrued during the period (per payroll register)
- Remitted during the period (per remittance records)
= Expected closing balance
```

**[gated]**: **opening `[auto]`; accrued `[manual]` without the register — though the payroll journal's
credit to the account is a proxy worth stating as one; remitted `[auto]` from payments.**

**The expected closing balance is usually:**

- **Zero for "clearing" or "in-transit" accounts after the payroll cycle settles**
- **Non-zero but predictable for liability accounts based on remittance schedule** — e.g. income tax
  withheld in the current month, remitted next month → **balance = current month's withholdings**

**Mosofin note on the proxy**: **where the register is unavailable, the payroll journal's posting to the
account is the best available accrual figure** — and **it is what was posted, not what the register says.**
**If they differ, the payroll journal is wrong**, which is precisely what a register-based reconciliation
exists to find. **State clearly which basis was used.**

## Step 3 — Compare actual GL to expected

For each account — **[gated]**:

```
GL closing balance                            $X
Expected closing balance                       $Y
Difference                                     $X − $Y
```

**Investigate every non-zero difference.**

**Report the difference for every account, including zero** — and **note that a nil difference is not a
reconciled account** where the expected balance was derived from the same postings as the actual. **Where
the register is absent, say what the comparison actually proves**: that the account moved as the journals
say, not that the journals were right.

## Step 4 — Itemize reconciling items per account

For each account with a difference, identify the components — **each with its detectability**:

| Cause | Example | Detectable? |
|-------|---------|---|
| **Timing — remittance after period end** | Withholding remitted on the 15th of next month | **[auto]** — the payment appears next period |
| **Manual JE posted to clearing** | Year-end true-ups | **[auto]** — a journal with no payroll cycle behind it |
| **Misclassified entry** | Wrong account used | **[auto]** — an entry inconsistent with the account's usual pattern |
| **FX revaluation** | Foreign-currency payroll | **[gated]** — see `multicurrency-fx-revaluation` |
| **Rounding** | Per-employee penny differences | **[auto]** — small, persistent, proportional to headcount |
| **Voided / cancelled payments** | Stop payments, recovered amounts | **[auto]** — a reversal in the account |
| **Adjustment to prior period** | Corrections, retroactive pay | **[auto]** — an entry dated or referencing a prior period |
| **Open accruals** — e.g. vacation accrual | Carry from prior periods | **[auto]** — a balance that never clears |
| **Benefit invoice timing** | Provider invoiced quarterly vs. monthly accrual | **[auto]** — a saw-tooth pattern |

**Eight of nine are detectable from the ledger**, and **most of them announce themselves in the account's
movement pattern rather than requiring investigation.** **Classify first from the pattern, then confirm.**

## Step 5 — Reconcile to bank disbursements

For each payroll cycle — **[gated]**:

- **Net pay disbursed** (per payroll register) **= sum of cash disbursements to employees + any direct
  deposits** — **[auto]** for the disbursements, `[manual]` for the register figure
- **Tax remittances = sum of withholdings + employer share, by tax authority** — **[auto]** for the
  payments, by payee
- **Benefit remittances = sum of withholdings + employer share, by provider** — **[auto]** for the payments
- **Total payroll cash impact = above sums** — **[auto]**

**Compare to the bank statement entries for the period. Differences here are typically timing** — e.g.
direct deposits initiated late and cleared post-period.

**Mosofin precision on that last instruction**: **the bank statement is `[manual]`.** **What is `[auto]` is
the recorded disbursement.** **Tying payroll to recorded disbursements proves the bookkeeping; tying it to
the bank statement proves the money left.** **State which was performed** — the same distinction as
`bank-reconciliation` and `merchant-and-payment-processor-rec`.

## Step 6 — Year-to-date reconciliations

**For tax-withholding accounts especially, YTD figures must reconcile to** — **[gated]**:

- **Cumulative payroll register YTD** — **[manual]** without the payroll system
- **Cumulative remittances YTD** — **[auto]** from payments
- **Year-end forms (W-2 / T4 / equivalent) when produced** — **[manual]**; see `payroll-tax-filings`

**Mid-year, the YTD reconciliation is a preview; year-end is the formal one.**

**[auto]** contribution: **cumulative accruals per the ledger against cumulative remittances per the
ledger**, which **should differ by exactly the outstanding liability.** That identity holds without the
register, and **a YTD difference that is not explained by the outstanding balance is a genuine break.**

## Step 7 — Investigate stale balances

**Any payroll clearing balance aged > 60 days warrants investigation.** **[auto]** — **and this is the step
the workspace performs best.**

**Common causes:**

- **Unclaimed pay** — returned direct deposits, uncashed cheques
- **Garnishments awaiting court direction**
- **Terminated employees with final-pay disputes**
- **Benefit reconciliation lagging the provider's invoice cycle**

**Stale balances may need to be:**

- **Returned to employees (if owed)**
- **Escheated to the state** — in jurisdictions with unclaimed property laws
- **Written off** — with proper authority and tax treatment

**Three points worth emphasising in a Mosofin run:**

**The ageing is exact.** **[auto]**: not "this looks old" but **"£4,180 has been in this account since March
2023, comprising nine items."** That specificity is what moves a stale balance from a note to an action.

**Escheatment is a legal obligation, not housekeeping.** **Unclaimed wages are unclaimed property**, and
jurisdictions with such laws impose **reporting deadlines and penalties for failing to remit.** **Writing
off unclaimed pay to income is frequently not permitted** — it belongs to the employee until it belongs to
the state. **Flag it as a compliance matter and name the determination as `[manual]`.**

**Handle garnishment balances carefully.** **They concern court orders and personal circumstances.**
**Report the total and the count; refer to individual items by reference.**

## Step 8 — Construct cleanup JEs

**Hand off to `journal-entry-builder`.** **Mosofin does not post** — these are proposals.

**For permanent differences requiring correction:**

- **Reclass**: post to the right account from the wrong account
- **Write-off**: **small immaterial residuals** to a payroll-related expense or other-income line, **per
  policy**
- **True-up**: correct an accrual error from a prior period

**For timing differences: document but do not adjust.**

**Two cautions**: **do not write off what is owed to a person** — see escheatment above; **and a residual
that recurs every period is not immaterial**, however small each instance is. **[auto]** to detect: **the
same small write-off proposed repeatedly is a process fault**, and writing it off again treats the symptom.

## Step 9 — Output

Deliver an `.xlsx` workpaper, **one tab per account**:

**Header per account:**
- **Account number and name**
- **Period**
- **GL balance**
- **Expected balance** (formula and inputs)
- **Difference**
- **Status** (tied / within tolerance / investigating)

**Add the Mosofin rows**: **the ageing profile**, **the never-clearing residual**, and **the basis of the
expected balance** — register or payroll journal proxy.

**Detail per account:**

| Item | Description | Type (Timing / Permanent / Investigating) | Amount | Age | Owner | Target Resolution |

**Age is `[auto]`.** **Descriptions refer to individuals by reference, never by name.**

**Roll-Forward per account:**

| Opening | + Accruals | − Remittances | +/− Adjustments | = Closing |

**Master summary:**

| Account | GL Balance | Expected | Difference | Status | Materiality Breach Y/N |

**Bank tie-out:**

| Pay Date | Cycle | Net Pay Disbursed | Per Bank | Difference |

**With a column stating whether "Per Bank" is the recorded disbursement or the bank statement.**

**Proposed JEs:** pass-through to `journal-entry-builder`, marked as **proposals**.

**Stale Balances — NEW, Mosofin-specific:**

| Account | Amount | Age | Item count | Probable cause | Treatment | Escheatment applicable? |

**Coverage — NEW, Mosofin-specific:**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Payroll_Recs_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the register, the provider statements, the bank statement — **name the source required**
instead of estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The payroll account list** and what each one holds
- **The remittance cadence per liability** — **the input the expected-balance pattern depends on**, and it
  changes rarely
- **The expected-balance pattern per account** — what "behaving correctly" looks like here
- **The payroll cycle calendar** — pay dates, remittance dates
- **The materiality tolerance** for write-offs, and the approval required
- **The escheatment position** — which jurisdictions apply and what the reporting deadlines are, **by
  reference**
- **Known recurring reconciling items** — expressed as rules: "the benefit provider invoices quarterly, so a
  two-month accrual is expected at those period ends"
- **The benefit providers and tax authorities** by payee name, so remittances match automatically
- **Whether a payroll platform is connected**, and which figures it supplies
- The replay recipe: the exact sequence of reads that produced the roll-forward and the ageing

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data** — no names, no pay amounts, no deductions, no garnishment
details, no bank details. **This is absolute.** **Garnishment information in particular reveals court
judgments and personal debts**, and it must not exist in a skill bundle in any form. **And never persist
balances, ageings or reconciling items** — all state.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — clearing 2200, PAYE 2210 remitted monthly on the 22nd, pension 2230 remitted monthly, benefits
invoiced quarterly, tolerance 50" — not "clearing 2200, PAYE 2210". **Account maps and cadences are
entity-specific and jurisdiction-specific**, and applying one entity's expected-balance pattern to another
produces false exceptions across the board. Record the chosen **scenario** (single vs multi) as a preference
too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of payroll accounts, one
cadence.

**Multi-entity.** Steps 0–9 run **once per entity**, each call targeting exactly one `data_source_id`, every
balance carrying its entity's `display_name`. Then:

- **A shared payroll service running several entities is common**, and **the clearing account is per
  entity.** **One payroll run covering three companies produces three sets of liabilities**, and a single
  bank payment covering all three must be allocated. **The allocation basis is `[manual]`.**
- **A payment made by one entity for another's payroll creates an intercompany balance** — not a payroll
  reconciling item. See `intercompany-reconciliation`; both sides must agree.
- **Employment jurisdiction, not entity location, drives the withholding accounts.** An entity employing
  people in three countries has three sets of withholding liabilities and three cadences.
- **Age and reconcile per entity.** A group-level clearing balance that nets to nil can conceal one entity
  owing and another over-remitted.
- **Escheatment obligations follow the employment jurisdiction**, and differ by state or country. **Do not
  apply one entity's position to another.**
- **Currency**: payroll in a currency other than the entity's functional currency creates FX on the
  liability between accrual and remittance — see `multicurrency-fx-revaluation`.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

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
| `create_skill` | Persists the evolved skill. Step 10. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Every payroll liability, clearing and expense account** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Roll-forward anchors, both period ends** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Every movement, and the ageing — the central read** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Remittances out, by payee and date** | `search_payments` / `search_checks` | `start_date`, `end_date` (required) |
| **The payroll journals, and manual entries to clearing** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Payroll expense by period | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` |
| Headcount, for scale only | `search_employees` | `query`/`name`, `active_only` |
| Legal name, **country**, currency | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register, YTD and component tools appear in
**its own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no benefit provider statement, no court order and no bank statement on this
surface.**

---

## Plain-language glossary

- **Payroll clearing / suspense** — a holding account between recording the payroll and paying it out.
  **It should return to nil after each cycle.**
- **Withholding** — money deducted from pay on someone else's behalf: tax, pension, union dues. **It is
  never the employer's money.**
- **Employer-side charges** — what the employer owes on top of gross pay: social contributions, pension
  match.
- **Remittance** — paying a withholding over to whoever it belongs to.
- **Remittance cadence** — how often that must happen. **Set by the authority, not the employer**, and it
  determines what a correct balance looks like.
- **Garnishment / wage assignment** — a legally required deduction paid to a third party, usually under a
  court order.
- **Escheatment** — handing unclaimed money to the state after a statutory period. **A legal obligation with
  deadlines and penalties**, not a write-off option.
- **Unclaimed property** — money owed to someone who cannot be found. **Still theirs.**
- **Stale balance** — an amount sitting in a control account long past when it should have cleared.
- **Roll-forward** — opening, plus accruals, less remittances, equals closing.
- **YTD reconciliation** — checking the cumulative year's figures, which is what year-end forms are built
  from.
- **Retroactive pay** — an adjustment for a past period, paid now.
- **Direct deposit reversal** — a payment returned because the account was closed. **Creates a balance owed
  to the employee.**

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-state / multi-province payroll**: **each jurisdiction has its own withholding remittances. Reconcile
by jurisdiction, then aggregate.**

**Multi-currency payroll**: **reconcile in functional currency; track FX gain / loss on the period's payroll
cycle.** See `multicurrency-fx-revaluation`.

**Stock-based compensation accruals**: see `equity-compensation-accounting`. **The reconciliation for
SBC-related accounts is separate from cash payroll.**

**Severance and termination payments**: **often paid through separate channels; ensure they're in the
payroll register and on the reconciliation.** *Mosofin note*: **a payment to a former employee outside the
normal cycle is readable**, and it is a common omission.

**Year-end accruals** — vacation, sick leave: **non-cash but liability-impacting. The vacation accrual
account ties to the entity's vacation policy and employee balance reports.** **The balance report is
`[manual]`.**

**Loans to employees**: **tracked as Due from Employee, not as a payroll item, but often coordinated with
payroll for repayment.** See `expense-report-processor`, where the same account appears.

**Garnishments**: **third-party recipient; reconcile to court orders / wage attachment notices.**
**Sensitive — report totals and counts, never individual detail.**

**Withholding tax remittance frequency varies by jurisdiction**: **monthly, semi-weekly, weekly, or
quarterly. The expected balance pattern follows the remittance cadence.** *Mosofin note*: **which is why the
cadence is a required input** — without it the behaviour test has no benchmark.

**Mid-year payroll-system change**: **YTD figures must transfer correctly. Reconcile pre- and
post-transition balances.** *Mosofin note*: **a discontinuity in the account's movement pattern is readable**
and marks the transition date.

**Reversed bonus accrual**: **a year-end bonus accrual later cancelled or modified — track the reversal.**

**Health insurance / benefit invoices in arrears**: **provider may invoice for the prior month's coverage.
Accrue the current month's expense and reconcile against the invoice when received.** *Mosofin note*: **the
saw-tooth pattern this creates is readable**, and it should not be mistaken for a break.

**Direct deposit reversals**: **an employee account closed, deposit returns. Track the return and the
re-issuance.** **The returned amount is owed to the employee** — see escheatment.

**A clearing account that never reaches nil** — *Mosofin-specific, and the headline finding*. **The minimum
balance over twelve periods is a permanent residual** wearing a payroll liability's name.

**A withholding account that only grows** — *Mosofin-specific*. Remittances are not happening, or not all of
them. **A serious finding**, since the money belongs to a tax authority.

**Unclaimed pay written off to income** — *Mosofin-specific compliance point*. **Frequently not permitted.**
It belongs to the employee, then to the state.

**The same small write-off proposed every period** — *Mosofin-specific*. **A process fault, not an immaterial
residual.** Writing it off again treats the symptom.

**The expected balance derived from the same postings as the actual** — *Mosofin-specific*. **A nil
difference then proves only that arithmetic works.** State the basis used.

**Recorded disbursements presented as bank-verified** — *Mosofin-specific*. Different assurances.

**A group clearing balance netting to nil** — *Mosofin-specific*. One entity owing and another over-remitted
cancel out. **Reconcile per entity.**

**A payment by one entity for another's payroll** — *Mosofin-specific*. An intercompany balance, not a
payroll reconciling item.

**A result comes back with `mock: true`** — *Mosofin-specific*. **These are amounts owed to people and to tax
authorities.**

**A stored balance or reconciling item is reused** — *Mosofin-specific*. All state. Persist the account map
and the cadences.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's cadence or escheatment position to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every payroll account has GL balance, expected balance, and explained difference**
- **YTD figures verified against payroll register**
- **Bank tie-out for each payroll cycle**
- **Stale balances flagged with age and proposed treatment**
- **Multi-jurisdiction breakdown if applicable**
- **File naming consistent**
- **Cleanup JEs proposed for permanent differences**
- **No silent absorption of differences**

**Mosofin additions:**

- **No individual's payroll data appears anywhere in the output** — reconciling items refer to people by
  reference, and garnishments are reported as totals and counts
- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**;
  **whether a payroll platform is connected is stated**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every balance is aged**, with the profile reported by band and **the never-clearing residual identified
  explicitly**
- **Each account's behaviour was tested against its remittance cadence**, and accounts that only grow or
  never clear are reported as findings
- **The basis of every expected balance is stated** — payroll register, or payroll journal proxy — and where
  the proxy was used, **what the comparison proves is stated**
- **The bank tie-out states whether it was to recorded disbursements or to the bank statement**
- **The YTD identity was tested** — cumulative accruals less cumulative remittances equals the outstanding
  liability
- **Stale balances carry exact ages, item counts and probable causes**, and **escheatment is flagged as a
  compliance obligation** rather than a write-off option
- **Unclaimed pay is not proposed for write-off to income**
- **Recurring small write-offs are reported as a process fault**, not as immaterial residuals
- **The payroll account list was proposed from the chart** and confirmed, with accounts showing payroll
  movement but absent from the list flagged
- In a multi-entity run, **ageing and reconciliation run per entity**, shared payroll payments are allocated
  on a stated basis, cross-entity payments are raised as intercompany, and **escheatment positions are not
  carried between entities**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no conclusion that a liability was remitted rests on
  mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data of any kind is persisted**, and no balances, ageings or reconciling items are
  stored; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no entry posted, no remittance made, no balance written off
