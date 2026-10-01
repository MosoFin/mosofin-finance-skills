---
name: fixed-asset-register-and-depreciation
description: "Use this skill whenever the user wants to maintain a fixed asset register, compute depreciation, capitalize new acquisitions, dispose of assets, or reconcile FA to the GL from their Mosofin workspace. Triggers include: 'add this asset to the FA register', 'compute monthly depreciation', 'depreciation schedule', 'capitalize this purchase', 'dispose of this asset', 'reconcile fixed assets', 'depreciation methods', 'asset impairment review', 'asset count', or uploading an asset listing. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then derives additions and disposals from the ledger movements, tests the capitalization threshold against the expense accounts, and reconciles the register both ways. Do NOT use for intangibles — use intangibles-and-amortization. Do NOT use for leases — use lease-accounting-asc842-ifrs16. Outputs an FA register with depreciation schedule, capitalization, disposal, reconciliation workpapers, and a coverage sheet."
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
# Fixed Asset Register and Depreciation (Mosofin)

Maintains the **fixed asset (PP&E) register**, computes depreciation by various methods, handles
capitalization and disposals, and **reconciles FA balances to the GL**.

**In plain words:** when a business buys something that will last for years — a van, a machine, a building
fit-out — the cost is not an expense all at once. It goes on the balance sheet and is written down a bit
each month over the years it will be used. Doing that properly needs a list of every asset, what it cost,
when it went into use, and how fast it is being written down.

This skill is **framework-aware** — it applies US GAAP, IFRS, or local GAAP depreciation rules per the
user's framework.

It is **workspace-scoped**: the ledger balances, the additions and disposals, and the recorded depreciation
come from tool calls against a company file connected to your Mosofin workspace in this conversation, or
from something you supplied by hand and that is labelled as such.

## The shape of this skill: totals without detail — and what that makes possible

**The general ledger holds the balances. It does not hold the register.** Gross cost, accumulated
depreciation and depreciation expense are all readable as totals per account. **Asset-level cost, in-service
date, useful life, salvage value, depreciation method, location and condition are not in the accounting
system at all** — they live in a fixed-asset module, a spreadsheet, or nobody's hands.

So the register itself is **`[manual]`**. But that is not the end of the story, because **the movements are
readable**, and that inverts the usual reconciliation into something more useful:

1. **Additions can be derived independently.** **Debits to the fixed asset accounts during the period are
   the capitalizations** (*`get_general_ledger`*, *`search_purchases`*). You do not have to ask for a list
   of acquisitions — you can read them, and then compare. **A debit to the asset account that is not in the
   register is an unrecorded asset; a register entry with no matching debit is a phantom.** Reconciling
   both directions is the whole game, and here both directions are available.
2. **Disposals likewise.** **Credits to the asset accounts, and any movement on gain-or-loss-on-disposal
   accounts**, are the disposal population.
3. **The capitalization threshold can be tested against the expense accounts.** **[auto]**, and this is the
   check auditors actually perform: scan repairs, maintenance, equipment and small-tools expense for
   **individual items at or above the threshold**. **Capital items hide in repairs and maintenance**, and
   finding them is one query.
4. **Depreciation can be sanity-checked without the register.** Recorded depreciation divided by gross cost
   gives an **implied rate**; compare it to the policy useful lives. **A rate far from policy means wrong
   lives, missed assets, or depreciation that stopped running.**
5. **Fully depreciated assets are visible** — where accumulated depreciation equals cost. **Assets still in
   use at zero net book value** are a register-hygiene finding and often an impairment or replacement
   signal.

**What remains genuinely out of reach:** every useful life and method, salvage values, the capitalization
policy itself, impairment testing (which needs forecasts and fair values), tax depreciation, and the
physical count — which is a physical act, not a query.

**Mosofin is read-only.** It cannot capitalize, depreciate, dispose or impair anything. Every entry below is
a *proposal*.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before computing anything. This ordering is the contract. Do not
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

**Check for a connected fixed-asset module or asset-management platform.** If one is live, **the register
itself becomes `[auto]`**, which converts the largest manual component of this skill. Most accounting
connections do not include one — say which case you are in rather than assuming.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. **Assets are frequently held in one entity and used by another**, which
  is the defining cross-entity issue here. See the cross-entity step.

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
  - **The GL fixed-asset balance is not a fixed asset register.** It is a total. It cannot tell you what
    the assets are, how old they are, or whether they still exist.
  - **A purchase posted to an asset account is not proof it was correctly capitalized** — it is proof
    somebody coded it there.
  - **Recorded depreciation is not correct depreciation.** It is what was posted, often by a recurring
    journal that nobody has revisited since the last asset was added.
  - **Accumulated depreciation equal to cost is not proof an asset is gone.** It is proof it is fully
    written down; it may be sitting in the yard, in use.
- **There is no fixed-asset register, no useful life, no salvage value and no physical existence check on
  this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar and
year-end, country / region.

**Ask the user** what actually changes the work — the original Inputs table, minus what the connected books
already answer:

| What to confirm | Required? | Notes |
|---|---|---|
| **Existing FA register** | Recommended — **[manual]** | **The core gap.** Without it, you can still reconcile movements and test the threshold, but not compute asset-level depreciation. |
| ~~New acquisitions for the period~~ | **Now [auto]** | **Derived from debits to the FA accounts.** Confirm rather than request. |
| ~~Disposals for the period~~ | **Now [auto]** | Derived from credits and gain/loss accounts. Confirm the reason and proceeds. |
| **Asset class policies** — useful life and method per class | **Required — [manual]** | Never assume a life. The table in Step 1 is a range, not a policy. |
| **Reporting framework** — US GAAP / IFRS / local GAAP | **Required — [manual]** | Decides componentization, revaluation and impairment reversal. |
| **Capitalization threshold** | **Required — [manual]** | **Ask for it early** — Step 2b's expense scan depends on it. |
| ~~Functional currency~~ | **Now [auto]** | From the profile. |
| ~~Chart of accounts~~ | **Now [auto]** | From `search_accounts`, including whether accumulated depreciation is per class or consolidated. |
| **Tax jurisdiction** | Recommended — **[manual]** | For tax-book differences; the rules are not on this surface. |
| **First / last period convention** | **Required — [manual]** | Half-month, full month or pro-rata. Changes every number. |
| **Impairment indicators**, if any | If applicable — **[manual]** | Nothing in the ledger signals a triggering event. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The register, the lives, the threshold and any impairment analysis are `[manual]`. Record what was supplied and as at when. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a useful life, a
salvage value, a capitalization threshold, or a convention.

**On later runs**, read stored preferences first (Step 13), confirm in one line, and ask only what changed.
The class policies, the threshold, the convention and the account map persist; **the balances, the
movements and the register are re-obtained every period**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The physical count is `[manual]` by its nature — it stays
in the workflow with an owner and a date.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the asset accounts, the expense accounts, the depreciation
accounts and the profile do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the fixed asset, accumulated depreciation, depreciation expense, gain / loss on
  disposal, and repairs and maintenance accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **gross cost and accumulated depreciation by account**,
  opening and closing — usually **[auto]**
- *`get_general_ledger`* on the **FA accounts** — **every debit and credit, which is the additions and
  disposals population** — usually **[auto]**
- *`get_general_ledger`* on **accumulated depreciation and depreciation expense** — the recorded charge and
  its pattern — usually **[auto]**
- *`search_purchases`* / *`search_bills`* — **the acquisition documents behind the debits**, with vendor and
  description — usually **[auto]**
- *`get_profit_and_loss`* — **repairs, maintenance, small tools and equipment expense**, for the threshold
  scan — usually **[auto]**
- *`search_fixed_assets`* — **where the platform exposes an asset list at all** — often absent; check
- *`search_departments`* / *`search_classes`* / *`search_locations`* — allocation dimensions — usually
  **[auto]**
- *`get_company_info`* — legal name, currency, year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a register reconciled to fixture balances is
not reconciled**, and depreciation computed from it must not be proposed for posting.

## Step 1 — Establish asset classes and policies

**Common asset classes** — the user's specific classes may differ. **[manual]** to set, `[auto]` to compare
against the actual chart of accounts:

| Asset Class | Typical useful life range | Common depreciation method |
|-------------|---------------------------|----------------------------|
| **Land** | **Not depreciated** | N/A |
| **Buildings — structure** | 25–40 years | Straight-line |
| **Buildings — improvements** | 5–20 years | Straight-line |
| **Leasehold improvements** | **Lesser of useful life or lease term** | Straight-line |
| **Machinery & equipment** | 5–15 years | Straight-line or Units-of-Production |
| **Vehicles** | 3–7 years | Straight-line or DDB |
| **Computer hardware** | 3–5 years | Straight-line |
| **Computer software (capitalized)** | 3–5 years | Straight-line — but consider `intangibles-and-amortization` |
| **Office furniture & fixtures** | 5–10 years | Straight-line |
| **Tools & small equipment** | 3–7 years | Straight-line |

**These are common ranges, not mandates. The entity's specific policy drives useful lives. Document.**

**Mosofin addition — map classes to real accounts.** **[auto]**: read the chart of accounts and map each
class to the accounts that actually exist here. **Two mismatches are worth reporting immediately:**

- **A class in the policy with no account** — where is it being posted?
- **An asset account with no class policy** — what life is it being depreciated over?

**And check land.** **[auto]**: if a land account carries accumulated depreciation, **land is being
depreciated**, which it should not be. It is a small check that finds a real error.

## Step 2 — Capitalization decisions

**For each new acquisition, capitalize if:**

- **Amount ≥ capitalization threshold**
- **Useful life > 1 year**
- **Tangible** — intangibles handled separately
- **Used in operations** — not held for sale

**Capitalized cost includes:**

- **Purchase price net of discounts and rebates**
- **Sales / use tax that's not recoverable**
- **Freight and import duties**
- **Installation costs**
- **Site preparation**
- **Testing and commissioning costs**
- **For self-constructed assets: direct materials, direct labor, and a share of overhead**

**Excluded from capitalized cost:**

- **Recoverable taxes** (VAT / GST input credits)
- **Operating costs after the asset is in service**
- **Training** — typically expensed
- **General administrative costs not directly related**

**[gated]**: the purchase documents are `[auto]` (*`search_purchases`*, *`search_bills`*) and often show
freight and installation as separate lines on the same invoice — **so the cost build-up is partly
readable.** Whether a cost belongs in the asset is judgment.

**Mosofin check — freight and installation expensed on a capitalized purchase.** **[auto]**: where an
invoice has one line to the asset account and another to freight or installation expense, **the asset may
be understated.** Same invoice, same vendor, same date — a readable pattern worth flagging.

## Step 2b — Test the threshold against the expense accounts (Mosofin addition)

**Run this every period.** **[auto]**, and it is the highest-value check in the skill.

Scan the expense accounts most likely to conceal capital items — **repairs and maintenance, small tools,
equipment, computer expense, leasehold or building costs** — for **individual transactions at or above the
capitalization threshold** (*`get_general_ledger`*, *`search_purchases`*).

Report each hit with **vendor, date, amount, description and account**, and a proposed treatment. **Do not
assert that a repair is a capital item** — a genuine large repair is still a repair. **Report the
candidates; the policy call is the user's.**

Run the reverse too: **items below the threshold sitting in asset accounts.** Capitalizing small items
inflates the register and creates depreciation nobody tracks.

## Step 3 — Choose depreciation method

Common methods — **[manual]** to elect, `[auto]` to compute:

**Straight-line (SL)**
```
Annual depreciation = (Cost − Salvage value) / Useful life
Monthly depreciation = Annual / 12
```
**Most common. Simple. Default for many asset classes.**

**Declining balance (DB) / Double-declining (DDB)**
```
Period depreciation = Beginning NBV × (Rate)
DDB rate = 2 / Useful life (annual; / 12 for monthly)
```
**Front-loaded. More depreciation in early years. Stop when NBV reaches salvage.**

**Sum-of-the-years'-digits (SYD)**
```
SYD = n × (n + 1) / 2  where n = useful life in years
Year 1 depreciation = (Cost − Salvage) × (n / SYD)
Year 2 depreciation = (Cost − Salvage) × ((n − 1) / SYD)
...etc.
```
**Front-loaded; less aggressive than DDB. Less common today.**

**Units of production (UOP)**
```
Depreciation per unit = (Cost − Salvage) / Total estimated units
Period depreciation = Units produced × per-unit rate
```
**For assets whose life is better measured in usage** — machinery hours, vehicle miles, units produced.
**[manual]** on the usage data: **units produced and hours run are not in the accounting system.**

**Tax depreciation is jurisdiction-specific** — **[manual]**, always:

- **US: MACRS** (Modified Accelerated Cost Recovery System) — **half-year or mid-quarter convention,
  specific recovery periods, declining balance switching to straight-line**
- **Other jurisdictions: capital allowances, AIA (UK), CCA (Canada), bonus depreciation, Section 179**

**Book depreciation and tax depreciation often differ — this creates deferred tax differences** (see
`corporate-tax-provision-asc740`).

**For book purposes, apply the entity's policy method. For tax depreciation specifically, hand off to the
tax return prep skills.**

## Step 4 — Convention for the first and last periods

**Pick a convention for the first month of service** — **[manual]**:

- **Half-month / mid-month**: half depreciation in the month placed in service
- **Full month**: depreciate from the first day of the month placed in service
- **Pro-rata**: depreciate from the actual in-service date through end of month

**Most entities use full month or half-month. Apply consistently. Document.**

**Same logic for the disposal period.**

*Mosofin note*: **the convention is invisible in the ledger but visible in the first month's charge.** Where
a register exists, check that the first period's depreciation matches the stated convention — a mismatch
means the convention in the policy is not the convention in the spreadsheet.

## Step 5 — Compute depreciation for the period

For each asset in service — **[gated]**: the arithmetic is `[auto]`, but it needs the register:

- **Apply the method, useful life, cost, salvage, and convention**
- **Compute the period's depreciation**
- **Update accumulated depreciation**
- **Update net book value (Cost − Accumulated Depreciation)**

**Verify: cumulative depreciation never exceeds (Cost − Salvage).**

**Mosofin addition — the implied-rate check, which runs without a register.** **[auto]**: divide the
period's recorded depreciation by gross cost per class and annualize. **Compare the implied life to the
policy life.** A machinery class on a 10-year policy showing an implied 3-year rate, or a 40-year rate,
means something is wrong — wrong lives applied, assets missing from the schedule, or a recurring journal
that no longer matches the register. **It is a coarse check, and it still finds real errors.**

Also **[auto]**: **has depreciation been posted at all this period?** A zero or absent charge in a month
where assets exist is worth surfacing before anything else.

## Step 6 — Construct the depreciation JE

**Hand off to `journal-entry-builder`.** Aggregate by expense account — often by department, project, or
asset class. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a proposal:

```
DR  Depreciation Expense                              $period depreciation
    CR  Accumulated Depreciation (per asset class)       $period depreciation
Memo: Monthly depreciation — [period]
```

**Use the user's COA. Some entities have multiple Accumulated Depreciation accounts (one per asset class);
others have one consolidated. Match the COA structure.** **[auto]** to determine which
(*`search_accounts`*) — read it rather than asking.

## Step 7 — Capitalization JE for new acquisitions

```
DR  Fixed Asset (specific asset class)                $capitalized cost
DR  Input Tax Recoverable (if applicable)             $tax
    CR  Cash / AP                                       $gross
Memo: Capitalize [asset description] — placed in service [date]
```

*Mosofin note*: **for assets already posted, this entry has happened** — the value of Step 2 is checking it
was right and complete, not re-proposing it. Propose the entry only for items the threshold scan surfaced
as wrongly expensed.

## Step 8 — Disposals

**When an asset is sold, scrapped, or retired:**

```
Compute gain or loss on disposal:
Gain/loss = Proceeds − (Cost − Accumulated depreciation at disposal date)
         = Proceeds − Net book value at disposal date
```

```
DR  Cash / AR                                         $proceeds (if any)
DR  Accumulated Depreciation                          $accumulated depreciation at disposal
DR  Loss on Disposal (if loss)                        $loss
    CR  Fixed Asset                                     $original cost
    CR  Gain on Disposal (if gain)                      $gain
    CR  Output Tax Payable                              $tax on proceeds (if applicable)
Memo: Disposal of [asset] — [reason]
```

**Remove the asset from the FA register; document the disposal date and reason.**

**Mosofin check — the half-disposal.** **[auto]**: a common error is removing the **cost** but not the
**accumulated depreciation**, or vice versa. Read both sides of the movement: **a credit to the asset
account with no corresponding debit to accumulated depreciation** leaves the balance sheet wrong and usually
produces a spurious loss. Likewise **proceeds received with no asset removed** — cash in with no disposal
entry — is a disposal nobody recorded.

## Step 9 — Roll-forward and tie-out

For each asset class — **[auto]** on the GL side, **[gated]** overall since the register side is manual:

```
Opening Cost
+ Capitalizations
- Disposals (at original cost)
+/- Transfers / reclassifications
+/- FX revaluation (foreign-currency assets)
= Closing Cost

Opening Accumulated Depreciation
+ Period depreciation
- Disposals (accumulated depreciation removed)
+/- FX revaluation
= Closing Accumulated Depreciation

Net Book Value = Closing Cost − Closing Accumulated Depreciation
```

**The roll-forward must tie to:**

- **GL fixed asset balances (gross and accumulated)** — **[auto]**
- **The FA register at period end** — **[gated]**, and only where a register was supplied

**Mosofin addition — reconcile in both directions.** The original ties the register to the GL. **Do both:**

1. **Register → GL.** Every register asset should have cost in the GL. **A register asset with no GL cost is
   a phantom** — often an asset disposed of years ago and never removed.
2. **GL → register.** Every GL debit in the period should appear in the register. **A capitalization with no
   register entry is an asset that will never be depreciated** — it sits at full cost forever, overstating
   assets and understating expense, and nothing else in the close will catch it.

**Report both difference lists separately.** They have different causes and different owners.

## Step 10 — Impairment review

**At least annually — and on triggering events — review for impairment.** **[manual]** throughout: the
forecasts and fair values are not on this surface.

**US GAAP (ASC 360):**
- **Step 1: Test recoverability** — are **undiscounted** future cash flows > carrying value?
- **Step 2: If not, impairment loss = carrying value − fair value**

**IFRS (IAS 36):**
- **Recoverable amount = higher of fair value less costs of disposal and value in use**
- **Impairment loss = carrying value − recoverable amount**
- **Reversal allowed if circumstances change** — **US GAAP does not allow reversal**

**Triggering events: significant decline in asset value, change in use, physical damage, obsolescence,
regulatory changes.**

**Document the test, the conclusion, and any impairment booking.**

**[auto]** contribution — indicators, not conclusions: **assets in a class whose associated revenue or
department has collapsed**, and **assets fully depreciated but still carried**, are both readable and both
worth raising as *candidates for review*. **Never conclude impairment from ledger data** — the test needs
cash flows the workspace does not hold.

## Step 11 — Periodic physical count

**At least annually** — **[manual]**, and it stays in the workflow with an owner and a due date:

- **Physical inspection of major assets**
- **Confirm location and condition**
- **Match to FA register**
- **Identify missing, damaged, or unrecognized assets**
- **Trigger disposals or impairments as needed**

**No amount of ledger access substitutes for looking at the asset.** The GL will report a machine that was
scrapped three years ago exactly as confidently as one running today. **Record the count as `[manual]`, with
its owner and its last-performed date** — and if it has never been performed, say so, because that is the
finding.

## Step 12 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Asset Register Master**

| Asset ID | Description | Asset Class | Acquisition Date | In-Service Date | Original Cost | Salvage Value | Useful Life | Method | Currency | Location | Department |

Add a **Source** column: register-supplied, or derived from a GL movement.

**Sheet 2: Depreciation Schedule (current period)**

| Asset ID | Asset Class | Opening NBV | Period Depreciation | Closing NBV |

**Sheet 3: Acquisitions** — current period additions with JE references. **Now GL-derived**, with the
vendor and document reference from the purchase record.

**Sheet 4: Disposals** — current period disposals with gain / loss calculations and JE references.

**Sheet 5: Roll-Forward by Class** — gross cost and accumulated depreciation movements.

**Sheet 6: GL Tie-Out** — FA register summary vs. GL balances, **with both direction lists**: register
assets missing from the GL, and GL movements missing from the register.

**Sheet 7: Impairment Review** — documentation of any impairment indicators and test results, with
`[auto]`-derived candidates clearly marked as candidates.

**Sheet 8: GL Posting** — all JEs for the period, marked as **proposals**.

**Sheet 9: Tax-Book Depreciation Differences** — for tracking deferred tax, if material.

**Sheet 10: Capitalization Threshold Scan — NEW, Mosofin-specific**

| Date | Vendor | Account | Amount | Description | Above threshold? | Proposed treatment |

Both directions: expensed items at or above the threshold, and capitalized items below it.

**Sheet 11: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Policy | `mock` | Gap |

Include a row for the **physical count** with its owner and last-performed date, even — especially — when it
has not been done.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `FA_Register_and_Depreciation_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — useful lives, salvage values, impairment, the count — **name the source required**
instead of estimating.

## Step 13 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The asset class policies**: useful life and method per class, as this entity has set them
- **The capitalization threshold**, with its effective date
- **The first / last period convention**
- **The account map**: which accounts are cost, which are accumulated depreciation, whether accumulated
  depreciation is per class or consolidated, and which expense accounts the threshold scan covers
- **The class-to-account mapping** — the join that makes the roll-forward automatic
- **The framework** and the elections within it: componentization, revaluation model, impairment approach
- **The salvage value policy** — how salvage is set, not the values themselves
- **The depreciation allocation basis** — which departments or classes the charge is split across
- **The physical count cadence** and its owner
- The replay recipe: the exact sequence of reads that produced the movements and the threshold scan

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist the asset register itself, asset-level costs, net book values, locations or serial
numbers.** The register is state — and asset locations and serial numbers are security-relevant detail
about physical property.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Manufacturing — threshold 2,500 from 2025-01-01, machinery 10yr SL, vehicles 5yr SL, full-month convention,
accdep per class" — not "threshold 2,500". **Thresholds and lives differ by company file**, and applying one
entity's ten-year machinery life to another's produces a depreciation charge that is wrong every month and
never obviously so. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the register, the balances and the accumulated depreciation are all state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One register, one roll-forward, one
tie-out.

**Multi-entity.** Steps 0–12 run **once per entity**, each call targeting exactly one `data_source_id`,
every asset and balance carrying its entity's `display_name`. Then the points specific to fixed assets:

- **Assets are often held in one entity and used by another.** A property company owning the premises, an
  operating company using them. **Depreciation belongs where the asset is held**, and the use is usually
  charged on as rent or a recharge. **Never move depreciation to the using entity** to make a management
  report look right — that is a different transaction.
- **Intra-group asset transfers are the classic trap.** On transfer, the receiving entity records cost at
  the transfer price, but **on consolidation the asset must be carried at original group cost, with the
  intra-group profit and the excess depreciation eliminated.** See `consolidation-and-eliminations`.
  **Reading each entity's register separately will not reveal this** — it needs the transfer history.
- **Policies must be consistent for consolidation.** Different useful lives for the same class in different
  subsidiaries produce a group charge that is not comparable. **Flag policy differences across entities**;
  they are readable once each entity's class policy is stored.
- **Currency**: **at acquisition, cost is converted at the acquisition-date rate and held at that historical
  rate.** Each entity depreciates in its own functional currency; group translation is a separate step.
- **The threshold may differ by entity** — legitimately, since materiality differs. Store thresholds keyed
  by entity and never apply one across the group.

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
| `create_skill` | Persists the evolved skill. Step 13. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Asset, accumulated depreciation, expense and disposal accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Gross cost and accumulated depreciation, opening and closing | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Additions and disposals — every FA account movement** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **The acquisition documents behind the debits** | `search_purchases` / `search_bills` / `get_bill` | `start_date`, `end_date` (required); `id` |
| **The threshold scan across expense accounts** | `get_profit_and_loss` / `get_general_ledger` | `start_date`, `end_date`, `account` |
| An asset list, where the platform exposes one | `search_fixed_assets` | varies — **often absent** |
| Depreciation allocation dimensions | `search_departments` / `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| Legal name, currency, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no fixed-asset register, no useful life, no salvage value, no valuation and no physical
verification on this surface.**

---

## Plain-language glossary

- **Fixed asset / PP&E (property, plant and equipment)** — something the business owns and uses for years
  rather than sells.
- **Capitalize** — put the cost on the balance sheet instead of charging it as an expense now.
- **Capitalization threshold** — the amount below which something is simply expensed, however long it
  lasts, because tracking it is not worth the effort.
- **Depreciation** — spreading an asset's cost across the years it is used.
- **Useful life** — how long the business expects to use it. **Salvage / residual value** — what it will be
  worth at the end.
- **Net book value (NBV)** — cost minus depreciation charged so far. **Not** what it would sell for.
- **Accumulated depreciation** — the running total charged to date; a **contra account** shown as a
  deduction from cost.
- **Straight-line** — the same amount every period. **Declining balance / double-declining** — more early,
  less later. **Sum-of-the-years'-digits** — front-loaded, more gently. **Units of production** — by usage
  rather than time.
- **Convention** — the rule for the first and last part-month.
- **In-service date** — when the asset was ready for use, which starts depreciation. **Not** the purchase
  date.
- **CIP (construction in progress)** — an asset being built. **Not depreciated until it is in use.**
- **Componentization** — splitting one asset into parts with different lives (a roof, a boiler, a shell).
- **Impairment** — writing an asset down because it is worth less than its book value.
- **Recoverable amount / value in use** — IFRS measures of what an asset is really worth to the business.
- **MACRS, capital allowances, AIA, CCA, Section 179, bonus depreciation** — tax depreciation systems.
  **They rarely match book depreciation, and the difference creates deferred tax.**
- **Roll-forward** — opening balance, plus additions, less disposals, equals closing balance.
- **Held for sale** — an asset being sold rather than used; **depreciation stops.**

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Composite assets** — a building with roof, HVAC and structure, each with different useful lives: **under
IFRS, must be componentized; under US GAAP, optional. The framework determines treatment.**

**Leasehold improvements**: **depreciated over the lesser of useful life or remaining lease term. When the
lease term changes, adjust depreciation prospectively.**

**Land**: **not depreciated. The building on the land is depreciated. Allocate purchase price between land
and building.** *Mosofin check*: accumulated depreciation on a land account is a readable error.

**Construction-in-progress (CIP)**: **not depreciated until placed in service. When placed in service,
transfer from CIP to the appropriate asset class and start depreciation.** *Mosofin note*: **a CIP balance
that has not moved in several periods is worth flagging** — either the project stalled, or it went into
service and nobody transferred it, which means depreciation never started.

**Capitalized interest** (ASC 835-20 / IAS 23): **for qualifying long-duration assets being constructed,
capitalize interest on borrowings. Calculation per the standard.**

**Asset transferred between classes** — a building reclassified as investment property under IFRS:
**special accounting required at reclassification.**

**Foreign-currency assets**: **at acquisition, the cost is converted to functional currency at the
acquisition-date rate and held at that historical rate. No ongoing FX revaluation of historical cost.
Depreciation is on the historical cost in functional currency.**

**Revaluation model (IFRS only)**: **IFRS allows carrying assets at fair value with periodic revaluation
through OCI. US GAAP does not.** If the user is IFRS and elects revaluation, **account separately** — and
note the valuation is `[manual]`.

**Government grants for asset acquisition**: **reduce the asset cost or set up a deferred grant liability
that amortizes alongside depreciation** — per framework choice.

**Assets held for sale** (ASC 360 / IFRS 5): **once held-for-sale criteria are met, reclassify, stop
depreciating, and measure at lower of carrying value or fair value less costs to sell.**

**Spare parts**: **major spare parts not used in normal operation can be capitalized; routine spares are
inventory or expense.**

**Software**: **typically intangible, not PP&E. Internal-use software has specific capitalization rules**
(ASC 350-40 / IAS 38).

**Disposal where the asset is donated**: **no proceeds; full NBV is a loss** — with a possible tax deduction
at fair value depending on jurisdiction.

**Trade-in of old asset for new**: **treat as two separate transactions: dispose old, acquire new. Fair
value of trade-in = proceeds on the old asset.** *Mosofin note*: on the invoice this appears as one net
amount, so **the gross cost of the new asset and the disposal of the old are both understated** if the net
figure is capitalized. A readable pattern worth checking on vehicle and equipment purchases.

**Group depreciation**: **a group of similar assets depreciated as one pool. Disposals don't trigger
gain / loss — just remove from the pool. Less common; used in some industries.**

**A capitalization appears in the GL but not in the register** — *Mosofin-specific, and the most damaging*.
**That asset will never be depreciated.** It sits at full cost indefinitely. Nothing else in the close
catches it.

**A register asset has no cost in the GL** — *Mosofin-specific*. A phantom, usually disposed of years ago
and never removed.

**A capital item is sitting in repairs and maintenance** — *Mosofin-specific check, and a standard audit
procedure*. Run the threshold scan every period. **Report candidates, not conclusions.**

**Cost removed on disposal but accumulated depreciation left behind** — *Mosofin-specific*. Or the reverse.
Both leave the balance sheet wrong and usually produce a spurious gain or loss.

**Proceeds received with no asset removed** — *Mosofin-specific*. Cash in from an equipment sale with no
disposal entry: the asset is still on the books.

**Depreciation has not been posted this period** — *Mosofin-specific*. Check before anything else; a
recurring journal that stopped is silent.

**The implied depreciation rate is far from the policy life** — *Mosofin-specific*. Wrong lives, missing
assets, or a stale recurring entry. Coarse, and it still finds real errors.

**Assets fully depreciated but still in use** — *Mosofin-specific*. Readable where accumulated depreciation
equals cost. A register-hygiene and replacement-planning finding, not an error in itself.

**The physical count has never been performed** — *Mosofin-specific emphasis*. **That is the finding.**
Record it with an owner; do not let a clean GL tie-out imply the assets exist.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
assets are therefore unexamined.

**A result comes back with `mock: true`** — *Mosofin-specific*. A register reconciled to fixture balances is
not reconciled, and depreciation computed from it must not be proposed for posting.

**A stored register or net book value is reused** — *Mosofin-specific*. Both are state. Persist the policies
and the account map; re-obtain the register and the balances.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's lives or threshold to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every asset has class, useful life, method, and depreciation calculation**
- **Acquisitions match capitalization policy**
- **Disposals show original cost, accumulated depreciation, NBV, proceeds, gain / loss**
- **Roll-forward ties to GL**
- **Impairment review documented**
- **Tax-book differences captured if material**
- **Multi-currency handled per policy**
- **File naming consistent**
- **No depreciation past (Cost − Salvage)**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Additions and disposals were derived from the ledger movements**, not only accepted as supplied
- **The tie-out runs in both directions**, with register-not-in-GL and GL-not-in-register reported as
  separate lists
- **The capitalization threshold was tested against the expense accounts**, both directions, with candidates
  reported as candidates and the policy call left to the user
- **The implied depreciation rate was compared to the policy life** per class, and any large divergence
  reported
- **Whether depreciation was posted at all this period is stated**
- **Disposals were checked for the half-entry error** — cost without accumulated depreciation, or proceeds
  without a disposal
- **Land carrying accumulated depreciation is flagged**, and a stalled CIP balance is surfaced
- Impairment candidates derived from ledger data are **marked as candidates**, never as conclusions
- **The physical count is recorded as `[manual]` with an owner and its last-performed date**, and its
  absence is reported as a finding
- Useful lives, salvage values, the threshold and the convention are **all stated with their source**, and
  none was assumed
- In a multi-entity run, **depreciation stays with the entity holding the asset**, policy differences across
  entities are flagged, and intra-group transfers are raised for `consolidation-and-eliminations`
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no proposed entry rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No register, asset-level cost, net book value, location or serial number is persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no asset capitalized, depreciated, disposed or impaired
