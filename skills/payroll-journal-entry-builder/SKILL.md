---
name: payroll-journal-entry-builder
description: "Use this skill whenever the user wants to build the journal entries that record payroll in the general ledger, against their Mosofin workspace. Triggers include: 'book the payroll journal', 'payroll journal entry', 'record this payroll run', 'payroll GL entries', 'accrue payroll', 'split payroll across departments/cost centers', or turning a payroll register/report into accounting entries. Workspace-scoped: it confirms the workspace, discovers which company files and payroll platforms are connected and which read-only tools are enabled, then builds against the real chart of accounts, validates the gross-to-net identity that catches the employer/employee mixing error, and compares the run to prior ones before anything is posted. Mosofin never posts: every entry is a proposal. Do NOT use for reconciling payroll to the GL after posting — use payroll-reconciliation. Do NOT use for payroll tax filings — use payroll-tax-filings. Outputs balanced payroll journal entries with gross-to-net breakdown, employer costs, accruals, clearing, and a coverage sheet."
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
# Payroll Journal Entry Builder (Mosofin)

Converts a **payroll register or report** into the general ledger journal entries that correctly record
**gross pay, withholdings, employer costs, net pay, and related accruals**. Ensures the entries **balance,
hit the right accounts, and split appropriately across departments and cost centers.**

**In plain words:** payroll costs the business more than the staff receive and more than it pays out on
payday. Gross pay is the cost; part of it goes to the employee and part to other people on their behalf; and
the employer owes more again on top. Recording it properly means keeping those three things apart.

This skill is **jurisdiction-agnostic** — **withholding and contribution types depend on the jurisdiction;
the skill maps whatever the payroll register contains.**

It is **workspace-scoped**: the chart of accounts, the department structure, the prior runs and the
validation evidence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart rather than accepting any mapping. That is a narrowing, stated rather than implied.

## Payroll data is personal

**Everything in a payroll register concerns identifiable people.** The rule from
`payroll-clearing-reconciliation` applies here in full:

- **Build and present entries at account and department level**, not by employee. **The journal is a total;
  the register is the detail, and the detail stays in the payroll system.**
- **Never itemise individual pay, deductions or garnishments** in a workpaper or a message.
- **Never persist any individual's payroll data.** See Step 9.

## Mosofin proposes; it never posts

**Like `journal-entry-builder`, this skill produces a proposal.** **Mosofin is read-only and cannot post a
payroll journal.** What it can do is make the proposal correct before a person posts it:

1. **Build against the real chart.** **[auto]**: the accounts exist, the names match, **no invented account
   numbers** — the original's own standard, now enforceable rather than aspirational.
2. **Validate the identities.** **[auto]**: Step 7's checks are arithmetic, and **two of them catch the
   error the edge cases call "the single most common"** — see below.
3. **Compare the run to prior runs.** **[auto]**, and this is an addition the original does not have.
   **Payroll is the most stable recurring cost most businesses have**, so **a run that differs materially
   from the last one without a headcount change is worth a question before it posts**, not after.
4. **Check the accrual actually reversed.** **[auto]** in the following period — the edge case the original
   flags as causing double-counting.

**The register itself is `[manual]`** unless a payroll platform is connected — the same position as
`payroll-clearing-reconciliation`. **Check at Gate 1.**

**This skill feeds two others**: the entries built here are what `payroll-clearing-reconciliation`
subsequently reconciles, and the liabilities created are what `payroll-tax-filings` remits. **Build them so
those skills can use them** — which mostly means using the account map consistently.

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

**When invoked as a handoff from `month-end-close-checklist`**, the gates have usually run in the same
conversation. **Confirm the entity in one line** rather than repeating the sequence.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check for a connected payroll platform.** **If one is live, the register becomes `[auto]`** — and with it
the gross-to-net detail, the employer costs and the department allocation, if the platform carries them.
**If not, the register is supplied and labelled as such.**

Settle the entity scenario:

- **Single-entity** — one company file; the entry is built against its chart.
- **Multi-entity** — ask which set, **and which entity employs the people in this run.** **A payroll run
  covering several group entities produces one journal per entity**, not one journal split by class. See
  the cross-entity step.

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

**If the chart read is `disabled`, the same fallback applies as in `journal-entry-builder`** — descriptive
account names labelled **PLACEHOLDER — REMAP REQUIRED**, and **say so**. Do not invent account numbers.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A balanced entry is not a correct entry.** Employer contributions credited to an employee withholding
    account balance perfectly and are wrong.
  - **A prior period's entry is not a template for this one** — rates change, headcount changes, and
    jurisdictions add liabilities.
  - **A department dimension is not a cost allocation basis.** The dimension records where a cost was
    tagged; the basis is a decision.
  - **The payroll journal's total is not the register's total** until they have been compared.
- **There is no payroll register, no rate table and no benefit schedule on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar, **country
/ region — which determines which withholding and contribution types exist.**

**Ask the user** what actually changes the work — the original Inputs table, **minus the parts the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Payroll register / report for the run** | **Required — [gated]** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise.** |
| **Pay period and pay date** | **Required** | **Both**, since the accrual in Step 6 depends on the gap. |
| ~~Chart of accounts mapping~~ | **Now [auto]** | **Real accounts.** Confirm which account holds which liability. |
| ~~Department / cost center allocation~~ | **Now [gated]** | **The dimensions are `[auto]`; the allocation basis is `[manual]`.** |
| ~~Accounting basis~~ — cash or accrual | **Now [auto]** | Readable from the reads; **whether a period-end accrual is needed follows from the dates.** |
| **Funding / payment details** — bank account, timing | Recommended — **[gated]** | **The bank accounts are `[auto]`;** the timing is the user's. |
| **Employer contribution details** | **Required for full cost — [gated]** | **In the register if connected; `[manual]` otherwise.** |
| **Whether a payroll clearing account is used** | **Required — Mosofin addition** | It changes Step 5 and feeds `payroll-clearing-reconciliation`. |
| **Any capitalized labor in this run** | **Required if applicable — [manual]** | Nothing in the register flags it. |
| **Confirm scope** | **Required** | Read back the entity by `display_name`, the pay period and the run. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. withholding types for a country the entity does not operate in. |
| **Confirm manual evidence** | **Required** | The register and the allocation basis are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an account mapping, an
allocation basis, or a capitalisation decision.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The account map, the allocation basis, the clearing convention and the entry template persist; **the
register and every amount are new each run.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The register is `[manual]` where no payroll platform is
connected.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the chart, the dimensions, the prior runs and the balances do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical batch, per in-scope entity:

- *`search_accounts`* — **the chart: wages, each withholding liability, each employer cost and liability,
  net pay payable, clearing, accrued payroll** — usually **[auto]**. **The primary read**
- *`search_departments`* / *`search_classes`* / *`search_locations`* — **the allocation dimensions** —
  usually **[auto]**
- *`search_journal_entries`* **for prior payroll runs** — **the run-over-run comparison, and the entry
  template actually in use** — usually **[auto]**
- *`get_general_ledger`* on **the payroll liability and clearing accounts** — **current balances, and
  whether the last accrual reversed** — usually **[auto]**
- *`get_profit_and_loss`* **by department, prior periods** — **payroll expense by department, for the
  comparison** — usually **[auto]**
- *`search_employees`* — **headcount only**, as the denominator for the comparison — usually **[auto]**
- *`get_company_info`* — legal name, **country**, currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the chart read,
  state that placeholder coding is in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **an entry validated against fixture accounts may
reference accounts that do not exist**, and it would be imported and posted.

## Step 1 — Understand the payroll register components

**A payroll register typically contains, per employee and in total** — **[gated]**, from the register:

- **Gross pay** — **salary, wages, overtime, bonus, commission**
- **Employee withholdings**, deducted from gross — **income tax withholding, employee social / payroll
  contributions, retirement contributions, benefit premiums, garnishments, other deductions**
- **Net pay** — **gross − withholdings** — what the employee receives
- **Employer costs**, on top of gross and **not deducted from it** — **employer social / payroll
  contributions, employer retirement match, employer benefit costs, other employer-borne taxes**

**The key accounting concept: gross pay is the expense; withholdings are liabilities owed to third parties;
net pay is the liability owed to employees; employer costs are additional expense and additional
liabilities.**

**Work from totals.** **The journal is built from the register's totals by component**, not employee by
employee — which is both correct accounting and correct handling of personal data.

**[auto]** mapping check: **every component in the register needs an account, and every payroll account in
the chart should receive something.** **A register component with no mapped account, or a mapped account
receiving nothing, is a gap to resolve before building** — the second often means a liability type the
entity has stopped using, or one it has started and not mapped.

## Step 2 — Build the gross pay and withholding entry

Record the employee side of payroll. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a
proposal:

```
DR  Wages / Salaries Expense (gross pay)        $gross
    CR  Income Tax Withholding Payable               $X
    CR  Employee Social/Payroll Contribution Payable $X
    CR  Retirement Contribution Payable (employee)   $X
    CR  Benefit Premiums Payable (employee)          $X
    CR  Garnishments Payable                         $X
    CR  Net Pay Payable / Wages Payable (or Cash)    $net
```

**The debit (gross expense) equals the sum of credits — the various liabilities plus net pay. Use the
entity's actual account names and numbers from the COA mapping — do not invent account numbers.**

**[auto]** on both: **the accounts come from the live chart**, and **the identity is arithmetic.**

**If net pay is disbursed the same day from cash, credit Cash directly instead of Net Pay Payable.**

## Step 3 — Build the employer cost entry

Record **employer-borne costs** — **these are additional expense, not deducted from the employee**:

```
DR  Payroll Tax Expense (employer)              $X
DR  Retirement Match Expense (employer)         $X
DR  Benefits Expense (employer)                 $X
    CR  Employer Social/Payroll Contribution Payable $X
    CR  Retirement Match Payable                      $X
    CR  Benefits Payable                              $X
```

**Again, debits = credits, using the entity's accounts.**

**Keep this entry separate from Step 2**, even where the platform would accept one combined journal.
**Separating them is what makes the employer/employee distinction visible** — and that distinction is the
error the edge cases identify as the most common. **A combined entry hides it; two entries expose it.**

**[auto]** check: **the employer liability accounts should be distinct from the employee withholding
accounts.** Where the chart uses one account for both — a single "PAYE and NI payable", for instance —
**say so**, because the clearing reconciliation in `payroll-clearing-reconciliation` will not be able to
separate them either.

## Step 4 — Allocate across departments / cost centers

**If labor cost must be split** — for departmental P&L, project costing, or capitalization — **[gated]**:

- **Allocate gross wages and employer costs to the relevant departments / cost centers per the allocation
  basis** — **hours, headcount, direct assignment** — **the basis is `[manual]`; the dimensions are
  `[auto]`**
- **The liability side is usually not split** — one payable per type; **only the expense side is
  allocated**

**For costs that should be capitalized** — e.g. labor on a self-constructed asset or capitalized software
development — **route to the asset account rather than expense — flag these.** **[manual]** to identify; see
`fixed-asset-register-and-depreciation` and `intangibles-and-amortization`, **where the same labor appears
from the other side.**

**[auto]** checks: **the allocation sums to the total** — Step 7's requirement — and **the allocation is
consistent with the prior run** unless something changed. **A department's share moving sharply between runs
is either a real change or an allocation error**, and it is visible.

## Step 5 — Handle net pay funding

Depending on timing — **[gated]**:

- **If net pay is paid on the pay date from the operating account: CR Cash**
- **If funded through a payroll clearing account (common): CR Payroll Clearing**, then **a separate entry
  clears it when the bank disburses** — coordinate with `payroll-clearing-reconciliation`
- **If paid via a third-party payroll provider that debits a lump sum: record the provider funding and clear
  the individual liabilities as the provider remits**

**The third case is the one most often booked wrongly.** **A single bank debit covering net pay, taxes and
the provider's fee is not one expense** — **book the components.** See the edge case, and note that **the
lump sum is `[auto]` from the bank account while its composition is `[manual]` from the provider's
statement.**

**[auto]** to determine which case applies: **whether a clearing account exists and carries payroll-cycle
movement.**

## Step 6 — Period-end accrual (if needed)

**If the pay period crosses the period-end** — employees earned wages not yet paid at month-end — **accrue**:

```
DR  Wages Expense (earned, unpaid portion)      $accrued
    CR  Accrued Payroll Liability                    $accrued
```

**Include employer costs in the accrual. Reverse in the next period when the actual payroll is booked** —
coordinate with `accruals-and-deferrals`. **Pro-rate based on days / hours earned in the period.**

**[auto]** to determine whether an accrual is needed: **the pay period end and the pay date against the
accounting period end** — pure date arithmetic. **[gated]** to compute: the pro-ration needs the register.

**And the employer-cost point is worth emphasising**: **an accrual covering only gross pay understates the
liability by the employer's contributions**, which can be a fifth of the cost again. **[auto]** check: **the
accrual's ratio to the last full run's total cost** should be plausible.

## Step 7 — Validate the entries

- **Each entry balances (debits = credits)** — **[auto]**
- **Gross pay = net pay + total employee withholdings** — **[auto]**, ⭐ **and this is the check that
  catches the employer/employee mixing error.** **If an employer contribution has been credited to an
  employee withholding account, this identity breaks** — the entry still balances, but gross no longer
  reconciles to net plus withholdings
- **Total expense recognized = gross pay + employer costs** — **[auto]**, and **the mirror of the same
  test**: if employer costs were netted into gross, total expense will be right and the split will be wrong
- **Liabilities created match amounts that will be remitted** — to tax authorities, retirement plans,
  benefit providers, employees — **[gated]**; see `payroll-tax-filings`
- **Department allocations sum to the total** — **[auto]**
- **Accrual reverses correctly next period** — **[auto]** to verify in the following period

**Mosofin additions to the validation set:**

- ✅ **Every account exists in the live chart** — **[auto]**, a hard stop if not
- ✅ **Employer and employee liabilities use distinct accounts** — **[auto]**, or the limitation is stated
- ✅ **Run-over-run comparison** — **[auto]**: **gross, each withholding type, each employer cost, and the
  cost per head, against the previous runs.** **Payroll is stable; a material movement without a headcount
  change deserves a question before posting.** Report the comparison with the entry
- ✅ **The prior period's accrual actually reversed** — **[auto]**: **if it did not, this run's entry will
  double-count.** The edge case the original warns about, now checkable

## Step 8 — Output

Deliver the journal entries plus a workpaper:

**Sheet 1: Journal Entries** — **ready-to-post entries** — gross / withholding entry, employer cost entry,
accrual if needed, clearing entries — **each balanced, with account, debit, credit, memo.** **Marked
PROPOSED — NOT POSTED**, with the entity by `display_name`.

**Sheet 2: Gross-to-Net Reconciliation** — **gross → withholdings → net, tying to the payroll register
total.** **State whether the register was read or supplied.**

**Sheet 3: Employer Cost Breakdown** — **each employer cost and its liability.**

**Sheet 4: Department / Cost Center Allocation** — **labor cost split with the allocation basis**, and the
prior-run comparison.

**Sheet 5: Liability Summary** — **each payable created, amount, and to whom / when remitted** — feeds
`payroll-tax-filings`.

**Sheet 6: Validation — NEW, Mosofin-specific** — the six original checks plus the four Mosofin ones, each
with its result and the evidence.

**Sheet 7: Run Comparison — NEW, Mosofin-specific** — this run against the prior three, by component and per
head, with movements flagged.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Payroll_JE_[YYYY-MM-DD]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`. **Every file states that the entries are proposals.**

**Grounding:** every account traces to the live chart; every validation traces to a tool result in this
conversation; **every amount traces to the register**, read or supplied. End with a single **Data sources**
line.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** — every register component to its account: gross by type, each employee withholding,
  each employer cost and liability, net pay, clearing, accrued payroll. **The most valuable stored asset
  here**, and it makes each run a fill-in
- **The entry template** — which entries, in what order, with what memo convention
- **The allocation basis** and the dimension used
- **The clearing convention** — whether clearing is used and how it is cleared
- **The funding model** — direct, clearing, or third-party provider lump sum
- **The pay calendar** — frequencies, pay dates, period ends, **and which period ends require an accrual**
- **The capitalised labour rule** — which projects or roles, and to which asset account
- **The comparison tolerances** — what movement is worth flagging
- **Whether employer and employee liabilities share accounts**, as a known limitation
- The replay recipe: the exact sequence of reads that produced the chart and the comparison

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data, and never persist amounts.** No names, no pay, no deductions,
no garnishments. **Persist the map and the template; never the run.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — gross to 7000 by department, PAYE 2210, NI employee 2211, NI employer 2212, net pay to clearing
2200, monthly on the 25th, accrual required at March and September" — not "gross to 7000". **Account maps
are chart-specific and jurisdiction-specific**, and applying one entity's map to another posts liabilities
to accounts that mean something else. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one set of entries.

**Multi-entity.** **Confirm which entity employs the people in this run before building anything.** Then:

- **One journal per entity, built against that entity's own chart.** **A payroll run covering three group
  companies produces three journals**, not one split by class — **the liabilities are owed by different
  legal entities to different authorities.**
- **A single bank payment covering several entities' payroll** must be allocated, **and the entities whose
  payroll was paid by another owe it back** — an intercompany balance, not a payroll item. See
  `intercompany-reconciliation`.
- **Employment jurisdiction drives the withholding types**, not the entity's own location. An entity
  employing people in two countries needs both sets of liability accounts.
- **Shared employees recharged between entities** follow the recharge agreement — **the cost sits where the
  employment is, and the recharge is a separate transaction.**
- **Currency**: payroll denominated in a currency other than the entity's functional currency creates FX
  between accrual and payment — see `multicurrency-fx-revaluation`.
- **Run the comparison per entity.** A group total can be stable while one entity's payroll has doubled.

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
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The chart: wages, withholdings, employer costs, clearing — the primary read** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The allocation dimensions** | `search_departments` / `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| **Prior payroll runs — the comparison and the template in use** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **Liability and clearing balances; whether the last accrual reversed** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Payroll expense by department, prior periods** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `department` |
| Headcount, as the comparison denominator | `search_employees` | `query`/`name`, `active_only` |
| Legal name, **country**, currency | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register and component tools appear in **its
own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no rate table and no benefit schedule on this surface.**

---

## Plain-language glossary

- **Payroll register** — the detailed output of a payroll run: every employee, every component. **The
  journal's source, and where the personal data stays.**
- **Gross pay** — the full cost of employing someone before anything is deducted. **The expense.**
- **Withholding / deduction** — money taken from gross pay and owed to somebody else: tax, pension,
  insurance, a court. **Never the employer's money.**
- **Net pay** — what actually reaches the employee. **A liability until it is paid.**
- **Employer costs** — what the employer owes **on top of** gross pay: social contributions, pension match,
  benefit costs. **Additional expense, not a deduction.**
- **The mixing error** — treating an employer contribution as an employee deduction, or the reverse.
  **Balances perfectly and is wrong.**
- **Payroll clearing** — a holding account between recording payroll and paying it out. **Should return to
  nil.**
- **Accrued payroll** — wages earned before the period end but paid after it.
- **Reversing entry** — undoing an accrual next period so the real payroll does not double-count.
- **Retroactive pay** — an adjustment for an earlier period, paid now.
- **Benefit in kind** — non-cash compensation that is still taxable. **Increases expense and the withholding
  base without affecting net pay.**
- **Capitalised labour** — wages that become part of an asset rather than an expense, because the work built
  something lasting.
- **Cost centre / department allocation** — splitting labour cost across the parts of the business that used
  it.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multiple pay frequencies**: **weekly, bi-weekly, monthly runs each need entries; period-end accruals
differ by frequency. Handle each run.** *Mosofin note*: **the accrual requirement per period end is date
arithmetic** and can be scheduled once the calendar is stored.

**Bonus / commission runs**: **often have different, sometimes higher, withholding rates and may be separate
runs. Book per the register.** *Mosofin note*: **these will flag in the run comparison** — correctly, and
they should be explained rather than suppressed.

**Benefits-in-kind / non-cash compensation**: **taxable non-cash benefits increase the expense and the
taxable / withholding base without a cash net-pay effect. Record per the register.**

**Employer vs. employee split**: **the single most common error is mixing employer and employee
contributions. Employee contributions reduce net pay — already in gross; employer contributions are
additional expense. Keep them separate.** *Mosofin note*: **the gross = net + withholdings identity catches
it**, and keeping the two entries separate makes it visible.

**Garnishments and third-party deductions**: **create a payable to the third party — court, agency; clear
when remitted. Don't net into tax accounts.** **Sensitive; report at account level.**

**Capitalized labor**: **labor on self-constructed assets or qualifying software development is capitalized,
not expensed. Route to the asset account; flag for the FA register**
(`fixed-asset-register-and-depreciation`) **or intangibles** (`intangibles-and-amortization`).

**Payroll clearing account**: **when used, the JE credits clearing and a separate bank entry clears it. The
clearing account should reconcile to zero** (`payroll-clearing-reconciliation`).

**Accrual reversal**: **a period-end accrual must reverse next period to avoid double-counting when the
actual payroll is booked. Use reversing entries.** *Mosofin note*: **whether the last one reversed is
`[auto]` to check** — and it is the check that prevents the double-count.

**Multi-currency / multi-entity payroll**: **book each in the right entity and currency; intercompany
recharges of shared employees follow `intercompany-reconciliation`.**

**Corrections / retro pay**: **prior-period adjustments and retroactive pay create catch-up entries; book in
the current period with a clear memo.**

**Third-party payroll provider lump-sum debit**: **reconcile the single bank debit to the sum of net pay +
taxes + provider fee; book the components, not just the lump sum.** *Mosofin note*: **the lump sum is
`[auto]`; its composition is `[manual]`** — and booking the lump sum as one expense loses every liability
this skill exists to create.

**An account in the entry does not exist in the chart** — *Mosofin-specific*. **A hard stop.** The import
would fail, or create the account.

**Employer and employee liabilities share one account** — *Mosofin-specific*. **State the limitation**;
`payroll-clearing-reconciliation` will not be able to separate them either.

**A register component with no mapped account** — *Mosofin-specific*. Resolve before building; it is usually
a new deduction type or a new jurisdiction.

**A payroll account receiving nothing this run** — *Mosofin-specific*. Dormant, or a liability the entity
has started incurring and not mapped.

**This run differs materially from the last** — *Mosofin-specific, and the point of the comparison*. A bonus
run, a headcount change, a rate change, or an error. **Ask before posting**, not after.

**The prior accrual never reversed** — *Mosofin-specific*. **This run will double-count.** Check first.

**An accrual covering gross only** — *Mosofin-specific*. **Understates the liability by the employer's
contributions**, which can be a fifth again.

**A department's share moves sharply** — *Mosofin-specific*. A real change, or an allocation error.

**A group payroll booked as one journal** — *Mosofin-specific*. **The liabilities are owed by different
legal entities.** One journal per entity.

**A result comes back with `mock: true`** — *Mosofin-specific*. An entry validated against fixture accounts
would be imported and posted.

**A stored template applied to another entity** — *Mosofin-specific*. Account numbers are chart-specific and
jurisdiction-specific.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every entry balances (debits = credits)**
- **Gross = net + employee withholdings; total expense = gross + employer costs**
- **Employer and employee contributions correctly separated**
- **Liabilities match amounts to be remitted** (feeds tax filings)
- **Department / cost-center allocations sum to total; capitalized labor routed correctly**
- **Period-end accrual booked and set to reverse where applicable**
- **Account numbers / names from the entity's COA only** — none invented
- **Clearing-account mechanics handled where used**
- **File naming consistent**

**Mosofin additions:**

- **Every entry is labelled a proposal**, and nothing is described as posted
- **No individual's payroll data appears anywhere in the output** — the journal is built from register
  totals by component
- The workspace was confirmed **by name** and the entity confirmed by `display_name` before the entry was
  built
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every account was confirmed to exist in the live chart**, and a missing account is a hard stop; where
  the chart could not be read, the placeholder fallback is stated
- **The gross-to-net and total-expense identities were tested**, and the employer / employee mixing error
  reported if either fails
- **The employer entry is kept separate from the employee entry**, and any shared-account limitation stated
- **Every register component maps to an account**, and unmapped components or unused accounts are flagged
- **The run was compared to prior runs** by component and per head, with material movements reported for
  explanation **before posting**
- **Whether the prior period's accrual reversed was verified**, so this run cannot double-count
- **Whether an accrual is required was determined from the pay calendar**, and any accrual includes employer
  costs
- **The allocation sums to the total** and is compared to the prior run
- **A third-party provider lump sum is booked by component**, never as a single expense
- In a multi-entity run, **one journal is produced per entity against its own chart**, cross-entity payments
  are raised as intercompany, and **the comparison runs per entity**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no entry is offered for posting on fixture-validated
  accounts**
- Every account traces to the live chart, every validation to a tool result, and every amount to the
  register; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No individual payroll data and no amounts are persisted** into a skill bundle; every persisted
  preference states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted**
