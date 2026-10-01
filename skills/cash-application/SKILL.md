---
name: cash-application
description: "Use this skill whenever the user wants to apply customer payments to open invoices, working from their Mosofin workspace. Triggers include: 'apply these customer payments', 'cash app this remittance', 'match payments to invoices', 'allocate this wire to invoices', 'process the lockbox file', 'short pay handling', or uploading a deposit / receipt file alongside open invoices. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then reads the open invoice population and the customer master directly and proposes matches — while naming plainly that lockbox files, remittance advices and bank statements sit outside any accounting datasource. Do NOT use for processing refunds — use credit-memo-and-refund-handler. Do NOT use for the bank reconciliation itself — use bank-reconciliation. Outputs an application schedule, the corresponding proposed JE, exceptions for unidentified or short payments, and a coverage sheet."
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
# Cash Application (Mosofin)

Applies customer payments to specific open invoices. Handles **partial payments, short pays, lump
payments covering multiple invoices, lockbox files, and unidentified deposits**.

**In plain words:** money arrives from a customer. Somebody has to decide which invoices it was
meant to pay. That sounds trivial and is not: the name on the bank line often isn't the customer's
name, the amount often doesn't match any single invoice, and when it is short you have to work out
whether that is a discount, a bank fee, a tax withheld at source, or a complaint nobody told you
about. This skill does that matching and writes the entry.

This skill is **jurisdiction-agnostic** — it applies whatever tax and discount rules the user
identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every invoice, payment, customer and
account name comes from a tool call against a company file connected to your Mosofin workspace in
this conversation, or from something you supplied by hand and that is labelled as such.

**Related skill:** `ar-cash-application-lockbox` covers the same ground from the **operations**
angle — the deduction-case workflow, the unapplied-cash aging, and the daily tie-out to bank
deposits. **This skill covers the matching logic and the resulting journal entry in detail.** Use
whichever fits the question; they share the same evidence base and should agree.

**The structural limit, stated up front.** Mosofin connects the **accounting system**. It reads
payments **once they are recorded** and it reads the **open invoice population** in full. It cannot
read a **lockbox file**, a **bank statement**, a **remittance advice** arriving by email or EDI, or
a **payment processor's settlement report** — unless that processor is itself a connected
datasource.

So the honest shape here is:

- **`[auto]` and strong**: the open invoice population with balances and dates; the customer master
  for fuzzy payer matching; payments already recorded and what they were applied to; credit memos
  that may explain a short pay; the deposit-versus-receipts comparison that reveals a netted fee.
- **`[manual]`**: the incoming payment file itself where payments are not yet recorded, every
  remittance advice, FX rates, and withholding tax certificates.

**Mosofin is read-only.** It cannot apply a payment, create a customer credit, post a write-off, or
move anything out of unapplied cash. Every application below is a *proposal* for a human.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before matching anything. This ordering is the contract. Do
not skip a gate because a previous conversation covered it — connections, permissions, and company
files change between runs.

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

**Check for a connected payment processor.** It converts the batch-settlement edge case from
`[manual]` guesswork into readable gross sales, fees, refunds and chargebacks — see
`merchant-and-payment-processor-rec`.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every payment, match and exception carries its entity's
  `display_name`. **Never apply one entity's receipt to another entity's invoice.** The legitimate
  version of that — a customer paying one lump sum covering invoices from several group companies —
  is handled explicitly in the cross-entity step, split and labelled.

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
  some underscored, some hyphenated.
- **A near-substitute is not a substitute.** A **customer balance** report gives one total per
  customer; cash application needs the **invoice-level** open population, because the whole task is
  deciding *which* invoice. A balance report cannot support level-2 or level-3 matching at all. If
  the invoice search is disabled, this skill cannot run on live data — say so and request an open
  invoice export.
- **The invoice search usually requires a date range.** Old unpaid invoices are precisely the ones
  a payment may be settling, so a default recent window will silently exclude them. Use the aging
  report as the population where it is available, and state the window you searched.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency (which determines whether Step 5
applies at all), fiscal calendar, country / region, **time zone** — which decides which day a
receipt falls on.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Customer payments / receipts** — deposit listing, lockbox file, processor export | **Required** | **[auto]** for payments already recorded in the books; **[manual]** for a file of payments not yet entered. Ask which population you are working on — they are different jobs. |
| **Open A/R invoices** | **Required — usually [auto]** | Normally pulled. Confirm the as-of date. |
| **Remittance advice** — if separate from the payment data | Recommended — **[manual]** | The single biggest driver of match quality. Ask whether any exist and where. |
| **Customer master** — helps fuzzy-match payer names | Recommended — usually **[auto]** | Pulled. Ask only for known payer aliases the books do not hold. |
| **Tolerances for short / over pay** — currency amount or % | Optional — **[manual]** | **Default exact** if not supplied, and say that is what you did. |
| **Tax jurisdiction** | Optional — **[manual]** | Needed only where withholding at source applies. |
| **FX rates** at the receipt date | Required if currencies differ — **[manual]** | No accounting connector supplies a rate; ask for the rate and its source. |
| **Application order default** — oldest-first (FIFO) or otherwise | Recommended | Step 2 level 3 and 4 both depend on it. Confirm rather than assuming. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | Remittances, FX rates and tax certificates will be among them. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the FX rate,
the tolerance, or the entity.

**On later runs**, read stored preferences first (Step 8), confirm in one line, and ask only what is
new, changed, or contradicted. The payer-alias map and the tolerance should not be re-asked daily.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the open
invoices, the customer master, the recorded payments and the credit memos do not depend on each
other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_aged_receivables`* — the **complete** open invoice population, including old items — usually
  **[auto]**
- *`search_invoices`* / *`read_invoice`* — invoice detail: number, dates, original amount,
  paid-to-date, open balance, currency, customer PO reference — usually **[auto]**
- *`search_customers`* / *`get_customer`* — the customer master, for fuzzy payer matching — usually
  **[auto]**
- *`search_payments`* / *`get_payment`* — payments already recorded and what they were applied to —
  usually **[auto]**
- *`search_deposits`* / *`get_deposit`* — how receipts were banked, and the netted-fee check —
  usually **[auto]**
- *`search_sales_receipts`* — receipts with no invoice behind them — usually **[auto]**
- *`search_credit_memos`* — credits that may explain a short pay — usually **[auto]**
- *`search_terms`* / *`get_term`* — payment terms, to identify a legitimate early-pay discount —
  usually **[auto]**
- *`search_accounts`* — the unapplied cash, customer credit, discount, bank fee, WHT and FX accounts
  — usually **[auto]**
- *`search_payment_methods`* — how methods are labelled here — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the matching logic but
**must never drive a real application or write-off**, which would show a real customer as paid when
they have not paid.

## Step 1 — Parse payments and invoices

For each payment — **[auto]** where recorded, **[manual]** from a file:

- **Date received** — use the entity's time zone for receipts near midnight
- **Amount**
- **Currency**
- **Payer name** — *often differs from the customer's legal name — it is a bank string*, truncated
  and upper-cased. This mismatch is the main cause of unmatched cash
- **Payment method** (wire, ACH, card, cheque, processor)
- **Reference field** (invoice #, statement #, PO #)

For each open invoice — **[auto]**:

- **Customer, invoice #, date, due date, original amount, paid-to-date, open balance, currency**

**Use the open balance, not the original amount**, for matching. An invoice part-paid last month
will never match on its original figure.

## Step 2 — Match payments to invoices

**Match hierarchy (stop at the highest-confidence match).** Record which level produced each match —
a level-1 and a level-5 match are not the same claim.

**1. Reference field cites the invoice number** → **exact match, apply.** **[auto]**
(*`search_invoices`* by document number). Always the best answer when available.

**2. Payer name + amount matches a single open invoice** → **high confidence.** **[auto]**. Check
first whether two open invoices share that amount; if so this is not unambiguous.

**3. Payer name + amount matches the sum of multiple open invoices** → **lump payment, apply to
those invoices (oldest first by default unless the customer specified).** **[auto]** to find
combinations; **[gated]** to choose, because several combinations can sum to the same total. Report
the combination selected and whether another existed.

**4. Payer name only matches; amount differs** — **[gated]**:

- **Amount > total open** → **overpayment**; apply to all open, leftover = customer credit
- **Amount < total open** → **partial**; apply to oldest (**FIFO**) unless specified
- **Amount = a subset of invoices** → apply to those

**5. Amount matches multiple customers' invoices** → **ambiguous; request remittance advice from the
customer or use bank string clues.** **[manual]** to resolve. Never pick one.

**6. No match** → **unidentified deposit. Park in a "Customer Deposits — Unidentified" account, hold
for research.** **[auto]** to identify what already sits there and how long it has been there
(*`search_accounts`*, *`get_general_ledger`*).

**Apply fuzzy matching for payer names (string similarity ≥ 0.85).** **[auto]** against the customer
master (*`search_customers`*). Common variants:

- **"ABC Corporation" vs "ABC CORP"** → match
- **"John Smith" paying for "Smith Consulting LLC"** → **flag** — a person paying for a company is a
  real relationship but not a name match, and it needs confirming once, then storing as an alias
- **Bank truncation ("ACME C")** → match against customers starting with "ACME C"

Present every fuzzy match with its similarity score and the alternatives considered. **Never
auto-accept below the threshold**, and store confirmed aliases at Step 8 so the same puzzle is not
re-solved every month.

## Step 3 — Short pay handling

When a customer pays less than the invoice total, the reason determines the accounting. Guessing
wrong either hides a dispute or writes off money you were entitled to.

| Reason | Treatment |
|--------|-----------|
| **Customer-claimed deduction** (damage, shortage) | Apply payment, leave residual open as **"Disputed"** pending investigation |
| **Early-pay discount taken** | Apply payment + book **Sales Discount** for the difference **if terms allowed it** |
| **Bank fee deducted** (cross-border wires often deduct) | Apply payment + book **Bank Fee** for the difference |
| **Withholding tax deducted** (cross-border) | Apply payment + book **Withholding Tax Receivable** for the difference, **pending tax certificate** |
| **Rounding / FX difference** | Apply payment + book **FX Gain/Loss** for the difference |
| **Unknown reason** | Apply payment, leave residual open, **flag for collections follow-up** |

**Distinguish carefully — short pays without explanation are different from short pays with a
documented reason.**

**[auto]** contributions that materially narrow the guesswork:

- **Check for an outstanding credit memo** first (*`search_credit_memos`*) — a short pay matching a
  credit is not a deduction at all
- **Check the invoice's terms** (*`get_term`*, *`read_invoice`*) — a discount taken **within** the
  discount window on terms that offer one is evidenced, not assumed; a "discount" taken outside the
  window is an unauthorised deduction and belongs in the last row, not the second
- **Check the deposit against its receipts** (*`get_deposit`*) — a shortfall at deposit level rather
  than payment level points to a bank or processor fee

The reason itself, where none of those apply, is **[manual]**.

## Step 4 — Overpayment handling

When a customer pays more than the open invoices:

- **Apply to all open invoices**
- **Park the excess in "Customer Credit" or "Unapplied Cash"**
- **Don't book the excess as revenue** — it isn't yours yet; it is money you owe back or owe goods
  for
- **Flag for application against future invoices or refund**

**[auto]** to check first for a **duplicate payment** — a customer paying the same invoice twice
looks identical to one overpaying once (*`search_payments`* for a matching earlier receipt). The
remedies differ: a duplicate is usually refunded, an overpayment usually held.

## Step 5 — Multi-currency

If the payment currency ≠ the invoice currency — **[gated]**:

- **Use the receipt date's FX rate to convert** — **[manual]**; no accounting connector supplies a
  rate. Record the rate and its source
- **Book FX gain/loss** for any difference between (invoice converted at the invoice rate) and (cash
  converted at the receipt rate)
- **Apply the payment to the invoice in the invoice currency at the converted equivalent**

**[auto]** to detect that the step applies at all: compare the currencies on the payment and the
invoice.

## Step 6 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — this is a proposal.

Per payment:

```
DR  Cash / Bank                             $payment amount
    CR  Accounts Receivable                    $applied to invoices
    CR  Customer Credit / Unapplied (if overpay) $overpay
    DR  Sales Discount (if discount taken)
    DR  Bank Fee (if fee withheld)
    DR  Withholding Tax Receivable (if WHT)
    DR/CR  FX Gain/Loss (if multi-currency)
Memo: Cash application — [Customer] — [Reference]
```

**Every sub-component appears on its own line.** Netting a bank fee into the cash line hides a real
cost; netting a discount into A/R hides a real margin reduction. Use the **real account names from
the connected chart of accounts** (*`search_accounts`*, **[auto]**), and say which you chose.

## Step 7 — Output

Deliver an `.xlsx` workpaper. If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Sheet 1: Application Summary**

- Total payments processed
- Total applied to invoices
- Total parked as customer credit / unapplied
- Total in unidentified deposits
- Short-pay residuals open

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one
and why; **which population was processed — recorded payments or a supplied file**; whether any
figure rests on `mock` data.

**Sheet 2: Payment-to-Invoice Mapping**

| Payment ID | Date | Payer | Amount | Currency | Invoice # | Applied Amount | Residual | Match Type | Confidence |

**Match Type** is the hierarchy level (1–6); **Confidence** carries the fuzzy-match score where one
was used.

**Sheet 3: Exceptions**

| Payment ID | Issue | Recommended Action |

Issues:
- **Unidentified** — needs research
- **Short pay** — needs collection follow-up
- **Overpay** — needs credit / refund decision
- **Multi-customer ambiguous**

**Sheet 4: GL Posting**

Pass-through to `journal-entry-builder`, marked clearly as **proposals**.

**Sheet 5: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

Rows for remittance advices, FX rates and withholding tax certificates will read `manual` with their
gaps named. That is the correct, expected result.

In a multi-entity run this sheet is **per entity**.

**File naming:** `Cash_Application_[YYYY-MM-DD].xlsx`

In a multi-entity run: `Cash_Application_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus one combined
file. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The payer-alias map** — every confirmed bank string, truncation and third-party payer against
  its customer. The highest-value artefact here by a wide margin: it is pure accumulated knowledge,
  never in the ledger, and it directly reduces unidentified cash on every future run
- **Tolerances** for short and over pay, and the application order (FIFO or otherwise)
- **The account mapping**: unapplied cash, customer credit, sales discount, bank fee, withholding
  tax receivable and FX accounts, by their real names
- **Customers who habitually withhold tax at source**, and the jurisdiction and rate
- **Customers who pay by statement or by PO** rather than invoice number
- Standing disputes and their owners
- The replay recipe: the exact sequence of reads that produced this run

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist bank account numbers, payment-level data, customer balances, or remittance
contents.** Those are transaction records; persist the *aliases and the rules*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — payer 'NRTHWD TRDG LTD' = Northwood Trading; tolerance $5; FIFO" — not "payer
alias". The same bank string can belong to different customers at different entities, and a
misapplied alias credits the wrong company. Record the chosen **scenario** (single vs multi, and
which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that
is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One application schedule, one JE
set.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every payment and match carrying that entity's `display_name`. Then one
cross-entity step:

- **The lump payment covering several entities' invoices** is the genuine cross-entity case, and it
  is common where a group bills one customer from more than one company. **Split it explicitly by
  entity**, show the split and its basis, and never let one entity's books absorb the whole receipt.
  Each entity's portion is applied against that entity's own open invoices only.
- **A parent paying on behalf of subsidiaries** is the same shape — apply to the subsidiary's
  invoices, capture the parent as payer-of-record, and record the alias per entity.
- **A shared bank account across entities** makes attribution ambiguous by design. Say so rather
  than allocating silently.
- **Compare unidentified-cash levels across entities** — one entity with far more than its siblings
  usually has a payer-naming or remittance problem rather than a customer problem.

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
| `create_skill` | Persists the evolved skill. Step 8. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The complete open invoice population** | `get_aged_receivables` | `report_date`, `customer`, `aging_method`, `num_periods` |
| Invoice detail: balance, dates, PO reference | `search_invoices` / `read_invoice` | `start_date`, `end_date` (required), `customer_id`, `query`/`name` (DocNumber); `id` |
| Customer master (fuzzy payer matching) | `search_customers` / `get_customer` | `query`/`name`, `active_only`; `id` |
| Payments recorded and their application | `search_payments` / `get_payment` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Deposits, and the netted-fee check | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| Receipts with no invoice behind them | `search_sales_receipts` / `get_sales_receipt` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Credits that may explain a short pay | `search_credit_memos` / `get_credit_memo` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Refunds already issued | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required); `id` |
| Terms, to evidence a legitimate early-pay discount | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| Balance per customer (tie-out) | `get_customer_balance` | `report_date`, `customer` |
| Unapplied cash, credit, discount, fee, WHT, FX accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Movement on unapplied cash (aging it) | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Payment methods in use | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Cash application** — deciding which invoices an incoming payment settles.
- **Remittance advice** — the customer's note saying which invoices a payment covers.
- **Lockbox** — a bank service that receives and banks your customer payments for you.
- **Payer name / bank string** — the name as the bank shows it: often truncated, upper-cased, and
  not the customer's legal name.
- **Short pay** — the customer paid less than the invoice.
- **Overpay** — the customer paid more.
- **Unapplied cash** — money received but not yet matched to an invoice.
- **Customer credit** — money held on a customer's account for future use.
- **Customer deposit** — money received before an invoice exists. Not revenue.
- **FIFO** — first in, first out: apply to the oldest invoice first.
- **Fuzzy matching** — matching names that are similar but not identical, with a similarity score.
- **Sales discount** — a reduction for paying early, recorded as a cost.
- **Trade discount** — a price reduction already built into the invoice; not recorded separately.
- **Withholding tax (WHT)** — tax the customer deducts and pays to their government on your behalf.
  You get a credit for it once they give you a **tax certificate**.
- **FX gain / loss** — the effect of the exchange rate moving between invoicing and payment.
- **Correspondent / intermediary bank** — a bank in the middle of a cross-border transfer that may
  take its own fee.
- **Batch settlement** — one bank deposit covering many card payments, net of fees.
- **Chargeback** — a card issuer reversing a payment.
- **NSF (non-sufficient funds)** — a payment that bounced.
- **Journal entry (JE)** — the balanced two-sided record. **DR** = debit, **CR** = credit.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Lockbox files**: typically standardized formats from banks. Map fields to invoices automatically.
Some lockboxes include OCR'd remittance — **use it.** *Mosofin note*: the file itself is `[manual]`;
once its rows are supplied, matching against the open population is `[auto]`.

**Payment processor batch settlements** (Stripe, Square, PayPal): **one bank deposit = many customer
payments minus processor fees.** Decompose the gross sales, fees, refunds and chargebacks — see
`merchant-and-payment-processor-rec`. *Mosofin note*: if the processor is connected, this is
`[auto]`; if not, the deposit-versus-receipts comparison still detects that netting occurred, even
without the settlement report.

**Payment for an invoice not yet in the system**: **hold as a customer deposit; apply when the
invoice is created.** Do not force it onto an unrelated open invoice.

**Partial payment with no explanation**: **do not auto-write-off the residual.** Leave it open, flag
for collections.

**Payment from a related entity / parent paying on behalf of a subsidiary**: apply to the
subsidiary's invoices; **capture the parent as payer-of-record.** Coordinate with intercompany — see
`intercompany-reconciliation`.

**Reversed payment / NSF**: **reverse the cash application JE, restore the invoice to open, charge
any bank NSF fee.** *Mosofin note*: an invoice that reverts to open after being marked paid is
detectable in the payment history — check for it before treating a re-received payment as new.

**Customer pays in advance for not-yet-issued invoices**: **customer deposit, not revenue.** Hold
until the invoice is issued.

**Cross-border wire with intermediary bank fees deducted multiple times**: each correspondent bank
may take a cut. **Reconcile against the customer's intended amount, not just the entity's gross
receipt** — otherwise a series of small deductions looks like a customer dispute.

**Trade discounts vs. early-pay discounts**: trade discounts are typically **already netted in the
invoice**; only book **early-pay** discounts as a sales discount expense. *Mosofin note*: the
invoice and its terms are both readable, so which one applies is usually evidenced rather than
assumed.

**Withheld tax at source**: customers in some jurisdictions withhold tax. The entity received less
cash but gets a **withholding-tax credit**. **Track WHT receivable; reconcile to tax certificates
received from the customer.** The certificate is `[manual]`, and a WHT receivable with no
certificate is an asset you cannot yet claim — age them.

**The payer name does not match any customer** — *Mosofin-specific and the commonest cause of
unidentified cash*. Run fuzzy matching against the customer master, present the score and the
alternatives, and **store the confirmed alias** so it never recurs.

**Two open invoices share the same amount** — *Mosofin-specific*. A level-2 match is no longer
unambiguous. Drop to research or present both; do not pick silently.

**Several invoice combinations sum to the payment** — *Mosofin-specific*. Report the combination
chosen and note that another existed. This is where level-3 matching quietly goes wrong.

**The invoice search window excluded old invoices** — *Mosofin-specific*. A default recent range
will miss exactly the aged invoices a payment may be settling. Use the aging as the population and
state the window searched.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose invoices were therefore not available to match against. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
matching logic but must never drive a real application against a named customer.

**The payments are already recorded and applied** — *Mosofin-specific*. This becomes a **review** of
how they were applied, not a proposal to apply them. Say which of the two you did; they carry
different assurance.

**A stored payer alias is wrong or stale** — *Mosofin-specific*. An alias that has changed will
credit the wrong customer. Re-confirm when the match it produces is contradicted by amount or
timing.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every payment is either applied, parked as credit, or flagged as unidentified**
- **Application logic is documented per payment (match type)**
- Short pays show the reason or **"unknown — needs follow-up"**
- **JE balances and reflects all sub-components (discount, fee, WHT, FX) separately**
- Customer credit balances surfaced
- File naming consistent
- **No silent absorption of short / over pays**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The output states which population was processed** — payments already recorded, or a supplied
  file of payments not yet entered
- **Every match records its hierarchy level (1–6)**, and every fuzzy match its similarity score and
  the alternatives considered
- **No fuzzy match below the threshold is auto-accepted**
- Matching uses the invoice **open balance**, never the original amount, and states the search
  window used
- Every short pay was checked against outstanding credit memos and against the invoice's own terms
  before its reason was assigned
- Every overpay was checked for a duplicate payment before a credit was proposed
- Every FX conversion states its rate and the rate's source
- Withholding tax receivables state whether a certificate has been received
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and no application or write-off rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence;
  the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No bank account numbers, payment-level data or remittance contents are persisted into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every application, credit and write-off is a proposal for
  a human to post
