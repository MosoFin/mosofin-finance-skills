---
name: recurring-transaction-builder
description: "Use this skill whenever the user wants to design, schedule, or validate recurring transactions against a connected Mosofin workspace — recurring journal entries, recurring bills, recurring invoices, or subscription billing schedules. Triggers include: 'set up a recurring JE for...', 'create a recurring bill schedule', 'generate the next 12 months of recurring entries', 'automate this monthly entry', 'subscription invoice template', 'did our recurring entry run', 'what should we be automating', or uploading a list of recurring items to build templates for. Do NOT use for one-off entries — use journal-entry-builder. Do NOT use for prepaid amortization specifically — use prepaid-amortization-schedule. Produces a validated recurring schedule with every future occurrence computed, checked against the live chart of accounts, and ready for a human to load. Mosofin does not create templates, does not post, and does not schedule anything."
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
# Recurring Transaction Builder — Mosofin Seed

Builds recurring transaction schedules — journal entries, bills or invoices that repeat on a defined cadence — and generates the full set of future-dated occurrences.

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## Read this before anything else

The original describes its output as occurrences "**ready to post**", to be "**batch-loaded, reviewed, or auto-posted by the accounting system.**"

**Mosofin cannot do the last part of that sentence. The gateway is read-only.** It cannot create a recurring template, cannot post an entry, cannot schedule anything, and cannot cause a payment or an invoice to happen at a future date. There is no write path and there is not going to be one in this skill.

That is a blunt statement and it needs to come first, because this is the one skill in the pack whose *stated purpose* is to make something happen inside an accounting system. Every other skill produces analysis, and analysis is what a read-only surface is for. This one produces automation, and automation is a write.

So the honest position is:

> **Mosofin designs and validates the schedule. A human creates the template in the accounting system. Mosofin then audits whether it actually ran.**

That division is not a consolation prize. Each of the three parts is real work, and the third one — auditing whether the automation ran — is a job nobody currently does, and it is the reason recurring entries fail silently for months. `prepaid-amortization-schedule` already relies on this skill for exactly that, and the two are consistent: Mosofin drafts the entry, the user automates it, Mosofin checks it every period thereafter.

### The three things this skill actually does

**1. Computation, which never needed the accounting system.**

Generating occurrence dates, rolling a 31st into a 30-day month, applying an escalation at an anniversary, substituting `{month}` into a memo — **none of this touches a ledger.** It is arithmetic and calendar logic. It was always automatable and the gateway is irrelevant to it.

This gives the skill an unusual verdict profile. In most skills, `[auto]` means "readable from the ledger." Here, a large block of `[auto]` means "computable from what the user told us." Both are genuinely automatic; they just have different failure modes, and the coverage sheet distinguishes them.

**2. Validation against the live ledger, which is new.**

The original builds a schedule against accounts, vendors and tax codes that the user names. **It has no way to check that any of them exist.** A connected workspace does, and this turns out to matter more than it sounds — see Step 2b. A recurring template pointed at an account that was renamed last quarter will fail, or post to suspense, **every month, forever, quietly.**

**3. Discovery and audit, which are the inverse of the original's job.**

The original waits to be told what to automate. A live ledger can be asked **what is already being done by hand every month that should not be** — and separately, **whether the templates that do exist are still running.** Both are one query. Neither was available before.

### A near-substitute is not a substitute

**A schedule is not a template.** A spreadsheet of twenty-four future-dated rows is a *plan*. The thing that makes a payment happen is an object inside the accounting system with a next-run date on it. Handing someone a well-formatted schedule and letting them come away believing automation now exists is this skill's characteristic failure — and it is a quiet one, discovered in month two when nothing happened.

**"Ready to post" is not "posted."** Every occurrence carries a status, and the status starts at Pending.

**The ledger's history of a charge is not the contract behind it.** Fourteen months of identical rent tells you what was paid. It does not tell you the lease has a step-up in month fifteen. Extrapolating a schedule from posting history is a hypothesis about the future, and it must be checked against the agreement. See `lease-accounting-asc842-ifrs16`.

### And one risk that is specific to producing a loadable file

Because Mosofin cannot load the occurrences, the user does — and a file containing twenty-four future-dated rent bills is a file that can be loaded **twice**. Duplicate-posting a year of rent is an expensive, embarrassing, and entirely preventable error.

So the Status column the original already includes is not decorative. It is the control. Every occurrence starts **Pending**, the file states in its header that nothing in it has been posted, and the schedule is designed to be reconciled back to the ledger after loading rather than trusted. Step 6 sets this out.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

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

## Gate 0 — Confirm the workspace before anything else

1. Call `list_workspaces` with no arguments.
2. If the status is `confirmed`, there is one workspace. **Read its name back and wait for an explicit yes.**
3. If the status is `selection_required`, ask: **"Is this a single-workspace task or a multi-workspace one?"**
   - Single: ask which one by name, then `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. Never print the internal numeric id, never ask for it, and if it appears in an error, name the workspace instead.

**Why this gate matters here.** The deliverable is a set of transactions someone will load into an accounting system. **A schedule validated against one company's chart of accounts and loaded into another's** produces postings to whatever those account codes happen to mean in the second book — which is a mess that recurs monthly until somebody notices. The chart is entity-specific; so is the validation. Confirm which entity before validating anything.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The **computation** still works in full — dates, escalations, memos, calendar rolls. **The validation does not.** No account check, no duplicate check, no discovery, no run audit. Say precisely that: the schedule is arithmetically sound and has been checked against nothing. |
| **Exactly one company file** | Confirm the `display_name` before reading. |
| **Several company files** | Ask which, **by `display_name`** — the schedule is validated against one chart and is not portable to another. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. The computation can proceed; **say clearly that it is unvalidated**, because an unvalidated schedule looks identical to a validated one. |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

**The no-datasource case deserves emphasis**, because it is the one where this skill degrades most invisibly. The output file looks exactly the same either way. Put the validation status in the header of Sheet 1, not in a footnote.

---

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Map what you can actually do

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

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each tool.

| `effective_policy` | Verdict | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch with other independent reads. |
| `permission` | `[gated]` | Expect `approval_required`. Explain what and why, get a yes, re-invoke with `approved=true`. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | `[manual]` | Not available. The step remains; the user performs it. |

Every verdict below is a **default written before the gateway was consulted.** Where Gate 2 disagrees, **Gate 2 wins** for this run. Do not carry a capability map between runs.

**A note that matters specifically here.** If a tool that creates or posts transactions appears in the listing, **it is out of scope for this skill regardless of its `effective_policy`.** Policy says what the gateway permits; this skill's scope says what it does. This skill reads, computes, and hands the result to a person. That is not a limitation being worked around — for an object that will fire every month without further review, it is the correct place to put a human.

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** The chart of accounts, the vendor list, the customer list, the tax codes and the recurring-charge history are all independent. One message.

### The `mock: true` flag

Fixture data will **validate cleanly**, because the fixture chart contains whatever the fixture transactions reference. Every account check, vendor check and tax-code check passes by construction — which is precisely the set of checks this skill adds.

So a clean validation on `mock: true` data means the validation logic ran, and nothing more. Label it in the file name and in Sheet 1's header, in the same place the validation status goes.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Two items in this skill's interview are **standing client facts that should never be asked twice**, and both are ones the original is right to insist on and right to refuse to default:

- **The holiday calendar.** Jurisdiction-specific, stable, and **not in the accounting system.**
- **The roll policy** — forward or backward — applied consistently.

If the profile has them, use them and say so. If not, ask once and persist them.

Interview for the rest of the schedule's parameters as set out in the Inputs table. **Decisions are the user's; state is the workspace's.**

---

## How to read the verdicts

This skill uses three, with one distinction worth drawing:

- **`[auto]`** — Mosofin does this unattended. **Two sub-kinds**, and Sheet 5 distinguishes them:
  - **`[auto: computed]`** — pure calculation from what the user supplied. Needs no ledger. Works even with no datasource connected.
  - **`[auto: read]`** — requires a live read of the workspace. Unavailable without a connection.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` and the `data_source_id`.
- **`[manual]`** — not on this surface, or not a machine's to do. **The step stays. The user performs it.**

**Nothing here is posted, created or scheduled.** Every occurrence is a proposal for a human to load.

---

## Inputs

All twelve preserved.

| Input | Format | Required | Mosofin source | Verdict |
|-------|--------|----------|----------------|---------|
| Transaction type | Recurring JE / Bill / Invoice / Subscription | **Required** | Not in the books | `[manual]` |
| Counterparty | Vendor or customer name | Required for AP/AR | **Verifiable** against the vendor and customer lists | `[manual]` to state, `[auto: read]` to verify |
| Amount and currency | Per occurrence | **Required** | Not in the books for a *new* schedule; **readable for an existing charge** | `[manual]`, or `[auto: read]` for discovery |
| Start date | First occurrence | **Required** | Not in the books | `[manual]` |
| End date or number of occurrences | One of the two | **Required** | Not in the books | `[manual]` |
| Cadence | Daily / Weekly / Bi-weekly / Semi-monthly / Monthly / Quarterly / Semi-annually / Annually / Custom | **Required** | Not in the books; **inferable from posting history** for an existing charge | `[manual]`, `[auto: read]` to infer |
| Day-of-period rule | First day / Last day / Specific day / Last business day / N business days into period | **Required** | Not in the books | `[manual]` |
| GL account(s) and posting template | From the user's COA | **Required for JEs** | **Verifiable against the live chart** — see Step 2b | `[manual]` to specify, `[auto: read]` to verify |
| Tax code | Per the user's jurisdiction and tax setup | Required if tax applies | **Verifiable** against the configured tax codes | `[manual]` to specify, `[auto: read]` to verify |
| Description / memo template | Text with variables `{month}`, `{year}` | Recommended | Not in the books | `[manual]` to supply, `[auto: computed]` to resolve |
| Escalation rule | Fixed / Annual % / CPI-linked / Step-up at date | Optional | **Not in the books — it is in the contract.** See Step 4. | `[manual]` |
| Stop / pause conditions | Termination clauses | Optional | In the contract | `[manual]` |

---

## Workflow

### Step 1 — Identify the recurring transaction type

`[manual]`. All four preserved.

| Type | Use case | Note |
|------|----------|------|
| **Recurring JE** | Depreciation, prepaid amortisation, accrual reversals, allocations | The template comes from `journal-entry-builder`. See also `prepaid-amortization-schedule` and `fixed-asset-register-and-depreciation`, both of which generate exactly this shape. |
| **Recurring Bill** | Monthly rent, SaaS subscriptions, vendor retainers | The duplicate check in Step 2c matters most here — a duplicated recurring bill is a duplicated payment. |
| **Recurring Invoice** | Subscription billing, retainer billing, lease income | A duplicated recurring invoice is a customer billed twice, which is worse commercially than it is financially. |
| **Subscription Schedule** | Customer-facing SaaS or service subscription with billing cycles | Carries service-period dates; see Step 5 and `revenue-recognition-asc606`. |

---

### Step 2 — Validate the schedule

The original's four confirmations, all preserved, all `[auto: computed]`:

- **Start date is reasonable** — not in the distant past unless deliberately backfilling
- **End date or count is specified.** **Open-ended recurrences require management approval — flag if the user wants one truly indefinite.** Preserved with emphasis: an unbounded recurring payment is a standing instruction with no review date, and those are how subscriptions outlive the thing they paid for.
- **Cadence is one of the supported intervals**
- **Day-of-period rule is unambiguous** — "1st of month" or "last business day", not "monthly"

> **For business-day-aware schedules, identify the holiday calendar to use (the entity's jurisdiction). If not provided, ask. Do not pick a default.**

Preserved exactly, and it is the same discipline `r-and-d-tax-credit` applies to tax rates: **do not supply a value that varies by jurisdiction and changes over time.** A holiday calendar is not in the accounting system either — it is a client fact, so ask once and persist it (Gate 3).

---

### Step 2b — Validate against the live chart *(Mosofin addition)*

`[auto: read]`. One batched read, and it catches a class of failure the original cannot see at all.

The original builds a schedule around accounts, counterparties and tax codes that the **user names**. It has no way to check any of them are real. A connected workspace does:

| Check | Why it matters |
|---|---|
| **Every GL account in the template exists** | A recurring JE pointed at a deleted account fails on every run, or posts to suspense. **Every month. Silently.** |
| **Every account is active**, not archived or made inactive | Same failure, and harder to spot, because the account still appears in old reports. |
| **Every account is of the right type** — an expense line pointing at a balance sheet account, or a debit template pointing at an income account | Catches transposed account numbers, which look plausible and post cleanly to the wrong place. |
| **The counterparty exists** in the vendor or customer list, spelled as given | A near-miss creates a *second* vendor record. Then the payments split across two, the statement never reconciles, and nobody knows why. See `vendor-statement-reconciliation`. |
| **The tax code exists** and is active | A missing tax code either blocks the load or posts the transaction untaxed. |
| **The account is not one the client has flagged as closed to posting** | Some charts mark control accounts as no-post; a template aimed at one will fail. |

**Why this check earns its place.** Validating a one-off entry saves one correction. **Validating a recurring template saves a monthly error that compounds until someone happens to look.** The whole point of automation is that nobody looks — which is exactly why the thing being automated has to be right before it starts.

---

### Step 2c — Check whether it already exists *(Mosofin addition)*

`[auto: read]`, and this is the check most likely to prevent real money going out of the door.

**Before building a schedule, read the ledger for what is already recurring.** For the counterparty in question, look at the trailing twelve to twenty-four months:

- Is there **already a charge of this amount, from this counterparty, on this cadence**? If so, a recurring template may already exist and this schedule would duplicate it.
- Is there a **similar but not identical** charge — same vendor, similar amount, similar timing? That is either the same arrangement with an escalation already applied, or a second arrangement. Ask which.
- Does the vendor have **two records** with similar names? Then some of the history is under one and some under the other, and the duplicate check needs both.

**A duplicated recurring bill is a duplicated payment, repeated monthly, to a real supplier who will not necessarily mention it.** A duplicated recurring invoice is a customer billed twice, which costs less and damages more. Both are prevented by one read before the schedule is built rather than a reconciliation six months after.

---

### Step 2d — Find what should be recurring but is not *(Mosofin addition)*

`[auto: read]`. The inverse of the skill's usual job, and it changes what the skill is for.

The original waits to be told what to automate. **Ask the ledger instead.** Scan the trailing twelve months for the signature of a manually repeated transaction:

- the **same counterparty**
- a **near-identical amount**
- a **regular interval** — monthly, quarterly
- **entered by hand**, one at a time, every period

That pattern is an automation candidate, and the list is usually longer than anyone expects. It is also self-prioritising: rank by frequency times effort, and the top of the list is where the client's month-end time is actually going.

**Two cautions on the output.**

**Do not present the list as a plan.** Some of those charges *should* be entered by hand — a variable amount that only looks stable, a payment that genuinely warrants a look each month, a vendor under review. Repetition is not the same as suitability for automation, and the person who has been keying it every month may have a reason.

**And an amount that has been identical for fourteen months may not stay identical.** See the near-substitute note above: the posting history is not the contract. Check the agreement before automating a figure into the future.

---

### Step 3 — Generate the occurrences

`[auto: computed]`, in full. This needs no ledger and works with no datasource connected.

One row per future occurrence, with all six fields preserved:

- **Occurrence number** (1, 2, 3, …)
- **Scheduled date**
- **Amount**, with the escalation rule applied
- **Period covered** — for accruals and subscriptions
- **Memo**, with variables resolved: `{month}`, `{year}`, `{quarter}` substituted
- **All other fields from the template**

**Calendar edge cases**, all three preserved and all `[auto: computed]`:

- **Monthly on the 31st**: roll to the last day of months with fewer than 31 days. Note that this is a **roll**, not a skip — February gets an occurrence on the 28th or 29th, not no occurrence at all. Skipping short months is a real bug and it silently drops one or two occurrences a year.
- **Semi-monthly** — the 15th and the last day, say: handle month-end shifts.
- **Weekday-only rules**: roll to the nearest prior or next business day **per policy** — the policy from Gate 3, applied consistently in one direction throughout. Never forward in one month and backward in the next; that produces a schedule nobody can predict and a reconciliation nobody can complete.

`[auto: read]` addition — **a sanity check against the ledger's own history.** Where the same charge has been posted before, compare the generated dates against the dates it has actually landed on historically. A schedule that says the 1st while the charge has consistently hit on the 3rd is either a roll policy that does not match reality or a template that was going to be wrong. Cheap to check, and it is checking the design against observed behaviour rather than against itself.

---

### Step 4 — Apply escalation

`[auto: computed]` for the arithmetic. `[manual]` for the rule, always.

All four preserved:

- **Fixed**: the same amount every occurrence.
- **Annual % increase**: bump the amount at each anniversary. Be explicit about which anniversary — the contract date or the calendar year — and about whether the increase compounds.
- **CPI / index-linked**: **ask the user for the index source and the inflation assumption. Do not assume a rate.**
- **Step-up at date**: change the amount on specified dates.

> **Document the escalation logic in each row's memo.**

Preserved, and it is what makes a schedule auditable a year later: the row itself says why its amount differs from the row above it.

**The CPI rule deserves the same emphasis as the holiday calendar**, and for the same reason. An inflation assumption is a forecast that varies by jurisdiction, by index, and by month. **Nothing in this file supplies one and nothing persisted from a prior run may supply one either** — persist the *index source* the client uses, never the *rate*. This is the identical discipline `r-and-d-tax-credit` applies to tax rates, and `quarter-end-close` applies to covenant definitions.

`[auto: read]` supporting observation: where the charge has history, **whether escalations have actually been applied in the past, and when.** A rent that has not moved in four years, under a lease with an annual review, is either a review that was never applied or a lease whose terms differ from what is being assumed. Both are worth raising before building three more years on the assumption.

---

### Step 5 — Construct the underlying transaction template

`[auto: computed]` to construct. **`[manual]` to create in the accounting system** — that is a write, and there is no write path.

All four preserved:

**Recurring JE** — hand off to `journal-entry-builder`. The same template for every occurrence, with date and memo variables substituted. Validated against the live chart at Step 2b.

**Recurring Bill** (vendor) — a bill record per occurrence: vendor, invoice date, due date, line items, GL coding, tax code. Vendor and tax code verified at Step 2b.

**Recurring Invoice** (customer) — an invoice record per occurrence: customer, invoice date, due date, line items, revenue account, tax code.

**Subscription Schedule** — **include the service period dates on each occurrence.** The original notes why and it is worth restating: **the service period, not the invoice date, drives deferred revenue.** A subscription invoiced annually in advance produces eleven months of deferred revenue on day one, and a schedule that omits the period dates cannot support that. See `revenue-recognition-asc606`.

**And the handoff, stated plainly.** What Mosofin produces is a **specification**: every field, validated, with every occurrence computed. What creates the recurrence is a person entering that specification into the accounting system's own recurring-transaction feature, or loading the occurrences as a batch.

**The specification is not the thing.** Say so on the file. See Step 6.

---

### Step 5b — Audit whether the template actually ran *(Mosofin addition)*

`[auto: read]`, and this is the part of the skill that pays off every month rather than once.

**Recurring entries stop.** They stop when an account is renamed, when a template hits its end date, when someone deactivates it during a clean-up, when a vendor record is merged. **The failure is silent** — nothing errors, an entry simply does not appear — and it is typically discovered at a year end, eight months late, by which point eight months of close files are wrong.

So, for every recurring arrangement known to the workspace:

- **Did an occurrence post in each expected period?** List the periods where none did.
- **Was the amount what the schedule expected?** A changed amount is either an escalation that was applied without updating the schedule, or a manual override.
- **Did it post to the expected accounts?**
- **For accrual-type recurrences: did the reversal post?** See Sheet 4 below — this one is worth its own paragraph.

`prepaid-amortization-schedule` relies on exactly this check for its Test 0a, and the two skills should give the same answer. **This is the ongoing job**: the user sets the automation up once; Mosofin confirms it is still running, every period, at the cost of one query.

---

### Step 6 — Output

An `.xlsx` workpaper. All four of the original's sheets, plus two additions.

**Sheet 1: Schedule Summary**
- Type, counterparty, start, end, cadence
- Total occurrences, total amount, total tax
- Escalation rule
- Posting cadence
- Stop conditions

**Mosofin additions to the header of this sheet**, and they belong at the top where they cannot be missed:

- **NOT POSTED — every occurrence in this file is Pending.**
- **Validation status**: validated against `[company display_name]`'s chart on `[date]`, or **NOT VALIDATED** where no datasource was connected.
- **Fixture flag**, if any read returned `mock: true`.

**Sheet 2: Occurrence Schedule**
| # | Scheduled Date | Period From | Period To | Amount | Tax | Total | Memo | Status (Pending / Posted / Skipped) |

**The Status column is the control against double-loading**, not a formality. Every row starts **Pending**. After the batch is loaded, it is reconciled back against the ledger and the statuses are updated from what actually posted — not from what was intended.

**Sheet 3: Per-Occurrence JE / Bill / Invoice Detail**
Each occurrence expanded with full posting lines, formatted for the target system. Add a **Validated** column per line, carrying the Step 2b result for that account or code.

**Sheet 4: Reversal Schedule** (accruals only)
Where the recurring JE is an accrual, the corresponding reversing entries on the first day of each following period.

**`[auto: read]` addition, and it is a strong one: check that prior reversals actually posted.** An accrual that was raised and never reversed is **counted twice** — once in the accrual and once when the real invoice arrives — and it persists until somebody analyses the account. Reading accrual entries against their expected reversals is one query and it finds a genuinely material error. See `journal-entry-review` and `month-end-close-checklist`.

**Sheet 5: Validation and Discovery** *(Mosofin addition)*
Three blocks, all `[auto: read]`:

- **Validation results** from Step 2b — every account, counterparty and tax code, with pass or fail
- **Duplicate check** from Step 2c — existing recurring charges matching this one
- **Automation candidates** from Step 2d — manually repeated transactions, ranked, **presented as candidates and not as a plan**

**Sheet 6: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet, including the `[auto: computed]` versus `[auto: read]` split.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

File naming: `[Counterparty or Description]_RecurringSchedule_[YYYY-MM-DD].xlsx`

The entity `display_name` goes in the file name and on every sheet — a schedule is validated against one chart and must not be loaded into another book.

---

## Edge Cases

All ten preserved, in order.

**Mid-period start**: the first occurrence may be a partial period — a monthly subscription starting on the 10th. **Pro-rate on days, or per the contract terms — ask the user which.** `[auto: computed]` once told; `[manual]` to decide. Do not default: day-prorating and charging a full first period are both common, and they differ by real money on the first invoice a customer ever sees.

**Mid-period termination**: the final occurrence may be partial. Pro-rate similarly. `[auto: computed]`, `[manual]` to decide.

**Cadence change mid-schedule**: **build as two sub-schedules.** `[auto: computed]`. Two clean schedules are auditable; one schedule with a hidden rule change is not.

**Currency change or revaluation**: each occurrence is in the contract currency; FX is handled separately at posting time via `multicurrency-fx-revaluation`. `[auto: computed]` to hold the currency; `[manual]` for the FX treatment. **Do not convert occurrences into the functional currency in this schedule** — that bakes in a rate that will be wrong by the time the transaction posts.

**Vendor or customer is also a related party**: flag for elimination consideration via `consolidation-and-eliminations`. **`[auto: read]` to detect** where the counterparty's name matches another connected company file's `display_name`, or appears in both the customer and vendor lists. `[manual]` to conclude. See `intercompany-reconciliation` and `related-party-disclosures-asc850`.

**Schedule with both a fixed and a variable component** — base rent plus CAM (common area maintenance) service charges that vary: **build the fixed schedule and flag the variable as requiring per-period actual amounts.** `[auto: computed]` for the fixed part. **Do not average the variable part into the fixed schedule.** An averaged estimate posted automatically every month is an accrual nobody decided to make, and it will drift.

**Customer subscription with a mid-term upgrade or downgrade**: **treat as a new schedule from the change date; the old schedule terminates.** `[auto: computed]`. Same reasoning as the cadence change — two schedules, not one with an invisible seam.

**Tax rate change during the schedule period**: if the user knows about it, build with the new rate from its effective date. If not, **flag for review at each rate change.** `[manual]` — and this is a third instance of the same rule: **rates change, so nothing here supplies one.** `[auto: read]` for the supporting fact: which tax codes the book currently has configured.

**Holidays and weekend rolls**: if the cadence falls on a non-business day and the policy is to roll, **apply it consistently — always forward or always backward, per policy.** `[auto: computed]` given the calendar; `[manual]` for the calendar itself, which is not in the accounting system.

**Open-ended ("until cancelled") subscriptions**: **build for a finite horizon — 12 or 24 months — and flag for renewal review at the end.** `[auto: computed]`. This is the right answer and worth defending: a finite horizon with a review date is a control. An indefinite schedule is a standing instruction that nobody will ever revisit, and Step 2's flag exists for the same reason.

---

## Output Quality Standards

All six preserved.

- **Every occurrence has a date, amount, memo and period covered.** `[auto: computed]`
- **Total amount = occurrences × amount + escalations (verified).** `[auto: computed]`
- **No silent assumption about holiday calendars, indexes or cadences.** `[manual]` inputs, asked for once and persisted. **This is the original's own version of "never hardcode," and it governs this file too.**
- **Memos are unique per occurrence**, with variables substituted. `[auto: computed]`
- **File naming consistent.** `[auto: computed]`
- **Reversal schedules included for accrual-type recurrences.** `[auto: computed]` to build; **`[auto: read]` to verify prior reversals actually posted.**

**Four Mosofin additions:**

- **Nothing is presented as posted, created or scheduled.** Every occurrence is Pending and the file says so in its header.
- **Every account, counterparty and tax code is validated against the live chart** — or the file states that it was not.
- **The duplicate check runs before the schedule is built**, not after it is loaded.
- **Computed and read are distinguished** throughout, so a reader can tell which parts of the output survived contact with the client's actual books.

---

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`) — **the chart this schedule was validated against**
- Date and time of the reads
- **Validation status**, in bold: validated, or **NOT VALIDATED**
- **Posting status**, in bold: **nothing in this file has been posted**
- **Fixture flag** — any `mock: true`? Note that validation passes by construction on fixture data.

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict. Note divergences from this file's defaults.

**Section C — Steps by verdict, with the computed/read split**
Every step, marked `[auto: computed]`, `[auto: read]`, `[gated]` or `[manual]`. **A reader should be able to see at a glance which parts of this output would have been identical with no workspace connected at all** — because that is exactly the question "was this validated?" is asking.

**Section D — What was not done, and why**
For this skill, always including:

- **Creating the recurring template in the accounting system.** **The gateway is read-only. A human does this.**
- **Posting any occurrence.**
- The holiday calendar, where not supplied — **not in the accounting system**
- The CPI index and inflation assumption — **a forecast, and jurisdiction-specific**
- Escalation terms — **in the contract, not the ledger**
- Stop and pause conditions — **in the contract**
- The pro-ration decision on partial first and last periods
- Whether an automation candidate from Step 2d *should* be automated

**Section E — Unknowns carried forward**
Validation failures not yet resolved. Possible duplicates awaiting confirmation. Automation candidates not yet reviewed. Recurring templates that did not run in a period. Accruals with no matching reversal.

**Section F — Parameters used**
Cadence, day-of-period rule, roll direction, holiday calendar, escalation rule and index, pro-ration convention, horizon for open-ended schedules. **Anyone re-running this needs every one of them to reproduce the same schedule** — and a schedule that cannot be reproduced cannot be reconciled.

---

## Seed to evolved: what happens on the first real run

**What must never be frozen into a seed:** the capability map, read fresh at Gate 2 — and, in this skill's own domain, **any rate**: no inflation assumption, no tax rate, no holiday calendar baked into the file.

**What is worth persisting after the first run:**

1. **The holiday calendar and the roll policy.** Standing client facts, asked once, used forever.
2. **The CPI index source** the client uses — never the rate.
3. **The chart mapping**: which accounts these recurring entries hit, validated, so Step 2b starts from a known-good set.
4. **The register of recurring arrangements** — what exists, its cadence, its expected amount, its accounts. **This is the file that makes Step 5b's run-audit possible**, and without it there is nothing to audit against.
5. **The pro-ration convention** and the open-ended horizon the client prefers.
6. **Automation candidates already reviewed and declined**, with the reason. Re-proposing the same automation every quarter, after the client has explained why it is entered by hand, is how a tool becomes irritating.
7. **Escalation terms once obtained**, since they come from contracts and are expensive to gather.
8. **Any observed policy that differed from this file's defaults.**

Persist through `create_skill`, scoped to the workspace. **Client facts belong in a client-scoped skill, never back in the seed.**

**The evolved version's most valuable output is not a new schedule. It is the monthly answer to "did everything that should have run, run?"** — which is a report the client currently gets from nobody.

---

## Anti-patterns

- **Implying that automation now exists** because a schedule was produced. The schedule is a specification; the template is a thing inside the accounting system, created by a person.
- **Saying "ready to post" without saying "not posted."** Every occurrence is Pending.
- **Delivering a loadable file with no double-load control.** Twenty-four rent bills loaded twice is real money.
- **Building a schedule without checking whether the recurrence already exists.** One read prevents a duplicated monthly payment.
- **Validating nothing and looking exactly as if you had.** Put the validation status in the header.
- **Pointing a template at an account nobody checked exists.** It will fail every month, quietly.
- **Creating a second vendor record** through a near-miss on the name.
- **Assuming a rate** — inflation, tax, or otherwise. The original forbids it; so does this file.
- **Defaulting a holiday calendar.** Ask.
- **Rolling forward one month and backward the next.**
- **Skipping February** on a monthly-on-the-31st schedule instead of rolling it.
- **Averaging a variable component into a fixed schedule.** That is an undecided accrual that will drift.
- **Converting occurrences to functional currency** at today's rate. The rate at posting will be different.
- **Extrapolating a schedule from posting history without reading the contract.** Fourteen identical months do not rule out a step-up in month fifteen.
- **Presenting automation candidates as a plan.** Some things are keyed by hand on purpose.
- **Saying "posted", "created" or "scheduled".** The gateway reads.

---

## Related skills

| Skill | Relationship |
|---|---|
| `journal-entry-builder` | Formats and validates the JE template that every recurring JE occurrence instantiates. |
| `prepaid-amortization-schedule` | Generates exactly this shape of recurring entry — and relies on Step 5b to confirm it kept running. |
| `fixed-asset-register-and-depreciation` | The other large source of recurring journal entries. |
| `journal-entry-review` | The reversal check in Sheet 4, and unreversed accruals generally. |
| `month-end-close-checklist` | Where a recurring entry that failed to run shows up as a missing close task. |
| `revenue-recognition-asc606` | Why subscription occurrences must carry service-period dates, not just invoice dates. |
| `multicurrency-fx-revaluation` | FX at posting time; occurrences stay in contract currency. |
| `consolidation-and-eliminations` | Where a recurring transaction with a related party needs eliminating. |
| `related-party-disclosures-asc850` | The disclosure side of the same detection. |
| `vendor-statement-reconciliation` | What happens when a near-miss name creates a second vendor record. |
| `lease-accounting-asc842-ifrs16` | Recurring rent — where the escalation terms actually live. |
| `real-estate-and-property-accounting` | Recurring rental income on the lessor side, and its straight-lining. |
