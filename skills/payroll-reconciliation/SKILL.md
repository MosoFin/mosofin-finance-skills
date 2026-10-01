---
name: payroll-reconciliation
description: "Use this skill whenever the user wants to reconcile payroll against their Mosofin workspace — payroll register to GL, payroll to bank, payroll liabilities to amounts remitted, or quarter/year-end payroll tie-outs. Triggers include: 'reconcile payroll', 'payroll register to GL', 'does payroll tie to the bank', 'reconcile payroll liabilities', 'year-end payroll reconciliation', 'reconcile wages to the tax filings', or checking payroll is correctly recorded and settled. Workspace-scoped: it confirms the workspace, discovers which company files and payroll platforms are connected and which read-only tools are enabled, then owns the GL side of every tie-out, rolls forward each liability, and surfaces the manual adjustments and negative balances that break the register-to-GL tie — while treating taxable wage bases as register data the ledger cannot supply. Do NOT use for building the payroll JE — use payroll-journal-entry-builder. Do NOT use for clearing-account zeroing only — use payroll-clearing-reconciliation. Outputs a payroll reconciliation workpaper tying register, GL, bank, and filings with flagged exceptions and a coverage sheet."
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
# Payroll Reconciliation (Mosofin)

Reconciles payroll across its **sources of truth** — the **payroll register**, the **general ledger**, the
**bank**, and the **tax and benefit remittances** — to confirm payroll is **recorded completely and
accurately and that all liabilities are settled**. **Catches mispostings, unremitted liabilities, and
register-to-GL gaps before they become filing or audit problems.**

**In plain words:** four systems should agree about what payroll cost and where the money went — the payroll
software, the accounts, the bank, and whatever was filed with the tax authority. When they do not, someone
has been paid the wrong amount, a liability has not been settled, or a filing will be wrong.

This skill is **jurisdiction-agnostic** — it reconciles whatever withholding and contribution types the
register contains.

It is **workspace-scoped**: the GL side of every tie-out, the liability movements and the recorded
disbursements come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**This is the umbrella payroll reconciliation.** `payroll-clearing-reconciliation` covers the clearing and
liability accounts in depth; **this one spans register ↔ GL ↔ bank ↔ filings.** Where they overlap, they
agree, and the detail belongs there.

## Payroll data is personal

**The rule from the other payroll skills applies in full**: **reconcile at account and total level, never
employee by employee.** **Individual pay, deductions and garnishments do not appear in this workpaper**;
where a reconciling item concerns one person, **refer to it by reference number.** **Never persist any
individual's payroll data.**

## Four sources, and the workspace owns one of them

| Source | Verdict |
|---|---|
| **The general ledger** — every payroll account and movement | **`[auto]`**, entirely |
| **The payroll register** — gross, withholdings, employer costs, net, **and the taxable wage bases** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise** |
| **The bank** — what actually left the account | **`[manual]`** for the statement; **`[auto]`** for the recorded disbursement |
| **The filings** — what was reported to the authority | **`[manual]`** — see `payroll-tax-filings` |

**So this is a four-way reconciliation in which the workspace owns one corner exactly and contributes to
two others.** That is worth stating, because **a "reconciliation" performed against only the corner you can
read is not one.**

**Three things the GL side contributes that are worth having on their own:**

1. **Manual adjustments to payroll accounts.** **[auto]**, and the edge cases name them as a cause of the
   register-to-GL break. **A journal entry to a payroll account with no payroll run behind it** is readable,
   and it is usually the explanation.
2. **Negative and anomalous liability balances.** **[auto]**, trivially. **A negative payroll liability is
   always wrong** — over-remittance or a posting error — and it is one query.
3. **The liability roll-forward's GL anchors.** **[auto]** at both ends, so **the roll-forward has to
   land**, and any difference is real.

**And the honest limit, which is the most important sentence in this file:**

> **The general ledger does not hold taxable wage bases.** **Step 5 reconciles each tax to its own base —
> gross, less pre-tax deductions, subject to caps — and none of that structure exists in the accounts.**
> The GL has one gross figure and one tax figure per liability.
>
> **So Step 5 is `[manual]` and cannot be approximated.** **A naive gross × rate check will mismatch for
> every employee who crossed a ceiling or made a pre-tax contribution** — which is exactly the error the
> original warns against. **Where the register is unavailable, report Step 5 as not performed** rather than
> substituting the gross comparison.

**Mosofin is read-only.** It cannot post a correction, remit a liability or amend a filing. Every correction
below is a *proposal*.

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

**Check for a connected payroll platform.** **If one is live, the register and the taxable wage bases become
`[auto]`** — which converts Steps 1, 4 and 5 from partial to complete. **This is the single most
consequential connection for the payroll skills**, and it is worth saying so.

Settle the entity scenario:

- **Single-entity** — one company file, one register.
- **Multi-entity** — ask which set. **A shared payroll service across entities** means the register covers
  several and **each entity's GL holds only its share.** See the cross-entity step.

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

Resolve **every reconciliation in Part B** against these buckets. The resolved list is the **capability
map** — built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **Gross wages are not a taxable wage base.** The central limit above.
  - **A payment to a tax authority is not proof of remittance of the right amount for the right period** —
    and **with a third-party provider, it is not even proof the provider remitted at all.**
  - **A recorded disbursement is not a bank statement.** Consistent with `bank-reconciliation`.
  - **A nil difference is not a reconciliation** where both sides came from the same postings.
- **There is no payroll register, no wage base, no bank statement and no filing on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, **fiscal calendar** — which sets the
quarter and year ends where Steps 4 and 5 bite — **country / region**.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| **Payroll register(s) for the period** | **Required — [gated]** | **`[auto]` if a payroll platform is connected.** |
| ~~GL payroll accounts activity~~ | **Now [auto]** | Confirm which accounts are in scope. |
| **Bank statement / payment records** | **Required — [gated]** | **Recorded disbursements `[auto]`; the statement `[manual]`.** |
| **Liability remittance records** | **Required for liability rec — [gated]** | **Payments `[auto]`; the authority's receipt `[manual]`.** |
| **Period** — month / quarter / year | **Required** | **Steps 4 and 5 apply at quarter and year end.** |
| **Tax filing figures** | Recommended — **[manual]** | See `payroll-tax-filings`. |
| **Prior period reconciliation** | Recommended — **[gated]** | **Opening balances `[auto]`; carried items `[manual]`.** |
| **The taxable wage base rules** per tax | **Required for Step 5 — [manual]** | Pre-tax deductions, caps, ceilings. **Not derivable here.** |
| **Remittance due dates** per liability | **Required for the overdue flag — [manual]** | |
| **Whether a third-party provider handles remittance** | **Required — Mosofin addition** | **The entity remains liable**; see the edge cases. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The register, wage bases, filings and bank statement are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a wage base rule, a due
date, or a remittance status.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only what changed.
The account map, the wage base rules, the due dates and the known reconciling items persist; **every balance
and every tie-out is re-performed.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The wage bases and the filings are legitimately `[manual]`,
and reporting Step 5 as not performed is the honest result where the register is absent.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the movements, the payments and
the journals do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **every payroll expense and liability account** — usually **[auto]**
- *`get_profit_and_loss`* — **wages and employer cost expense for the period** — the Step 1 target — usually
  **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* at both period ends — **the liability roll-forward anchors**
  — usually **[auto]**
- *`get_general_ledger`* on **every payroll account** — **movements, ageing, and the manual adjustments** —
  usually **[auto]**. **The central read**
- *`search_payments`* / *`search_checks`* — **net pay disbursements and remittances**, by payee — usually
  **[auto]**
- *`search_journal_entries`* — **the payroll journals, and any manual entry to a payroll account** — usually
  **[auto]**
- *`search_employees`* — **headcount only** — usually **[auto]**
- *`get_company_info`* — legal name, country, **fiscal calendar** — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that reconciliation to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a payroll reconciliation feeds tax filings and
employee wage statements**, and a fixture-based tie means nothing to either.

## Step 1 — Reconcile payroll register to GL (expense and gross)

**Confirm what the payroll system reports matches what was booked** — **[gated]**: **the GL side is
`[auto]`**, the register side is not:

- **Total gross wages per the register(s) = wages / salaries expense posted to the GL for the period**
- **Employer costs per the register = employer cost expense in the GL**
- **Investigate differences: missing runs, manual adjustments, misclassified postings, capitalized labor
  (legitimately not in expense), timing**

**Build a register-to-GL bridge reconciling any difference to explained items.**

**Mosofin contribution — four of the five listed causes are detectable.** **[auto]**:

| Cause | How it shows |
|---|---|
| **Missing runs** | **a pay period with no journal** — the payroll journal pattern has a gap |
| **Manual adjustments** | **a journal to a payroll account with no payroll run behind it** — see below |
| **Misclassified postings** | **payroll-cycle amounts in a non-payroll account**, or the reverse |
| **Capitalized labor** | **a debit to an asset account on the payroll journal date** |
| **Timing** | a run dated in one period and posted in another |

**The manual adjustment check deserves its own emphasis**, since the edge cases name it as a tie-breaker:
**list every entry to a payroll account that is not part of a payroll run**, with its date, amount, account
and memo. **In most broken register-to-GL reconciliations, the answer is on that list.**

## Step 2 — Reconcile net pay to bank

- **Total net pay per the register(s) = net pay disbursed per the bank** — direct deposits + checks —
  **[gated]**
- **Account for timing** — a pay date spanning a bank cutoff — **uncashed checks, returned payments** —
  **[gated]**: **returned payments and reissues are readable**
- **Where a payroll clearing account is used, confirm it nets appropriately** — hand detail to
  `payroll-clearing-reconciliation`

**State which side of "bank" was used.** **Recorded disbursements are `[auto]`; the bank statement is
`[manual]`** — and **tying net pay to recorded disbursements proves the bookkeeping, not that the money
left.** The same distinction as `bank-reconciliation` and `merchant-and-payment-processor-rec`.

## Step 3 — Reconcile withholding and employer liabilities

For each liability type — **income tax withholding, social / payroll contributions employee and employer,
retirement, benefits, garnishments** — **[gated]**:

```
Opening liability balance (from GL)
+ Amounts accrued this period (from register/JE)
− Amounts remitted this period (from bank/remittance records)
= Closing liability balance (should equal GL)
```

**Opening and closing are `[auto]`; remittances are `[auto]` from payments; accruals are `[manual]` without
the register — though the payroll journal's credit is a stated proxy.**

**Confirm the closing GL balance for each liability equals what's genuinely still owed (and not yet due).
Flag:**

- **Unremitted liabilities past their due date** — **penalty risk** — **[gated]**: the balance and its age
  are `[auto]`, **the due date is `[manual]`**
- **Liabilities that should be zero but aren't** — over-accrual, missed remittance, or misposting —
  **[auto]** given the expected pattern; see `payroll-clearing-reconciliation` Step 0b
- **Negative liability balances** — over-remittance or posting error — **[auto]**, ⭐ **and always wrong.**
  One query, run it every period

**The overdue flag is the one with consequences.** **An unremitted withholding past its due date accrues
penalties and interest**, and in many jurisdictions **payroll taxes carry personal liability for
directors** — which is a materially different exposure from an ordinary overdue payable. **Given the due
dates, the flag is arithmetic; without them it cannot be raised.** Ask for them.

## Step 4 — Reconcile to tax filings (quarter/year-end)

**When filings are prepared** (`payroll-tax-filings`), **tie the payroll records to the filed figures** —
**[gated]**: the GL side `[auto]`, **the filings `[manual]`**:

- **Total taxable wages per the GL / register = taxable wages on the filing**
- **Total tax withheld / contributed per the GL = tax reported on the filing**
- **Year-end employee wage statements (totals) = sum of registers = GL wages**
- **Reconcile any differences** — e.g. non-taxable items, pre-tax deductions affecting taxable wage bases
  differently

**This is critical: filings, wage statements, and the GL must agree, or it surfaces in audits and employee
tax filings.**

**Note the first bullet contains the Step 5 problem.** **"Taxable wages per the GL" is not available** — the
GL holds gross, not taxable. **Where the register is absent, this comparison runs on gross and will differ
by exactly the pre-tax deductions and capped amounts.** **Say that**, rather than reporting an unexplained
difference.

**The year-end statement tie has a deadline.** **Differences must be resolved before statements are issued
to employees**, because a wrong statement means amended filings and employees amending their own tax
returns. **[auto]** contribution: **the GL wage total is exact and available immediately**, which makes the
comparison possible as soon as the register is.

## Step 5 — Reconcile taxable wage bases

**Different taxes apply to different wage bases** — some withholdings are on gross, some on gross less
pre-tax deductions, some capped at a ceiling. **Reconcile each tax's wage base:**

- **Gross wages**
- **Less pre-tax deductions** — retirement, certain benefits — where applicable
- **Subject to caps / ceilings** where applicable
- **= Taxable base for that specific tax**

**Confirm each tax was computed on the correct base. Mismatched bases are a common error.**

**[manual]**, entirely, and **this is where the register is irreplaceable.**

**Why it cannot be approximated here:** **caps apply per employee, not in aggregate.** An entity whose
employees have collectively earned well above a ceiling may still have most of them below it. **There is no
aggregate arithmetic that recovers a per-employee capped base**, and **pre-tax deductions vary by employee
election.** **The GL's single gross figure cannot be decomposed into them.**

**Where the register is unavailable, report this step as NOT PERFORMED**, name what it would have shown, and
**do not present a gross-based rate check as a substitute** — it will mismatch for every affected employee
and the mismatch will look like an error when it is not.

## Step 6 — Investigate and resolve exceptions

For every reconciling item — **[gated]**:

- **Classify: timing, error, missing transaction, legitimate difference** — **[auto]** support from Step 1's
  cause table
- **Quantify** — **[auto]**
- **Determine the correction** — adjusting JE, remittance, filing amendment — **[manual]** judgment;
  the JE via `payroll-journal-entry-builder`
- **Document**

**Note the three correction types have very different urgencies.** **An adjusting JE is internal. A missed
remittance accrues penalties from its due date. A filing amendment may require amended employee wage
statements** — and the third is the one people discover last. **Order the exception list by consequence, not
by amount.**

## Step 7 — Output

Deliver an `.xlsx` reconciliation workpaper:

**Sheet 1: Reconciliation Summary** — **each reconciliation (register↔GL, net pay↔bank, liabilities,
filings) with status (tied / exceptions) and total unreconciled.** Add the Mosofin header: workspace name;
the entity by `display_name`; **which sources were read and which supplied**; **whether Step 5 was
performed**; whether any figure rests on `mock` data.

**Sheet 2: Register-to-GL Bridge** — **gross and employer cost, register vs. GL, reconciling items**, with
**the manual adjustments listed separately**.

**Sheet 3: Net Pay to Bank** — **disbursements tie-out**, stating **recorded or bank-verified**.

**Sheet 4: Liability Roll-Forward** — **per liability: opening + accrued − remitted = closing, vs. GL, with
overdue / anomaly flags.** **Negative balances listed explicitly.**

**Sheet 5: Filing Reconciliation** — **wages and taxes per GL vs. filings vs. wage statements** (quarter and
year-end).

**Sheet 6: Taxable Wage Base Reconciliation** — **each tax's base derived and confirmed** — **or marked NOT
PERFORMED with the reason**.

**Sheet 7: Exceptions & Corrections**

| Item | Type | Amount | Root Cause | Correction | Owner | Status |

**Ordered by consequence**, with **due-date exposure flagged**.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Payroll_Reconciliation_[Period]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where a reconciliation could
not be performed — Step 5 without a register, the bank without a statement — **say so** rather than
reporting a tie.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** — every payroll expense and liability account and what it holds
- **The taxable wage base rules** per tax — **pre-tax deductions, caps, ceilings** — **the input Step 5
  depends on entirely**, and it changes annually with statutory limits
- **The remittance due dates** per liability, and the cadence
- **The reconciliation set** — which tie-outs are performed monthly, quarterly and annually
- **Known recurring reconciling items** — expressed as rules: "capitalised development labour is charged to
  the software asset, so the register exceeds wage expense by that amount"
- **The third-party provider arrangement**, and **who is responsible for remitting**
- **The materiality tolerance** per reconciliation
- **Whether a payroll platform is connected**, and which figures it supplies
- The replay recipe: the exact sequence of reads that produced the GL side

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data, and never persist balances, wage figures or exceptions.**
All state, and the personal data rule is absolute.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — PAYE 2210 due 22nd monthly, NI 2211/2212 due 22nd monthly, pension 2230 due 19th, wage base:
gross less salary-sacrifice pension, no cap" — not "PAYE 2210 due 22nd". **Wage base rules and due dates are
jurisdiction-specific**, and applying one entity's to another produces false overdue flags and false base
mismatches. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One register, one GL, one set of
filings.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one `data_source_id`, every
figure carrying its entity's `display_name`. Then:

- **A shared payroll service means one register covers several entities**, and **each entity's GL holds only
  its share.** **The register-to-GL tie must be run per entity against that entity's slice** — comparing the
  whole register to one entity's GL will fail by the others' payroll.
- **Filings are per employer**, and **the employer is the legal entity.** **Reconcile filings to the entity
  that filed them**, not to the group.
- **Wage bases and caps apply per employer per employee.** An employee who moved between group entities
  mid-year **may restart a cap in the new entity** depending on jurisdiction — a real and easily missed
  effect.
- **A payment by one entity covering another's liabilities** is an intercompany balance, not a remittance
  for that entity. See `intercompany-reconciliation`.
- **Run the negative-balance and overdue checks per entity.** A group view nets them away.
- **Currency**: payroll liabilities denominated in another currency revalue between accrual and remittance —
  see `multicurrency-fx-revaluation`.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each reconciliation's verdict per
company file.

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
| `create_skill` | Persists the evolved skill. Step 8. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Every payroll expense and liability account | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Wages and employer cost expense — the Step 1 target** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `department` |
| **Liability roll-forward anchors** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Movements, ageing and manual adjustments — the central read** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Net pay disbursements and remittances, by payee** | `search_payments` / `search_checks` | `start_date`, `end_date` (required) |
| **Payroll journals and manual entries to payroll accounts** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Headcount, for scale only | `search_employees` | `query`/`name`, `active_only` |
| Legal name, country, **fiscal calendar** | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register, wage base and YTD tools appear in
**its own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no taxable wage base, no bank statement and no filing on this surface.**

---

## Plain-language glossary

- **Payroll register** — the payroll system's detailed output for a run. **One of the four sources, and the
  only one holding wage bases.**
- **Register-to-GL bridge** — the schedule explaining why the payroll system's total and the accounts'
  total differ.
- **Taxable wage base** — the amount a particular tax is actually charged on. **Not gross**, and different
  for different taxes.
- **Pre-tax deduction** — something taken from pay before a tax is calculated, reducing that tax's base.
- **Cap / ceiling** — an annual limit above which a contribution stops. **Applies per employee, which is why
  aggregate arithmetic cannot recover it.**
- **Remittance** — paying a withholding over to whoever it belongs to. **Due dates are set by the
  authority.**
- **Unremitted liability past its due date** — money withheld from employees and not passed on. **Penalties,
  interest, and in many places personal liability for directors.**
- **Negative liability balance** — the accounts say the authority owes you. **Always an error.**
- **Wage statement** — the annual summary given to each employee for their own tax return. **Must agree to
  the filings and the GL before it is issued.**
- **Off-cycle run** — a payroll outside the normal schedule: a bonus, a correction, a final payment.
- **Third-party provider** — an outsourced payroll company that pays staff and remits taxes on the
  employer's behalf. **The employer remains liable if it does not.**
- **Capitalised labour** — wages charged to an asset rather than expense, so the register legitimately
  exceeds wage expense.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Pre-tax deductions changing the wage base**: **retirement and certain benefit deductions reduce some
taxable bases but not others. Reconcile each tax's base separately; a single "gross" comparison will
mismatch.**

**Wage base caps / ceilings**: **some contributions stop once an employee hits an annual ceiling. Mid-year
and year-end, employees who crossed the cap break a naive rate × gross check. Reconcile to the capped
base.** *Mosofin note*: **caps apply per employee**, so **no aggregate figure in the GL can reproduce
them.**

**Timing across period boundaries**: **a pay date or remittance date straddling the period end creates
expected differences between accrual, GL, and bank. Identify and carry them.**

**Multiple pay runs and off-cycle payments**: **bonuses, corrections, and final pays may be separate runs.
Include all runs in the register total.** *Mosofin note*: **a payroll journal outside the usual cadence is
readable**, and it is the prompt to ask whether a run was missed from the register total.

**Third-party payroll provider**: **the provider's reports are the register; reconcile the provider's
lump-sum bank debits to net pay + taxes + fees, and confirm the provider actually remitted the taxes — the
entity remains liable even if the provider fails to remit.** **The most important sentence in this list**:
**a provider's failure to remit is the employer's problem**, and the accounts will look perfectly settled
while the liability is unpaid. **Confirming remittance is `[manual]`, from the authority.**

**Year-end wage statement reconciliation**: **the sum of employee wage statements must equal the GL wages
and the filed totals. Differences must be resolved before statements are issued to employees.**

**Capitalized labor**: **legitimately not in wage expense; ensure the register-to-GL bridge accounts for it
rather than flagging it as an error.** **[auto]** to detect — a payroll-dated debit to an asset account.

**Garnishments and third-party payables**: **confirm these were remitted to the correct third party and
cleared; stale balances indicate missed remittances.** **Report at account level.**

**Manual adjustments / journal corrections**: **prior manual entries to payroll accounts can break the
register-to-GL tie. Identify and explain them.** **[auto]**, and **usually the answer.**

**Negative or unusual liability balances**: **usually a posting error or over-remittance; investigate rather
than ignore.** **[auto]**, one query.

**Step 5 attempted without a register** — *Mosofin-specific*. **A gross-based check mismatches for every
affected employee**, and the mismatch looks like an error. **Report NOT PERFORMED.**

**"Taxable wages per the GL"** — *Mosofin-specific*. **The GL holds gross, not taxable.** Step 4's first
comparison needs the register.

**A nil difference where both sides came from the same postings** — *Mosofin-specific*. It proves arithmetic,
not agreement. **State the basis.**

**Recorded disbursements presented as bank-verified** — *Mosofin-specific*. Different assurances.

**Exceptions ordered by amount** — *Mosofin-specific*. **An overdue remittance is more urgent than a larger
timing difference.** Order by consequence.

**A group-level reconciliation** — *Mosofin-specific*. **Negative balances in one entity and positive in
another net away.** Run per entity.

**An employee who moved between group entities mid-year** — *Mosofin-specific*. **Caps may restart**, which
changes the wage base in both entities.

**A result comes back with `mock: true`** — *Mosofin-specific*. This reconciliation feeds filings and
employee wage statements.

**A stored wage base rule reused across a statutory year** — *Mosofin-specific*. **Caps and thresholds
change annually.** Store them with effective dates and re-confirm.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's due dates or wage bases to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the reconciliation as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Register ties to GL** (gross and employer cost), **with a documented bridge**
- **Net pay ties to bank disbursements**
- **Each liability rolled forward** (opening + accrued − remitted = closing) **and agreed to GL**
- **Overdue, anomalous, or negative liabilities flagged**
- **Quarter / year-end: GL, filings, and wage statements reconciled to each other**
- **Each tax reconciled to its correct taxable wage base** — pre-tax deductions, caps applied
- **Every exception classified, quantified, and assigned a correction**
- **Account references from the entity's COA**
- **File naming consistent**
- **No naive single-base comparison where multiple wage bases apply**

**Mosofin additions:**

- **No individual's payroll data appears anywhere in the output**
- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**;
  **whether a payroll platform is connected is stated**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Each of the four sources is identified as read or supplied**, and **no reconciliation is reported as
  tied against a source that was not obtained**
- **Step 5 is reported as NOT PERFORMED where the register is unavailable**, with what it would have shown
  — **never substituted by a gross-based check**
- **Manual adjustments to payroll accounts are listed separately** in the register-to-GL bridge
- **Negative liability balances are listed explicitly**, since all of them are errors
- **The overdue flag names the due date and its source**, and its consequence — penalties, interest,
  personal liability — is stated
- **The net pay tie states whether it was to recorded disbursements or to the bank statement**
- **Where a third-party provider remits, the entity's continuing liability is stated**, and confirmation of
  actual remittance is marked `[manual]`
- **Exceptions are ordered by consequence**, not by amount
- **A nil difference derived from common postings is identified as such**
- In a multi-entity run, **the register-to-GL tie runs against each entity's slice**, filings are reconciled
  per employer, negative-balance and overdue checks run per entity, and **mid-year inter-entity moves are
  flagged for cap effects**
- Every reconciliation carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source
  used, and its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no filing or wage statement rests on a mock-based
  tie**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data, balances, wage figures or exceptions are persisted** into a skill bundle;
  every persisted preference states the datasource and `display_name` it covers, **and wage base rules carry
  effective dates**
- Nothing was written back to any system — no correction posted, no liability remitted, no filing amended
