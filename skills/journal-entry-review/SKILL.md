---
name: journal-entry-review
description: "Use this skill whenever the user wants to review journal entries for risk, propriety, or anomalies from their Mosofin workspace — a control/audit lens on JEs. Triggers include: 'review the journal entries', 'JE testing', 'analyze journal entries for risk', 'find unusual journal entries', 'manual journal entry review', 'journal entry controls', 'test JEs for fraud indicators', or screening a journal entry population for items needing scrutiny. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then screens the entire entry population rather than a sample — since screening is a query — while naming the approval-workflow indicators it cannot test. Do NOT use for building entries — use journal-entry-builder. Do NOT use for full forensic investigation — use fraud-detection-and-forensics. Outputs a risk-scored journal entry review with flagged anomalies, characteristics tested, follow-up items, and a coverage sheet."
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
# Journal Entry Review (Mosofin)

Reviews a population of journal entries through a **control and audit lens** — screening for **unusual,
high-risk, or potentially improper entries** using risk characteristics, and producing a **prioritized list
for investigation**. **A core audit procedure — journal entry testing is required in financial statement
audits — and a useful internal control.**

**In plain words:** most accounting entries come from an invoice, a payment, a payroll run. A few are typed
in by hand, and those are the ones that bypass the normal checks. This looks through them for the patterns
that tend to accompany mistakes or manipulation, and puts the ones worth a closer look at the top.

It is **workspace-scoped**: the journal entry population, the account types and the pattern evidence come
from tool calls against a company file connected to your Mosofin workspace in this conversation, or from
something you supplied by hand and that is labelled as such.

**This skill identifies risk indicators and anomalies; it does not conclude fraud occurred** — that requires
investigation (`fraud-detection-and-forensics`).

## What changes: screen everything, and name what cannot be screened

**The original says: *"Don't try to review every entry — screening focuses attention on the ones that
matter."* That is right about review and no longer right about screening.**

> **Screening every entry is a query.** The population is readable, the criteria are computable, and the
> cost of applying them to 8,000 entries is the same as applying them to 80. **So screen 100% and review the
> top** — the same reasoning as `internal-audit-workpaper`, where a readable population removes sampling
> risk.
>
> **Report the population size and state that the screen was complete.** "All 4,812 entries screened; 63
> flagged; 12 high-risk reviewed" is a materially stronger sentence than any sample-based version, and it is
> what an auditor wants to hear about JE testing.

**The strongest `[auto]` area is Step 5 — patterns.** Individual flagged entries are noisy; **clusters,
recurring period-end adjustments, and reserves that move with earnings are the ones that actually mean
something**, and they need the whole population to see. **The original says patterns are often more telling
than single entries. Here they are also cheaper.**

**And the gap, stated plainly:**

> **Approval data is generally not on this surface.** **Four of the People-and-process indicators depend on
> it** — entries lacking approval, self-approved entries, one person posting and approving, and the
> segregation-of-duties failure that follows. **Where approval status is not exposed, these cannot be
> tested. Report them as NOT RUN**, name what they would have shown, and ask for the approval log from the
> system that holds it.
>
> **And where a user field does exist, a user name is not a person.** Shared logins, delegated access and
> system-generated entries all break that link — the same caveat as
> `fraud-detection-and-forensics`, `internal-audit-workpaper` and `ipo-readiness-accounting`.

**One more inherited discipline:** **this skill escalates to the fraud skill and inherits its rules.** **An
anomaly is not a finding.** Entries are posted by identifiable people; **a flagged list is a list of
questions, not of suspects**, and **nothing from it is persisted.**

**Mosofin is read-only.** It cannot correct, reverse or reclassify anything it flags.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before screening anything. This ordering is the contract. Do not
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

**An excluded entity is a scope limitation** in the audit sense — **and JE testing is a required audit
procedure**, so an entity whose entries could not be screened must be named as unscreened rather than
passed over.

**Check for a connected consolidation or reporting platform.** **Topside entries** — see the edge cases —
are frequently made above the subledgers in a separate system, and **they are the higher-risk population.**
If that system is not connected, **the topside entries are not in your population**, which is a material
limit on the review.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`.
- **Multi-entity** — ask which set. **Screen each entity separately**; see the cross-entity step.

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

Resolve **every criterion in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**Check which fields the entry read actually returns.** **The criteria you can test depend entirely on the
fields available** — posting date versus effective date, user, description, source. **Establish the field
list before designing the screen**, and record which criteria are unavailable because a field is not
exposed.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A flag is not a finding.** The whole discipline.
  - **A user name is not a person.**
  - **Absence of approval data is not absence of approval.** The control may exist and simply not be
    exposed here.
  - **A system-source label is not proof an entry was system-generated.** See the edge cases.
  - **Entries visible here are not necessarily the whole population** — topside and consolidation entries
    may live elsewhere.
- **There is no approval workflow, no supporting document and no interview on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, **fiscal calendar and period
ends** — which the timing criteria depend on — country / region.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Journal entry population~~ | **Now [auto]** | **Full population, not a sample.** Confirm the field list. |
| **Period under review** | **Required** | |
| **Chart of accounts with risk-sensitive accounts noted** | Recommended — **[gated]** | **The chart is `[auto]`; which accounts are sensitive here is `[manual]`** — though revenue, reserves, equity and suspense are readable by type. |
| **Approval / workflow data** — who approved, approval status | Recommended — **[manual]**, usually | **Generally not on this surface.** Ask for the approval log. |
| **Expected posting patterns** — normal volumes, timing, sources | Recommended — **now [auto]** | **Derivable from history**, which is better than an expectation. |
| **Materiality threshold** | Recommended — **[manual]** | Needed for magnitude screening and the below-threshold test. |
| **Known risk areas** | Recommended — **[manual]** | Focuses the review. |
| **Authorization thresholds** | **Required for the just-below test — [manual]** | The test is meaningless without them. |
| **Whether topside entries exist and where** | **Required — Mosofin addition** | They may not be in this population at all. |
| **Who may see the output** | **Required — Mosofin addition** | It names people. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm manual evidence** | **Required** | Approval data, thresholds and known risk areas are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an authorization
threshold, a materiality level, or a conclusion about an entry.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The criteria set, the scoring weights, the sensitive-account list and the cleared-pattern rules persist;
**every flagged entry is re-derived**, and **no flag is carried forward.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The approval-based criteria are legitimately unavailable
where approval data is not exposed, and they are recorded as not run rather than omitted.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the entry population, the chart and the comparative history
do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_journal_entries`* **for the period** — **the population, in full** — usually **[auto]**
- *`get_journal_entry`* on individual entries — line detail where the search result is summary — usually
  **[auto]**
- *`search_accounts`* — **the chart with account types**, which drives the account-combination criteria —
  usually **[auto]**
- *`get_general_ledger`* — **entries by account, and dormant-account detection** — usually **[auto]**
- *`search_journal_entries`* **for prior periods** — **the baseline for "normal"**, and the pattern
  population — usually **[auto]**
- *`get_profit_and_loss`* / *`get_balance_sheet`* by period — **for the reserves-move-with-earnings test** —
  usually **[auto]**
- *`get_company_info`* — legal name, **period ends** — usually **[auto]**

**Pull prior periods deliberately.** **"Unusual" is meaningless without a baseline**, and Step 5's patterns
need several periods by construction.

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that criterion to **[manual]** and **record which criteria are therefore
  not tested.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a JE review over fixtures produces fictional
anomalies attributed to real-sounding users.** Stop.

## Step 1 — Understand the JE population

**Profile the population** — **[auto]** throughout:

- **Total number and value of entries**
- **Split by source: system-generated** (automated, lower risk) **vs. manual** (higher risk — **the focus of
  most review**)
- **By account, by user, by period**
- **Normal patterns**, so anomalies stand out

**Manual journal entries are the primary focus — they bypass routine controls and are where errors and
manipulation concentrate.**

**Mosofin addition — derive "normal" rather than asking for it.** The original lists *"expected posting
patterns"* as a recommended input. **[auto]**: **read several prior periods and compute them** — entries per
period, value, the manual proportion, the usual posters, the usual accounts, the usual timing. **A baseline
measured from this entity's own history is better than an expectation someone states**, and it makes every
subsequent "unusual" judgment concrete.

**Report the profile before the flags.** A population that is 4% manual behaves differently from one that is
60% manual, and the review's emphasis should follow.

## Step 2 — Define risk characteristics

**Screen entries against characteristics associated with error or manipulation.** Each indicator carries its
verdict:

### Timing

- **Entries posted at period-end or after the close cutoff** — to hit targets — **[auto]**
- **Entries posted on weekends / holidays or outside business hours** — **[gated]**: **weekends are `[auto]`
  from the date; hours need a timestamp**, which may not be exposed
- **Back-dated entries** — posting date later than effective date — **[auto]** where both dates are
  returned. **One of the strongest single indicators available**, and it depends entirely on the field
  being present
- **Entries to prior closed periods** — **[auto]**

### Account combinations

- **Entries hitting revenue, earnings, or reserves directly** — **[auto]** from account types
- **Unusual account pairings** — revenue credited against a non-customer account; expense reclassified to a
  balance sheet account — **[auto]**: **account types make the pairing computable**
- **Entries to suspense, clearing, or rarely-used accounts** — **[auto]**
- **Entries crossing to equity or directly to retained earnings** — **[auto]**

### Amounts

- **Round-dollar or even amounts** — e.g. exactly 50,000 — **[auto]**
- **Amounts just below approval / authorization thresholds** — **[gated]**: **the test is `[auto]`, the
  threshold is `[manual]`.** Ask for it; the test is meaningless without it
- **Large / material entries** — **[gated]**; the threshold is `[manual]`
- **Entries that net to zero across suspicious accounts** — **[auto]**

### People and process

- **Entries by users who don't normally post** — e.g. senior management overriding — **[gated]**: **`[auto]`
  where a user field exists and a baseline of usual posters has been derived**; **a user name is not a
  person**
- **Entries lacking approval or self-approved** — **[manual]**. **Approval data is generally not on this
  surface. NOT RUN**
- **Entries with missing, vague, or generic descriptions** — "adjustment," "reclass," blank — **[auto]**,
  and a good one: a length-and-content test over the memo field
- **One person both posting and approving (SoD failure)** — **[manual]**. **NOT RUN** without approval data

### Other

- **Reversing entries that aren't re-posted** (or vice versa) — **[auto]**: **trace reversal pairs across
  periods**
- **Duplicate entries** — **[auto]**; see `duplicate-invoice-detection` for the matching discipline
- **Entries to seldom-used or dormant accounts** — **[auto]**: account activity frequency is readable

**Fifteen of the nineteen indicators run as queries; four depend on approval data that is generally
unavailable.** **Report the four as NOT RUN** — and note that **they are precisely the segregation-of-duties
indicators**, which is a meaningful hole in a control-focused review, not a rounding error.

## Step 3 — Score and flag entries

**Apply the characteristics to the population** — **[auto]**:

- **Flag entries meeting one or more risk criteria**
- **Assign a risk score** — more or weightier criteria = higher score
- **Prioritize the highest-risk entries for review**

**Don't try to review every entry — screening focuses attention on the ones that matter.**

**Mosofin refinement of that last sentence: screen every entry, review the top.** The screen is complete;
the review is prioritised. **State both numbers.**

**On weighting**: **a single criterion is usually noise.** A round-number accrual at period end is a
description of most accruals. **Weight combinations** — round amount *and* posted by an unusual user *and*
to a reserve account — and **say what the weighting was**, so the score is interpretable rather than
oracular.

## Step 4 — Analyze flagged entries

For each high-priority flagged entry — **[gated]**, and the split matters:

- **Examine the description and supporting documentation** — description **[auto]**, **documentation
  `[manual]`**
- **Assess business rationale** — is there a legitimate reason? — **[manual]**
- **Check approval and segregation** — **[manual]**; not on this surface
- **Verify it ties to underlying support** — **[gated]**: **where the support is another transaction in the
  system it is findable**; where it is a contract or a calculation, it is not
- **Determine whether it's: clearly legitimate, needs explanation, or genuinely anomalous** — **[manual]**
  judgment

**Three of five need a person.** **The screen finds candidates; the analysis is where they are resolved**,
and it cannot be automated away.

## Step 5 — Pattern and trend analysis

**Beyond individual entries, look for patterns** — **[auto]** throughout, and **this is the strongest area
of the skill**:

- **A user with a cluster of high-risk entries** — **[auto]**, subject to the user-name caveat
- **Recurring period-end adjustments to the same accounts** — **[auto]**, and often the most revealing:
  the same account adjusted every quarter-end by a manual entry is a process problem at minimum
- **Entries that consistently move results toward a target** — e.g. always just enough to hit a number —
  **[auto]**: **compute the pre-entry and post-entry result and look at the direction and the proximity to
  round or threshold figures**
- **Increasing manual entry volume to a sensitive account over time** — **[auto]**
- **Reserves / accruals that move suspiciously with earnings** — **[auto]**, and **the same test as in
  `fraud-detection-and-forensics`**: plot reserve movements against pre-reserve profit across periods. **A
  reserve that reliably moves in the smoothing direction is an indicator worth investigating**

**Patterns are often more telling than single entries.** **And they require the full population and several
periods** — which is exactly what the workspace makes cheap. **Lead the output with them.**

## Step 6 — Document and follow up

For each item requiring follow-up — **[gated]**:

- **The entry detail** — **[auto]**
- **Why it was flagged** — which criteria — **[auto]**
- **The explanation obtained (or outstanding)** — **[manual]**
- **Resolution: legitimate** (with rationale), **error** (correction needed), **or escalate** — potential
  impropriety → `fraud-detection-and-forensics`

**On escalation**: **the fraud skill's rules apply from the moment you escalate** — objectivity, no
accusation, evidence preservation as a separate discipline, and **no approval prompt to someone within
scope.** Read it before proceeding.

## Step 7 — Assess control implications

**The review informs control assessment** (`sox-controls-design-and-testing`) — **[gated]**:

- **Are JE approval controls operating?** — **[manual]**; **the review cannot answer this without approval
  data**, and saying so *is* the control observation
- **Is SoD enforced (post vs. approve)?** — **[manual]**; same
- **Are descriptions and support required and present?** — **descriptions `[auto]`**, support `[manual]`.
  **The proportion of entries with blank or generic descriptions is a directly measurable control
  indicator**
- **Should certain accounts / users have tighter controls?** — **[gated]**; the concentration data is
  `[auto]`, the recommendation is judgment

**The measurable control observations are worth stating numerically**: "38% of manual entries carried a
description of three words or fewer" is a control finding with a number attached, and it is more useful than
an assertion that documentation is weak.

## Step 8 — Output

Deliver an `.xlsx` review workpaper:

**Sheet 1: Population Profile** — **volume / value, manual vs. system, by account / user / period.** Add
**the derived baseline** from prior periods. Plus the header block: workspace name; the entity by
`display_name`; excluded company files; **the population size and the statement that the screen was
complete**; whether any read returned `mock` data; **and whether topside entries are in the population**.

**Sheet 2: Risk Criteria & Screening** — **the criteria applied and how many entries each flagged.** Add
**the verdict per criterion**, and **a clearly separated block for criteria NOT RUN**, with the reason.

**Sheet 3: Flagged Entries (Risk-Scored)**

| JE# | Date | Posted By | Approved By | Accounts | Amount | Criteria Met | Risk Score | Description | Status |

**Sorted by risk score.** The **Approved By** column is retained and **populated as "not available" where
approval data is not exposed** — the column's emptiness is itself information.

**Sheet 4: Detailed Review** — analysis of high-priority entries with explanation and resolution.

**Sheet 5: Patterns & Trends** — **clusters and recurring patterns identified.** **Lead with this sheet in
any summary**; it is where the workspace contributes most.

**Sheet 6: Follow-Up & Escalation** — items needing explanation, correction, or escalation.

**Sheet 7: Control Observations** — implications for JE controls, **with the measurable ones quantified**.

**Sheet 8: Criteria Not Run — NEW, Mosofin-specific**

| Criterion | Why it could not run | What it would have shown | How to obtain it |

**The four approval-based indicators, and any criterion lost to a missing field or a `disabled` tool.**
**A clean Sheet 3 alongside an empty Sheet 8 would misrepresent the coverage.**

**Sheet 9: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | Population and size | As-at date | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `JE_Review_[Period]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every flagged entry traces to a tool result in this conversation. End with a single **Data
sources** line grouping calls by datasource. Where a criterion could not run, **name it** rather than
omitting it.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **method**:

- **The criteria set** in use for this entity, and **which criteria cannot run here** and why
- **The scoring weights**, so scores are comparable between periods
- **The sensitive-account list** — which accounts count as revenue, reserves, equity, suspense here
- **The authorization and materiality thresholds**, with effective dates
- **The baseline definition** — how many prior periods, and which measures
- **The cleared-pattern rules** — expressed as rules, never as entries: "the monthly depreciation journal
  is system-generated from a schedule and is expected at period end" is a rule; **a list of specific
  entries is not**
- **The escalation path** and the authorized recipients, **by role**
- **Where topside entries live**, if outside this system
- The replay recipe: the exact sequence of reads that produced the population and the baseline

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist flagged entries, risk scores, user names, explanations or any anomaly.** **These are
observations about how identifiable people did their jobs**, most of which will turn out to be entirely
proper. **A flag carried forward outside a formal tracker, unrebutted and unclosed, becomes a permanent mark
on someone who was never told** — the same rule as `fraud-detection-and-forensics`. **Persist the method;
never the results.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — sensitive accounts 4000–4999, 2400–2450, 3200; authorization threshold 10,000 from 2025-04-01;
baseline 6 prior periods; approval criteria not testable" — not "threshold 10,000". Record the chosen
**scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged as unscreened** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One population, screened completely.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one `data_source_id`, every
entry and flag carrying its entity's `display_name`. Then:

- **Screen each entity separately, against its own baseline.** **Normal differs by entity** — a subsidiary
  with three staff has a different posting pattern from a shared service centre, and **one baseline across
  the group would flag the small entity's every entry.**
- **Sensitive accounts differ by chart.** The account-combination criteria are chart-specific; **store the
  sensitive list per entity.**
- **A user posting across several entities is worth noting** — **[gated]**, where user fields exist. It may
  be a shared finance team, which is normal, or access nobody intended.
- **Topside and consolidation entries sit above the entities**, often in a separate system. **They are the
  highest-risk population and the least visible** — see the edge cases. **If they are not in any connected
  file, say so.**
- **Intercompany entries appear in two populations**, and **a manual entry on one side with no counterpart
  on the other is both a JE-review flag and an intercompany break** — see `intercompany-reconciliation`.
- **Report flag rates per entity as well as in total.** A group rate averages away the one entity where the
  control has failed, which is the only thing the rate was going to tell you.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each criterion's verdict per
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
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The entry population, in full** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **The chart with account types — the account-combination criteria** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Entries by account, and dormant-account detection** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Prior periods — the baseline and the pattern population** | `search_journal_entries` | `start_date`, `end_date` (required) |
| **The reserves-move-with-earnings test** | `get_profit_and_loss` / `get_balance_sheet` | `start_date`, `end_date`, `summarize_column_by` |
| Legal name, **period ends** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no approval workflow, no supporting document and no interview on this surface.**

---

## Plain-language glossary

- **Journal entry testing** — examining manual entries for signs of error or manipulation. **A required
  audit procedure**, because manual entries are how controls get bypassed.
- **Manual vs. system-generated** — typed in by a person, or produced automatically by a process. **Manual
  is where the risk concentrates.**
- **Topside entry** — an adjustment made above the subledgers, usually at consolidation, often by senior
  finance. **Higher risk and less visible.**
- **Management override** — senior people bypassing the controls that bind everyone else. **The classic
  fraud risk**, precisely because they can.
- **Back-dated entry** — recorded later than the date it claims. **One of the strongest single
  indicators.**
- **Segregation of duties (SoD)** — the person who posts an entry should not be the person who approves it.
- **Suspense / clearing account** — a temporary holding place. **Entries into one deserve attention because
  they are meant to be transient.**
- **Dormant account** — one with no normal activity. **Sudden use is unusual by definition.**
- **Net-zero entry** — an entry whose total effect is nil but which moves amounts between accounts.
  **Look at the movement, not the net.**
- **Risk scoring** — combining indicators so attention goes where it is most warranted.
- **Screen vs. review** — testing everything cheaply, then examining a few things properly.
- **Reserve smoothing** — adjusting provisions so reported results move less than the underlying business.
- **Escalation** — handing an unresolved anomaly to investigation. **Not an accusation.**

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Legitimate period-end entries**: **many valid entries occur at period-end — accruals, true-ups. The flag
is a screen, not a conclusion — a period-end entry with proper support and approval is fine. Avoid crying
wolf on every routine close entry.** *Mosofin note*: **the derived baseline shows which period-end entries
are routine for this entity**, which is the cheapest way to stop crying wolf.

**Round numbers can be legitimate**: **estimates and accruals are often round. Combine with other criteria
rather than flagging all round amounts.**

**Management override risk**: **senior management posting unusual entries is a classic fraud risk — they can
override controls. Entries by executives to sensitive accounts warrant particular scrutiny.**

**Topside entries**: **consolidation and topside adjustments made above the subledgers, often by senior
finance, are higher risk and less visible. Ensure they're in the population and reviewed.** *Mosofin note*:
**they may not be in any connected file at all.** Establish where they live at Gate 1.

**Missing or weak descriptions**: **a vague description isn't proof of impropriety but impedes review and is
itself a control weakness — flag for both reasons.** *Mosofin note*: **measurable**, and worth quantifying
as a control observation.

**Volume too large to review individually**: **rely on risk-based screening; review the highest-risk subset
thoroughly rather than everything superficially.** *Mosofin note*: **the screen is no longer the
constraint** — screen everything, review the top.

**System-generated entries assumed safe**: **usually lower risk, but a manipulated automated process or a
manual entry disguised as system-generated is possible. Don't ignore the system population entirely.**
*Mosofin note*: **a source label is a field, not a fact.**

**Reversing entries**: **a reversal posted but the original never re-posted — or an accrual reversed without
the cash following — can hide or shift amounts. Trace reversal pairs.** **[auto]**, and it needs the
following period in the population.

**Entries net-zero across accounts**: **an entry that nets to zero overall but moves amounts between a
sensitive pair — reduces an expense, increases a different reserve — can mask manipulation. Look at the
account-level movement, not just the net.**

**Escalation discipline**: **an anomaly is not a finding of fraud. Document objectively and escalate to
investigation (`fraud-detection-and-forensics`) rather than accusing — preserve objectivity and avoid
prejudicing any inquiry.**

**Approval-based criteria cannot run** — *Mosofin-specific, and the material gap*. **Four indicators, and
they are the segregation-of-duties ones.** Report NOT RUN; ask for the approval log.

**A user field treated as a person** — *Mosofin-specific*. Shared logins, delegated access and system
entries all break the link.

**The screen was sampled** — *Mosofin-specific*. **Screening is a query; screen the whole population** and
say so.

**"Unusual" asserted without a baseline** — *Mosofin-specific*. **Derive normal from prior periods**; it is
one more read.

**A back-dating test run without both dates** — *Mosofin-specific*. **It depends entirely on the posting
date and effective date both being returned.** Check the field list before claiming the test ran.

**Patterns skipped in favour of individual flags** — *Mosofin-specific*. **Patterns are the strongest
evidence here and the cheapest to compute.** Lead with them.

**One baseline applied across a group** — *Mosofin-specific*. Normal differs by entity, and a shared
baseline floods the small ones with flags.

**A company file is connected but not active** — *Mosofin-specific*. **JE testing is a required audit
procedure**; an unscreened entity must be named as unscreened.

**A result comes back with `mock: true`** — *Mosofin-specific*. **Fictional anomalies attributed to
real-sounding users.** Stop.

**Flags carried forward to the next review** — *Mosofin-specific, and prohibited*. Most flagged entries are
proper. **Persist the method; never the flags.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's sensitive-account list or thresholds to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the criterion as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Population profiled** — manual vs. system, by account / user / period
- **Risk criteria clearly defined and applied across the population**
- **Entries risk-scored and prioritized** — not all-or-nothing
- **High-priority entries analyzed with rationale and resolution**
- **Patterns and clusters identified, not just individual entries**
- **Management override and topside entries specifically considered**
- **Follow-up items classified** — legitimate / error / escalate
- **Control implications noted**
- **Objective documentation; anomalies flagged, not concluded as fraud**
- **File naming consistent**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; **every excluded entity is named as unscreened**,
  since JE testing is a required procedure
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The screen covered the entire population**, with the population size stated and the completeness
  asserted explicitly
- **Every criterion carries its verdict**, and **criteria that could not run are listed in Sheet 8** with
  what they would have shown — **the four approval-based indicators named specifically**
- **The baseline was derived from prior periods**, not asserted, and "unusual" is defined against it
- **Whether topside entries are in the population is stated**
- **The scoring weights are stated**, and single-criterion flags are not presented as equivalent to
  multi-criterion ones
- **Patterns lead the summary**, including the reserves-versus-earnings test
- **Every flagged entry is presented as a question**, never as a conclusion about a person, and **the
  user-name caveat is stated wherever a user field is used**
- **Measurable control observations are quantified** — the proportion of entries with weak descriptions,
  the manual proportion, the concentration by user or account
- **Escalations follow `fraud-detection-and-forensics`** from the moment they are raised
- In a multi-entity run, **each entity is screened against its own baseline**, sensitive-account lists are
  per chart, and **flag rates are reported per entity as well as in total**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no anomaly is reported from mock data**
- Every flagged entry traces to a tool result in this conversation; the answer ends with a single **Data
  sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No flagged entries, risk scores, user names, explanations or anomalies are persisted** into a skill
  bundle — **the method is stored; the results never are**; every persisted preference states the datasource
  and `display_name` it covers
- Nothing was written back to any system — no entry corrected, reversed or reclassified
