---
name: inventory-to-gl-reconciliation
description: "Use this skill whenever the user wants to reconcile inventory subledger or physical counts to the GL using their Mosofin workspace. Triggers include: 'reconcile inventory to the GL', 'physical count variance', 'inventory subledger vs GL', 'investigate inventory shrinkage', 'tie inventory to balance sheet', 'cycle count variance', or uploading an inventory listing alongside GL data. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then establishes whether the subledger and the GL are actually two systems or one — because if they are one, that leg reconciles by construction — and runs the cut-off, negative-quantity and reserve checks the ledger can genuinely perform. Do NOT use for inventory costing methodology — use inventory-costing-fifo-lifo-wavg. Outputs a reconciled inventory workpaper with variances explained, shrinkage analysis, the cleanup JEs, and a coverage sheet."
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
# Inventory to GL Reconciliation (Mosofin)

Reconciles the **inventory subledger** (or **physical count**) to the **general ledger inventory control
account**. Identifies variances, classifies them — **shrinkage, count error, costing variance, in-transit** —
and produces **cleanup JEs**.

**In plain words:** the accounts say there is a certain value of stock. The stock system says there is a
certain quantity. The warehouse, when someone actually walks round and counts it, says something else again.
This finds out where the three disagree and why.

This skill works **across product categories**. **The costing method — FIFO / LIFO / weighted average /
standard cost — drives the valuation but not the reconciliation procedure**;
`inventory-costing-fifo-lifo-wavg` handles the costing method.

It is **workspace-scoped**: the GL balances, the item quantities, the transaction cut-off evidence and the
reserve movements come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## The question that decides what this reconciliation is worth

**Before anything else: are the subledger and the GL two systems, or one?**

**In many small and mid-market accounting platforms they are one.** The item module *is* the subledger, and
posting a sale updates the item quantity and the inventory account **in the same transaction, in the same
database.** Where that is so:

> **GL-to-subledger reconciles by construction. It cannot disagree, and proving that it agrees proves the
> software works — not that the inventory is right.** It is the same trap as the system-generated balance
> sheet in `financial-statement-builder`, and it should not be presented as a completed reconciliation.

**Where they are genuinely two systems** — a warehouse management system, a manufacturing ERP or a 3PL
platform feeding summary entries into the accounting ledger — **the reconciliation is real, and it is one of
the most valuable controls in the close.** Differences accumulate quietly in interface failures, timing and
mapping errors.

**Establish which case you are in and say so on the face of the workpaper.** Everything downstream depends
on it.

**And then the harder truth about the third leg:**

> **The physical count is the only comparison that tests whether the goods exist**, and it is **`[manual]`,
> always. No query substitutes for someone walking the racks.** The ledger and the subledger can agree
> perfectly on stock that was stolen last March.

**So what does the workspace actually contribute here?** Rather more than that framing suggests, but none of
it is existence:

1. **Negative quantities.** **[auto]**, and **always wrong** — a missing receipt or a duplicated sale. One
   query, and it finds real errors every time.
2. **Cut-off testing.** **[auto]**: receipts and shipments dated close to the period boundary, and entries
   posted after period end. **This is where a large share of genuine variances originate.**
3. **The reserve roll-forward.** **[auto]**, and it must tie to the reserve account.
4. **Shrinkage trending.** **[auto]** where shrinkage is posted to an identifiable account — the rate over
   time, which is what tells you whether this period is unusual.
5. **The GL side of everything**, exactly and by category.
6. **Standard cost variance balances**, where variance accounts exist.

**What stays outside:** the physical count, the 3PL statement, consignment arrangements, Incoterms and title
terms, and the operational explanation for any variance.

**Mosofin is read-only.** It cannot post an adjustment, a write-down or a cut-off correction. Every entry
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

**This gate answers the one-system-or-two question.** **Check specifically for a connected inventory, WMS,
manufacturing or 3PL platform.** If one is live alongside the accounting platform, **both sides of the
subledger-to-GL comparison are readable and the reconciliation is genuine.** If only the accounting platform
is connected, **the item module is almost certainly the same database as the GL** — say so.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`.
- **Multi-entity** — ask which set. **Stock held for another group entity, and stock in transit between
  entities, are the recurring cross-entity issues.** See the cross-entity step.

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
  - **A same-system agreement is not a reconciliation.** The central point above.
  - **Quantity on hand is not physical quantity.** **Only a count proves existence.**
  - **A location field is not proof of location.** It records where the system thinks the goods are.
  - **A consignment flag is not a title determination** — ownership turns on the contract.
  - **A variance account balance is not an explained variance.** It is where unexplained differences have
    been accumulating.
- **There is no physical count, no 3PL statement, no Incoterms and no warehouse team on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar and year-end,
country / region.

**Ask the user** what actually changes the work:

| What to confirm | Required? | Notes |
|---|---|---|
| ~~Inventory subledger / system extract~~ | **[auto]** if an items module exists — **but see the one-system question** | Confirm whether it is a separate system. |
| ~~GL inventory balance(s) at period end~~ | **Now [auto]** | From the trial balance, by account. |
| **Physical count results** — counted SKUs, quantity, location | **Required for the count comparison — [manual]**, always | **The only leg that tests existence.** Ask when it was last done. |
| **Period being reconciled** | **Required** | |
| ~~Chart of accounts~~ | **Now [auto]** | Including which accounts are which inventory category. |
| **Inventory locations / warehouses** | Recommended — **[gated]** | Readable where location tracking is used. |
| **Standard cost vs. actual cost variance accounts** | Recommended — **[auto]** where they exist | Their balances are readable; **the absorption policy is `[manual]`.** |
| **In-transit / consignment inventory** — quantity and value | Recommended — **[manual]** | **Title terms are contractual.** |
| **Inventory reserve / write-down policy** | Recommended — **[manual]** | See `inventory-obsolescence-and-reserve`. |
| **Whether the subledger is a separate system** | **Required — Mosofin addition** | **Decides what this reconciliation proves.** |
| **When the last physical count was performed** | **Required — Mosofin addition** | If never, that is the finding. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the period. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The count, the 3PL statement and the title terms are `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a count result, a
title determination, or a variance explanation.

**On later runs**, read stored preferences first (Step 10), confirm in one line, and ask only what changed.
The account map, the location structure, the known reconciling items and the count cadence persist; **every
balance, quantity and variance is re-obtained each period.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The physical count is `[manual]` by its nature — it stays
in the workflow with an owner and a date.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the items and the cut-off
population do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **raw materials, WIP, finished goods, in-transit, consignment, reserve, shrinkage
  and variance accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **the GL balances by inventory account** — usually
  **[auto]**
- *`search_items`* / *`search_products`* — **quantity on hand, unit cost, extended value, location** —
  usually **[auto]**
- *`get_general_ledger`* on the **inventory, reserve, shrinkage and variance accounts** — **movements, and
  the reserve roll-forward** — usually **[auto]**
- *`search_invoices`* / *`search_purchases`* / *`search_bills`* **around the period boundary** — **the
  cut-off population** — usually **[auto]**
- *`search_journal_entries`* — manual inventory adjustments — usually **[auto]**
- *`search_locations`* — the location structure — usually **[auto]**
- *`get_company_info`* — legal name, currency, year-end — usually **[auto]**

**Pull the cut-off population deliberately**: **transactions dated in the last days of the period and the
first days of the next, plus anything posted after the period end regardless of its date.** That second
group is where most cut-off errors actually live.

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a reconciliation against fixture balances is not
a reconciliation**, and inventory is frequently the largest asset on the balance sheet.

## Step 0b — Establish the systems and the count status (Mosofin addition)

**Run before Step 1**, and put the answer in the workpaper header.

1. **Is the subledger a separate system?** **[manual]** to confirm, **[gated]** to corroborate: if the item
   module and the GL are one platform, **the extended value of all items should equal the inventory account
   exactly.** **If it does, that is construction, not agreement.**
2. **When was the last physical count?** **[manual]**. **If the answer is "never" or "some years ago", that
   is the headline finding** — the GL and subledger may have been agreeing with each other about
   non-existent stock for a long time.
3. **What is the count cadence?** Full annual, cycle counting, or none.

**Report all three.** A perfect GL-to-subledger reconciliation with no count in three years is a weaker
result than a messy one with a count last month.

## Step 1 — Capture balances and structure

For each inventory category / location — **[auto]** on the GL side:

**GL side:**
- **Raw materials**
- **Work-in-progress (WIP)**
- **Finished goods**
- **In-transit**
- **Consignment-out** — the entity's inventory at another's location
- **Consignment-in** — third party's inventory at the entity's location — **typically NOT on the entity's
  balance sheet**
- **Inventory reserve (contra)**

**Subledger side:**
- **Sum of (qty × unit cost) per SKU / location** — **[gated]**, per Step 0b

**[auto]** structural check: **does the chart actually separate these categories?** Many do not — a single
"Inventory" account covering raw materials, WIP and finished goods **makes category-level reconciliation
impossible**, and that is worth reporting as a structural limitation rather than working around silently.

**And check consignment-in explicitly.** **Third-party goods on the entity's balance sheet overstate both
assets and liabilities**, and it is one of the commonest inventory errors — see the edge cases.

## Step 2 — Three-way comparison

**For a robust reconciliation, ideally:**

1. **GL ← compare to → Subledger** — **[gated]**, and **possibly meaningless per Step 0b**
2. **Subledger ← compare to → Physical count** — **[manual]**, **and the leg that matters**
3. **Confirm GL ↔ Subledger ↔ Physical (transitively)**

**If only the subledger is available — no recent physical count — the GL / subledger rec is partial.
Recommend a physical count cadence.**

**Mosofin emphasis**: that last sentence is the crux. **Where the subledger and GL are one system, leg 1 is
not merely partial — it is vacuous**, and the reconciliation reduces to leg 2, which the workspace cannot
perform. **Say this plainly rather than presenting a complete-looking three-way schedule with one leg
missing.**

## Step 3 — Reconcile GL to Subledger

For each inventory account — **[gated]**:

```
GL balance                                           $X
+ items in subledger not in GL (rare)                $A
- items in GL not in subledger                       $B
+/- FX revaluation (if multi-currency)               $C
+/- Standard cost variances not yet absorbed         $D
+/- In-transit / cut-off items                       $E
= Adjusted subledger basis                           $X + A − B + C + D + E

Subledger balance (sum of extended values)           $Y

Reconciled difference                                $(X + A − B + C + D + E) − $Y
```

**Investigate every non-zero difference.**

**[auto]** contributions to the reconciling items: **standard cost variance balances (D)** are readable where
variance accounts exist; **cut-off items (E)** come from the Step 0 boundary population; **FX (C)** is
readable where multi-currency is in use — though note inventory is a **non-monetary** item held at
historical rates, so a genuine FX revaluation of inventory is usually an error rather than a reconciling
item.

**Report the difference including zero** — and where the systems are one, **report it as "nil by
construction"** rather than as a reconciliation result.

## Step 4 — Reconcile Subledger to Physical Count

**For full counts: every SKU is counted. For cycle counts: a subset of SKUs is counted**, typically rotating
per **ABC stratification**.

**For each counted SKU** — **[gated]**: the subledger quantity and unit cost are `[auto]`, **the counted
quantity is `[manual]`**:

```
Subledger qty
Counted qty
Difference (in units)
× Unit cost
= Value of variance
```

**Classify the variance:**

- **Shrinkage**: physical < subledger — **theft, damage, miscount, spoilage**
- **Overage**: physical > subledger — **count error, returned goods not booked, found inventory**
- **Cut-off**: **receipt or shipment posted in the wrong period** — **[auto]** to corroborate from the
  boundary population
- **Wrong location**: **inventory moved but not transferred in system** — **[gated]** where locations are
  tracked
- **Damaged but still in subledger**: **needs write-down** — **[manual]**; condition is physical

**Three of the five classifications can be corroborated from readable data; two cannot.** Say which is
which per variance, rather than assigning causes uniformly.

## Step 5 — Common reconciling items

| Item | Description | Treatment | Verdict |
|------|-------------|-----------|---|
| **Goods received not invoiced (GRNI)** | Goods in inventory but no vendor invoice yet | **Booked via `ap-accrual-cutoff`; should NOT cause GL / subledger variance if properly accrued** | **[auto]** — the GRNI accrual balance is readable |
| **Goods invoiced not received** | Vendor invoice booked but goods not yet in subledger | **Cut-off issue — either reverse the invoice or accept inventory-in-transit** | **[auto]** — bills near the boundary |
| **In-transit inventory** (entity-owned in shipping) | **Title has transferred per Incoterms** | **Should be on subledger; ensure GL reflects** | **[gated]** — **Incoterms are `[manual]`** |
| **Returns from customers in transit** | Returned but not yet received | **Hold in "Returns Pending" account** | **[gated]** — credit memos are readable |
| **WIP component cost adjustments** | Re-costing of WIP at period end | **Usually GL-driven; ensure subledger reflects** | **[auto]** on the balance, `[manual]` on the basis |
| **Inventory write-downs (NRV, obsolescence)** | Lower of cost or NRV adjustments | **GL reserve account; subledger may stay at cost — track contra** | **[auto]** — see `inventory-obsolescence-and-reserve` |
| **Sample / promotional inventory consumed** | No invoice, but units gone | **Track separately as marketing expense** | **[gated]** — a common untracked shrinkage cause |
| **Manufacturing variances** | Standard vs. actual cost differences | **PPV, MUV, etc. — see standard costing** | **[auto]** on balances |

**Note the first row carefully**: **a properly accrued GRNI should not cause a variance at all.** Where it
does, the accrual is wrong — which points at `ap-accrual-cutoff` rather than at the warehouse.

## Step 6 — Investigate variances

For each material variance — **[gated]**, and the split is instructive:

1. **Look at recent transactions on the SKU** — **[auto]**
2. **Check for posting cutoffs** — **[auto]**
3. **Check for location transfers** — **[gated]**, where locations are tracked
4. **Check for incorrectly entered transactions** — **[auto]**: duplicates, reversals, wrong-sign entries
5. **Cross-reference with physical area / storage location** — **[manual]**
6. **Get the warehouse team's input on operational reasons** — **[manual]**, **and frequently the step that
   actually explains it**

**Document the investigation.**

**Four of six start in the data; two require people — and the two requiring people are where causes come
from.** A variance investigation that stops after step 4 will produce a classification, not an explanation.

## Step 7 — Compute shrinkage

**For genuine shrinkage — loss confirmed, not just a count error** — **[gated]**:

- **Total shrinkage value = sum of confirmed shortages × unit cost**
- **Shrinkage % = shrinkage value / average inventory value or revenue** — **[auto]** on both denominators
- **Compare to historical / industry rates** — **[auto]** for historical, **[manual]** for industry
- **Investigate if shrinkage is materially elevated**

**Note the precondition — "loss confirmed, not just a count error".** **Shrinkage requires a count.** A
shrinkage figure computed without one is not shrinkage; it is an unexplained GL difference wearing the
name.

**[auto]** trend: **shrinkage posted to an identifiable account, by period, as a percentage of inventory and
of revenue.** The trend is what tells you whether this period is unusual, and it is the context an isolated
number lacks.

## Step 8 — Construct cleanup JEs

**Hand off to `journal-entry-builder`.** `DR` is a debit, `CR` a credit. **Mosofin does not post** — these
are proposals:

**Inventory shrinkage / write-down**:
```
DR  Inventory Shrinkage / Loss / COGS              $loss value
    CR  Inventory                                     $loss value
Memo: Period shrinkage — physical count [date]
```

**Inventory overage** (rare; usually count error correction):
```
DR  Inventory                                       $overage value
    CR  Inventory Adjustments / Other Income           $overage value
Memo: Period overage — physical count [date]
```

**Write-down to NRV** (lower of cost or net realizable value):
```
DR  Cost of Goods Sold / Inventory Write-Down       $write-down
    CR  Inventory Reserve (or directly Inventory)     $write-down
Memo: NRV write-down — [SKU or category]
```

**Cut-off correction**: **reverse or move the misposted entry to the right period** (see
`restatement-and-prior-period-adjustment` if cross-year).

**Note the memo lines reference a count date** — which is the original's own reminder that these entries
follow a count, not a query.

## Step 9 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Reconciliation Summary**
- **Period**
- **GL balances by inventory account**
- **Subledger balances**
- **Physical count results (if conducted)**
- **Reconciled variances by category**
- **Shrinkage % and trend**

Plus the Mosofin header block: workspace name; the entity by `display_name`; excluded company files;
**whether the subledger is a separate system or the same one**; **when the last physical count was
performed**; whether any figure rests on `mock` data.

**Sheet 2: GL to Subledger Detail**

| GL Account | GL Balance | Subledger Balance | Difference | Reason | Action |

**Marked "nil by construction" where the systems are one.**

**Sheet 3: Physical Count Variances** (if applicable)

| SKU | Description | Location | Sub Qty | Count Qty | Variance Qty | Unit Cost | Variance Value | Classification | Action |

**Sheet 4: In-Transit and Cut-Off Items**

| Reference | Type | Description | Value | Period It Belongs | Correct Treatment |

**Populated from the `[auto]` boundary population.**

**Sheet 5: Write-Downs and Reserves**

| Item / Category | At Cost | NRV | Write-Down | Reserve Category | Authority |

**With the reserve roll-forward tied to the reserve account.**

**Sheet 6: GL Posting** — pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 7: Ledger Checks — NEW, Mosofin-specific**

| Check | Result | Detail |

**Negative quantities** — every one, always wrong; **cut-off exceptions**; **consignment-in on the balance
sheet**; **category structure limitations**; **variance account balances**; **shrinkage trend**.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

**Record the physical count as `[manual]` with its owner and last-performed date**, even — especially — when
it has not been done.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Inventory_Recon_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the count, the 3PL statement, the title terms — **name the source required** instead of
estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **Whether the subledger is a separate system**, and if so which
- **The account map**: raw materials, WIP, finished goods, in-transit, consignment-out, consignment-in,
  reserve, shrinkage, and each variance account
- **The location structure** and which locations are third-party or 3PL
- **The count cadence and method** — full annual, cycle counting with its stratification, or none — **and
  the owner**
- **The known recurring reconciling items** — expressed as rules: "the 3PL feed posts three days in
  arrears, so a three-day timing difference is expected"
- **The consignment arrangements** — which stock is consignment-in and which consignment-out, and with whom
- **The standard cost variance absorption policy**
- **The cut-off testing window** used
- **The materiality threshold** for variance investigation
- The replay recipe: the exact sequence of reads that produced the balances and the boundary population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist quantities, balances, variance amounts, shrinkage figures or count results.** All state.
**And never persist item-level costs or supplier pricing** — commercially sensitive, and not needed to
repeat the procedure.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Distribution — items module is the subledger, single Inventory account 1300 covering all categories, no
separate WIP, cycle counts monthly on A items, 3PL at Location 'Midlands'" — not "cycle counts monthly".
**Account structures and count regimes are entity-specific**, and applying one entity's map to another
reconciles the wrong accounts. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of accounts, one item master,
one count.

**Multi-entity.** Steps 0–9 run **once per entity**, each call targeting exactly one `data_source_id`, every
balance and quantity carrying its entity's `display_name`. Then the points specific to inventory:

- **Stock held by one entity for another is the owner's, wherever it sits.** The same rule as consignment,
  applied within the group. **A distribution entity holding manufacturer-owned stock should not carry it**,
  and if it does, both entities are misstated.
- **Goods in transit between group entities belong to whichever entity holds title**, per the internal
  terms. **At period end this stock is frequently on neither balance sheet or on both** — check both sides
  explicitly, exactly as `intercompany-reconciliation` checks both sides of a balance.
- **An intra-group sale creates inventory in the buyer at the transfer price**, carrying mark-up that is not
  group profit. **The reconciliation is per entity at each entity's own cost; the elimination is a
  consolidation step** — see `consolidation-and-eliminations`.
- **Shrinkage should be computed and investigated per entity and per location.** A group shrinkage rate
  averages away the one site with a problem, which is the only thing the number was going to tell you.
- **Counts happen per location, not per entity**, and a group with ten sites may have counted three.
  **Report count coverage by location**, not as a single yes or no.
- **Category structures may differ across entities**, which makes a group-level category reconciliation
  impossible without a mapping. Store it.

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
| Inventory category, reserve, shrinkage and variance accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The GL balances by inventory account** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Quantity on hand, unit cost, extended value, location** | `search_items` / `search_products` / `get_item` | `query`/`name`, `active_only`; `id` |
| **Movements, and the reserve roll-forward** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **The cut-off population around the period boundary** | `search_invoices` / `search_purchases` / `search_bills` | `start_date`, `end_date` (required) |
| Manual inventory adjustments | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| The location structure | `search_locations` | `query`/`name`, `active_only` |
| Legal name, currency, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no physical count, no 3PL statement, no Incoterms and no warehouse team on this surface.**

---

## Plain-language glossary

- **Subledger** — the detailed stock records behind the single inventory figure in the accounts. **Sometimes
  a separate system, sometimes the same one.**
- **Control account** — the single inventory line in the general ledger that the subledger is supposed to
  add up to.
- **Physical count** — actually counting. **Full** counts everything at once; **cycle counting** counts a
  rotating subset continuously.
- **ABC stratification** — counting high-value items more often than low-value ones.
- **Shrinkage** — stock that has gone: theft, damage, spoilage, or errors nobody caught.
- **Overage** — more stock than the records say. **Usually an earlier error, not good news.**
- **Cut-off** — whether a receipt or shipment landed in the right period. **A large share of variances start
  here.**
- **In-transit** — goods on the move. **Whose they are depends on the shipping terms, not on where the lorry
  is.**
- **Incoterms** — the standard shipping terms that decide when title and risk pass.
- **Consignment-out** — your goods at someone else's site. **Still yours.** **Consignment-in** — their goods
  at yours. **Not yours, and not on your balance sheet.**
- **3PL** — a third-party logistics provider holding stock for you.
- **GRNI (goods received not invoiced)** — goods arrived, invoice hasn't. **Accrued, not a variance.**
- **WIP (work in progress)** — part-made goods: materials plus labour plus overhead so far.
- **PPV (purchase price variance)** — the difference between standard and actual purchase cost.
  **MUV (material usage variance)** — between standard and actual quantity used.
- **Negative inventory** — the system says you hold less than nothing. **Always an error.**
- **Reserve roll-forward** — opening reserve, additions, write-offs, releases, closing reserve.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Standard cost system with significant variances**: **variances accumulate in PPV (purchase price
variance), MUV (material usage variance), etc. At period end, they're either expensed or capitalized back
into inventory. Document the policy.** *Mosofin note*: **the variance balances are readable**; the
absorption policy is not.

**Negative inventory** — the system allows quantity to go below zero: **always wrong. Indicates a missing
receipt or duplicate sale. Investigate every negative balance.** *Mosofin note*: **one query, and it finds
real errors every time.** Run it every period.

**Consignment inventory**: **the entity's goods at a customer location remain the entity's inventory. A
customer's goods at the entity's location are NOT the entity's inventory. Common error.** *Mosofin note*:
**consignment-in sitting on the balance sheet overstates assets and liabilities together** — check for it
explicitly.

**Inventory at third-party logistics (3PL)**: **ensure inventory is reconciled to 3PL statements; in-transit
between entity and 3PL is the entity's.** **The 3PL statement is `[manual]`.**

**Returned merchandise**: **customer returns flow back into inventory at the original cost or at NRV if
damaged. Don't reactivate damaged returns at full cost.**

**Long-aged inventory (slow-moving / obsolete)**: **candidate for write-down. The entity's policy might be:
aged > 12 months → 25% reserve; > 24 months → 50%; > 36 months → 100%. Apply per policy.** See
`inventory-obsolescence-and-reserve`.

**Damaged / scrap inventory**: **write off at the time of scrapping; document with photos and approvals if
material.** **Condition is `[manual]`** — nothing here can see it.

**Multi-currency inventory**: **inventory is valued in functional currency at purchase cost converted at the
purchase-date rate. No ongoing revaluation of inventory itself for FX — it's a non-monetary asset.**
*Mosofin note*: so **an FX revaluation appearing against inventory is usually an error**, not a reconciling
item.

**Component parts in WIP not yet assembled into finished goods**: **WIP value = raw materials + labor +
overhead applied to in-process units. Reconciliation must trace from raw materials through WIP into finished
goods.** **Impossible where the chart has a single inventory account** — a structural limitation to report.

**Inventory acquired in a business combination**: **opening value at fair value, often higher than book cost.
Track separately for cost-allocation purposes.** See `business-combinations-asc805`.

**ROU vs. inventory**: **leased equipment is not inventory — it's ROU under ASC 842 / IFRS 16. Common
misclassification.**

**Inventory reserve roll-forward**:
```
Opening reserve
+ Period write-downs / additions
- Period write-offs (inventory actually scrapped)
- Releases (NRV recovered, reserved items sold above cost)
= Closing reserve
```
**The reserve account net of inventory equals the carrying value.** **[auto]** — and it must tie to the
account.

**GL and subledger are the same system** — *Mosofin-specific, and the central point*. **They agree by
construction.** Report it as nil by construction, not as a reconciliation.

**A clean reconciliation with no recent count** — *Mosofin-specific*. **The two systems may have been
agreeing about stock that is not there.** The count date belongs in the header.

**Shrinkage computed without a count** — *Mosofin-specific*. It is an unexplained GL difference, not
shrinkage. **The name matters** because shrinkage implies a cause nobody has established.

**A single inventory account covering all categories** — *Mosofin-specific structural limitation*.
Category-level reconciliation is impossible. Report it.

**Cut-off tested only on transaction dates** — *Mosofin-specific*. **Entries posted after period end,
whatever their date, are the larger population** and the one where errors hide.

**A variance account balance treated as explained** — *Mosofin-specific*. It is where unexplained
differences have been accumulating, sometimes for years.

**Investigation stopped after the data steps** — *Mosofin-specific*. **Steps 5 and 6 need people**, and they
are where causes come from. Four of six is a classification, not an explanation.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
inventory is therefore unreconciled.

**A result comes back with `mock: true`** — *Mosofin-specific*. Inventory is frequently the largest asset on
the balance sheet.

**A stored count result or variance is reused** — *Mosofin-specific*. All state. **Persist the account map
and the cadence; re-obtain the figures.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's account map to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **GL, subledger, and physical (where applicable) reconciled with explained variances**
- **Shrinkage quantified and trended**
- **Write-downs documented with policy basis and authority**
- **Cut-off items identified and corrected**
- **In-transit items tracked**
- **File naming consistent**
- **No silent absorption of variances into COGS without classification**
- **Inventory reserve roll-forward present**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Whether the subledger is a separate system is established and stated**, and where it is not, the
  GL-to-subledger leg is reported as **nil by construction** rather than as agreement
- **The date of the last physical count is stated in the header**, and its absence is reported as the
  headline finding
- **The physical count is recorded as `[manual]` with an owner**, and no ledger evidence is presented as
  testing existence
- **Every negative quantity is listed**, since all of them are errors
- **Cut-off testing covers both transactions dated near the boundary and entries posted after period end**
- **Consignment-in on the balance sheet is checked for explicitly**
- **Where the chart does not separate inventory categories, that structural limitation is reported**
- **Shrinkage is only called shrinkage where a count supports it**, and it is trended against inventory and
  revenue
- **The reserve roll-forward ties to the reserve account**, with the difference reported
- **Each variance classification states whether it was corroborated from data or requires fieldwork**
- **Variance investigation is not reported as complete after the data steps alone**
- In a multi-entity run, **stock held for another entity is reported against its owner**, in-transit stock is
  checked on both sides, **shrinkage is computed per entity and per location**, and **count coverage is
  reported by location**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no reconciliation rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No quantities, balances, variance amounts, shrinkage figures, count results or item costs are
  persisted** into a skill bundle; every persisted preference states the datasource and `display_name` it
  covers
- Nothing was written back to any system — no adjustment, write-down or cut-off correction posted
