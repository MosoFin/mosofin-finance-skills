---
name: prepaid-amortization-schedule
description: "Use this skill whenever the user wants to build, maintain, or audit a prepaid expense amortization schedule against a connected Mosofin workspace. Triggers include: 'set up a prepaid amortization schedule', 'amortize this prepaid', 'build a schedule for [insurance / SaaS / rent / etc.] paid in advance', 'monthly prepaid expense JE', 'reconcile prepaid balance to schedule', 'is my prepaid account right', 'did we miss an amortization', 'find prepaids we never set up', or any task involving period allocation of advance payments. Do NOT use for deferred revenue (the customer side of the same idea) — use revenue-recognition-asc606. Do NOT use for a full close — use month-end-close-checklist. Reads the live prepaid account and expense ledger through the Mosofin read-only gateway; proposes a schedule, the amortization entries, and a tie-out to the GL prepaid balance. Proposes only — Mosofin posts nothing."
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
# Prepaid Amortization Schedule — Mosofin Seed

Builds and maintains schedules for expenses paid in advance (money you have already handed over for something you have not yet received), amortizes them across the period of benefit, produces the monthly entry, and reconciles the running balance to the general ledger.

This is a **seed skill**. It is built to be run against a live Mosofin workspace, and it is built to be *rewritten* the first time it is run there — because the shape of a client's prepaid account is not knowable in advance.

---

## What this skill is, and what it is not

The original version of this skill was **system-agnostic** and **chart-of-accounts-agnostic**. That claim is now only half true, and it is more honest to say so plainly than to keep the sentence.

The *accounting* is still framework-neutral: straight-line allocation over a coverage period is straight-line allocation everywhere. What is no longer neutral is the **evidence**. This version reads a specific, real, connected set of books through the Mosofin gateway. It knows which accounts exist, what the prepaid balance actually is, and what has actually been posted to it. That is a large gain in usefulness and a real loss in portability. Both are stated here rather than hidden.

### The one thing to understand before anything else

**The general ledger holds the prepaid balance. It does not hold the schedule.**

This distinction runs through the whole skill, so it is worth being slow about.

The ledger can tell you that Prepaid Expenses stands at 84,000. It cannot tell you:

- what the 84,000 is *for*
- which months of coverage it buys
- when that coverage ends
- whether any of it expired eight months ago and simply never came off
- whether it is even prepaid at all, rather than a refundable deposit somebody coded there

Those facts live on **contracts, policy schedules, and invoices** — documents outside the accounting system. A balance that agrees with itself is not evidence of anything. A prepaid account will reconcile to its own trial balance every single time, because it is the same number twice.

So: **the schedule is an input, not an output of the ledger.** The workspace supplies the balance and the movement. The user supplies the coverage dates. Neither half is a schedule on its own.

### And the inverse, which is where this skill earns its keep

The ledger cannot build the schedule. But it is unusually good at telling you the schedule is **wrong or missing**, and it can do that in a handful of queries:

- A prepaid account that only ever **increases** is one where the amortization entries were never posted.
- A twelve-month insurance premium **expensed in a single month** shows up as one large lonely debit in an expense account that is otherwise flat. That is an unrecorded prepaid, and lumpiness is its signature.
- A prepaid balance that **exceeds the last twelve months of additions**, in a book where everything is annual, is carrying residue from coverage that has already expired.
- An amortization credit that is **a different amount every month, in round numbers, posted by hand** is not a schedule being run. It is somebody guessing.

None of that requires the contracts. All of it is `[auto]`. That is the trade this skill makes: it gives up on generating the schedule and becomes very good at auditing it.

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

Nothing below runs until the workspace is confirmed. Not a read, not a lookup, not a "quick check of the balance."

1. Call `list_workspaces` with no arguments.
2. If the status comes back `confirmed`, there is exactly one workspace. **Read its name back to the user and wait for an explicit yes.** Silence is not a yes. A previous message about a different task is not a yes.
3. If the status comes back `selection_required`, there are two or more. Ask, in chat: **"Is this a single-workspace task or a multi-workspace one?"** Do not guess, and do not take the first row because it is the first row.
   - Single: ask which one by name, then call `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then call `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by its **name** and, where a stable machine reference is unavoidable, by the opaque `ws_...` handle the tools hand back. There is an internal numeric id behind it. Never print it, never repeat it back, never ask the user for it. If it turns up inside an error message, name the workspace instead and move on.

**Why a prepaid task specifically needs this gate.** Prepaid schedules are among the most casually copied artifacts in accounting. The same insurance broker writes policies for four related companies; the same SaaS vendor bills three of them. A schedule built against the wrong entity looks entirely plausible — same vendors, same amounts, similar balance — and will reconcile to nothing. Confirming first costs one question.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

Then establish, **out loud with the user**, which of these you are in:

| Scenario | What it means here |
|---|---|
| **No datasource connected** | Every step below is `[manual]`. Say so immediately. Do not build a half-schedule out of what the user typed into chat and call it reconciled. |
| **Exactly one company file** | The straightforward case. Confirm the `display_name` back to the user before reading. |
| **Several company files** | Ask which one, **by `display_name`**. If the answer is "all of them," that is not one schedule — it is several, each labelled with its entity, and never merged into one column. |
| **Connected but stale or broken** | If a call returns a `reconnect_url`, the connection needs the user's attention. Stop and tell them. Do not fill the gap with assumptions. |

Refer to company files by `display_name` throughout — "Northwind Trading Ltd", not the `data_source_id`. Pass the id between tools; never show it.

**On multi-entity prepaids specifically.** Group insurance policies and group software licences are frequently paid by one entity for several. If two connected entities show prepaid balances that look related, do not net them and do not assume a recharge exists. Label every figure with the entity it came from. See `intercompany-reconciliation`, and the "paid by a related entity" edge case below.

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

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each returned tool. That field, not documentation and not this file, decides what is possible today.

| `effective_policy` | Verdict in this skill | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch it with other independent reads. |
| `permission` | `[gated]` | Calling raises `approval_required`. Explain what you want and why, get a yes, then re-invoke with `approved=true`. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | `[manual]` | Not available. The step still exists; the user performs it. Never quietly drop it. |

Every verdict in this document is a **default written before the gateway was consulted**. If Gate 2 disagrees with the label on a step, **Gate 2 wins**. A step marked `[auto]` here that comes back `permission` in this workspace is `[gated]` in this workspace, for this run, and the write-up should say so.

Read the tool names off the response. Do not type them from memory and do not infer them from an account name — an `UNKNOWN_TOOL` envelope means exactly that, and it is a signal to re-read the tool list, not to try a near-miss.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the re-invocation after an approval. Dropping it on the retry is the single most common way an approved call fails.

**Batch independent reads.** The prepaid account transaction detail, the expense ledger, the chart of accounts, and the vendor list do not depend on one another. Issue them together in one message. Serializing four reads that could have been one round trip wastes the user's time for no gain in correctness.

### The `mock: true` flag, and what it means for a prepaid schedule

If a response carries `mock: true`, you are looking at **fixture data**, not the client's books.

The consequence here is specific and worth naming, because prepaid work is the one place it is most likely to fool you: **fixture data ties out.** A synthetic prepaid account will reconcile to a synthetic schedule perfectly, on the first pass, with a zero variance, because both were generated from the same made-up assumptions. A real prepaid account almost never does. It has a stale policy from 2023, a deposit somebody miscoded, and a month where the recurring entry silently stopped.

So a clean tie-out on mock data tells you the arithmetic in this skill works. It tells you nothing whatsoever about the client. Label the output as fixture-derived, in the file name and on the first sheet, and do not let a clean variance column be read as reassurance.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` first. If the workspace already carries a client profile — the materiality threshold, the amortization convention, the prepaid account structure, whether recoverable tax is split — **use it and say you are using it.** Asking a client a question they have already answered, on a schedule they have already agreed, is how a tool stops being trusted.

Interview only for what is genuinely still open. For this skill that is a short and specific list:

1. **Which account (or accounts) is prepaid?** Read the chart first, then confirm. Many books have several: Prepaid Expenses, Prepaid Insurance, Prepaid Rent, and something called Other Current Assets that has become a drawer.
2. **The materiality threshold** — below which an item is expensed rather than scheduled. The original skill was explicit that this is the user's call. It remains the user's call. This skill applies it; it does not set it.
3. **The convention: whole-month or daily proration?** Both are defensible. Mixing them within one schedule is not.
4. **Is recoverable tax (VAT/GST) split out at payment, or is it sitting in the asset?** This is answerable from the ledger, but the *policy* is the user's to state.
5. **The coverage dates** for each open item. This is the big one, and it does not come from the ledger. See the section immediately below.

**Decisions are the user's; state is the workspace's.** The workspace can tell you the balance moved. Only the user can tell you whether a policy runs to March or to June.

---

## How to read the verdicts

Every task below is tagged. This is the point of the conversion, so the tags are used strictly and never omitted to make a step look better than it is.

- **`[auto]`** — Mosofin can do this from live reads, unattended, with no further permission.
- **`[gated]`** — Mosofin can do this, but the gateway will ask first. Expect `approval_required`; explain, get consent, re-invoke with `approved=true` and the `data_source_id`.
- **`[manual]`** — Mosofin cannot do this at all. The evidence is not on this surface, or the judgment is not a machine's to make. The step is still here, still required, and the user performs it.

A step with three sub-parts may carry three different verdicts. That is normal and is shown rather than averaged into one.

**Everything this skill produces is a proposal.** Mosofin's gateway is read-only. It reads books; it does not write to them. Every entry below is drafted for a human to review and post in the accounting system themselves. Nothing in this skill posts anything. If a sentence anywhere seems to say otherwise, this sentence is the one that is right.

---

## Inputs

| Input | Format | Required | Mosofin source | Verdict |
|-------|--------|----------|----------------|---------|
| List of prepaid items | Vendor, description, amount, payment date, coverage period | **Required** | Amount, vendor and payment date are readable from the prepaid account's transaction detail and the bill/payment records. **The coverage period is not.** | `[auto]` in part, `[manual]` for coverage dates |
| Currency per item | ISO code | **Required if multi-currency** | On the transaction record | `[auto]` |
| Functional currency | ISO code | **Required** | Company/preferences record | `[auto]` |
| Chart of accounts | For prepaid asset and expense accounts | **Required** | Live read of the account list | `[auto]` |
| Tax jurisdiction | For tax handling on the original invoice | Recommended | Tax codes on the bills are readable; the *jurisdiction rules* are not | `[auto]` for the codes, `[manual]` for the treatment |
| Materiality threshold | Below which an item is expensed directly | Recommended | Not in the books. A policy decision. | `[manual]` (Gate 3) |
| Amortization frequency | Monthly (most common), quarterly | Optional | Inferable from the posting pattern; confirm rather than assume | `[auto]` to observe, `[manual]` to set |

For each prepaid item the original skill requires eight fields. They are all kept, with their source stated:

| Field | Mosofin source | Verdict |
|---|---|---|
| Vendor name | Bill / payment record | `[auto]` |
| Description / what was paid for | Memo and line description — **as good as whoever typed it** | `[auto]` to read, `[manual]` to trust |
| Invoice / contract reference | Document number on the transaction | `[auto]` |
| Original payment amount (gross if tax-inclusive, net otherwise) | Transaction amount | `[auto]` |
| Recoverable tax, kept separate from the prepaid asset | Tax lines on the bill | `[auto]` |
| Payment date (cash outflow) | Payment / bill payment date | `[auto]` |
| Coverage period start | **Not in the ledger** | `[manual]` |
| Coverage period end | **Not in the ledger** | `[manual]` |

### A near-substitute is not a substitute

Six of the eight fields come out of the books cleanly. The two that do not are the two that make it a schedule.

It is very tempting to treat the **invoice memo** as the coverage period. Resist it. "Annual policy renewal" does not say *which* twelve months. "Q3 licence" does not say whose quarter. "Insurance — 12 mo" is closer, and still does not tell you whether coverage started on the invoice date, the payment date, or the first of the following month — and the original skill is emphatic that this distinction is exactly the one that matters (Step 3).

Equally tempting: treating the **payment date plus twelve months** as the coverage period. It is right often enough to be dangerous. When it is wrong it is wrong by weeks, in the same direction, every year, and it produces a schedule that never quite ties and nobody can explain.

Where the coverage dates are unknown, say **unknown**. Put the item on the schedule with the dates blank and a flag. An honest gap is a work item. A guessed date is a silent misstatement that will be inherited by next year's schedule and the year after.

---

## Workflow

### Step 0 — Read the shape of the prepaid account before touching anything else

*(A Mosofin addition. There is no equivalent step in the original, because the original had no ledger to look at.)*

Before building or checking any schedule, pull the prepaid account's full transaction detail for at least twenty-four months, along with the account list. This is one batched read and it decides how the rest of the run goes.

**Test 0a — Does the account ever come down?** `[auto]`

Sum debits and credits to the prepaid account by month.

- Debits every month, credits never → **amortization has not been posted at all.** The balance is a growing pile of expired coverage. This is a material finding on its own and you have made it in one query.
- Debits and credits both present, but credits absent in some months → **a missed amortization run.** Name the months. The recurring entry probably stopped and nobody noticed, which is the ordinary way this fails.
- Credits present every month → good. Move to 0b.

**Test 0b — What do the credits look like?** `[auto]`

Read the amortization credits themselves.

- Identical to the cent, every month → a straight-line schedule is being run consistently. Good sign.
- Varying by a few units → daily proration, or a schedule with items starting and ending mid-stream. Normal.
- **Round numbers, differing month to month, entered by hand** → this is not a schedule being run. It is an estimate being posted. Say so. The whole point of the workpaper this skill produces is to replace that.

**Test 0c — Does anything odd live in this account?** `[auto]`

Scan the debits for entries that do not look like prepayments at all:

- Round-sum amounts to landlords or utilities → likely **refundable deposits**, which are not prepaid (see Step 1).
- Large single amounts to equipment vendors → likely **fixed assets** miscoded (see `fixed-asset-register-and-depreciation`).
- Entries with an FX or revaluation source → see the foreign-currency edge case; a prepaid asset is **non-monetary** and generally should not be revalued.
- Entries from a journal source with no vendor → these need explaining before they go on any schedule.

**Test 0d — Is the balance bigger than the last twelve months of additions?** `[auto]`

If everything in this book is annual (and Step 1's candidate list will tell you whether it is), the prepaid balance should never much exceed one year of prepayments. If it does, there is **residue from coverage that has already expired** sitting in the asset. You cannot say which items without the schedule. You can say, with confidence and with figures, that some exists.

These four tests take one round trip and, on a neglected set of books, will often be the most valuable thing this skill produces all day.

---

### Step 1 — Identify prepaid candidates

The original list is preserved in full, with the workspace read that finds each one.

**Common prepaid items** — and how they surface in a live ledger:

| Item | Signature in the books | Verdict |
|---|---|---|
| Insurance premiums paid annually | One large debit to an insurance expense account, once a year, from a broker or carrier | `[auto]` |
| SaaS / software annual contracts | Annual charge from a software vendor; frequently the same month each year | `[auto]` |
| Maintenance contracts | Annual or multi-year charge from an equipment or facilities vendor | `[auto]` |
| Rent paid in advance | Payment to a landlord dated *before* the period it covers, or a thirteenth payment in a twelve-month year | `[auto]` |
| Property tax paid in advance | Charge from a municipal authority, usually annual or semi-annual | `[auto]` |
| Annual subscriptions, memberships | Professional bodies, trade associations, licences | `[auto]` |
| Professional retainers covering future services | Payment to a law or advisory firm with no matching engagement activity | `[auto]` to find, `[manual]` to judge |
| Deposits that are expensed over time | Requires reading the agreement | `[manual]` |
| Marketing pre-buys (annual ad spend committed upfront) | One large media charge, then flat | `[auto]` |

**The general query behind all nine rows** `[auto]`: read the expense ledger for the period and rank accounts by *lumpiness* — the ratio of the largest single charge to the account's monthly average. A twelve-month premium expensed in one hit produces a ratio near twelve. A genuinely monthly expense produces a ratio near one.

**This is the highest-yield `[auto]` in the skill.** The original Step 1 is a memory exercise: the accountant tries to remember what was paid in advance. On live books it is a ranked list, and the top of that list is almost always right.

**Items that are NOT prepaid** — the original's four confusions, kept, each with the test:

| Not prepaid | Correct home | How to tell | Verdict |
|---|---|---|---|
| Refundable deposits | Asset: Deposits | The money comes back at the end; nothing is consumed. Round sums, landlords and utilities. | `[auto]` to flag, `[manual]` to confirm from the agreement |
| Equipment purchases | Fixed Asset, depreciated | A thing exists afterwards. See `fixed-asset-register-and-depreciation`. | `[auto]` to flag |
| Inventory purchases | Inventory, expensed as COGS on sale | Goods for resale. See `inventory-costing-fifo-lifo-wavg`. | `[auto]` to flag |
| Investments in financial instruments | Separate accounting entirely | Broker or fund counterparty | `[auto]` to flag |

Flagging is automatic. **Deciding** is not — a deposit that will be applied to the final month's rent behaves like a prepaid; one that comes back in cash does not. Only the agreement says which, and the agreement is not on this surface.

---

### Step 2 — Apply materiality

`[manual]` for the threshold, `[auto]` for everything downstream of it.

The original is explicit and correct: *the threshold is the user's decision; this skill applies it.* That does not change here. Mosofin does not set materiality.

What Mosofin adds is the ability to show the user **what their threshold actually does** before they commit to it, which is not something the original could offer:

- `[auto]`: list the candidate prepaids that fall below the stated threshold, with a count and a total.
- `[auto]`: compute the aggregate P&L effect of expensing all of them directly in the month of payment, rather than spreading them.
- `[auto]`: show that effect month by month across the year, so the user can see whether the lumpiness it introduces is tolerable.

A threshold that looks harmless per item can be material in aggregate when there are forty small annual subscriptions. That is a real finding, it is arithmetic, and it is one read.

Above threshold → schedule it. Below → expense directly, if that is the policy. Either way, **record the threshold used on the coverage sheet**, so next period's run does not silently apply a different one.

---

### Step 3 — Determine the amortization period

`[manual]` at its core. This is the step the ledger cannot do, and the honest thing is to lead with that rather than bury it.

The original's rules are preserved exactly:

- **The coverage period is the basis.** A twelve-month insurance policy amortizes over twelve months.
- **Amortization is effective from the start of coverage, not the payment date**, and the two frequently differ.
- **If service starts mid-period** — payment on 15 June for service running 1 July to 30 June — **amortization starts 1 July.** Not June.
- **If service ends mid-period**, amortization ends on the end date and the final period takes a partial.
- **For irregular coverage** (an annual subscription whose use is tied to events), amortize ratably over the contract term **unless the consumption pattern materially differs.**

Each of these needs a date that exists on a contract, not in a ledger. So:

**What the workspace can contribute here** `[auto]`:

- The **payment date** exactly. This is the anchor, and it is the thing most often mistaken for the start of coverage. Show it next to the coverage start so the difference is visible rather than assumed.
- The **invoice date and document reference**, which is what the user will use to find the contract.
- **Prior-year behaviour.** If the same vendor was prepaid last year and the year before, the pattern of payment dates tells you the renewal cycle. That does not establish the coverage period — but it will often tell you when to expect it, and it will flag a renewal that has moved.
- **Whether a renewal has been missed.** A vendor prepaid every March for three years with nothing this March is either a cancelled contract or an unbooked one. Both are worth raising.

**What it cannot contribute:** the dates themselves. Ask for them, one item at a time, and leave them blank with a flag where the answer is not available. Do not derive them from the payment date. See "a near-substitute is not a substitute" above — this is the case that section was written for.

---

### Step 4 — Compute monthly amortization

`[auto]`, once Step 3 has supplied the dates. This is arithmetic and the arithmetic is not in dispute.

Default method: **straight-line over the coverage period.**

```
Monthly amortization = Total prepaid amount / Total months of coverage
```

For partial months at the start or end:

```
Partial month amortization = (Monthly amortization x Days in partial month) / Days in full month
```

Or, more simply, prorate on calendar days throughout:

```
Daily amortization = Total prepaid amount / Total days of coverage
Period amortization = Daily amortization x Days in that period
```

**Pick one method per item and apply it consistently. Document which.** The original says this and it is preserved because it is where schedules go wrong quietly: a book that whole-months some items and day-prorates others will never reconcile cleanly, and nobody will be able to say why.

`[auto]` addition: **observe which convention the existing entries already follow.** Step 0b has already told you whether the historic credits are flat or varying. If the client has been whole-monthing and the new schedule day-prorates, the change will show up as a small unexplained variance in the tie-out. Better to notice that before it appears in Sheet 3 than after.

For items with **materially uneven benefit patterns** — a marketing campaign with concentrated launch spending — amortize on benefit consumed if it is measurable; otherwise straight-line. Measuring benefit consumed is `[manual]`; the ledger records what was paid, not what was used.

---

### Step 5 — Build the schedule

`[auto]` for the construction and the checks; `[manual]` for the inputs it is built from.

For each prepaid item:

| Period | Period Start | Period End | Opening Balance | Period Amortization | Closing Balance |
|--------|--------------|------------|-----------------|---------------------|-----------------|

All three of the original's verifications are kept, and all three are `[auto]`:

- Sum of all period amortizations = total prepaid amount
- Closing balance after the last period = 0
- Opening balance minus period amortization equals closing balance, on every row

**These verify the schedule against itself.** They are worth running — they catch rounding drift and a mis-keyed month count — but be clear about what they prove. A schedule that satisfies all three is *internally consistent*. It is not thereby *correct*. If the coverage end date is wrong, every row above will still tick, and the schedule will still be wrong. Internal consistency is a floor, not a result. Step 8 is where the schedule meets something outside itself.

`[auto]` addition — **rounding**: force the final period to absorb the rounding difference rather than letting it accumulate. A twelve-way split of an amount that does not divide by twelve leaves a residue, and a residue left in the closing balance means the account never quite clears. Put it in the last month and say you have.

---

### Step 6 — Initial booking, at payment

`[auto]` to draft and to check; `[manual]` to post — as with every entry in this skill.

When the prepayment is made:

```
DR  Prepaid Expense (BS asset, per user's COA)         $net amount
DR  Input Tax Recoverable (if jurisdiction allows)     $tax
    CR  Cash / Bank or AP                                $gross
Memo: Prepayment to [vendor] for [service] covering [start - end]
```

The memo line matters more here than almost anywhere else in accounting, because it is the **only place the coverage period will ever be recorded inside the accounting system.** Everything this skill has said about coverage dates not being in the ledger is true only because people leave this memo blank. Write it properly and next year's run gets easier.

**If the entire amount was already expensed in error, reverse the expense to set up the prepaid asset.** `[auto]` to detect — this is precisely what Step 1's lumpiness scan finds — and `[auto]` to draft the correcting entry. Posting remains the user's.

**Tax, and a real finding available here** `[auto]`:

In a jurisdiction with recoverable VAT/GST, the tax should come out at payment and be recovered in full then — **not amortized over the coverage period**. The original states this in its edge cases and it is worth pulling forward, because the ledger will tell you whether it happened.

Read the prepaid debits against the gross invoice amounts on the corresponding bills. **If the prepaid additions equal the gross figures in a jurisdiction that allows recovery, recoverable tax is sitting inside the asset and is being amortized into expense.** That is a cash-flow error and a P&L error at once, it recurs every year, and it is one comparison to find. Raise it with the figures.

---

### Step 7 — The monthly amortization entry

`[auto]` to compute and draft. `[manual]` to post, and `[manual]` to automate — this second one needs stating clearly rather than glossed.

Per item:

```
DR  Expense account (per user's COA)                   $period amortization
    CR  Prepaid Expense                                    $period amortization
Memo: Amortize prepaid [vendor / description] - [period]
```

Aggregated by expense account, which is what most books actually want:

```
DR  Insurance Expense                          $sum of insurance amortizations
DR  Software Subscriptions Expense             $sum of SaaS amortizations
DR  Rent Expense                               $sum of rent amortizations
DR  ...                                        $other categories
    CR  Prepaid Expense                          $total period amortization
Memo: Monthly prepaid amortization - [period]
```

Hand the drafted entry to `journal-entry-builder` for formatting and validation.

**On the recurring entry.** The original says: *Recurring JE: hand off to `recurring-transaction-builder`.* That handoff is preserved and the cross-reference stands — but be honest about the boundary. **Mosofin cannot create a recurring transaction.** The gateway is read-only; it does not write to the accounting system, and a recurring template is a write. So:

- Drafting the entry, with the right accounts and the right amounts, from the schedule: `[auto]`
- Setting it up as a recurring template in the accounting system: `[manual]`, performed by the user
- **Checking, next period, that it actually ran:** `[auto]` — and this one is worth having. Test 0a already does it. Recurring entries stop. They stop when an account is renamed, when a template expires, when someone deactivates it during a clean-up. The failure is silent, and a monthly read catches it in the month it happens rather than at year end.

That last bullet is the genuine division of labour here: the user automates the posting, and Mosofin audits the automation.

---

### Step 8 — Roll-forward and tie-out

**This is the step where the workspace contributes most, and it is worth being precise about which legs are automatic.**

The original's roll-forward, preserved:

```
Opening prepaid balance (GL)                       $X
+ New prepayments booked during the period         $Y
- Amortization during the period                   $Z
+/- FX revaluation (multi-currency)                $A
+/- Cancellations / refunds                        $B
= Closing prepaid balance                          $X + Y - Z + A + B
```

Line by line, with verdicts:

| Line | Source | Verdict |
|---|---|---|
| Opening prepaid balance (GL) | Live read of the account at the prior period end | `[auto]` |
| New prepayments booked during the period | Debits to the prepaid account, with vendor and reference | `[auto]` |
| Amortization during the period | Credits to the prepaid account | `[auto]` |
| FX revaluation | Revaluation-source entries hitting the account — **and their presence is itself a finding**, see below | `[auto]` |
| Cancellations / refunds | Credits with a cash or AR counterparty rather than an expense one | `[auto]` |
| Closing prepaid balance | Live read at period end | `[auto]` |

**The entire roll-forward is `[auto]`.** Every component is a live read, and each line ties to identifiable transactions rather than to a summary figure. That is a substantial improvement on the original, where the roll-forward was assembled by hand from whatever the accountant could find.

The original then requires **three-way agreement**:

1. **GL closing prepaid balance** — `[auto]`, live read
2. **The roll-forward result** — `[auto]`, computed from the components above
3. **Sum of remaining prepaid balances on the schedule** — `[manual]` in origin, because the schedule came from outside

Two of the three legs are automatic. **The third is the one that matters.** Legs 1 and 2 will agree with each other whenever the arithmetic is right, because they are two views of the same ledger — that agreement proves the accounting system adds up, which was never in doubt. **Only leg 3 tests whether the balance is right**, because only the schedule carries information the ledger does not have: what the balance is for and when it ends.

This is the same trap as the balance sheet that always balances (see `financial-statement-builder`). Do not let a green variance column between legs 1 and 2 be reported as a reconciliation. Report the variance against the **schedule**, and if there is no schedule, say there is no reconciliation — only a roll-forward.

**If it does not agree, investigate.** `[auto]` for the investigation, and this is where the transaction-level detail pays off:

- Variance equal to one month's amortization → a missed run. Test 0a names the month.
- Variance equal to a whole item's remaining balance → an item on the schedule that was never booked, or booked to a different account.
- Variance equal to a gross-versus-net difference → recoverable tax in the asset. See Step 6.
- Variance that is small and stubborn → convention drift. Whole-month against day-prorated. See Step 4.
- Variance with no pattern → look for the journal-source entries Test 0c flagged.

Naming the *shape* of the variance before hunting for it turns a reconciliation from a search into a lookup.

---

### Step 9 — Cancellations and changes

`[auto]` to detect, `[auto]` to compute, `[manual]` to decide, `[manual]` to post.

If a prepaid item is cancelled mid-period — an insurance policy cancelled with a partial refund:

- Compute the unamortized balance at the cancellation date — `[auto]` from the schedule
- Compare it to the refund received — `[auto]`, the refund is in the books
- The difference is an expense (if the refund is less) or income (if it exceeds, which is rare)

```
DR  Cash / AR for refund                           $refund
DR  Expense account (if refund < unamortized)      $diff
    CR  Prepaid Expense                              $unamortized balance
    CR  Other Income (if refund > unamortized)       $diff
Memo: Cancel prepaid [item] - refund [date]
```

**The `[auto]` worth having here: cash arriving from a vendor you prepaid.** A deposit or credit memo from a vendor with an open prepaid balance is either a cancellation or a rebate, and either way it needs to hit the schedule. Read receipts and vendor credits against the vendors on the prepaid schedule. Money coming *back* from a supplier is unusual enough to be worth flagging every time, and it is one query.

**If the contract is modified — extended, for example — update the schedule with the new end date and recompute the monthly amortization from the modification date forward.** `[manual]` to learn of the modification, `[auto]` to recompute. Prospective, from the modification date. Do not restate the months already amortized; a modification is a change in the arrangement, not a correction of the past.

---

### Step 10 — Output

Deliver an `.xlsx` workpaper. The original's five sheets are kept in order, with two Mosofin additions.

**Sheet 1: Prepaid Schedule Master**
| Item ID | Vendor | Description | Payment Date | Total Amount | Currency | Coverage Start | Coverage End | Months | Monthly Amort | Expense Account |

Add a **Source** column: `ledger` for fields read live, `user` for coverage dates supplied in the interview, `unknown` for the flagged gaps from Step 3. A reader should never have to guess which figures came from the books and which came from a conversation.

**Sheet 2: Period Detail**
For each item, the monthly amortization across the coverage period.

**Sheet 3: GL Tie-Out**
| Period | Opening GL Balance | Additions | Amortizations | Cancellations | FX | Closing GL Balance | Schedule Sum | Variance |

Every column except **Schedule Sum** is `[auto]`. Mark the header so that is visible. And repeat the Step 8 caution on the sheet itself: the variance that matters is against the schedule, not between two readings of the ledger.

**Sheet 4: Monthly JE**
The current period's aggregate amortization entry, formatted for handoff to `journal-entry-builder`. Marked, unambiguously, **PROPOSED — NOT POSTED**.

**Sheet 5: Cancellations / Modifications Log**
| Item | Original Schedule | Change | New Schedule | Impact |

**Sheet 6: Ledger Findings** *(Mosofin addition)*
The output of Step 0 and the Step 1 lumpiness scan — everything the books said without being asked:

| Finding | Evidence | Amount | Periods affected | Recommended action |
|---|---|---|---|---|

Missed amortization months. Prepaid candidates never set up. Non-prepaid items sitting in the account. Recoverable tax inside the asset. FX revaluation of a non-monetary asset. Balance exceeding twelve months of additions.

On a neglected set of books this sheet is frequently the reason the engagement was worth running, and it exists only because there is a live ledger to read.

**Sheet 7: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet. Its contents are set out in full below.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

File naming: `Prepaid_Schedule_[YYYY-MM].xlsx`

Where more than one entity is in scope, the entity `display_name` goes in the file name **and** in a column on every sheet. Never one file with two companies silently interleaved. If the data is fixture data (`mock: true`), say so in the file name and on Sheet 1.

---

## Edge Cases

All thirteen of the original's edge cases are preserved, in order, each with the workspace read that bears on it.

**Annual contracts with monthly billing** (NOT a prepaid): if the vendor invoices monthly, it is an ordinary expense each month and no prepaid setup is needed. The distinction: prepaid means paid **more than one period in advance**. `[auto]` — the billing frequency is directly visible in the vendor's transaction history, and this is the cheapest false positive to eliminate from Step 1's candidate list. A vendor with twelve invoices a year is not a prepaid, whatever the contract says.

**Prepayment for a variable amount** (a minimum commitment with usage-based overages): amortize the fixed portion; expense the overages when incurred. `[auto]` to see the pattern — a fixed annual charge with irregular top-ups is a recognisable shape in the ledger. `[manual]` to split it, because only the contract says which part is the commitment.

**Multi-year prepayments**: amortize over the full term even if it spans years. **Split between the current portion (next twelve months) and the non-current portion (beyond twelve months) on the balance sheet.** `[auto]` for the split once coverage dates exist — it is arithmetic. `[auto]` for a related check: if the chart has no non-current prepaid account at all, and multi-year items exist, the classification is wrong on the face of the balance sheet. Say so.

**Mid-contract price increase**: typically the original amount continues amortizing on its existing schedule; the increase is a **new prepaid item from its effective date**. `[auto]` to detect — a second charge from a vendor already on the schedule, mid-term, is exactly this. Do not blend it into the original item; a blended schedule cannot be unwound later.

**Item paid in installments rather than fully upfront**: each installment is its own prepaid with its own coverage period, if applicable. Or the entire contract value is set up as prepaid with an offsetting payable for the unpaid installments. `[auto]` to detect the installment pattern; `[manual]` to choose between the two treatments, and **apply the choice consistently** — a book that does both will not reconcile.

**Foreign-currency prepaid items**: a prepaid asset is **non-monetary** — typically **not revalued for FX after initial recognition**. Some entities elect otherwise; confirm the policy. `[auto]` and important: **look for revaluation-source entries hitting the prepaid account.** If they are there and the policy is non-revaluation, an FX process is reaching an account it should not touch, and it will do so again next month. This is a one-query finding of a recurring error. See `multicurrency-fx-revaluation` and `foreign-currency-translation-asc830`.

**Tax-inclusive prepayments** (VAT/GST jurisdictions): set up the prepaid **net** of recoverable tax; recover the tax **in full at payment**, not amortized across the coverage period. `[auto]` to test, as set out in Step 6 — compare the prepaid debits to the gross bill amounts. This is one of the most reliably detectable errors in the whole skill.

**Prepayments to related parties**: check substance. If it is effectively a loan, it does not belong in prepaid. If it is a genuine advance for services, it does. `[auto]` to flag — a prepayment to a name that also appears in the customer list, or to a connected entity's `display_name`, is worth a second look. `[manual]` to judge, because substance is not a field. See `intercompany-reconciliation` and `related-party-transactions`.

**Prepaid items that become impaired** (the vendor fails, the service will not be delivered): write down the unamortized balance. `[manual]` to learn of it — vendor insolvency is not in the ledger. `[auto]` for one weak signal: a vendor with an open prepaid balance and no transaction activity for an unusually long stretch is worth asking about. Weak, but free.

**Initial direct costs of obtaining a lease**: formerly parked in prepaid; under ASC 842 / IFRS 16 they are **included in the ROU asset**. `[auto]` to flag lease-related items sitting in prepaid; `[manual]` to reclassify. See `lease-accounting-asc842-ifrs16`.

**Subscriptions that auto-renew without an explicit invoice**: the schedule rolls into the new period automatically; make sure the new period's invoice is captured. `[auto]` and genuinely useful — **compare the vendors on the schedule to the vendors with recent charges.** A schedule item whose coverage has ended with no renewal charge in the books is either a cancelled service or an uncaptured invoice, and both need an answer.

**Prepayment paid by a related entity on behalf of this entity**: due-from / intercompany handling. The prepaid is real, offset by an intercompany payable. `[auto]` where both entities are connected to the workspace — read both sides in one batch and check they agree. **If only one side is connected, this cannot be reconciled**, and a single-sided figure should be labelled as such rather than presented as agreed. See `intercompany-reconciliation`.

**Mid-year change in policy or amortization method**: a change in **estimate**, applied **prospectively**. Document it. `[auto]` to detect — Step 0b's convention read will show the point where the credit pattern changed. `[manual]` to document the reason, because the reason is not in the books.

---

## Output Quality Standards

The original's nine standards are preserved, each with the verdict that says who is responsible for meeting it.

- **Every prepaid item has full coverage dates, amount, and expense account.** `[auto]` for amount and account; `[manual]` for coverage dates. Where a date is unknown, it is **flagged as unknown, never inferred from the payment date.**
- **Monthly amortization x months = total prepaid (verified).** `[auto]`
- **Schedule sum reconciles to the GL balance every period.** `[auto]` for the GL side; `[manual]` for the schedule side. **Both legs must be present for this standard to be met** — a roll-forward that ties to itself does not satisfy it.
- **Cancellations and modifications logged with impact.** `[auto]` to detect and compute; `[manual]` to approve.
- **FX handling per policy.** `[auto]` to test that practice matches the stated policy; `[manual]` to state the policy.
- **Materiality threshold applied.** `[manual]` to set, `[auto]` to apply, and **recorded on the coverage sheet** so the next run uses the same one.
- **File naming consistent.** `[auto]`
- **Recurring JE handled via `recurring-transaction-builder` when appropriate.** `[manual]` to create — Mosofin cannot write. `[auto]` to verify it ran.
- **No unallocated prepaid at the end of the schedule's last period.** `[auto]` against the schedule; and `[auto]` against the ledger too, which is the stronger test — Step 0d asks whether the account is carrying expired coverage, and that question does not need the schedule to be asked.

**Two Mosofin additions:**

- **Every figure is attributed.** Ledger-read, user-supplied, or unknown. No mixing without labels.
- **Nothing is presented as posted.** Every entry in the pack is a proposal for a human to review and post. The gateway is read-only and the workpaper says so on the sheet that carries the entries.

---

## Coverage and Provenance sheet (mandatory)

Sheet 7 of every output. Not optional, not abbreviated when the run went well.

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`)
- Date and time of the reads
- Period covered by the schedule
- **Fixture flag** — was any response `mock: true`? If yes, in bold, with the caution from Gate 2 restated: a clean tie-out on fixture data proves the arithmetic and nothing else.

**Section B — Capability map as observed today**
For each tool this run needed: its name as returned by `get_datasource_tools`, its `effective_policy`, and the resulting verdict. Where an observed policy differed from the default in this file, note it — that difference is exactly what the evolved version of the skill should absorb.

**Section C — Steps by verdict**
Every step above, with its verdict **as it actually applied in this workspace**, not as defaulted here. Count them. A reader should be able to see at a glance how much of this run was automatic.

**Section D — What was not done, and why**
The `[manual]` list, with reasons. For this skill it will typically include:

- Coverage start and end dates for the items where they were unavailable — **not in the accounting system; from contracts and policy schedules**
- The materiality threshold, if the user did not state one
- The substance judgment on any deposit or related-party advance
- Impairment assessment for any vendor in difficulty
- Creation of the recurring template — **read-only gateway; the user posts and automates**
- Posting of every proposed entry

**Section E — Unknowns carried forward**
Items on the schedule with blank coverage dates. Prepaid candidates identified in Step 1 but not yet confirmed. Variances in Step 8 that were quantified but not explained. These are the opening work list for next period, and writing them down is the difference between a schedule that improves each month and one that is rebuilt from nothing each year.

**Section F — Parameters used**
Materiality threshold. Amortization convention (whole-month or daily). Prepaid accounts in scope. Tax treatment applied. Rounding convention. Anyone re-running this next period needs these to get the same answer, and "the same answer" is most of what a schedule is for.

---

## Seed to evolved: what happens on the first real run

This file is a **seed**. It was written without seeing the client's books, so every verdict in it is a prediction. The first real run against a live workspace replaces predictions with observations, and the skill should be rewritten to hold them.

**What must never be frozen into a seed:** a snapshot of which tools existed, or what their policies were, on the day it was written. Capabilities change. Policies get tightened after an incident and loosened after a review. A seed that hardcodes today's capability map is wrong the first time anything changes, and worse, it is wrong *silently* — it will keep reporting `[auto]` for something that has been disabled for a month. **Gate 2 exists so that the capability map is read fresh on every run.** Do not replace it with a list.

**What is worth writing into the evolved version, after the first run:**

1. **Which accounts are the prepaid accounts in this book.** Read from the chart at Gate 3 the first time, confirmed with the user, then recorded. Saves a question every month thereafter.
2. **This client's amortization convention**, and the fact that it was agreed rather than assumed.
3. **The materiality threshold**, with the date it was set and by whom.
4. **The recurring items and their renewal months.** After a year of running this, the pattern of "insurance in March, licences in July, property tax in October" is established, and next year's Step 1 becomes a check rather than a search.
5. **The coverage dates that were established by interview.** They cost the user real effort to produce. Losing them and asking again next year is the fastest way to make this skill unwelcome.
6. **The errors found and fixed**, so the same tests run first next period. If recoverable tax was in the asset once, check it every time.
7. **Any observed policy that differed from this file's default**, so the next run's expectations are calibrated.

Persist that through `create_skill`, scoped to the workspace it came from. **Client-specific facts belong in a client-scoped skill, never back in the seed** — the seed is what gets handed to the next engagement, and it must not arrive carrying the last client's account numbers.

**The evolved version should be shorter in its interview and longer in its findings.** That is the direction of travel: fewer questions each month, because the answers accumulate; more tests each month, because the known failure modes accumulate too.

---

## Anti-patterns

Specific to this skill, and each one has been seen.

- **Reporting the roll-forward as a reconciliation.** Legs 1 and 2 of Step 8 agree because they are the same ledger read twice. Only the schedule tests the balance. A tie-out with no schedule column is a roll-forward with a green cell.
- **Deriving coverage dates from the payment date.** Right often enough to be dangerous, wrong by weeks when it is wrong, and wrong in the same direction every year.
- **Reading the coverage period out of the invoice memo.** "Annual renewal" is not twelve identified months.
- **Mixing whole-month and day-prorated items in one schedule** and then hunting for the small variance it creates.
- **Amortizing recoverable tax.** It comes out at payment. Step 6 tests for it; run the test.
- **Letting an FX process revalue the prepaid asset.** It is non-monetary. If revaluation entries are hitting the account, that is a finding, not a rounding difference.
- **Treating the prepaid account as a drawer.** Deposits, fixed assets and inventory get coded there. Step 0c looks; look.
- **Presenting a fixture tie-out as a clean result.** `mock: true` data reconciles perfectly and means nothing.
- **Assuming the recurring entry ran.** It stops silently. Test 0a is one query and finds the month it stopped.
- **Merging two entities' prepaids into one schedule** because the same broker wrote both policies.
- **Claiming this skill is still system-agnostic.** It reads a specific connected ledger. The accounting is portable; the evidence is not. Say which is which.
- **Saying "posted" anywhere.** Nothing here is posted. The gateway reads.

---

## Related skills

| Skill | Relationship |
|---|---|
| `revenue-recognition-asc606` | The mirror image — deferred revenue is the customer-side version of the same timing idea. Use that skill, not this one, for money received in advance. |
| `month-end-close-checklist` | The parent process. Prepaid amortization is one line on it; run this skill for that line, not for the whole close. |
| `journal-entry-builder` | Formats and validates the proposed entries from Steps 6, 7 and 9. |
| `recurring-transaction-builder` | Where the monthly entry gets automated — by the user, in the accounting system. Mosofin drafts it and later verifies it ran. |
| `lease-accounting-asc842-ifrs16` | Initial direct costs and prepaid rent both migrate here under the current standards. |
| `multicurrency-fx-revaluation` | Prepaid is non-monetary and should generally be left alone by revaluation. Cross-check when FX entries appear in the account. |
| `fixed-asset-register-and-depreciation` | Where miscoded equipment purchases belong. Step 0c flags them. |
| `intercompany-reconciliation` | For prepayments made by one connected entity on behalf of another. |
| `bank-reconciliation` | Confirms the cash side of the original prepayment and of any refund. |
| `financial-statement-builder` | The current / non-current split for multi-year prepaids lands on the balance sheet there. |
| `notes-to-financial-statements` | Significant prepaid balances and their composition, where disclosure is required. |
