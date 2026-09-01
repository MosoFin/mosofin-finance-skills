---
name: bank-reconciliation
description: "Use this skill whenever the user needs to reconcile a bank account (cash GL) to bank statements for a period, working from their Mosofin workspace. Triggers include: bank recon, reconcile bank, cash reconciliation, bank statement tie-out, unreconciled items, outstanding checks, deposits in transit, or investigating recon differences. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds the complete book side from live ledger data and prepares the bridge — while stating plainly that the bank statement is outside any accounting datasource and must be supplied before a reconciliation can actually be completed. Produces a recon output, variance explanations, a clean list of required journal entries or corrective actions, and a coverage sheet."
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
# Bank Reconciliation (Mosofin)

Reconciles the cash balance per the **general ledger (GL)** to the **bank statement** balance for
a specified period, explains timing differences, and identifies errors requiring correction.

**In plain words:** your books say you have one amount of cash; the bank says another. Usually
both are right — cheques you wrote haven't been cashed yet, money you banked hasn't landed yet,
and the bank has charged fees you didn't know about. **Reconciling** is proving that the two
figures differ *only* for reasons you can name. Anything left over is an error, and finding it is
the point.

This skill supports single or multiple bank accounts.

It is **workspace-scoped**: every ledger balance, payment and deposit comes from a tool call
against a company file connected to your Mosofin workspace in this conversation, or from
something you supplied by hand and that is labelled as such.

## The defining limitation — read this before promising a reconciliation

A bank reconciliation has two sides. **Mosofin can read one of them.**

Mosofin connects the **accounting system**. It reads the GL cash balance, every payment, every
deposit and every transfer recorded in the books. It **cannot read a bank statement, a bank feed,
or a downloaded transaction file**, and no accounting datasource exposes one.

> **Without a bank statement, a bank reconciliation cannot be performed.** Not partially, not
> approximately. Comparing the books to the books is not a reconciliation — it is a total
> agreeing with itself. Never label such an output a bank reconciliation, and never report a
> cash balance as "reconciled" on that basis.

**What this skill genuinely does from a connected workspace, and it is worth doing:**

- Builds **the entire book side** of the bridge from live data — the GL ending balance and every
  transaction behind it.
- Produces the **candidate lists**: payments recorded but plausibly not yet cleared (potential
  outstanding cheques), deposits recorded near period end (potential deposits in transit).
- **Detects book-side errors without the statement** — duplicate entries, wrong-account postings,
  wrong dates, and transactions after the cutoff.
- **Flags stale items** against the escalation rules in Quality checks.
- Prepares a **reconciliation template with the book side complete**, so that when the statement
  arrives the remaining work is matching, not rebuilding.

Then it **asks for the statement** and says exactly what it could not conclude without it.

If a **banking or payments platform is a connected datasource** in this workspace, that changes
everything — check at Gate 1 before assuming the statement is unavailable.

**Mosofin is read-only.** It cannot post an adjusting entry, mark an item cleared, or sign off a
reconciliation. Every entry below is a *proposal* for a human.

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

**Check every connected row for a banking or payments platform.** This is the highest-value check
in the whole gate for this skill: a connected bank feed converts the reconciliation from
`[manual]` to genuinely two-sided. Do not assume the workspace is accounting-only without
looking.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every balance, unmatched item and proposed entry carries its
  entity's `display_name`. **Never reconcile one entity's GL cash to another entity's statement.**
  Where several entities genuinely share one bank account, that is a specific and awkward case —
  see the edge case.

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability
map** — built this run, held for this run, written out as the coverage sheet, **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated.
- **A near-substitute is not a substitute, and here it is the central trap.** A **balance sheet**
  cash figure, a **cash flow statement**, and a **deposit listing** are all views of the *book*
  side. None of them is the bank's view. Assembling them into something that looks like a
  two-column reconciliation produces a document that asserts a control was performed when it was
  not. If the statement is absent, the output is a *book-side preparation*, and it must be
  labelled that way.
- **The connected books may not expose a "cleared" or "reconciled" flag.** Most read-only
  connectors do not. That means **outstanding cheques and deposits in transit cannot be
  identified with certainty from the books alone** — only proposed as candidates by date. Say
  "candidate", not "outstanding".

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency (which determines whether an FX line
belongs in the bridge at all), fiscal calendar, country / region, and **time zone** — which
matters here, because whether a transaction falls on the statement's last day can depend on it.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Bank account(s) in scope** — account name(s), **account numbers masked** | **Required — partly [auto]** | The chart of accounts pulls the cash accounts; ask which are in scope. **Never display or store a full account number.** |
| **Reconciliation period** — start / end dates | **Required** | Never default the period. |
| **Bank statement** — PDF/CSV, or the ending balance plus statement lines | **Required — [manual]**, always | Ask for it explicitly and early. If it cannot be supplied, say what the output will and will not be before doing the work. |
| **GL activity for cash account(s)** — date, description, amount, counterparty, reference | **Required — usually [auto]** | Pulled from the connected books. |
| **Prior month reconciliation status** — prior recon report or last reconciled date | Recommended — **[manual]** | Without it, opening outstanding items are unknown and the bridge starts blind. Ask for at least the last reconciled date. |
| **Cutoff policy** — posting cutoffs, deposit processing, cheque clearing | Recommended — **[manual]** | Sets the date windows in Step 3 and the escalation ages in Quality checks. |
| **Materiality threshold** | Recommended | Ask; do not assume. Note that the final tie is **to the cent** regardless — materiality governs which *items* get chased, not whether the bridge balances. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the accounts in scope by name. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The statement and the prior recon will both be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the account, or the entity.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what
is new, changed, or contradicted. The account list, cutoff policy and escalation ages should not
be re-asked every month.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*,
not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the cash
ledger, the deposits, the payments and the transfers do not depend on each other. Never serialize
them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — to identify the cash / bank accounts by their real names — usually
  **[auto]**
- *`get_trial_balance`* / *`get_balance_sheet`* — the GL cash ending balance — usually **[auto]**
- *`get_general_ledger`* on each cash account for the period — every book-side movement, the core
  of this skill — usually **[auto]**
- *`search_deposits`* / *`get_deposit`* — money banked, and the deposit-in-transit candidates —
  usually **[auto]**
- *`search_bill_payments`* / *`get_bill_payment`* — supplier payments, the outstanding-cheque
  candidates — usually **[auto]**
- *`search_purchases`* — cheques, card spend and direct debits — usually **[auto]**
- *`search_payments`* / *`search_sales_receipts`* — customer receipts — usually **[auto]**
- *`search_transfers`* — movements between the entity's own accounts, which appear on both sides
  and are a classic double-count — usually **[auto]**
- *`search_journal_entries`* — manual entries hitting cash, a frequent error source — usually
  **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the bridge's format
but **cannot support a completed reconciliation**, because a reconciliation is a control and
performing it on fixtures records a control as operating when it did not.

## Step 1 — Establish the two starting points

Capture:

- **Bank statement ending balance** as of the statement end date — **[manual]**
- **GL cash account ending balance** as of the same date — **[auto]**
  (*`get_trial_balance`*, *`get_balance_sheet`*, *`get_general_ledger`*)

**Confirm both are for the same account and currency.** This sounds trivial and is a common real
error: an entity with several accounts at the same bank, or a foreign-currency account carried in
the base currency, will produce a bridge that can never balance. State the account name, the
currency, and the date on both sides before going further.

If the statement balance is not available, **stop and say so here** — do not proceed to build a
bridge with one side missing and present it as a reconciliation. Continue instead with the
book-side preparation described at the top of this file, clearly labelled.

## Step 2 — Build the reconciliation bridge

Two ladders that must meet in the middle.

```
Bank statement ending balance
+ Deposits in transit
- Outstanding checks / payments
+/- Bank errors (rare; document)
= Adjusted bank balance

Book balance (GL ending balance)
+ Bank interest and other credits not recorded
- Bank fees and other debits not recorded
+/- Errors on books
= Adjusted book balance
```

**Adjusted bank balance must equal adjusted book balance.**

- **Deposits in transit** — money you banked that the bank hasn't credited yet. **[gated]**:
  the deposits are **[auto]** (*`search_deposits`*), but *which* are still in transit needs the
  statement. Without it, list them as **candidates** by date.
- **Outstanding cheques / payments** — payments you issued that haven't been cashed. Same split:
  the payments are **[auto]** (*`search_bill_payments`*, *`search_purchases`*); which are still
  outstanding needs the statement.
- **Bank errors** — rare, and **[manual]**. Document them; banks do make mistakes and they are
  worth pursuing.
- **Interest and credits not recorded / fees and debits not recorded** — **[manual]** to identify
  without the statement, since by definition they are not in the books. This is the same blind
  spot described in `bank-fee-and-interest-analysis`.
- **Errors on books** — **[auto]** and the strongest automated contribution here: duplicates,
  wrong amounts, wrong dates, wrong accounts, all detectable in the ledger alone.

## Step 3 — Match transactions (bank vs GL)

Work down the methods; record which one produced each match, because a level-1 match and a level-4
match carry very different confidence.

Matching process — **[gated]**, requiring both sides:

1. **Exact amount + date window match** (same day to ± 3 business days) — the strongest.
2. **Exact amount + fuzzy description match** — for when the bank's wording differs from yours.
3. **Reference match** (cheque number, ACH ID, wire reference, merchant descriptor) — often the
   most reliable of all where the reference survives on both sides.
4. **Split / combined matches** — one bank line covering several book entries, or vice versa.
   Common with batched deposits and card settlements, and the level where false matches start.

**[auto]** even without a statement: run the *book side against itself* to find duplicates — the
same amount, counterparty and date recorded twice. That is not matching, but it removes a
frequent cause of an unbalanced bridge before the statement even arrives.

## Step 4 — Classify all unmatched items

**Unmatched bank items** — **[manual]** without the statement, since these are things only the
bank knows:

- **Bank fees**
- **Interest earned**
- **Returned items / NSF** — a customer's payment bounced ("non-sufficient funds")
- **Chargebacks** — a card issuer reversing a payment
- **Merchant processor netting / reserves** — the processor taking its fee before paying you, or
  holding back a reserve
- **Loan payments (principal / interest)** — often taken automatically by direct debit
- **FX gains / losses** (if applicable)
- **Unknown (needs research)** — an honest category; give it an owner and a date

**Unmatched GL items** — **[auto]** to list, **[gated]** to classify:

- **Deposits in transit**
- **Outstanding checks**
- **Timing differences**
- **Book errors** — duplicate entry, wrong account, wrong amount, wrong date. **[auto]** to detect
  all four from the ledger alone (*`get_general_ledger`*, *`search_journal_entries`*), which makes
  this the part of Step 4 that can be completed before the statement arrives

## Step 5 — Propose corrections / journal entries

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — these are
proposals.

JE templates:

**Record bank fee**
```
DR Bank Fees Expense                 XXX
    CR Cash (Bank Account)               XXX
```

**Record interest income**
```
DR Cash (Bank Account)              XXX
    CR Interest Income                  XXX
```

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which you chose. Every proposed entry
names the statement line that evidences it — an entry proposed without that evidence is a guess
at what the bank did.

## Step 6 — Close out and document

Deliver:

- **Reconciliation summary table** — both ladders, meeting or not meeting
- **Unreconciled items list with owner + next action** — every item, including the "unknown"
  category
- **Proposed JEs with memos and support** — marked as proposals
- **Sign-off checklist** — **[manual]**. Mosofin cannot sign anything. Preparer and reviewer are
  named humans, and they should not be the same person

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This runs every month, so the evolution step pays back quickly.

On an explicit yes, persist the **decisions**:

- **The bank account list** — by account name and the entity that owns it, with **masked**
  identifiers only
- **The cutoff policy** — posting cutoffs, deposit processing times, typical cheque clearing
  windows — which sets the Step 3 date windows
- **The escalation ages** — the deposit-in-transit and outstanding-cheque thresholds from Quality
  checks, if the entity uses different ones
- **The materiality threshold** for chasing items
- **Recurring statement items** — the standing monthly fee, the regular loan direct debit, the
  processor's settlement pattern — so each is recognised rather than re-researched every month
- The account mapping for fees, interest and FX
- Where the statement comes from and who supplies it
- The replay recipe: the exact sequence of reads that produced the book side

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Never persist bank account numbers, statement contents, balances, or unreconciled item detail.**
Account numbers are payment credentials and the top fraud target; balances and item lists are the
period's evidence and belong in the close file. Persist the *policy, the thresholds and the
account names*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Operating account (…4471): cheques clear in ~5 days, escalate DIT over 10
business days" — not "cheques clear in ~5 days". Entities bank differently, and an unlabelled
clearing window applied to the wrong company file mis-ages every item. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to
the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is
the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Outputs

1. **Reconciliation summary** — with a header stating the workspace, the entity `display_name`,
   the account by name, the period, **whether a bank statement was supplied**, and whether any
   figure rests on `mock` data.
2. **Matched transaction list** — each with the matching method (1–4) that produced it.
3. **Unmatched lists with classification** — bank side and book side, per Step 4.
4. **Exception log with recommended next actions** — each with an owner and a target date.

**Coverage sheet — NEW, Mosofin-specific.**

One row per task in Steps 1–6:

| Task | Entity (`display_name`) | Account | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

If no statement was supplied, the rows for the bank side, the matching step and the unmatched-bank
classification all read `manual` with the gap "bank statement not supplied", and **the summary
says the reconciliation was not completed**. That is the correct, expected output — not a defect,
and not something to disguise with a book-side total.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming — Mosofin addition** (the original left it unstated, and multi-account, multi-entity
output needs it): `Bank_Rec_[AccountName]_[YYYY-MM].xlsx`, and in a multi-entity run
`Bank_Rec_[EntityDisplayName]_[AccountName]_[YYYY-MM].xlsx`. Every file states which datasource,
which `display_name` and which account it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead of
estimating.

---

## Quality checks

- **Same statement end date on both sides**
- **No duplicates in the GL export** — **[auto]** to test, and worth doing on every run
- **Deposits-in-transit older than 10 business days escalated** — money banked that the bank has
  not credited after two weeks is usually a lost deposit or a booking error, not timing
- **Outstanding checks older than 90 days escalated** — a cheque uncashed for a quarter may be
  lost, may be a duplicate payment about to be made, and in many jurisdictions eventually becomes
  unclaimed property
- **Adjusted balances tie to the cent** — not to materiality. A bridge that nearly balances has an
  unidentified item in it

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The output states plainly whether a bank statement was supplied**, and if not, is labelled a
  book-side preparation rather than a reconciliation
- **A book-side total is never presented as a reconciled cash balance**
- Outstanding cheques and deposits in transit identified without a statement are labelled
  **candidates**, never confirmed outstanding items
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- Every matched item records the matching method that produced it
- Every proposed entry names the statement line that evidences it
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no reconciliation is signed off on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids, no raw `data_source_id` values, and **no unmasked bank account
  numbers** appear in anything the user sees or in any persisted preference
- Nothing was written back to any system — every entry is a proposal, and nothing was marked
  cleared or signed off

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`, once per bank account in
scope.

**Multi-entity.** Steps 0–6 run **once per entity and per account**, each call targeting exactly
one `data_source_id`, every balance and item carrying its entity's `display_name`. Then one
cross-entity step:

- **A group cash position summary** — total reconciled cash by entity and account, with each
  entity's reconciliation status shown separately. **Group cash is only as reliable as the least
  reconciled account in it**, so report the status, not just the total.
- **Intercompany transfers appear on both entities' books** — one entity's payment is another's
  receipt. Match them across entities (*`search_transfers`*, *`search_deposits`*) and confirm both
  legs were recorded; a transfer recorded once is a classic cause of an unbalanced bridge at one
  entity and an unexplained credit at the other.
- **A bank account shared across entities** — where several entities genuinely transact through
  one account, no single entity's GL can reconcile to the full statement. Say so explicitly,
  reconcile the statement to the *combined* book activity, and treat the per-entity split as an
  allocation question, not a reconciliation.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
company file and per account.

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
| `create_skill` | Persists the evolved skill. Step 7. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Identify the cash / bank accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| GL cash ending balance | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Every book-side cash movement | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Deposits (deposit-in-transit candidates) | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| Supplier payments (outstanding-cheque candidates) | `search_bill_payments` / `get_bill_payment` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Cheques, card spend, direct debits | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required); `id` |
| Customer receipts | `search_payments` / `search_sales_receipts` | `start_date`, `end_date` (required), `customer_id` |
| Transfers between own accounts | `search_transfers` / `get_transfer` | `start_date`, `end_date` (required); `id` |
| Manual entries hitting cash | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Refunds issued | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required); `id` |
| Cash movement over the period | `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by` |
| Payment methods in use | `search_payment_methods` | `query`/`name`, `active_only` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Bank reconciliation** — proving the difference between your books and the bank's records is
  fully explained.
- **General ledger (GL)** — the complete record of every transaction in the books.
- **Book balance** — cash according to your books. **Statement balance** — cash according to the
  bank.
- **Bridge** — the two ladders of adjustments that bring both balances to the same adjusted figure.
- **Deposit in transit (DIT)** — money you banked that the bank hasn't credited yet.
- **Outstanding cheque** — a payment you issued that hasn't been cashed yet.
- **Cutoff** — the point at which a period stops accepting transactions.
- **NSF (non-sufficient funds)** — a payment that bounced.
- **Returned item** — a receipt reversed because it failed.
- **Chargeback** — a card issuer reversing a payment.
- **Merchant netting** — the card processor deducting its fee before paying you.
- **Reserve** — money a processor holds back against future chargebacks.
- **ACH ID / wire reference / merchant descriptor** — identifiers that let you match a bank line
  to a book entry.
- **Split / combined match** — one bank line covering several book entries, or the reverse.
- **Tie to the cent** — the bridge must balance exactly, not approximately.
- **Unclaimed property** — money (like an uncashed cheque) that must eventually be handed to the
  state.
- **Journal entry (JE)** — the balanced two-sided record. **DR** = debit, **CR** = credit.

---

## Edge Cases

*The original did not carry an Edge Cases section; these are Mosofin additions plus the hazards
implicit in the steps above.*

**No bank statement was supplied** — the default situation in an accounting-only workspace. Do the
book-side preparation, label it as such, and say the reconciliation was not completed. Never
produce a two-column document that implies otherwise.

**The connector exposes no "cleared" flag** — outstanding cheques and deposits in transit can only
be proposed as **candidates** by date. Label them that way.

**No prior reconciliation is available** — opening outstanding items are unknown, so an item
appearing unmatched may be months old. Say the bridge starts unqualified and recommend
establishing a baseline.

**A foreign-currency account carried in the base currency** — the bridge will never balance if one
side is converted and the other is not. Reconcile in the account's own currency, then translate;
see `multicurrency-fx-revaluation`.

**A transfer between the entity's own accounts recorded once** — appears as an unexplained debit on
one account and an unexplained credit on another. Always check transfers on both accounts before
classifying either as an error.

**A batched deposit or card settlement** — one bank line, many book receipts, often net of fees.
Match the batch, expect the net, and gross up the fee rather than forcing the amounts to agree.

**A duplicate payment about to be reissued** — an old outstanding cheque that is really lost will
be reissued, and if the original then clears the entity pays twice. Escalate cheques over 90 days
rather than rolling them forward.

**Deposits in transit that never clear** — after ten business days this is a missing deposit or a
booking error, not timing. Investigate rather than carrying it forward.

**Someone reconciles to materiality** — the bridge ties **to the cent**. A "close enough" bridge
has an unidentified item in it, and unidentified items are where fraud and error live.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
which accounts are therefore unreconciled. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A reconciliation is a control;
performing it on fixture data records a control as operating when it did not.

**A bank account is shared by several entities** — *Mosofin-specific*. No single entity's GL can
tie to the whole statement. Reconcile the statement to combined activity and treat the split as an
allocation.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.
