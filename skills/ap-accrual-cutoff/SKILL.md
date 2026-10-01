---
name: ap-accrual-cutoff
description: "Use this skill whenever the user wants to identify and book period-end AP accruals from their Mosofin workspace — invoices not yet received for services/goods already delivered, or goods received not yet invoiced (GRNI). Triggers include: 'book the AP accrual at month-end', 'accrue for services received but not invoiced', 'GRNI accrual', 'cutoff entries for AP', 'what AP do I need to accrue', 'period-end accruals for vendors', or running a cutoff procedure. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds the accrual schedule from live purchase orders, bills, and vendor spend history plus whatever the user supplies. Do NOT use for general accruals beyond AP — use accruals-and-deferrals. Do NOT use for full month-end close — use month-end-close-checklist. Outputs an accrual schedule with proposed JEs, reversing entries for the new period, and a coverage sheet showing what was pulled automatically versus supplied by hand."
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
# AP Accrual Cutoff (Mosofin)

Identifies period-end **accounts payable (A/P) accruals**: services or goods received during
the period for which an invoice hasn't been received or posted. Builds the accrual **journal
entry (JE)** plus the reversing entry for the new period.

**In plain words:** at the end of a month, some of what you used hasn't been billed to you
yet. The cleaner came, the parts arrived, the consultant worked — but no bill has landed. If
you close the month without recording those costs, the month looks cheaper than it really
was, and next month looks worse. **Cutoff** is the discipline of putting each cost in the
month it actually belongs to. This skill finds those unbilled costs, estimates them, and
writes the entries for a human to post.

This skill remains **jurisdiction-agnostic** — it applies whatever tax and reporting rules
the user identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every purchase order, bill,
balance, and account name comes from a tool call against a company file connected to your
Mosofin workspace in this conversation, or from something you supplied by hand and that is
labelled as such.

**Mosofin is read-only.** Nothing here posts a journal entry or closes a period. Every entry
below is a *proposal* for a human to review and post.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before identifying any accrual. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** —
`list_workspaces`, `get_agent_datasources`, `get_datasource_tools`,
`invoke_datasource_api_tool`, `get_skills`, `get_my_skill`, `create_skill`. Do not add a
`mosofin_` prefix and do not hardcode a client-side `mcp__…` namespace; that string is
composed by whichever MCP client is running.

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

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the
opaque `ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded** ("*Northwood Demo Books* is
  present but not active, so no accrual below draws on it"). A cutoff schedule that silently
  omits an entity understates the period's costs. Surface any `reconnect_url`.

A workspace can connect the **same platform several times** — several company files, plus
purchasing or payment platforms. Each is its own row with its own `data_source_id` and
`display_name`.

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and a combination step follows. Every accrual line
  carries its entity's `display_name`. Two entities' accrued liabilities are never added into
  one figure without that label.

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
map** — built this run, held for this run, written out as the coverage sheet, **never**
written into this file.

Rules that bite this skill in particular:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated. In this skill you will reach for both a
  purchase-order search and a single-bill read, and those two are often styled differently
  in the same catalog. Take the exact string from the Gate 2 listing.
- **A near-substitute is not a substitute.** If the purchase-order tool is disabled, a vendor
  *spend* report is not a stand-in: spend shows what was already billed, which is precisely
  the population that does **not** need accruing. GRNI is what is *missing* from spend. Mark
  it `[manual]` and say so.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** what the profile answers:

- **Functional currency** — the base currency the books are kept in. Ask about currency only
  if the transactions show more than one.
- **Fiscal calendar and year-end** — which tells you whether this cutoff is a routine month-end
  or the year-end one, and year-end usually carries a tighter materiality.
- Country / region and time zone.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Period being closed** — month or quarter, exact dates | **Required** | Never default the period. |
| **Open POs and receipts (GRNI candidates)** | **Required for GRNI accruals** | Purchase orders are usually **[auto]**; the **goods-receipt record is often [manual]** — see Step 1. Ask where receipts are logged. |
| **Recurring vendor schedule** — vendors with regular monthly bills | Recommended — largely **[auto]** | Normally derivable from spend history; ask the user to confirm and add anything the books do not show. |
| **Invoices received post-period** — bills dated after period end for in-period services | Recommended — usually **[auto]** | Normally pulled by searching bills after period end. |
| **Chart of accounts** — the accounts to post to | **Required — usually [auto]** | Pulled from the books; ask the user to confirm the specific accrued-liability account, since naming varies. |
| **Tax jurisdiction** | **Required if tax is recoverable** | Drives the Step 4 tax decision. Do not assume. |
| **Materiality threshold for accruals** | Recommended | If not given, accrue everything identified — and say that is what you did. |
| **Functional currency** | Recommended — usually derived | Ask only to resolve a contradiction or where several currencies appear. |
| **Subsequent-event window** — how many days after period end to look for late invoices | **Required** | Drives the Step 3 search range. Common answer is "up to the date the books close". |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | E.g. the profile's year-end does not match the period named. |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the
period, the accounting method, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only
what is new, changed, or contradicted. The interview shrinks; the gates never do.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical
evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence.

Tool names in *italics* are typical. Resolve the real names and policies from your Gate 2
catalog — the italic name is a pointer, not a promise.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — open
purchase orders, in-period bills, post-period bills, and vendor spend history do not depend
on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_purchase_orders`* — commitments made, the GRNI starting population — usually
  **[auto]**
- *`get_purchase_order`* — one PO's line detail: quantity and unit price — usually **[auto]**
- *`search_bills`* for the period — what has already been billed — usually **[auto]**
- *`search_bills`* for the **subsequent window** (period end + 1 through the close date) —
  the late invoices of Step 3 — usually **[auto]**
- *`get-bill`* — one bill's line detail and its service dates — usually **[auto]**
- *`get_vendor_expenses`* — spend per vendor over several prior periods, to establish the
  recurring pattern and the expected amount — usually **[auto]**
- *`search_accounts`* — the chart of accounts, to find the accrued-liability account —
  usually **[auto]**
- *`get_trial_balance`* / *`get_balance_sheet`* — the accrued-liability balance carried in —
  usually **[auto]**
- *`search_journal_entries`* — last period's accruals and whether their reversals posted —
  usually **[auto]**
- *`get_company_info`* — fiscal calendar and base currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can show the shape of a schedule
but **cannot support a posted entry**. Say so at the top if any proposed accrual rests on it.

## Step 1 — Identify accrual candidates from open POs (GRNI)

**GRNI — "goods received, not invoiced"** — means the stuff turned up but the bill hasn't.
You owe for it, so it belongs in this period even though nothing has been billed.

A **purchase order (PO)** is the order you placed. A **goods receipt (GRN)** is the record
that it arrived.

Process:

- **Pull all open POs with receipts in the period** — **[auto]** for the POs themselves
  (*`search_purchase_orders`*, *`get_purchase_order`*); **[gated/manual] for the receipts**.
  This is the honest split, and it is the single most important capability judgment in this
  skill: most accounting connectors expose **orders and bills, but no separate
  goods-receipt object**. Where no receipt record exists in the connected books, ask the
  user where receipts are logged (a warehouse system, a signed delivery note, an inventory
  module) and treat the receipt quantity as **[manual]** input.
- **For each line: GRN qty × PO unit price = expected accrual value** — **[auto]**
  arithmetic; **[auto]** for the unit price from the PO line; receipt quantity per the
  verdict above.
- **Subtract any invoices already matched against that PO line** — **[auto]** where bills
  reference their PO (*`search_bills`*, *`get-bill`*). Where the connector does not carry
  the PO link on the bill, match by vendor, date, amount and description and **say the match
  was inferred, not linked** — an inferred match is a judgment, and a wrong one causes the
  double-count Step 7's quality standard forbids.
- **Net = GRNI to accrue** — **[auto]**.

**For services with completed service confirmations: same logic** — confirmed delivery
without an invoice is an accrual. Service confirmations are almost always **[manual]**;
where the workspace tracks time, *`search_time_activities`* (**[auto]**) can evidence that
work was performed even when no confirmation document exists.

## Step 2 — Identify recurring-vendor accruals

Some bills arrive every month like clockwork. If this month's hasn't landed yet, it still
needs to be in this month's numbers.

For each recurring vendor (rent, utilities, subscriptions, maintenance contracts, **staff
augmentation** — contract staff working alongside your own — etc.):

- **Confirm the period's bill has been received and posted** — **[auto]**
  (*`search_bills`* for the period, by vendor).
- **If not, accrue at the expected amount** based on — **[auto]** for all three bases, since
  each is derivable from the connected books:
  - **The most recent invoice for the same service** (*`search_bills`*, *`get-bill`*)
  - **The contract / agreement amount** — **[manual]** where the contract is not in the
    books; **[auto]** where a recurring template or standing order exists
  - **The recurring schedule** (`recurring-transaction-builder`)
- **Flag any variance from prior periods** — **[auto]** by comparing the expected amount
  against several prior months (*`get_vendor_expenses`* with a monthly breakdown). E.g. this
  month's expected utility bill is unusually high or low.

Identifying the recurring population itself is **[auto]** and worth doing properly: a vendor
billed in each of the last several periods but not this one is exactly the accrual candidate
that gets missed by hand.

## Step 3 — Identify post-period invoices for in-period services

Look at what arrived *after* you closed the gate, and ask whether it really belongs inside.

**Subsequent-events review**: look at invoices received and posted after period end, dated
after period end, but **for services delivered before period end**. **[auto]** to find them
(*`search_bills`* with `start_date` = period end + 1 through the close date confirmed at
Gate 3); **[gated]** to judge each one, because the service period is often in the
description rather than a structured field.

**The service period is the test** — not the invoice date:

- **Service date / period entirely in the period being closed → accrue**
- **Service date / period entirely in the new period → don't accrue**
- **Service period straddles the cutoff → accrue the in-period portion (pro rata)** —
  *pro rata* meaning split in proportion to the days on each side

Where the bill does not state its service period, that judgment is **[manual]** — record it
in the exceptions sheet rather than guessing a split.

## Step 4 — Calculate the accrual amount

For each candidate:

- **Estimate the gross expense amount** — **[auto]** from the evidence gathered above.
- **Tax handling** depends on whether the entity's jurisdiction allows accrual of **input
  tax** (the recoverable sales tax / VAT / GST on what you buy) on services without an
  invoice — **[manual]**, always, because this is a rule, not a number in the ledger:
  - **Most jurisdictions**: tax recovery requires a **valid tax invoice** — so accrue the
    gross expense, book no input-tax line, and recognise the tax when the invoice arrives
  - **Some jurisdictions**: tax can be accrued — book input-tax recoverable alongside the
    expense
  - **Confirm with the user — do not assume**, and do not carry a rule over from a stored
    preference without re-confirming it

**The conservative default**: accrue the expense gross of recoverable tax, and let the tax
come through when the actual invoice posts.

The tax accounts and codes in use are **[auto]** to discover (*`search_tax_codes`*,
*`search_tax_rates`*, *`search_accounts`*), which helps you name the right account — but the
recoverability rule stays the user's to confirm.

## Step 5 — Build the accrual JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. `BS` means the balance sheet.
**Mosofin does not post these** — it drafts them.

For each accrual:

```
DR  Expense account (per user's COA)               $accrual amount
    CR  Accrued Liabilities (BS, per user's COA)      $accrual amount
Memo: Accrue [service] from [vendor] for [period] — invoice expected [date]
```

Mark each JE as **reversing on the first day of the new period**:

```
DR  Accrued Liabilities                            $accrual amount
    CR  Expense account                                $accrual amount
Memo: Reversal of accrual [original JE #] — original [vendor] [service]
```

**The reversal cancels the accrual; when the real invoice posts, it hits the same expense
account, netting clean.**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which account you chose.
**[auto]** to check whether last period's reversals actually posted
(*`search_journal_entries`* over the first days of the current period) — an unreversed
accrual is the most common cause of a creeping accrued-liabilities balance.

## Step 6 — Materiality screen

**Materiality** is the size below which a difference isn't worth chasing.

If the user provided a materiality threshold:

- Accruals **below** the threshold can be skipped, **with disclosure**
- Accruals **above** the threshold are required
- **The sum of skipped items must remain immaterial in aggregate** — flag if the cumulative
  immaterial items add up to a material amount. Individually trivial, collectively they can
  change the picture, and the aggregate is what an auditor asks for.

**If no threshold was provided, accrue everything identified** — and say that is what you
did, rather than quietly applying a figure of your own.

## Step 7 — Output

Deliver an `.xlsx` workpaper. If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Sheet 1: Accrual Summary**

- Period closed
- Total accruals by category (GRNI / recurring / subsequent invoices)
- Total accrual amount (functional currency)
- Materiality threshold applied
- Count of items above / below threshold
- **Added:** workspace name; each in-scope company file by `display_name`; each excluded
  company file and why; whether any figure rests on `mock` data

**Sheet 2: GRNI Accruals**

| Vendor | PO # | PO Line | GRN # | Received Qty | Unit Price | GRNI Amount | Currency | Functional Amount | Expense Account | Memo |

Add a column recording, per line, whether the receipt quantity came from a tool or from the
user — the GRN column is frequently the manual one.

**Sheet 3: Recurring Accruals**

| Vendor | Service | Expected Amount | Source (prior invoice / contract) | Variance vs Prior % | Expense Account | Memo |

**Sheet 4: Subsequent Invoices**

| Vendor | Invoice # | Invoice Date | Service Period Start | Service Period End | Accrual Period Portion | Amount Accrued | Expense Account | Memo |

**Sheet 5: Proposed JEs**

Pass-through to `journal-entry-builder`, including both the period-end accruals and the
first-day-of-next-period reversals. Marked clearly as **proposals**.

**Sheet 6: Exceptions / Open Items**

- Receipts on POs with no unit price (estimate needed)
- Services with a completion confirmation but no contract value
- Subsequent invoices with an unclear service period
- Variances vs. prior period flagged for review
- **Added:** PO-to-bill matches that were **inferred** rather than linked

**Sheet 7: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus estimated. One row per accrual candidate:

| Item | Category (GRNI / recurring / subsequent) | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: a tool enabled for one company file may
be disabled for its sibling, so the same task can be `[auto]` for one and `[manual]` for
another.

**File naming:** `AP_Accruals_[YYYY-MM]_Cutoff.xlsx`

In a multi-entity run: `AP_Accruals_[YYYY-MM]_[EntityDisplayName]_Cutoff.xlsx`, plus one
combined file named for the set. Every file states which datasource and `display_name` it
covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead
of estimating.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved
them, ask — explicitly, at that point, not earlier — whether to save this as their own
customized version. A general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- The Gate 3 answers: materiality threshold, tax jurisdiction and the input-tax accrual rule
  confirmed, subsequent-event window, functional currency
- The **recurring vendor list** with each one's expected amount, basis, and expense account —
  the single highest-value thing to carry forward, since it turns Step 2 from discovery into
  confirmation
- The account mapping: which accrued-liability account, and which expense account per vendor
  or category, by their real names in the chart of accounts
- Standing exclusions and why
- How receipts are evidenced when the books hold no goods-receipt record
- The replay recipe: the exact sequence of reads that produced this period's schedule

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — rent accrual $8,400/mo to Occupancy Costs, materiality $500" — not "rent
$8,400". One entity's landlord is not another's, and an unlabelled recurring-vendor list
applied to the wrong company file books a cost that does not exist there. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's;
state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One accrual schedule, one
JE set, one workpaper.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every accrual line carrying that entity's `display_name`. Then one
cross-entity step:

- **A roll-up** of total accruals by category and entity — accruals do aggregate meaningfully,
  but only once each entity is shown on its own line first.
- Watch for the **shared vendor**: one supplier billing several entities is normal, but the
  same invoice accrued at two entities is a double-count. Compare vendor and amount across
  entities before combining.
- Watch for the **intercompany accrual**: an accrual at one entity may be an unbilled
  receivable at another. Flag the pair rather than netting silently — see
  `intercompany-reconciliation`.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict
per company file.

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
| Open purchase orders (GRNI population) | `search_purchase_orders` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One PO's line detail (qty, unit price) | `get_purchase_order` | `id` |
| Bills in the period, and after it | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results` |
| One bill's lines and service dates | `get-bill` | `id` |
| Vendor spend history (recurring pattern, variance) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by`, `accounting_method` |
| Outstanding vendor balances | `get_vendor_balance` | `report_date`, `vendor` |
| Vendor master | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Vendor credits to net off | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Payments already made | `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| Chart of accounts (find the accrual account) | `search_accounts` | `query`/`name`, `active_only` |
| Accrued-liability balance carried in | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Transaction detail behind the balance | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Prior accruals and their reversals | `search_journal_entries` | `start_date`, `end_date` (required) |
| Work performed, where time is tracked | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Tax codes and rates in use | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accounts payable (A/P)** — money you owe suppliers.
- **Accrual** — recording a cost in the period it happened, even though no bill has arrived.
- **Cutoff** — the discipline of putting each transaction in the correct period.
- **GRNI** — "goods received, not invoiced": it arrived, the bill hasn't.
- **PO (purchase order)** — the order you placed with a supplier.
- **GRN (goods receipt note)** — the record that the goods actually arrived.
- **Three-way match** — matching the order, the receipt, and the bill before paying. GRNI is
  what you find when the third leg is missing.
- **Staff augmentation** — contract staff working alongside your own employees.
- **Subsequent events** — things that happen after period end but tell you about the period.
- **Pro rata** — split in proportion, usually by days.
- **Straddle** — a service period that crosses the period end.
- **Input tax** — the recoverable sales tax / VAT / GST on things you buy.
- **Valid tax invoice** — the document most tax regimes require before you can reclaim tax.
- **Journal entry (JE)** — the balanced two-sided record that moves numbers between accounts.
  **DR** = debit, **CR** = credit, **BS** = balance sheet.
- **Reversing entry** — an entry that undoes an accrual on the first day of the next period.
- **Chart of accounts (COA)** — the list of every account the books use.
- **Functional currency** — the main currency the entity's books are kept in.
- **Materiality threshold** — the size below which a difference isn't worth chasing.
- **Prepaid** — you paid ahead for something you'll consume later. The opposite of an accrual.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**GRN with no PO price** (rare; usually a process exception): estimate from prior receipts or
the contract; flag it. **[auto]** to find prior receipts of the same item
(*`search_items`*, *`search_purchase_orders`*); the estimate itself is a judgment.

**PO with multiple receipts, partial invoicing**: track cumulatively — GRNI = cumulative
received − cumulative invoiced, **per line**. Line-level tracking matters; a PO-level netting
hides a line that is fully received and unbilled behind another that is fully billed.

**Services delivered but no GRN equivalent**: depend on a service-completion confirmation,
time sheets, or vendor-side milestone declarations. If none exists, ask the user for the
basis — do not manufacture one.

**Significant variance vs. expected**: a recurring vendor's bill that is normally $1,000
estimated this month at $1,500 — flag it and ask the user to confirm or adjust. **Don't
silently post a 50% larger accrual.**

**Multi-currency**: accrue in the functional currency at the period-end FX rate. The reversal
in the new period uses the same rate — or rebooks at the new-period rate per policy, but
**consistency matters**; see `multicurrency-fx-revaluation`.

**Tax-inclusive vs exclusive estimates**: make sure the accrual is on the expense amount, not
the gross. If the expected total includes tax, decompose it.

**Cross-period contracts** (e.g. a three-year service contract billed annually in advance):
different accounting — that is a **prepaid**, not an accrual. Hand to
`prepaid-amortization-schedule`.

**Bills received but not yet posted to A/P** (sitting in an inbox or approval queue): **not an
accrual** — these should simply be posted. Check the approval queue first. **[manual]** in
Mosofin: an unposted bill is by definition not yet in the books, so no tool can see it. Ask
the user to clear the queue before finalising, and say that the schedule assumes it was
cleared.

**Items accrued last period and reversed this period, but the invoice never arrived**:
investigate. Either the service didn't happen and no accrual is needed, or the invoice is
delayed and should be re-accrued. **[auto]** to detect this — compare last period's accrual
JEs against bills received since (*`search_journal_entries`*, *`search_bills`*).

**Year-end vs. period-end materiality**: year-end may use a tighter materiality; check with
the user rather than reusing the monthly figure. The profile's fiscal year-end
(*`get_company_info`*) tells you when to ask.

**Subsequent-event window**: how many days after period end should you look back for
invoices? A common cutoff is the date the books close. Confirm with the user — this is a
Gate 3 question because it sets the Step 3 search range.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say which costs are therefore unaccrued. Surface any `reconnect_url`.

**No goods-receipt record exists in the connected books** — *Mosofin-specific, and the most
common gap in this skill*. Most accounting connectors carry orders and bills but not
receipts. Do not infer that an open PO was received just because it is open — an unreceived
order is a commitment, **not** a liability, and accruing it overstates costs. Mark the
receipt quantity `[manual]`, name where receipts actually live, and ask for them.

**A bill does not carry a link to its PO** — *Mosofin-specific*. Match by vendor, date, amount
and description, and **record the match as inferred**. An inferred match that is wrong
produces exactly the double-count the quality standards forbid, so it belongs in the
exceptions sheet.

**The purchase-order tool is `disabled` in this workspace** — *Mosofin-specific*. Do not
substitute a vendor spend report: spend is what was already billed, which is the population
that does **not** need accruing. Mark GRNI `[manual]`, name the tool, and ask for an open-PO
export.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate
the schedule's shape but cannot support a posted entry. Flag it at the top of the deliverable.

**The books are kept on a cash basis** — *Mosofin-specific*. A cash-basis ledger does not
carry accruals at all, so the opening accrued-liability balance may legitimately be zero. Say
that explicitly, and confirm whether the user is converting to accrual basis for reporting.

**A stored recurring-vendor preference no longer matches reality** — *Mosofin-specific*. A
vendor whose contract ended will otherwise be accrued forever. On every run, re-check each
stored recurring vendor against actual recent bills before accruing it.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- Every accrual line shows its source (GRN, recurring, subsequent invoice)
- Every accrual has a corresponding reversing entry for the next period
- The accrual amount's basis is documented
- Variance from the prior period is flagged where notable
- Tax handling is documented (accrued or not, per jurisdiction)
- File naming consistent
- **No double-counting: an item is either GRNI or a subsequent invoice, never both**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- Every accrual candidate carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool
  used, and that tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no candidate is silently dropped
- **Receipt evidence is stated per GRNI line** — an open PO is never treated as received
  without evidence
- **PO-to-bill matches state whether they were linked or inferred**
- Account names in every proposed JE are the **real names from the connected chart of
  accounts**, not generic placeholders
- `mock` status is reported wherever it applies, and no proposed entry rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional
  term kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- Every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every JE is a proposal for a human to post
