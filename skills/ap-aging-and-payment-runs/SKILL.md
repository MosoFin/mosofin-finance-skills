---
name: ap-aging-and-payment-runs
description: "Use this skill whenever the user wants an accounts payable aging analysis, a payment run, or vendor payment prioritization from their Mosofin workspace. Triggers include: 'run an AP aging', 'who do we owe and when is it due', 'build a payment run for this week', 'which bills should we pay first', 'identify early-pay discounts', 'who's overdue', or uploading an AP balance / open bill list. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds the aging from the live A/P aging report — or reconstructs it from open bills, payments and credits when that report is unavailable — and proposes a prioritized payment run. Do NOT use for individual vendor invoice extraction — use invoice-data-extractor. Do NOT use for vendor onboarding — use vendor-onboarding-and-w9-tin. Outputs an AP aging schedule, a prioritized payment run proposal, discount-capture analysis, and a coverage sheet showing what was pulled automatically versus supplied by hand."
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
# AP Aging and Payment Runs (Mosofin)

Produces **accounts payable (A/P) aging** analysis and proposes prioritized **payment runs**
based on due dates, early-pay discounts, cash availability, and vendor importance. Designed
for A/P teams running weekly or bi-weekly pay cycles.

**In plain words:** this answers two questions — *who do we owe, and how late are we?* and
*given the cash we actually have this week, who should we pay first?* An **aging** sorts
every unpaid bill by how overdue it is. A **payment run** is the batch of payments you send
out in one go.

This skill is **jurisdiction-agnostic** — it applies whatever terms and rules the user
identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every bill, balance, term, and
vendor name comes from a tool call against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled
as such.

**Mosofin is read-only.** It cannot send a payment, release a payment run, change a vendor's
bank details, or put a vendor on hold. Every payment run below is a *proposal* for a human to
review, approve, and execute in the banking or accounting system.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before any aging work. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a
client-side `mcp__…` namespace; that string is composed by whichever MCP client is running.

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

This gate carries real money risk in this skill: a payment run proposed from the wrong
entity's books is a list of payments the entity does not owe.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded** ("*Northwood Demo Books* is
  present but not active, so nothing it owes appears in this aging"). An aging that silently
  omits an entity understates what the group owes. Surface any `reconnect_url`.

A workspace can connect the **same platform several times** — several company files, plus
payment platforms. Each is its own row with its own `data_source_id` and `display_name`.
Payments are made **per legal entity from that entity's bank**, so the entity question here
decides whose money is being spent.

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`. Every aging line and every proposed payment carries
  its entity's `display_name`, **and each entity's payment run is constrained by its own
  cash** — never a pooled figure, unless the user explicitly confirms a shared treasury.

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

**The aging report deserves a specific note in this skill.** Whether a dedicated A/P aging
report is `enabled`, `permission`-gated, or `disabled` varies by workspace and by company
file, and it is common for the payables aging to carry a different policy from the
receivables one in the same catalog. Check it; never assume it from a sibling report.

There are then two very different fallbacks, and confusing them is the trap:

- **A legitimate reconstruction.** If the aging *report* is unavailable but bill-level data
  is not, you can **rebuild the aging from the underlying bills, payments and credits**
  (*`search_bills`*, *`search_bill_payments`*, *`search_vendor_credits`*). This is the same
  evidence the report is made from, so the result is genuine — but **label it as
  reconstructed**, and tie the total back to the A/P control balance
  (*`get_balance_sheet`*) so any gap is visible.
- **A near-substitute, which is not a substitute.** A **vendor balance** report is *not* an
  aging. It gives one total per vendor with no due-date buckets, so it cannot tell you what
  is overdue, what is due this week, or which discount expires on Friday — the three things
  this skill exists to answer. Never present a vendor balance report as an aging. If neither
  the aging report nor bill-level data is available, the task is `[manual]`: name the tool
  and ask for an open-bill export.

Also: **read the real tool name from the catalog, never from memory.** Names are not
uniformly styled — some underscored, some hyphenated — and in this skill you will reach for
both a bill search and a single-bill read, which are often styled differently in the same
catalog.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each
in-scope entity.

**Derive silently** what the profile answers:

- **Functional currency** — the base currency the books are kept in. Ask about currency only
  if the bills show more than one.
- Fiscal calendar, country / region, time zone — the time zone matters here, because a
  discount deadline is a date in *someone's* local time.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Open A/P / unpaid bills** | **Required — usually [auto]** | Normally pulled from the connected books. Ask what sits outside them (a bill not yet entered, another entity's ledger). |
| **As-of date for the aging** | **Required** | Never default it. The aging changes materially day to day. |
| **Cash available for the payment run** | **Required for payment-run mode** | **[gated]**: bank balances are usually readable, but *available* cash is a decision — it nets off committed payments, floats, and any minimum the business keeps back. Ask; do not read a bank balance and call it available. |
| **Vendor master / payment terms** | Recommended — usually **[auto]** | Terms are normally on the vendor record or the bill; ask only for what is missing. |
| **Vendor priority tier** (critical / standard / discretionary) | Optional — **[manual]** | The books do not know which supplier stops serving you first. Ask, and store it in Step 8. |
| **Early-pay discount terms** | Optional — usually **[auto]** | Normally derivable from the terms record; ask where terms are held outside the books. |
| **Payment method per vendor** (ACH / wire / cheque / card) | Recommended | Method names are often **[auto]**; the per-vendor mapping is usually **[manual]**. |
| **Aging buckets** | Recommended | Defaults are in Step 2; confirm if the entity uses different ones. |
| **Functional currency** | Recommended — usually derived | Ask only to resolve a contradiction or where several currencies appear. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | For each gap, ask whether the user can supply it, and how. |

**Minimum bill fields** — whatever the source, each bill needs:

- Vendor name
- Bill / invoice number
- Bill date
- Due date (or payment terms from which to compute it)
- Open amount (original − payments − credits applied)
- Currency

Where a pulled bill is missing one of these, it goes to the exceptions sheet — it is not
silently dropped from the aging.

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the
as-of date, the cash available, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only
what is new, changed, or contradicted. The vendor tiers and payment methods in particular
should not be re-asked every week.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical
evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the aging
report, the bill list, the payment history, the credit list and the terms catalogue do not
depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_aged_payables`* — the A/P aging, if its policy allows — **[auto]** or **[gated]**, or
  **[manual]** if disabled (then reconstruct, per Gate 2)
- *`search_bills`* — open bills, and the raw material for a reconstruction — usually **[auto]**
- *`get-bill`* — one bill's lines, terms and due date — usually **[auto]**
- *`search_bill_payments`* — what has already been paid against those bills — usually **[auto]**
- *`search_vendor_credits`* — credits available to net off — usually **[auto]**
- *`get_vendor_balance`* — total owed per vendor, for the tie-out — usually **[auto]**
- *`search_vendors`* / *`get-vendor`* — vendor master, terms, remit-to details — usually
  **[auto]**
- *`search_terms`* / *`get_term`* — the payment-terms catalogue, including discount terms —
  usually **[auto]**
- *`get_balance_sheet`* — the A/P control balance and the bank balances — usually **[auto]**
- *`search_payment_methods`* — the payment methods in use — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → reconstruct if bill-level data is available (labelled as such),
  otherwise convert to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the aging's shape
but **must never drive a real payment run**. A payment proposed from fixture data would be a
real transfer of real money against an imaginary bill. If any figure is mock, say so at the
top and mark the payment run as illustrative only.

## Step 1 — Parse and normalize

Get every bill into a consistent shape before you sort anything.

For each open bill — **[auto]**:

- **Confirm open amount > 0** (skip fully paid or fully credited bills)
- **Compute days outstanding = (As-of date) − (Due date)**
  - **Negative = not yet due**
  - **Positive = overdue**
- **Normalize currency labels**

Where the connector returns a bill without a due date, derive it from the terms record
(*`get_term`*, **[auto]**) and **say it was derived**, since a derived due date drives every
bucket downstream.

**Flag suspicious entries** — **[auto]**, all four are computable from the pulled data:

- **Open amount > original amount** (a data error)
- **Bill date after due date** (likely a terms entry error)
- **Bill dated in the future** (capture but flag)
- **Same vendor + same amount + same date appearing twice** (a possible duplicate — see
  `duplicate-invoice-detection`)

## Step 2 — Build the aging buckets

An **aging bucket** is a band of lateness. Sorting bills into bands is what turns a list of
debts into a picture of a problem.

Default buckets (override if the user specifies different ones):

- **Not yet due**
- **1 – 30 days overdue**
- **31 – 60 days overdue**
- **61 – 90 days overdue**
- **91 – 120 days overdue**
- **Over 120 days overdue**

Output by vendor and by bucket. **Totals per vendor and per bucket.**

**[auto]** whether the buckets come from the aging report directly or are computed from bill
dates. If they were computed, say so — a report-native aging and a reconstructed one can
differ where the report applies its own aging method (aging from the due date versus from the
report date), and that difference is worth naming rather than hiding.

## Step 3 — Identify early-pay discounts

Some suppliers knock a percentage off if you pay quickly. The return on doing so is usually
enormous, so this step often pays for the whole exercise.

For each bill, check the payment terms for an early-pay discount — **[auto]** where terms are
on the bill or the terms record (*`get-bill`*, *`get_term`*, *`search_terms`*).

**"2/10 Net 30" means: 2% discount if paid within 10 days, otherwise the full amount is due
in 30 days.**

For each bill with a discount opportunity — **[auto]** arithmetic:

- **Compute the last day to take the discount**
- **Compute the discount amount**
- **Compute the implied annualized return** on taking the discount versus waiting

Implied return formula:

```
Discount % × (365 / (Net days − Discount days))
```

Example: 2/10 Net 30 → 2% × (365 / 20) = ~36.5% annualized. **This is essentially always
worth taking if cash allows** — few uses of cash return 36% a year.

**Flag any discount where the deadline is within the payment-run horizon.** Use the entity's
time zone from the profile when a deadline falls on the run date itself.

## Step 4 — Identify late-pay penalties

**[gated]**: if the terms specify a late fee or interest, compute the accruing penalty for
overdue bills. Terms text is usually readable (*`get_term`*, **[auto]**), but penalty clauses
often live in the contract rather than the terms record — where that is so, the penalty is
**[manual]**.

**Flag bills accruing a penalty so the user can prioritize** — a bill quietly accruing
interest can outrank a larger one that is not.

## Step 5 — Prioritize the payment run (if cash is constrained)

When there isn't enough cash for everything, the order matters more than the total.

Rank in this default order (override if the user specifies) — **[gated]**, since the ranking
mixes ledger facts with business judgment:

1. **Vendors marked critical** — services that stop without payment: utilities, the payroll
   provider, key SaaS, a key supplier. **[manual]** input, from the tiers confirmed at Gate 3
2. **Bills past due where the vendor is threatening collection / late penalties are accruing**
   — **[auto]** for past-due status, **[manual]** for the threat
3. **Early-pay discount opportunities expiring within the run window** — **[auto]**, because
   the discount return is usually huge
4. **Bills due this week** — **[auto]**
5. **Bills due next week** — **[auto]**
6. **Already paid / not yet due / discretionary — defer** — **[auto]** for paid and not-due,
   **[manual]** for discretionary

**Constraint check: sum of proposed payments ≤ cash available. Stop adding payments when cash
runs out. Show what's left unpaid.** The unpaid remainder is not a footnote — it is the part
the user has to make a decision about, and it belongs on the face of the output.

Because Mosofin cannot execute anything, the run is a **proposal**. Say so on the sheet, and
never phrase a line as though a payment has been made or scheduled.

## Step 6 — Multi-currency handling

If bills are in multiple currencies and the entity pays from a single-currency bank —
**[gated]**:

- **Convert to the functional currency** at a user-provided FX rate or a stated source
  (e.g. the bank's wire rate today). **[manual]**: no accounting connector supplies a live
  wire rate, so the rate is the user's to give
- **Flag the rate source and the date used** — a converted figure without its rate and date
  cannot be checked later
- **Each payment will have an FX gain / loss at settlement** — the difference between the
  rate when the bill was booked and the rate when it is paid. Note it for
  `multicurrency-fx-revaluation`

## Step 7 — Output

Deliver an `.xlsx` workpaper. If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Sheet 1: Aging Summary**

By vendor, columns = aging buckets, rows = vendors. Totals row at bottom.

Add a header block: workspace name; each in-scope company file by `display_name`; each
excluded company file and why; the as-of date; **whether the aging was report-native or
reconstructed**; whether any figure rests on `mock` data.

**Sheet 2: Aging Detail**

| Vendor | Bill # | Bill Date | Due Date | Days Past Due | Bucket | Original Amount | Open Amount | Currency | Payment Terms | Discount Eligible? | Discount Deadline | Discount Amount | Late Penalty Accruing? | Vendor Tier | Payment Method | Status |

**Sheet 3: Proposed Payment Run**

| Vendor | Bill # | Payment Amount | Payment Method | Reason in Run | Discount Captured | Net to Pay |

With:
- Total proposed payment
- Cash available (input)
- Remaining cash after run
- Bills deferred to next run

Headed clearly: **proposal — no payment has been made or scheduled.**

**Sheet 4: Discount Opportunities**

All discount-eligible bills with deadlines, amounts, and implied annualized returns. Sorted
by return descending.

**Sheet 5: Exceptions**

Bills with data issues — flagged for cleanup before payment. Include bills missing any of the
minimum fields, and any due date that was **derived** rather than read.

**Sheet 6: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus supplied. One row per task in Steps 1–6:

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: the aging report may be enabled for one
company file and disabled for its sibling, so the same task can be `[auto]` for one and
reconstructed or `[manual]` for another.

**File naming:** `AP_Aging_and_PaymentRun_[YYYY-MM-DD].xlsx`

In a multi-entity run: `AP_Aging_and_PaymentRun_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus
one combined file named for the set. Every file states which datasource and `display_name` it
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

- The Gate 3 answers: aging buckets if non-default, functional currency, the run cadence
- **The vendor priority tiers** — critical / standard / discretionary, per vendor. This is the
  highest-value thing to carry forward, since it is pure judgment that the books never hold
  and it would otherwise be re-asked every single week
- **Payment method per vendor**, and any remit-to grouping for vendors that bill from several
  entities
- Standing holds and disputes, with the reason and the date opened — so a held vendor is not
  quietly paid next week by a fresh run
- The prioritization order, if the user overrode the default
- The replay recipe: the exact sequence of reads that produced this run

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Do not persist vendor bank account details.** Bank details are the top payment-fraud target
(see the edge case below); they belong in the accounting or banking system with its own
controls, never in a skill bundle.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Power Co: critical, ACH" — not "Power Co: critical". The same supplier
can be critical to one entity and discretionary to another, and an unlabelled tier applied to
the wrong company file reorders a real payment run. Record the chosen **scenario** (single vs
multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's;
state is the workspace's.** Cash available is *also* state, not a decision — it changes daily
and must be asked for every run, never recalled.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One aging, one payment
run, one workpaper.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every aging line and proposed payment carrying that entity's
`display_name`. Then one cross-entity step:

- **A side-by-side comparison plus a group total.** Total A/P does aggregate meaningfully —
  but **the payment runs do not**. Each entity pays from its own bank, so each run is
  constrained by that entity's own cash. Never propose paying one entity's bill from
  another's balance unless the user explicitly confirms a shared treasury arrangement, and
  even then label it as an intercompany funding decision, not a payment run line.
- **Shared vendors** are the point of the comparison: the same supplier owed by three
  entities may be a concentration risk, may be eligible for one negotiated discount, and may
  have three different tiers assigned. Show the vendor once per entity, labelled, plus the
  group total.
- **Intercompany payables** — where one entity owes another — should be flagged and settled
  through `intercompany-reconciliation`, not paid through a normal run.

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
| A/P aging with due-date buckets | `get_aged_payables` | `report_date`, `vendor`, `aging_method` (Current / Report_Date), `days_per_aging_period`, `num_periods` |
| Open bills (and the raw material to reconstruct an aging) | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One bill's lines, terms and due date | `get-bill` | `id` |
| Payments already made against bills | `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| One bill payment's detail | `get_bill_payment` | `id` |
| Credits available to net off | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Total owed per vendor (tie-out only, **not** an aging) | `get_vendor_balance` | `report_date`, `vendor` |
| Vendor master, remit-to, terms | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Payment-terms catalogue, incl. discount terms | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| Payment methods in use | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| A/P control balance and bank balances | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Bank and A/P accounts | `search_accounts` | `query`/`name`, `active_only` |
| Transaction detail behind the A/P balance | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Spend history per vendor (concentration, patterns) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Purchase orders behind a disputed bill | `search_purchase_orders` / `get_purchase_order` | `start_date`, `end_date` (required); `id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accounts payable (A/P)** — money you owe suppliers.
- **Aging** — a list of unpaid bills sorted by how overdue they are.
- **Aging bucket** — a band of lateness (e.g. 31–60 days overdue).
- **Days past due** — how long a bill has been overdue, counted from its due date.
- **Payment run** — a batch of supplier payments sent out together.
- **Payment terms** — the agreed rules for when and how a bill is paid.
- **2/10 Net 30** — 2% off if paid within 10 days; otherwise the full amount at 30 days.
- **Early-pay discount** — a reduction for paying sooner than required.
- **Implied annualized return** — the discount expressed as an annual rate of return, so it
  can be compared with other uses of the same cash.
- **Late-pay penalty** — a fee or interest charged for paying after the due date.
- **Credit memo** — a credit from a supplier that reduces what you owe them.
- **Credit hold** — deliberately withholding payment, usually pending a dispute.
- **Remit-to entity** — the legal entity a supplier wants to be paid to, which is not always
  the name on the invoice.
- **Control balance** — the single total in the general ledger that the detailed list must
  agree with.
- **Tie-out** — the proof that the detail and the control balance agree.
- **Functional currency** — the main currency the entity's books are kept in.
- **FX gain / loss** — the difference caused by the exchange rate moving between when a bill
  was booked and when it was paid.
- **ACH / wire / cheque / card** — ways of moving the money.
- **Discretionary** — a supplier you could delay paying without the business stopping.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Vendor on credit hold** (the entity is intentionally withholding payment pending a dispute):
exclude from the payment run; show on a separate "Held" tab. **[manual]** — a hold is a
decision, rarely a field in the books — so hold status must come from the user or from a
stored preference, and a hold that has been forgotten is how a disputed bill gets paid by
accident.

**Credit memos applied to specific bills**: net the credit against the bill. Show the original
amount, the credit applied, and the net open amount — not just the net, or the tie-out to the
control balance will not be checkable.

**Partial payments already in flight**: reduce the open amount by any in-process payment. Flag
if it has not yet cleared the bank. **[gated]**: the books show payments *recorded*; whether
one has actually cleared is a bank fact, and an uncleared payment recorded twice is a genuine
double-payment risk.

**Vendors with multiple billing entities**: group by **remit-to entity**, not just by vendor
name. Two vendor records with the same trading name may be different legal payees, and one
payee may bill under several names.

**Cross-border vendors with currency mismatch**: pay from a same-currency bank if one is
available; otherwise convert at the wire rate. Flag the FX cost.

**Vendor with both bills and credits open**: net to a single proposed payment — never pay
gross and wait for a refund of the credit.

**Bills approved but not yet due, where the vendor offers an early-pay discount**: surface them
in the discount tab even if the bill is not due in this run's window. The whole point of a
discount is that it expires before the due date.

**Statement-based vendors** (some prefer payment by statement total rather than per invoice):
group their bills and propose one payment with the list of bills it covers. Cross-check
against `vendor-statement-reconciliation` before paying a statement total.

**Bills with disputed line items**: pay the undisputed portion; flag the disputed amount on
hold. **[manual]** — a dispute is not a ledger field.

**Vendor change of bank details**: re-verify before sending payment to a new bank — **this is
the top payment-fraud vector**, and a convincing email asking to update bank details is the
most common way businesses lose money. Flag it and require user confirmation through a
channel the vendor did not supply. *Mosofin note*: Mosofin is read-only and cannot change,
verify, or transmit bank details, and this skill must never carry them into an output or a
stored preference.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say whose payables are therefore missing. Surface any `reconnect_url`.

**The aging report is `disabled` in this workspace** — *Mosofin-specific*. **Reconstruct** the
aging from bills, payments and credits, label it as reconstructed, and tie the total to the
A/P control balance. Do **not** substitute a vendor balance report: it gives one number per
vendor with no due-date buckets, which cannot answer what is overdue or which discount
expires this week.

**A reconstructed aging does not tie to the A/P control balance** — *Mosofin-specific*.
Report the gap rather than forcing the total. The difference is usually unposted bills,
bills outside the search window, or credits applied differently — say which you checked.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can illustrate the
aging but must never drive a payment run, because the payment would be real and the bill would
not be. Mark the run illustrative only.

**"Cash available" was read from a bank balance rather than confirmed** — *Mosofin-specific*.
A bank balance is not available cash: it has not netted off cheques in flight, imminent
payroll, or any minimum the business keeps back. Always ask; never infer.

**A bill has no due date in the books** — *Mosofin-specific*. Derive it from the terms record,
say that it was derived, and put the bill on the exceptions sheet. A derived due date drives a
bucket, a priority, and possibly a payment.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Aging buckets total to the A/P control balance** (note the figure for the tie-out)
- Every overdue bill is flagged with its days past due
- Every discount opportunity shows its deadline, amount, and implied return
- Proposed payment run totals ≤ stated cash available
- No bill appears twice (duplicates surfaced separately)
- Currency clearly identified per bill
- File naming consistent

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The aging states whether it is report-native or reconstructed**, and a reconstructed aging
  is tied to the A/P control balance with any gap explained
- A vendor balance report is never presented as an aging
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no bill and no task is silently dropped
- **Cash available was confirmed by the user, never inferred from a bank balance**
- Any derived due date is labelled as derived and listed in the exceptions sheet
- `mock` status is reported wherever it applies, and **no payment run rests on mock data**
- The payment run is labelled a **proposal**; no line implies a payment was made or scheduled
- **No vendor bank details appear in any output or stored preference**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional
  term kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- Every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system, and no payment was sent, scheduled, or released
