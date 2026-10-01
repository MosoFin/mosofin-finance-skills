---
name: closing-entries-and-trial-balance
description: "Use this skill whenever the user wants to prepare closing entries, lock the books for a fiscal period, or produce / audit a trial balance from their Mosofin workspace. Triggers include: 'close the books for the year', 'closing entries', 'roll income to retained earnings', 'final trial balance', 'reset the P&L for new year', 'lock the period', 'check the trial balance', 'TB doesn't balance', 'preliminary vs final TB', or uploading a TB for review. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then reads the live trial balance and account types — and tests whether the platform has already auto-closed the year, so nobody double-closes retained earnings. Do NOT use for the full year-end close — use year-end-close. Do NOT use for monthly close orchestration — use month-end-close-checklist. Outputs the closing entries, post-closing trial balance, a tie-out workpaper, and a coverage sheet."
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
# Closing Entries and Trial Balance (Mosofin)

Prepares the formal **closing entries** at fiscal year-end — closing revenue, expense, and dividend
/ distribution accounts to **retained earnings** — and produces or audits the **trial balance**.

**In plain words:** at the end of a financial year the profit and loss accounts have to be emptied
back to zero so next year starts fresh, and the year's profit gets rolled into the owners' stake in
the business. The balance sheet accounts carry on as they are. This skill works out those entries,
proves the books still balance afterwards, and checks the new year opens correctly.

This skill is **chart-of-accounts-agnostic**. It applies the standard closing procedure for
accrual-basis entities.

It is **not** system-agnostic. It is **workspace-scoped**: the trial balance, the account types, the
prior-year equity and the year's activity all come from tool calls against a company file connected
to your Mosofin workspace in this conversation, or from something you supplied by hand and that is
labelled as such.

**Two things a connected workspace changes here.**

1. **Nearly the whole procedure is `[auto]`.** The trial balance, every account's *type* (which is
   what decides temporary versus permanent), net income, opening retained earnings, dividends
   declared, and whether the adjusting entries have actually posted — all readable. This is one of
   the most fully automatable skills in the pack.
2. **The "don't double-close" hazard becomes testable.** The original's most practically damaging
   edge case is that *"some systems automatically close P&L to RE when the fiscal year is advanced;
   the closing entry may not need explicit posting."* Post an explicit closing entry on top of an
   automatic one and retained earnings is wrong by the whole year's profit. **In a connected
   workspace you can check**: read the trial balance at the first day of the new fiscal year and see
   whether the P&L accounts are already zero, and search for an explicit closing journal. Do this
   **before** proposing anything.

**Mosofin is read-only.** It cannot post a closing entry, and — importantly for Step 9 — **it cannot
lock a period**. Every entry below is a *proposal*, and locking is a human action in the accounting
system.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before computing anything. This ordering is the contract. Do
not skip a gate because a previous conversation covered it — connections, permissions, and company
files change between periods.

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

Settle the entity scenario — and here the domain rule is unusually clean:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. **Each entity closes its own books.** The workflow runs **once
  per entity**, every call targeting exactly one `data_source_id`, and every entry, trial balance and
  tie-out carries that entity's `display_name`. **There is no such thing as a group closing entry** —
  consolidation is a separate procedure (`consolidation-and-eliminations`) performed on already-closed
  entity books. Never combine trial balances before closing.

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
built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled —
  some underscored, some hyphenated.
- **The account-search tool carries the account *types*, and those types decide the whole procedure.**
  Temporary versus permanent is a function of account type, not of account name — a "Gain on
  Disposal" account is temporary, a "Treasury Stock" account is permanent, and neither is obvious
  from wording alone. If the account tool is disabled, classification becomes `[manual]` and must be
  confirmed account by account.
- **A near-substitute is not a substitute.** A **balance sheet plus a P&L** is not a **trial
  balance**: the reports are already classified and totalled, so they cannot show whether debits
  equal credits at the account level, which is the entire point of Step 1. If the trial balance tool
  is disabled, say the balance check could not be performed.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers:

- **Fiscal year end** — which defines the closing date and the first day of the new year. **The most
  important field in this skill**; a closing run against the wrong year-end closes the wrong twelve
  months
- **Functional currency**
- Legal name, country / region, industry

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Fiscal year end date** | **Required — usually [auto]** | Derived from the profile; **read it back and confirm**, since a changed year-end is common and the profile may lag. |
| **Pre-closing trial balance** | **Required — usually [auto]** | Pulled at the year-end date. Confirm it is the **final** TB, after adjusting entries. |
| **Entity type** — corporation / partnership / LLC / sole proprietor / nonprofit | **Required — [gated]** | Legal form is not a ledger field, but the **equity account names are a strong signal** (Owner's Draw, Member Capital, Net Assets). Propose what the accounts suggest and **have the user confirm** — Step 5's entry differs entirely by type. |
| **Chart of accounts with account types** | **Required — usually [auto]** | Pulled. This drives the temporary / permanent split. |
| **Functional currency** | **Required — usually [auto]** | Derived. |
| **Dividends / distributions declared during the year** | If applicable — usually **[auto]** | Readable as movement on the dividends or draws account. |
| **Prior year's retained earnings** (closing balance) | **Required for continuity — usually [auto]** | Pulled from the balance sheet at the prior year end. |
| **Reporting framework** — US GAAP / IFRS / Local GAAP / Other | Recommended — **[manual]** | Affects OCI treatment. |
| **Other comprehensive income items** | Recommended — **[gated]** | OCI accounts are readable where they exist; whether an item belongs in OCI is **[manual]**. |
| **Whether the platform auto-closes the year** | **Required** | See the banner above and Step 0b. **Test it, then confirm with the user.** |
| **Whether the audit is complete** | Recommended | Determines preliminary versus final close — see the edge case. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the fiscal
year end, the entity type, or the framework.

**On later runs** — this is annual — read stored preferences first (Step 11), confirm in one line,
and ask only what changed. The entity type, the closing method and the account classification should
not be rebuilt each year.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the trial
balance, the chart of accounts, the P&L and the prior-year balance sheet do not depend on each
other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* **at the fiscal year end** — the pre-closing TB — usually **[auto]**
- *`search_accounts`* / *`get_account`* — **every account with its type**, which drives the temporary
  / permanent split — usually **[auto]**
- *`get_profit_and_loss`* for the year — net income, and the totals for Step 4 — usually **[auto]**
- *`get_balance_sheet`* **at the prior year end** — opening retained earnings — usually **[auto]**
- *`get_balance_sheet`* at the current year end — the closing equity section, for the Step 8 tie-out
  — usually **[auto]**
- *`get_general_ledger`* on the equity, dividend and draw accounts — distributions declared, and any
  direct-to-equity postings — usually **[auto]**
- *`search_journal_entries`* near the year end — **whether the adjusting entries actually posted**,
  and whether a closing entry already exists — usually **[auto]**
- *`get_trial_balance`* **at the first day of the new fiscal year** — the auto-close test — usually
  **[auto]**
- *`get_company_info`* — fiscal year end and currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — a closing entry built on it would misstate
retained earnings permanently.

## Step 0b — Test whether the year is already closed (Mosofin addition)

**Do this before proposing any entry.** It takes one read and prevents the single most damaging error
available in this skill.

- **Read the trial balance at the first day of the new fiscal year** (*`get_trial_balance`*,
  **[auto]**). **If the revenue and expense accounts are already at zero, the platform has closed the
  year automatically.**
- **Search for an explicit closing journal entry** around the year-end date
  (*`search_journal_entries`*, **[auto]**) — a large entry to retained earnings on or near the last
  day of the year.
- **Compare retained earnings** at the prior year end and the current year end
  (*`get_balance_sheet`*, **[auto]**). If it has already moved by the year's net income, the roll has
  happened.

Report which of three states applies:

1. **Not closed** — proceed with Steps 1–9 and propose the entries.
2. **Auto-closed by the platform** — **do not propose closing entries.** Produce the trial balances,
   the tie-outs and the documentation, and state explicitly that the system performs the roll. This
   is Step 9's "document the system's behavior", answered with evidence.
3. **Already closed by an explicit entry** — verify it rather than repeating it. Run Step 8's
   tie-outs against the entry that exists.

**Posting a closing entry on top of an automatic one overstates or understates retained earnings by
the entire year's result**, and it is a genuinely common error. This test is cheap; run it every time.

## Step 1 — Verify the pre-closing trial balance

Before any closing entries:

1. **Sum debits and sum credits. They must equal.** — **[auto]** (*`get_trial_balance`*)
2. **Confirm all adjusting entries are posted** (depreciation, accruals, deferrals, prepaid
   amortization, tax provision, etc.) — **[gated]**: entries near year-end are readable
   (*`search_journal_entries`*), and their *absence* is detectable — no depreciation entry in the
   final month is a strong signal — but confirming the full list is **[manual]**
3. **Confirm all reconciliations are tied out** — **[manual]**; see `balance-sheet-reconciliations`
4. **Confirm material variances reviewed** — **[manual]**
5. **Confirm management has approved the financial statements** — **[manual]**

**If the TB does not balance, investigate before closing.** Common causes:

- **Unposted entry**
- **One-sided entry**
- **Wrong sign**
- **Account type mismatch** (asset booked to liability, etc.)
- **Roll-forward error from prior period**

**Build a journal-entry-by-journal-entry diff if the imbalance is small and persistent** — **[auto]**
(*`search_journal_entries`*, *`get_general_ledger`*): most systems will not let an unbalanced entry
post, so a persistent imbalance in a live system usually points to a report parameter or an account
type problem rather than a genuine one-sided entry. Check the accounting method and date range you
requested before hunting for a phantom transaction.

## Step 2 — Identify accounts to close

Two categories in a standard closing — **[auto]** to classify from account type
(*`search_accounts`*):

**Temporary accounts (closed to zero each year)**:

- **All Revenue accounts** (close to zero, transfer net to RE)
- **All Expense accounts** (close to zero, transfer net to RE)
- **Other Income / Other Expense** (close to zero, transfer net to RE)
- **Income Tax Expense** (close to zero, transfer net to RE)
- **Gains / Losses** (close to zero, transfer net to RE)
- **Dividends / Distributions / Owner Draws** (close to RE / Owner Capital)

**Permanent accounts (carry forward)**:

- **All Asset accounts**
- **All Liability accounts**
- **All Equity accounts** (Common Stock, APIC, Treasury, RE, OCI components)

**OCI items have their own treatment (see Step 6).**

Classify on **type**, never on name — and list any account whose type and name seem to disagree as an
exception for the user to confirm. A revenue-typed account called "Deferred Revenue" is a real
misconfiguration and closing it would move a liability into retained earnings.

## Step 3 — Two-step or four-step closing

**Two-step** (modern accounting; most common):

1. Close all revenue and expense accounts **directly to Retained Earnings** (skipping the Income
   Summary account).
2. Close **Dividends / Distributions** to Retained Earnings.

**Four-step** (traditional textbook approach; some entities use):

1. Close revenue accounts to **Income Summary**
2. Close expense accounts to Income Summary
3. Close the Income Summary balance (= net income) to Retained Earnings
4. Close Dividends / Distributions to Retained Earnings

**Both produce the same end state. Use whichever the entity has historically used or whichever the
user prefers.** **[auto]** to check which was used historically: look for an Income Summary account
in the chart of accounts and for prior-year closing entries (*`search_accounts`*,
*`search_journal_entries`*). Consistency year to year matters more than the choice itself.

## Step 4 — Compute the closing entries

Sum each account category from the pre-closing TB — **[auto]**:

```
Total Revenue                              $A
Total Other Income / Gains                 $B
                                       -------
Total credits to close                     $(A + B)

Total Cost of Revenue                      $C
Total Operating Expenses                   $D
Total Other Expenses / Losses              $E
Total Income Tax Expense                   $F
                                       -------
Total debits to close                      $(C + D + E + F)

Net Income / (Loss) = (A + B) − (C + D + E + F)

Dividends / Distributions Declared          $G  (to be closed to RE)
```

**Cross-check the computed net income against the P&L** (*`get_profit_and_loss`*, **[auto]**). If they
differ, an account is classified in a way the report and the trial balance disagree about — resolve
it before closing, not after.

## Step 5 — Construct the closing JEs (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — these are proposals.

**Closing Entry 1 — Close Revenue and Income accounts**
```
DR  Revenue (each account, to zero out)        $A
DR  Other Income / Gains (each account)        $B
    CR  Retained Earnings                         $(A + B)
Memo: Close revenue and other income to RE — FY[YYYY]
```

**Closing Entry 2 — Close Expense and Loss accounts**
```
DR  Retained Earnings                          $(C + D + E + F)
    CR  Cost of Revenue (each account, to zero)   $C
    CR  Operating Expenses (each account)         $D
    CR  Other Expenses / Losses                   $E
    CR  Income Tax Expense                        $F
Memo: Close expenses to RE — FY[YYYY]
```

**Closing Entry 3 — Close Dividends / Distributions**

For a **corporation**:
```
DR  Retained Earnings                          $G
    CR  Dividends Declared                        $G
Memo: Close dividends to RE — FY[YYYY]
```

For a **partnership / LLC**:
```
DR  Member Capital (or per partner)            $G
    CR  Member Distributions / Draws              $G
Memo: Close member distributions to capital — FY[YYYY]
```

For a **sole proprietor**:
```
DR  Owner Capital                              $G
    CR  Owner Draws                               $G
Memo: Close owner draws to capital — FY[YYYY]
```

**Net effect on RE / Capital:**
- **Increased by net income** (positive) or **decreased by net loss**
- **Decreased by dividends / distributions**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**), and list every account being zeroed individually rather than by category — a closing
entry that says "Revenue" when there are eleven revenue accounts is not postable.

## Step 6 — OCI handling

Items in **Other Comprehensive Income (OCI)** — gains and losses that bypass the profit and loss
account — **generally do NOT close to retained earnings. They close to Accumulated Other
Comprehensive Income (AOCI)**, a separate equity account that carries forward.

**OCI items** — **[gated]**: the accounts are readable, the classification is **[manual]**:

- **Foreign currency translation adjustments (CTA)**
- **Unrealized gains / losses on available-for-sale securities** (US GAAP)
- **Unrealized gains / losses on certain hedging instruments**
- **Pension actuarial gains / losses** (per framework)
- **Revaluation surplus** (IFRS)

Closing entry for OCI:
```
DR  OCI — [item]                               $X (if a loss)
    CR  AOCI                                       $X
or
DR  AOCI                                       $X
    CR  OCI — [item]                              $X (if a gain)
```

**OCI items that are later "recycled" (reclassified to net income) follow the recycling rules of the
relevant standard.**

The error to guard against: **an OCI item swept into net income and closed to RE**. It is easy to do
when an OCI account is typed as income in the chart of accounts, and it misstates both retained
earnings and AOCI. Check the account types explicitly.

## Step 7 — Post-closing trial balance

After closing entries, produce a **post-closing trial balance** — **[auto]** to construct from the
pre-closing TB plus the proposed entries, and **[auto]** to verify against the live system once the
entries are actually posted by a human.

Properties of a post-closing TB:

- **All revenue and expense accounts = $0**
- **Retained Earnings reflects: Opening RE + Net Income − Dividends**, with OCI closed to AOCI as a
  separate line
- **Total debits = Total credits**
- **Only permanent accounts remain**

**The post-closing TB equals the opening trial balance for the new fiscal year.**

## Step 8 — Tie-outs

Verify — **[auto]** for all four:

- **Pre-closing TB → Post-closing TB: only temporary accounts moved**
- **Pre-closing net income (per P&L) = increase in RE from closing entries**
- **Pre-closing dividends declared = decrease in RE from closing entries**
- **Permanent accounts unchanged**

```
Opening RE                          $W
+ Net Income                        $X
- Dividends declared                $Y
+/- OCI items closed to AOCI        $Z  (or kept separate)
= Closing RE                        $(W + X − Y + Z)
```

**Reconcile to the equity section of the closing balance sheet** — **[auto]**
(*`get_balance_sheet`*). This is the proof that the whole exercise worked, and it is fully
evidenced in a connected workspace.

## Step 9 — Lock and roll

Once closing entries are posted and verified:

- **Lock the fiscal year in the system** (no further entries permitted) — **[manual]**, and
  emphatically so: **Mosofin cannot lock a period.** This is a human action in the accounting
  system, and it is the control that makes the close mean anything. Name the person who will do it
- **The new fiscal year opens with the post-closing TB as its opening TB** — **[auto]** to verify
  afterwards
- **Period 1 of the new year begins with all P&L accounts at zero** — **[auto]** to verify

**Some systems do this automatically when you advance to a new fiscal year; some require explicit
closing entries. Document the system's behavior.** Step 0b answers this with evidence rather than
assumption — carry that finding into the documentation.

## Step 10 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Pre-Closing Trial Balance** — all accounts with debits and credits, summed. Add a header
block: workspace name; the entity by `display_name`; each excluded company file and why; the fiscal
year end; **the Step 0b closed-state finding**; whether any figure rests on `mock` data.

**Sheet 2: Closing Entries** — the journal entries with full detail **per account**, marked as
**proposals**. Where Step 0b found the year already closed, this sheet says so instead.

**Sheet 3: Post-Closing Trial Balance** — only permanent accounts; temporary accounts at zero.

**Sheet 4: Income Statement (for the closed year)** — from the temporary accounts being closed.

**Sheet 5: Statement of Retained Earnings (or Statement of Equity Changes)**

| Opening RE | + Net Income | − Dividends | + OCI to AOCI | = Closing RE |

See `statement-of-equity-changes` for the full statement if multi-component equity.

**Sheet 6: Tie-Outs** — pre-close TB to post-close TB reconciliation. **Confirmation that debits =
credits at both stages.**

**Sheet 7: Roll Forward to New Year** — the opening balances for the new fiscal year.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be evidenced and who owns it |

The rows for reconciliations tied out, management approval, and **locking the period** read `manual`
with named owners. Locking in particular must never appear as done.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Closing_Entries_TB_FY[YYYY]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`, one file per entity — **never a combined file**,
since each entity closes its own books. Every file states which datasource and `display_name` it
covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 11 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The entity type** and therefore which Step 5 variant applies
- **The closing method** — two-step or four-step — so it stays consistent year to year
- **Whether the platform auto-closes**, as confirmed by the Step 0b test, and what that means for the
  procedure
- **The account classification exceptions** — any account whose type and name disagree, and how it
  was resolved
- **The OCI account list** and each item's treatment
- **The equity account map**: retained earnings, AOCI, dividends / draws, capital accounts by member
  where relevant
- **Who locks the period**, and the pre-lock checklist the entity requires
- The replay recipe: the exact sequence of reads that produced the trial balances and tie-outs

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist balances, net income, retained earnings or the trial balances.** They are one year's
results and belong in the year-end file. Persist the *method, the classifications and the owners*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — LLC, member capital per member, two-step close, platform auto-closes" — not
"two-step close". Entities in one group frequently have different legal forms, and applying a
corporation's dividend entry to an LLC posts to an account that does not exist. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and **whether this year is closed yet is state**, re-tested every run at Step 0b.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is
no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of closing entries, one
post-closing TB.

**Multi-entity.** **Each entity closes its own books, separately and completely.** Steps 0–10 run
**once per entity**, each call targeting exactly one `data_source_id`, every entry and trial balance
carrying that entity's `display_name`. Then:

- **There is no group closing entry.** Consolidation happens *after* each entity has closed, on the
  closed figures — see `consolidation-and-eliminations`. Never combine trial balances before closing;
  the result would close intercompany balances into retained earnings.
- **Entity type may differ across the group.** A corporation subsidiary and an LLC subsidiary take
  different Step 5 entries. Confirm the type per entity rather than per group.
- **Fiscal year ends may differ.** Check each entity's own profile; closing one entity against
  another's year-end closes the wrong twelve months.
- **The auto-close test is per entity**, since platform behaviour and configuration can differ
  between company files even on the same platform.
- **CTA arising on consolidating a foreign subsidiary** belongs to the group's AOCI, not to the
  subsidiary's own closing entries — the subsidiary closes in its functional currency.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
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
| `create_skill` | Persists the evolved skill. Step 11. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Pre-closing trial balance; and the new-year auto-close test** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Every account with its type** (temporary vs permanent) | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Net income and the Step 4 category totals | `get_profit_and_loss` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Opening RE, closing equity, the Step 8 tie-out | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Dividends / draws declared; direct-to-equity postings | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Adjusting entries posted; any existing closing entry** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Fiscal year end, currency, legal name | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no tool to lock a period, and there never will be.**

---

## Plain-language glossary

- **Closing entries** — the year-end entries that empty the profit and loss accounts back to zero.
- **Trial balance (TB)** — a list of every account and its balance, where total debits must equal
  total credits.
- **Pre-closing / post-closing TB** — before and after the closing entries.
- **Temporary accounts** — revenue, expense and drawings accounts, which reset each year.
- **Permanent accounts** — assets, liabilities and equity, which carry forward.
- **Retained earnings (RE)** — accumulated profits kept in the business rather than distributed.
- **Income Summary** — an optional holding account used in the four-step method.
- **Adjusting entries** — the corrections and accruals posted before closing.
- **Dividends / distributions / draws** — money taken out by owners, under three names for three
  legal forms.
- **APIC (additional paid-in capital)** — money shareholders paid above the nominal share value.
- **Treasury stock** — the company's own shares it has bought back; a contra-equity account.
- **OCI (other comprehensive income)** — gains and losses that bypass the profit and loss account.
- **AOCI** — the equity account where OCI accumulates.
- **CTA (cumulative translation adjustment)** — the OCI item from translating a foreign business.
- **Recycling** — later moving an OCI item into profit and loss.
- **Revaluation surplus** — the IFRS reserve from revaluing assets upward.
- **Net assets with / without donor restrictions** — the nonprofit equivalent of equity.
- **Soft close / hard close** — a period closed but still amendable, versus one locked.
- **Roll forward** — carrying closing balances into the next period as opening balances.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**TB doesn't balance (debits ≠ credits)**: investigate before closing. Common causes:
- **Compute the imbalance amount**
- **Search for an entry of that exact amount** (often a one-sided posting)
- **Search for an entry of half that amount** (sign error: posted as DR instead of CR)
- **Check sub-ledger postings to the GL**
- **Check whether OCI items are appearing as net income items**
- **Check for a missing roll-forward of opening retained earnings**

*Mosofin note*: in a live double-entry system a genuine one-sided entry is usually impossible, so a
persistent imbalance more often means the report was requested with a different accounting method or
date range than expected. Check the request parameters before hunting a phantom transaction.

**Multiple ledgers / multi-entity**: **each entity closes its own books.** Consolidation is a separate
procedure (`consolidation-and-eliminations`). The closing entries are at the entity level.

**Closing in a multi-currency environment**: closing entries are **in functional currency. CTA flows
to AOCI, not RE.** Re-translation for consolidated reporting is separate.

**Sole proprietor / partnership / LLC**: **no Retained Earnings account.** Income closes to Owner
Capital or Members' Capital (per allocation). Distributions / draws close to the same. *Mosofin note*:
the equity account names in the chart make the entity type strongly inferable — propose, then confirm.

**Nonprofit**: typically uses **Net Assets** rather than RE, often split between **Without Donor
Restrictions** and **With Donor Restrictions**. Closing rolls the change-in-net-assets into the
appropriate net asset class. See `nonprofit-fund-accounting`.

**Prior period adjustment discovered after closing**: requires re-opening the prior year or restating
per `restatement-and-prior-period-adjustment`.

**Stock-based compensation expense closed to RE**: routine. **The accumulated SBC sits in APIC, not
closed. The expense is closed.**

**Treasury stock**: a **contra-equity account. Permanent, not closed.**

**OCI never recycled** (e.g. revaluation surplus under IFRS): stays in AOCI / Revaluation Surplus
indefinitely unless the asset is sold, when it may transfer directly to RE under IFRS.

**Discontinued operations / extraordinary items**: typically combined with continuing operations in
the closing entries unless presented separately on the P&L per the framework.

**Software / system behavior at year-end**: **some systems automatically close P&L to RE when the
fiscal year is advanced; the closing entry may not need explicit posting. Verify and document the
system's behavior so the entity doesn't double-close.** *Mosofin note*: **this is now a test, not an
assumption** — see Step 0b. Run it before proposing anything.

**Audit adjustments posted after preliminary close**: **re-run the closing entries with audit
adjustments included, or post a final-close adjustment. Document.** *Mosofin note*: ask at Gate 3
whether the audit is complete; a preliminary close that is then adjusted needs the tie-outs re-run.

**Late entries after close**: in soft-closed periods, may post with senior approval. In hard-closed
(year-end), typically requires re-opening and proper authorization. **Document everything.**
*Mosofin note*: detectable — entries dated within a closed year but created after it are visible in
the journal history.

**An account's type and name disagree** — *Mosofin-specific*. A liability-sounding account typed as
revenue will be closed to retained earnings and misstate it. Classify on **type**, and list every
name / type mismatch as an exception before closing.

**Mosofin cannot lock the period** — *Mosofin-specific*. Step 9's lock is the control that makes the
close real, and it is `[manual]`. Never report the period as locked; name the person who will do it.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose books are therefore unclosed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A closing entry misstates retained
earnings permanently; fixture data cannot support one.

**The profile's fiscal year end has changed** — *Mosofin-specific*. A changed year-end means a short
or long period. Read it back and confirm before closing anything.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply one entity's closing method or entity type to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Pre-closing TB balances**
- **All temporary accounts close to zero**
- **Post-closing TB balances**
- **Net income per P&L = increase in RE from closing**
- Dividends / distributions closed correctly **per entity type**
- **OCI items routed to AOCI separately from net income to RE**
- Period locked in system
- New year opens with the post-closing TB as its opening balance
- File naming consistent
- **No silent ignoring of imbalances or unposted adjustments**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The closed-state test (Step 0b) was run and its finding stated** before any entry was proposed —
  not closed, auto-closed, or already closed by an explicit entry
- **Accounts are classified as temporary or permanent on their type, never their name**, and every
  name / type mismatch is listed as an exception
- **The computed net income is cross-checked against the P&L** before closing
- Closing entries list **every account individually**, using the real names from the connected chart
- **The period lock is reported as a manual step with a named owner** — never as done
- Each entity closes separately; **no combined trial balance is produced before closing**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no closing entry rests on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No balances, net income or trial balances are persisted into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every closing entry is a proposal, and no period was locked
