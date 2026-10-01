---
name: cash-flow-forecast-13-week
description: "Use this skill whenever the user wants a short-term cash flow forecast from their Mosofin workspace — classically a 13-week direct cash forecast for liquidity management. Triggers include: 'build a 13-week cash forecast', 'short-term cash flow', 'weekly cash projection', 'liquidity forecast', 'cash runway', 'will we run out of cash', 'TWCF', 'rolling 13-week', or any near-term cash planning. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds the forecast from live open invoices and bills — and derives each customer's actual historical days-to-pay rather than assuming they pay on the due date. Do NOT use for the GAAP cash flow statement — use cash-flow-statement-indirect-method. Do NOT use for annual forecasting — use rolling-forecast. Outputs a weekly direct cash forecast with receipts, disbursements, net cash, minimum-balance / covenant alerts, and a coverage sheet."
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
# 13-Week Cash Flow Forecast (Mosofin)

Builds a short-term, **direct-method** cash forecast (classically 13 weeks) for liquidity
management. Projects cash **receipts** and **disbursements** week by week, computes the running cash
balance, and flags liquidity risks. Essential for treasury, turnaround situations, and any
cash-constrained entity.

**In plain words:** profit is an opinion; cash is a fact. This forecast ignores accounting niceties
and asks one question, week by week: how much money will actually be in the bank? It is the tool
that tells you whether you can make payroll in seven weeks' time, and it is the first thing a lender
or a restructuring adviser asks for.

This skill is **direct method** — actual cash in and out, not accrual.

It is **not** system-agnostic. It is **workspace-scoped**: every opening balance, open invoice and
open bill comes from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## Why this skill fits a connected workspace particularly well

Most of the inputs are readable, and one of them matters more than all the rest.

**`[auto]` and strong:**

- **Opening cash by account** — the starting point of the whole chain
- **Open A/R with due dates** and **open A/P with due dates** — the bulk of both columns
- **Recurring receipts and disbursements** — derivable as a pattern from several months of history
  rather than typed from memory
- **Actual cash movement by week**, which makes the Step 7 forecast-versus-actual tracker automatic
  instead of a manual chore

**And the one that changes the forecast's quality most:**

> **Each customer's actual historical days-to-pay is derivable.** Invoice dates and the dates their
> payments were received are both in the books, so "this customer pays on average 15 days late" is a
> **measurement**, not an assumption. The original's own final quality standard is *"No optimistic
> collection assumptions that ignore payment behavior"* — in a connected workspace you can satisfy
> that with evidence rather than caution.

**`[manual]`:** the payroll schedule (unless payroll is connected), the debt service schedule, tax
payment due dates, the minimum cash threshold or covenant, the credit facility's terms, FX rates,
and every judgment about which payments could slip.

**Mosofin is read-only.** It cannot draw on a facility, schedule a payment, or defer anything. Every
lever below is a *proposal* for a human.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before forecasting anything. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

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
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`. In a cash
  forecast an excluded entity is not a presentational issue: its payroll and its bills are real
  outflows, and omitting them makes a tight forecast look comfortable.

Settle the entity scenario — and here it matters more than in most skills:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and ask the critical follow-up: is cash actually pooled?**
  Entities may hold separate bank accounts with no ability to move money between them without a
  formal intercompany loan. **A group forecast that nets one entity's surplus against another's
  shortfall is wrong unless the cash can genuinely move.** Run the forecast **once per entity**,
  every call targeting exactly one `data_source_id`, then consolidate only on an explicit
  confirmation that funds are transferable. See the cross-entity step.

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability map**
— built this run, held for this run, written out as the coverage sheet, **never** written into this
file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled —
  some underscored, some hyphenated — and the receivables and payables agings frequently carry
  different policies in the same catalog, which would leave you with one side of the forecast
  automated and the other not.
- **A near-substitute is not a substitute.** A **balance report** gives totals with no due dates,
  and this forecast is **entirely about dates**. Without due dates there is no week to place
  anything in. If the aging is disabled, reconstruct from invoice- and bill-level data (labelled as
  reconstructed), or mark it `[manual]`.
- **Check whether payment history is readable**, because that is what makes the days-to-pay
  derivation possible. If it is not, collection timing falls back to due dates plus a **stated**
  assumption — and the forecast is materially weaker, which should be said.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency, fiscal calendar, country / region, and
**time zone** — which decides which week a receipt near a boundary falls into.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Opening cash balance** — by account, as of the start date | **Required — usually [auto]** | Pulled. Confirm which accounts count as available cash, and **exclude restricted cash**. |
| **Forecast horizon** — default 13 weeks; can be 6, 8, 17, 26 | **Required** | Ask; see the seasonality edge case before defaulting to 13. |
| **AR / open invoices with expected collection timing** | **Required — [auto] for the invoices, [gated] for the timing** | Invoices and due dates pull; the expected pay date is derived from history and then confirmed. |
| **AP / open bills with payment timing** | **Required — [auto] for the bills, [manual] for the plan** | Due dates pull; **which bills you intend to pay when is a decision**, not data. |
| **Payroll schedule** — pay dates and amounts | **Required — [manual]** unless payroll is connected | Historical payroll outflows are visible and give the rhythm; the forward amounts are not. |
| **Recurring receipts and disbursements** — rent, debt service, taxes, subscriptions | **Required — partly [auto]** | Recurring patterns derive from history; **debt service and tax due dates are [manual]** and are exactly the lumpy items that breach a floor. |
| **Expected new sales / bookings cash timing** | Recommended — **[manual]** | |
| **Minimum cash threshold / covenant** — the floor to stay above | Recommended — **[manual]** | Ask for the covenant's **exact definition** of cash; see the edge case. |
| **Available credit facility** — undrawn revolver, etc. | Recommended — **[manual]** | Including borrowing-base mechanics and any clean-down requirement. |
| **Functional currency (and FX if multi-currency)** | Recommended — currency **[auto]**, rates **[manual]** | |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, **and whether cash is pooled**. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | Payroll, debt service, taxes, the floor and the facility will all be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the opening
balance, the floor, the payroll amounts, or the entity.

**On later runs** — and this forecast is meant to roll weekly — read stored preferences first
(Step 9), confirm in one line, and ask only what changed. The recurring schedule, the floor and the
facility terms should not be re-asked every week; **the collection-timing assumptions should be
re-derived**, because that is the whole point of the rolling discipline.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence — and in a cash forecast an omitted outflow is not a presentational gap, it is a
forecast that will be wrong in the direction that hurts.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the cash
balances, the two agings, the payment history and the recurring spend do not depend on each other.
Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — identify the cash and bank accounts, and any restricted ones — usually
  **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **opening cash by account** — usually **[auto]**
- *`get_aged_receivables`* — open invoices with due dates — usually **[auto]**
- *`get_aged_payables`* — open bills with due dates — usually **[auto]**
- *`search_invoices`* / *`read_invoice`* — invoice dates and terms, for the days-to-pay derivation
  — usually **[auto]**
- *`search_payments`* — **when invoices were actually paid**, the other half of that derivation —
  usually **[auto]**
- *`search_bills`* / *`search_bill_payments`* — bill dates and when they were actually paid, giving
  the entity's own payment behaviour — usually **[auto]**
- *`get_vendor_expenses`* over several months — the **recurring disbursement** pattern — usually
  **[auto]**
- *`get_general_ledger`* on the cash accounts — **actual weekly cash movement**, for the tracker and
  for the payroll rhythm — usually **[auto]**
- *`get_cash_flow`* — historical cash generation as a sanity check — usually **[auto]**
- *`search_customers`* / *`search_vendors`* — counterparty names for the detail sheets — usually
  **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it **must never drive a liquidity
decision**. A forecast on fixtures can look perfectly healthy while a real business misses payroll.

## Step 1 — Set up the weekly grid

**Columns = weeks (Week 1 through Week 13, with dates). Rows = cash flow categories. Direct method:
actual cash movements, not accruals or non-cash items.**

**Establish each week's start and end dates and the opening cash balance for Week 1.** **[auto]** for
the opening balance; **[gated]** for which accounts count — **restricted cash is excluded**, and a
deposit account you cannot access this week is not liquidity.

Use the entity's time zone when a week boundary falls near a payment date.

## Step 2 — Forecast cash receipts (cash in)

**Collections from AR (the biggest forecasting judgment)** — and the one this workspace supports
best:

- **Take open invoices with due dates** — **[auto]** (*`get_aged_receivables`*, *`search_invoices`*)
- **Apply expected collection timing based on customer payment behavior — not just due dates,
  because customers pay late** — **[auto]** to derive, **[gated]** to confirm
- **Use historical days-to-pay per customer or per segment** — **[auto]**: for each customer, compare
  invoice dates against the dates their payments were received (*`search_invoices`* against
  *`search_payments`*) over the last several months, and compute the average and the spread. Show
  the sample size; a days-to-pay from two invoices is not a pattern
- **For example: a customer who pays on average 15 days late → forecast collection 15 days after the
  due date** — with the derived figure, this stops being an example and becomes the method
- **Probability-weight uncertain collections** — **[gated]**; disputed and at-risk invoices are
  `[manual]` to identify

**Other receipts** — mostly **[manual]**, since they are future events:

- **New sales expected to close and be paid within the window**
- **Interest income** — **[auto]** as a historical run-rate
- **Tax refunds**
- **Asset sale proceeds**
- **Financing draws (if planned)**
- **Other one-time inflows**

**Place each receipt in the week it's expected to hit the bank (cash basis, not invoice date).**

## Step 3 — Forecast cash disbursements (cash out)

**Payroll (usually the most certain and critical)** — **[manual]** for forward amounts,
**[auto]** for the historical rhythm and magnitude (*`get_general_ledger`* on payroll accounts):

- **Net pay on each pay date**
- **Payroll taxes on their remittance dates** — a separate, later outflow, and easy to omit
- **Benefits on their dates**
- **Place in the exact weeks they clear**

**AP / vendor payments** — **[auto]** for the population, **[manual]** for the plan:

- **Open bills by planned payment date** (per `ap-aging-and-payment-runs`)
- **Prioritized payment runs**
- **Place in the week payment will be made (considering payment method clearing time)**

**Recurring / fixed disbursements** — **[auto]** to detect the pattern from history
(*`get_vendor_expenses`*, *`search_bills`* across months), **[manual]** to confirm amounts change:

- **Rent / lease payments**
- **Debt service (principal + interest) on scheduled dates** — **[manual]** for the schedule
- **Insurance**
- **Software subscriptions**
- **Utilities**

**Periodic / lumpy disbursements** — **[manual]**, and the ones most likely to breach a floor:

- **Tax payments (income, sales / VAT, payroll) on their due dates**
- **Annual / quarterly payments**
- **Capex**
- **Distributions / dividends**

**Place each in the exact week of expected cash outflow.**

**[auto]** contribution worth running: scan the prior twelve months for **large one-off outflows**
(*`get_general_ledger`* on the cash accounts) and check whether an anniversary of each falls inside
the horizon. Annual insurance, tax instalments and licence renewals are the classic forgotten items,
and they are visible in last year's cash.

## Step 4 — Compute the weekly cash position

For each week — **[auto]** arithmetic:

```
Opening cash (= prior week's closing)
+ Total receipts
− Total disbursements
= Net cash flow for the week
= Closing cash
```

**The closing cash of one week is the opening of the next. Run the chain across all 13 weeks.**

## Step 5 — Flag liquidity risks

Against the minimum cash threshold / covenant — **[auto]** to compute once the floor is supplied:

- **Weeks where closing cash < minimum threshold** → **red flag**
- **Weeks where closing cash goes negative** → **critical (insolvency risk)**
- **The lowest projected cash point (and which week)** — **the binding constraint**, and the single
  most important number in the whole output
- **Cash runway**: if cash is declining, **how many weeks until it hits zero / the floor**

**If a revolver or facility is available, show the draw needed to stay above the floor and the
resulting facility utilization.** **[manual]** for the facility's terms and availability.

State plainly whether the floor came from a covenant or from management preference — they carry
very different consequences when breached.

## Step 6 — Sensitivities and levers

Show how the forecast responds to — **[auto]** arithmetic:

- **Collections slipping** (e.g. AR comes in one week later than expected) — **often the biggest
  risk**, and with derived days-to-pay you can slip by the *observed spread* rather than an
  arbitrary week
- **A large receipt failing to materialize** — **[auto]** to identify which single receipt matters
  most, by testing each of the largest against the floor
- **Deferring discretionary disbursements** — which payments could slip if cash is tight
- **Accelerating collections** — early-pay discounts offered to customers

**Identify the controllable levers to manage through a tight week.** Which payments are genuinely
deferrable is **[manual]** — see the payroll edge case.

## Step 7 — Reconcile to actuals (rolling discipline)

Each week, compare the prior forecast to actual cash flows — **[auto]** for the actuals
(*`get_general_ledger`* on the cash accounts, *`search_payments`*, *`search_bill_payments`*):

- **Forecast vs. actual receipts (collection accuracy)**
- **Forecast vs. actual disbursements**
- **Variance explanation**
- **Roll the forecast forward one week** (Week 1 drops off, a new Week 13 is added)

**This rolling discipline sharpens collection-timing assumptions over time.** In a connected
workspace it does so mechanically: each week's actual receipts feed straight back into the
days-to-pay derivation, so the forecast improves without anyone maintaining a spreadsheet of
assumptions.

## Step 8 — Output

Deliver an `.xlsx` cash forecast workbook.

**Sheet 1: 13-Week Cash Forecast**

| Category | Wk 1 | Wk 2 | ... | Wk 13 | Total |

- Opening cash
- Receipts (by category)
- Total receipts
- Disbursements (by category)
- Total disbursements
- Net cash flow
- Closing cash
- Minimum threshold
- Headroom / (shortfall)

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one
and why; **whether cash is pooled**; whether any figure rests on `mock` data.

**Sheet 2: AR Collection Detail**

| Customer | Invoice | Amount | Due Date | Expected Collection Week | Confidence |

**Add:** the customer's **derived days-to-pay** and the **sample size** it came from, so the
expected week is auditable rather than asserted.

**Sheet 3: AP / Disbursement Detail**

| Vendor / Item | Amount | Due Date | Planned Payment Week | Priority |

**Sheet 4: Liquidity Alerts**

Weeks below threshold; lowest cash point; runway; facility draws needed.

**Sheet 5: Sensitivities**

Collections-slip, missed-receipt, and lever scenarios.

**Sheet 6: Forecast vs. Actual Tracker**

Rolling accuracy of prior weeks.

**Sheet 7: Coverage — NEW, Mosofin-specific**

| Line or assumption | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Sample / periods used | Policy | `mock` | Gap — what could not be evidenced and who supplied it |

The rows for payroll, debt service, tax dates, the floor and the facility will read `manual`. **Those
are the lines that breach floors**, so their gaps must be visible, not buried.

**Build with live formulas so the chain recalculates as inputs change.** This matters more here than
almost anywhere: the forecast is used interactively in a meeting, with people asking "what if that
receipt slips a week?"

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `13Week_Cash_Forecast_[YYYY-MM-DD].xlsx`

In a multi-entity run: `13Week_Cash_Forecast_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus a group
file **only where cash is pooled**. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

This forecast rolls **weekly**, so the evolution step pays back faster here than in any other skill
in the pack.

On an explicit yes, persist the **decisions**:

- **The recurring schedule**: rent, debt service, insurance, subscriptions, tax instalment dates —
  with their amounts, dates and frequency. The single biggest time saving on every subsequent run
- **The payroll calendar**: pay dates, the tax remittance lag, and benefit payment dates
- **The minimum cash threshold**, whether it is a covenant or a management floor, and **the
  covenant's exact definition of cash**
- **The facility terms**: limit, borrowing-base mechanics, clean-down requirements, interest
- **Which accounts count as available cash** and which are restricted
- **Which disbursements are deferrable** and in what order — the lever list, agreed once when calm
  rather than improvised when tight
- **The days-to-pay derivation method** — the lookback window and the segmentation. **Not the
  derived values**: those are re-derived every week, which is the entire point
- The horizon, if not 13 weeks
- The replay recipe: the exact sequence of reads that produced this forecast

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist cash balances, the forecast itself, customer-level collection data, or facility
utilisation.** A distressed entity's cash position is highly sensitive, and a stale one is
misleading. Persist the *schedule, the thresholds and the method*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — floor $250k (covenant, tested weekly, cash net of restricted); payroll 15th and
last day; days-to-pay from trailing 6 months by customer" — not "floor $250k". Entities have
different covenants and different payroll calendars, and an unlabelled floor applied to the wrong
company file produces a false alarm or, worse, a missed one. Record the chosen **scenario** (single
vs multi, whether pooled, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and a cash balance is emphatically state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that
is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One grid, one floor, one runway.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every receipt and disbursement carrying that entity's `display_name`. Then:

- **Consolidate only if cash is genuinely pooled.** This is the decisive question, asked at Gate 1.
  Where entities hold separate accounts and cannot move money freely, **a group total is a fiction**:
  one entity can breach its floor while the group looks comfortable. Present per-entity forecasts
  first, always, and the group total only with an explicit statement that funds are transferable.
- **Where cash can move, model the transfer explicitly** — as an intercompany movement in a named
  week, out of one entity and into another, not as a silent netting. It has tax and legal
  consequences and someone must actually do it.
- **Each entity has its own floor and its own covenant.** Test each separately. A group headroom
  figure hides a component breach, and covenants are tested at the entity that signed them.
- **Intercompany payments between entities in scope are both an outflow and an inflow** in the same
  week. Include both legs or one entity's forecast is wrong.
- **Payroll is per entity.** It cannot be met from a sibling's account without a real transfer.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each line's verdict per
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
| Identify cash / bank accounts, and restricted ones | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Opening cash by account** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Open invoices with due dates | `get_aged_receivables` | `report_date`, `customer`, `aging_method`, `num_periods` |
| Open bills with due dates | `get_aged_payables` | `report_date`, `vendor`, `aging_method`, `num_periods` |
| **Invoice dates and terms** (days-to-pay numerator) | `search_invoices` / `read_invoice` / `get_term` | `start_date`, `end_date` (required), `customer_id`; `id` |
| **When invoices were actually paid** (days-to-pay denominator) | `search_payments` / `get_payment` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Bill dates and when bills were actually paid | `search_bills` / `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| **Recurring disbursement patterns** | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| **Actual weekly cash movement; payroll rhythm; annual one-offs** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Historical cash generation (sanity check) | `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by` |
| Deposits and transfers between own accounts | `search_deposits` / `search_transfers` | `start_date`, `end_date` (required) |
| Counterparty names for the detail sheets | `search_customers` / `search_vendors` | `query`/`name`, `active_only` |
| Credits reducing expected collections | `search_credit_memos` | `start_date`, `end_date` (required), `customer_id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **13-week cash flow (TWCF)** — the standard short-term liquidity forecast, week by week.
- **Direct method** — forecasting actual money in and out, rather than starting from profit.
- **Receipts / disbursements** — cash coming in / going out.
- **Opening and closing cash** — the balance at the start and end of each week; one week's closing
  is the next week's opening.
- **Runway** — how long the cash lasts at the current rate.
- **Minimum cash threshold / floor** — the balance you must not go below, by policy or by covenant.
- **Headroom** — how far above the floor you are.
- **Covenant** — a promise to a lender, often that cash or a ratio stays above a level. Breaching it
  can make the loan repayable immediately.
- **Revolver** — a credit facility you can draw on and repay repeatedly.
- **Borrowing base** — the formula limiting how much of a facility you may actually draw, usually
  based on receivables and inventory.
- **Clean-down** — a requirement to repay a facility to zero for a period each year.
- **Days-to-pay** — how long a customer actually takes to pay, measured from invoice or due date.
- **Float / clearing time** — the delay between initiating a payment and the money moving.
- **Probability-weighting** — including an uncertain receipt at less than its full value.
- **Debt service** — scheduled loan repayments of principal and interest.
- **Capex** — spending on long-lived assets.
- **Distributions / dividends** — payments out to owners.
- **Earn-out** — a deferred payment on an acquisition, contingent on performance.
- **Restricted cash** — cash you cannot freely use, so not liquidity.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Turnaround / distressed situation**: this forecast becomes **the central management tool**. Higher
rigor, daily or weekly updates, **conservative collection assumptions**, and explicit
creditor-payment prioritization. Often required by lenders or restructuring advisors. *Mosofin note*:
here the derived days-to-pay matters most — under stress, customers of a distressed supplier often
pay *slower*, so use the recent window rather than a long average, and say which you used.

**Customer concentration**: if one large customer's payment timing dominates the forecast, **model it
explicitly and stress-test a delay.** *Mosofin note*: concentration is directly measurable
(*`get_customer_sales`*, *`get_aged_receivables`*) — quantify it rather than asserting it.

**Seasonal cash cycles**: a 13-week window may sit entirely within a high or low season — **extend
the horizon if the window misses a critical inflection** (e.g. a large seasonal collection just past
week 13). *Mosofin note*: last year's monthly cash movement shows where those inflections fall.

**Multi-currency cash**: forecast each currency separately if the entity holds and spends in
multiple currencies; consolidate at forecast FX. **FX timing on conversions matters.**

**Lumpy large payments** (tax, debt maturity, earn-out): **a single large outflow can breach the
floor in one week even if the trend is healthy. Highlight these explicitly.** They are also the most
common omission — check last year's cash for anniversaries falling inside the horizon.

**Revolver mechanics**: model the **borrowing-base availability**, draw / repay timing, and interest.
**Some facilities have weekly clean-down requirements.** Undrawn capacity is not the same as
available capacity.

**Disputed / at-risk receivables**: **don't forecast collection of disputed invoices at full
confidence**; probability-weight or exclude. *Mosofin note*: dispute status is `[manual]` — the books
do not flag it, and an old invoice is not evidence of a dispute.

**Payment float / clearing time**: a cheque or ACH takes days to clear. **Place the cash impact in
the week it actually clears, not the week it's initiated.**

**Payroll is sacrosanct**: in a tight forecast, **payroll and statutory remittances are typically
non-deferrable. Model other payments as the flex.** Never present a lever list that includes payroll.

**Forecast feeding a covenant certificate**: if a minimum-liquidity covenant is tested, **ensure the
forecast aligns with the covenant's exact definition of cash / liquidity** — which may exclude
restricted cash, may include undrawn facility, or may be measured on a different day.

**Collection timing was assumed rather than derived** — *Mosofin-specific, and the biggest quality
lever here*. If payment history is readable, derive days-to-pay per customer and show the sample
size. Forecasting collection on the due date is the optimism the final quality standard forbids.

**A days-to-pay derived from too few invoices** — *Mosofin-specific*. Two invoices is not a pattern.
State the sample size, and fall back to a segment average or a stated assumption where it is thin.

**Restricted cash included in opening balance** — *Mosofin-specific*. A cash account in the chart of
accounts is not necessarily available cash. Confirm which accounts count.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose payroll and bills are therefore missing. In this skill that omission flatters the forecast.
Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A forecast on fixture data can look
healthy while a real business misses payroll. Never let it drive a liquidity decision.

**Cash is not actually pooled across entities** — *Mosofin-specific*. Do not net one entity's surplus
against another's shortfall without confirming funds can move, and model any transfer explicitly.

**A stored recurring item has ended or changed** — *Mosofin-specific*. A lease that expired will
otherwise be forecast forever. Re-check each stored recurring item against recent actuals every run.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Direct method**: actual cash in / out by week, no accruals or non-cash items
- **Receipts timed to expected bank dates (using payment behavior, not just due dates)**
- Disbursements timed to actual clearing weeks
- **Weekly chain ties (closing = next opening)**
- **Lowest cash point and runway identified**
- Threshold / covenant headroom shown each week
- Sensitivities on collection timing and key levers
- Rolling forecast-vs-actual tracking
- Live formulas
- File naming consistent
- **No optimistic collection assumptions that ignore payment behavior**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **Collection timing is derived from the entity's own payment history where readable**, and each
  customer's days-to-pay is shown **with its sample size**; where it was assumed instead, that is
  stated
- **Opening cash names the accounts included and excludes restricted cash explicitly**
- Lumpy annual outflows were checked against the prior year's cash for anniversaries inside the
  horizon
- Every line carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and the periods
  it drew on, in the coverage sheet
- **`[manual]` lines — payroll, debt service, taxes, the floor, the facility — are listed
  prominently**, because those are the lines that breach floors
- The floor states whether it is a covenant or a management preference, and covenants state their
  exact cash definition
- **No lever list includes payroll or statutory remittances**
- In a multi-entity run, **the group total appears only where cash is confirmed pooled**, and every
  transfer is modelled explicitly
- `mock` status is reported wherever it applies, and **no liquidity decision rests on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No cash balances, forecasts, customer collection data or facility utilisation are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every draw, deferral and transfer is a proposal for a
  human
