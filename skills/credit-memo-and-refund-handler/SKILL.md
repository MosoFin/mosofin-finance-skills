---
name: credit-memo-and-refund-handler
description: "Use this skill whenever the user wants to process a credit memo, customer refund, vendor credit, or sales return from their Mosofin workspace. Triggers include: 'issue a credit memo', 'process a refund to a customer', 'record a vendor credit note', 'apply this credit against an invoice', 'how do I record a sales return', or uploading a credit memo document. Also trigger for chargebacks, write-offs of customer balances, and goodwill credits. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then validates every credit against the original invoice automatically — existence, balance, period, currency and tax codes — and surfaces unapplied credits sitting on account. Do NOT use for bad-debt write-offs as policy — use bad-debt-and-write-offs. Do NOT use for normal invoice extraction — use invoice-data-extractor. Outputs a credit memo record, the offsetting JE, application instructions, and a coverage sheet."
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
# Credit Memo and Refund Handler (Mosofin)

Processes **customer credit memos, customer refunds, vendor credit notes, and chargebacks**. Determines
the correct accounting treatment, produces posting inputs, and tracks application against the original
invoice.

**In plain words:** sometimes money has to go back the other way — a customer returns goods, a price was
wrong, a supplier over-billed you, or a card payment gets reversed. Each of those looks similar on the
surface and is accounted for quite differently underneath. This skill works out which one you have, what
happens to the tax, and how the credit gets used up.

This skill is **jurisdiction-agnostic** and **chart-of-accounts-agnostic**. It captures tax reversal
exactly as it appears on the credit memo and uses the user's COA.

It is **workspace-scoped**: original invoices, existing credits and open balances come from tool calls
against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## Why this skill fits a connected workspace unusually well

**Step 2 — "validate against the original" — is fully automatable.** Every one of its four checks is a
query rather than a request:

- **Does the invoice exist?** — readable
- **Is the credit ≤ the invoice balance?** — readable, and a credit exceeding the balance is exactly the
  case the original says needs management approval
- **Is the period right?** — readable, including whether the original sits in a closed year
- **Does the currency match?** — readable

**And Step 3's discipline is checkable.** Tax on a credit must mirror tax on the original. The original
invoice's tax codes and amounts are readable, so "does this reversal actually mirror the original?"
stops being an instruction and becomes a test.

**One more finding worth running every time: unapplied credits sitting on account.** Both directions
matter, and the second is often overlooked:

- **Customer credits unapplied** — money you owe a customer that is quietly ageing. It overstates
  receivables and eventually becomes a refund request or unclaimed property.
- **Vendor credits unapplied** — **money you are entitled to and have not taken.** A vendor credit note
  sitting unused is a discount you already negotiated and are not receiving. This is the closest thing to
  free money in the whole pack, and it is one query away.

**Mosofin is read-only.** It cannot issue a credit memo, send a refund, or apply a credit. Every entry
below is a *proposal* for a human.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before processing anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between runs.

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

**Check for a connected payment processor.** Chargebacks originate there, and a connected processor
supplies the processor fee and the reference that the accounting system usually lacks.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting exactly
  one `data_source_id`, and every credit carries its entity's `display_name`. **A credit must be applied
  against an invoice at the same entity that issued it** — crediting one entity's customer against
  another's invoice is an intercompany transaction, not an application. See the cross-entity step.

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
- **There are four distinct document types and four distinct tools.** Customer **credit memos**, customer
  **refund receipts**, **vendor credits**, and the underlying **invoices** and **bills** each have their
  own search. Using the wrong one silently returns nothing, which reads as "no credits exist" rather than
  "wrong query".
- **A near-substitute is not a substitute.** A **customer balance** shows the net position; it cannot
  tell you which credits are unapplied or which invoice a credit relates to. Both of those are the point
  of this skill. If the credit-level tool is disabled, say the credit register could not be built.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which determines whether the currency check
in Step 2 can ever fail — fiscal calendar and **year-end**, which matters for the closed-period edge case,
country / region.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Credit memo type** — customer credit / customer refund / vendor credit / chargeback | **Required — [gated]** | Often inferable from the document type already recorded; **confirm it**, since the accounting differs materially by type. |
| **Original invoice reference** — number, date, amount | **Required if applicable — [auto] to verify** | Ask for the number; **the existence, amount, balance, period and currency are then all checkable**. |
| **Credit memo amount** | **Required** | |
| **Reason for credit** — return, pricing dispute, goodwill, damage, error | **Required — [manual]** | Drives the accounting: a return hits inventory, a goodwill credit hits expense, a pricing error hits revenue. Never infer it. |
| **Chart of accounts** | **Required for GL posting — usually [auto]** | Confirm the sales returns, chargeback fee and write-off accounts by their real names. |
| **Tax jurisdiction** | Required if tax was on the original invoice — **[manual]** | Drives the write-off recoverability question in Step 4. |
| **Original tax code(s)** — from the related invoice | Required if tax involved — **usually [auto]** | Readable from the original invoice; confirm rather than ask. |
| **Functional currency** | Optional — default same as original; usually **[auto]** | |
| **Approval for any credit exceeding the invoice balance** | **Required if that check fails** | **[manual]** — and the check itself is **[auto]**. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required if Gate 2 produced any [manual]** | |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the reason, the
credit type, or the tax treatment.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The account map, the reason-code set and the approval thresholds persist; **the open credit register is
always re-read**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the credits, the
refunds, the vendor credits and the originals do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_credit_memos`* / *`get_credit_memo`* — **customer credits already recorded**, with their
  amounts and linked invoices — usually **[auto]**
- *`search_refund_receipts`* / *`get_refund_receipt`* — **refunds already paid out** — usually **[auto]**
- *`search_vendor_credits`* / *`get_vendor_credit`* — **vendor credits held**, including unapplied ones —
  usually **[auto]**
- *`search_invoices`* / *`read_invoice`* — **the original invoices**: amount, balance, date, currency and
  **tax codes** — usually **[auto]**
- *`search_bills`* / *`get-bill`* — the original bills, for vendor credits — usually **[auto]**
- *`get_customer_balance`* / *`get_aged_receivables`* — open customer positions, including credit balances
  — usually **[auto]**
- *`get_vendor_balance`* / *`get_aged_payables`* — open vendor positions — usually **[auto]**
- *`search_accounts`* — the sales returns, chargeback fee, write-off and tax accounts — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — the tax codes in use — usually **[auto]**
- *`search_items`* / *`read_item`* — item cost, for sales returns with inventory — usually **[auto]**
- *`get_company_info`* — base currency and fiscal year end — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — a refund proposed on it would send real money
against an imaginary invoice.

## Step 1 — Identify the type

| Type | What it does | Direction |
|------|--------------|-----------|
| **Customer credit memo (applied to a future invoice)** | Reduces AR; a future invoice settles partially against this credit | AR ↓ |
| **Customer refund (cash returned)** | Reduces AR and Cash | AR ↓, Cash ↓ |
| **Vendor credit note (applied to a future bill)** | Reduces AP; a future bill settles partially against this credit | AP ↓ |
| **Vendor refund (cash received from vendor)** | Reduces AP and increases Cash | AP ↓, Cash ↑ |
| **Sales return** | A specific kind of customer credit, **with inventory implications** | AR ↓, Inventory ↑ |
| **Chargeback** | Customer-initiated reversal via a payment processor | AR varies + processor fee |
| **Write-off (goodwill)** | Credit issued to maintain the relationship, no cash | AR ↓, Expense ↑ |

**[gated]**: the *document* type recorded in the books is **[auto]** and narrows this considerably — a
refund receipt is not a credit memo — but **the distinction between a sales return, a goodwill credit and
a pricing correction is the reason, not the document**, and the reason is `[manual]`. Three of these rows
can share an identical document and require three different entries.

## Step 2 — Validate against the original

If the credit references an original invoice — **[auto]** for all four checks:

- **Confirm the invoice exists in the system** (*`search_invoices`*, *`read_invoice`*)
- **Confirm the credit amount ≤ the invoice balance.** **A credit larger than the outstanding amount needs
  management approval** — and this check is exact, since the current balance is readable
- **Confirm the period** — **credits dated after the original is fully closed may need different
  treatment, especially across fiscal years.** Compare against the fiscal year end from the profile
- **Confirm the currency matches**

**If no original invoice** — rare for customer credits, common for goodwill credits — **flag and ask for
the business reason.** **[auto]** to detect: a credit with no linked invoice is directly identifiable.

Run these checks on **every** credit in the period, not only the one being processed. Credits already
recorded that fail a check are exceptions worth surfacing — particularly a credit exceeding an invoice
balance, which nobody approved.

## Step 3 — Compute the tax reversal

**Only if tax was on the original invoice.**

**Tax on a credit memo must mirror tax on the original.** If the original had 7.5% sales tax (or 5% GST,
or 20% VAT, etc.), **the credit memo reverses that same tax amount proportionally.**

- **For full credits** → reverse the full original tax
- **For partial credits** → reverse proportional tax

**Capture the tax reversal as a separate line. Do not bundle it into the net amount.**

**[auto]** and worth doing as a check rather than only a computation: read the **original invoice's tax
codes and tax amount** (*`read_invoice`*, *`search_tax_codes`*), compute the expected reversal, and
**compare it to the tax actually on the credit**. A mismatch is a real error — it either over-claims or
under-claims tax — and it is invisible without the original to hand.

## Step 4 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit. **Mosofin does not post** — these are proposals. Use the **real account
names from the connected chart of accounts** (*`search_accounts`*, **[auto]**).

#### Customer credit memo (no cash paid)
```
DR  Sales Returns & Allowances (contra-revenue)   $net
DR  Tax Payable / Output Tax Collected            $tax (if applicable)
    CR  Accounts Receivable                          $gross
Memo: Credit memo [CM #] re: invoice [Inv #] — [reason]
```

*Contra-revenue* means it sits against sales rather than in expenses — so the top line falls, which is
usually what management wants to see.

#### Customer refund (cash returned)
```
DR  Sales Returns & Allowances                     $net
DR  Tax Payable / Output Tax                       $tax
    CR  Cash / Bank                                   $gross
Memo: Refund to [Customer] re: invoice [Inv #] — [reason]
```

#### Sales return (with inventory)
```
DR  Sales Returns & Allowances                     $net
DR  Tax Payable / Output Tax                       $tax
DR  Inventory                                      $cost
    CR  Accounts Receivable (or Cash)                 $gross
    CR  Cost of Goods Sold                            $cost
Memo: Sales return [SR #] re: invoice [Inv #] — [reason]
```

**The inventory portion uses original cost** (per the inventory costing policy — see
`inventory-costing-fifo-lifo-wavg`). **[gated]**: the item's cost is often readable
(*`read_item`*), but whether the goods came back saleable is not — see the damaged-return edge case.

#### Vendor credit note (applied to future bill)
```
DR  Accounts Payable                               $gross
    CR  Expense / Asset originally booked             $net
    CR  Input Tax Recoverable                         $tax (reverses original recovery)
Memo: Vendor credit [VC #] re: bill [Bill #] — [reason]
```

Note the credit goes back to **the account the cost was originally booked to** — **[auto]** to determine
from the original bill (*`get-bill`*). Crediting it to a generic income account instead is a common error
that leaves the original expense overstated.

#### Vendor refund (cash received)
```
DR  Cash / Bank                                    $gross
    CR  Expense / Asset originally booked             $net
    CR  Input Tax Recoverable                         $tax
Memo: Vendor refund re: bill [Bill #] — [reason]
```

#### Chargeback
```
DR  Sales Returns / Chargebacks                    $net
DR  Tax Payable / Output Tax                       $tax
DR  Chargeback Fees Expense                        $fee
    CR  Cash / Merchant Clearing                      $gross + fee
Memo: Chargeback re: invoice [Inv #] / processor ref [Ref] — [reason]
```

**If the original sale and the chargeback are in different periods, post the reversal to the period the
chargeback occurred — do not restate the prior period unless materiality and policy demand it.**
**[manual]** for the processor fee and reference unless a processor is connected.

#### Goodwill / write-off credit
```
DR  Bad Debt Expense (or Goodwill Allowance)       $net
DR  Tax Payable / Output Tax                       $tax (only if tax recoverable on write-off in jurisdiction)
    CR  Accounts Receivable                           $gross
Memo: Goodwill write-off re: invoice [Inv #] — [reason]
```

**Tax recoverability on write-offs varies by jurisdiction. Some jurisdictions require formal bad-debt
relief procedures before reclaiming output tax. Flag for the user.** **[manual]**, always — never claim
the tax back automatically.

## Step 5 — Application

For credits applied (not refunded in cash) — **[auto]** to track:

- **Customer credit applies to a specific future invoice or remains on account**
- **Vendor credit applies to a specific future bill or remains on account**
- **Track the open credit balance until fully applied**
- **When applied, no new JE — it's a sub-ledger application that closes both the credit and the invoice
  line by the applied amount**

That last point matters and is often misunderstood: applying a credit moves nothing in the general
ledger, because the credit was already recorded when it was issued. Proposing a second entry on
application double-counts it.

For partial applications:

- **Reduce the open credit by the applied amount**
- **Reduce the corresponding invoice by the same amount**
- **Both remain open for any residual**

**[auto]** and worth running every time — **the unapplied credit register, in both directions**:

- **Customer credits unapplied**, with their age. These overstate what customers owe you and eventually
  become refund requests
- **Vendor credits unapplied**, with their age. **These are money you are owed and have not taken** — a
  negotiated discount going unused. Present the total; it is frequently material and almost always a
  surprise

## Step 6 — Output

**For single credits** → markdown summary inline + JE inputs.
**For batches** → `.xlsx` with:

**Sheet 1: Credit Memos Register**

| CM # | Date | Type | Counterparty | Original Invoice | Original Amount | Credit Amount | Tax Reversed | Reason | Status (Open / Applied / Refunded) |

Add a header block: workspace name; the entity by `display_name`; each excluded company file and why;
whether any figure rests on `mock` data.

**Sheet 2: GL Posting Inputs** (per credit) — marked as **proposals**.

**Sheet 3: Application Tracking**

| CM # | Applied to Invoice # | Amount Applied | Date Applied | Remaining Balance |

**Sheet 4: Unapplied Credits — NEW, Mosofin-specific**

| Direction (customer / vendor) | Counterparty | Credit # | Date | Amount | Age | Suggested application |

**Vendor credits appear first, sorted by value.** They are money the entity is entitled to.

**Sheet 5: Validation Exceptions — NEW, Mosofin-specific**

| Credit # | Check failed | Detail | Action required |

Covering the Step 2 checks — missing original, credit exceeding invoice balance, period mismatch,
currency mismatch — and the Step 3 tax-mirroring check.

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be verified and who supplied it |

If creating xlsx, read: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `CreditMemos_[YYYY-MM].xlsx`

In a multi-entity run: `CreditMemos_[YYYY-MM]_[EntityDisplayName].xlsx`. Every file states which
datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the reason, the jurisdiction's write-off rules — **name the source required** instead of
estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map**: sales returns & allowances, chargeback fees, goodwill / bad debt, and the tax
  accounts, by their real names
- **The reason-code set** the entity uses, and which accounting treatment each reason maps to — the thing
  that turns Step 1 from a judgment into a lookup
- **The approval threshold** above which a credit needs sign-off, and who signs
- **The jurisdiction's position on output-tax recovery for write-offs**, and the procedure required
- **The restocking-fee policy**, if any
- **The chargeback handling**: which processor, which clearing account, how fees are coded
- **The unapplied-credit review cadence**, so vendor credits get claimed rather than aged
- The replay recipe: the exact sequence of reads that produced the credit register

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Do not persist customer or vendor names with credit amounts, reasons, or dispute detail.** A stored
record that a named customer received a goodwill credit for a quality complaint is commercially sensitive
and potentially contentious. Persist the *mapping and the policy*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — returns to Sales Returns & Allowances; goodwill credits need director approval above $500;
output tax not recoverable on write-off without formal relief" — not "goodwill credits need approval
above $500". Entities operate under different tax regimes and different authority levels, and an
unlabelled threshold applied to the wrong company file authorises a credit nobody approved. Record the
chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the open credit balance is state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One credit register, one application
tracker.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every credit carrying its entity's `display_name`. Then:

- **A credit belongs to the entity that issued the original invoice.** Applying one entity's credit
  against another's invoice is an **intercompany transaction**, not an application — it moves value
  between legal entities. Flag it and route it to `intercompany-reconciliation`.
- **A customer trading with several entities may hold credits at one and owe another.** They will
  frequently ask to net them. That netting is a group decision with intercompany consequences, not a
  routine application — say so rather than doing it.
- **The unapplied vendor credit sweep runs per entity and is worth totalling for the group.** A shared
  supplier may hold credits at several entities, and the aggregate is what makes the claim worth making.
- **Chargebacks arrive at whichever entity holds the merchant account**, which may not be the entity that
  made the sale. Check before coding the reversal.

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
| `create_skill` | Persists the evolved skill. Step 7. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Customer credits recorded, and unapplied ones** | `search_credit_memos` / `get_credit_memo` | `start_date`, `end_date` (required), `customer_id`, `query`/`name`; `id` |
| **Refunds already paid out** | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required), `customer_id`; `id` |
| **Vendor credits held — including unapplied** | `search_vendor_credits` / `get_vendor_credit` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| **The original invoice: amount, balance, date, currency, tax codes** | `search_invoices` / `read_invoice` | `start_date`, `end_date` (required), `customer_id`, `query`/`name`; `id` |
| **The original bill, and the account the cost was booked to** | `search_bills` / `get-bill` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Open customer position, incl. credit balances | `get_customer_balance` / `get_aged_receivables` | `report_date`, `customer` |
| Open vendor position | `get_vendor_balance` / `get_aged_payables` | `report_date`, `vendor` |
| Sales returns, chargeback fee, write-off and tax accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Tax codes and rates on the original | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Item cost for a sales return | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| Cash impact of refunds paid | `search_purchases` / `get_general_ledger` | `start_date`, `end_date` (required); `account` |
| Base currency and fiscal year end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Credit memo / credit note** — a document reducing what a customer owes you, or what you owe a
  supplier.
- **Refund** — money actually sent back, rather than a credit held on account.
- **On account** — a credit sitting on a customer's or supplier's record, not yet used.
- **Application** — using a credit to settle part of an invoice.
- **Sales return** — goods coming back, which affects inventory as well as receivables.
- **Chargeback** — a customer reversing a card payment through their bank or card issuer.
- **Goodwill credit** — a credit given to keep a customer happy, not because anything was wrong.
- **Contra-revenue** — an account that reduces sales rather than adding to costs.
- **Sales returns & allowances** — the standard contra-revenue account for credits.
- **Output tax** — tax you charged a customer. **Input tax** — tax you paid a supplier and can reclaim.
- **Bad-debt relief** — the formal process some tax regimes require before you can reclaim tax on an
  unpaid invoice.
- **Restocking fee** — a charge for taking goods back, which reduces the credit.
- **NRV (net realisable value)** — what returned goods are actually worth now, which may be less than
  their original cost.
- **Volume rebate** — a discount earned by buying a lot, not tied to any one bill.
- **Merchant clearing** — the holding account for money moving through a card processor.
- **Sub-ledger** — the detailed customer or supplier records behind the general ledger totals.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Credit issued in a different period than the original invoice**: **post to the credit's period unless
materiality forces a prior-period adjustment. Note in the memo.** *Mosofin note*: **detectable
automatically** — compare the credit date against the invoice date and the fiscal year end.

**Credit issued in a different currency**: **use the original invoice's FX rate to preserve the offset,
then post an FX gain / loss for any rate movement.** Flag for `multicurrency-fx-revaluation`. The currency
mismatch itself is **[auto]** to detect; the rate is **[manual]**.

**Partial sales return with a restocking fee**: **the restocking fee is income; reduce the credit by the
fee. Two-line treatment** — never a single net figure, or the fee income disappears.

**Customer overpaid and is now owed a refund**: **not a credit memo — it's a customer deposit / refund of
overpayment. Different posting (DR Customer Deposits, CR Cash). Flag for the user.** *Mosofin note*:
distinguishable — an overpayment sits as an unapplied *payment*, not as a credit memo.

**Vendor offers a credit as a discount on future bills (volume rebate)**: **this is a rebate, not a credit
against a specific bill. Different treatment — often Other Income or contra-COGS. Flag.** A rebate credited
against one arbitrary bill distorts that bill's cost.

**Chargeback where the original sale's tax has already been remitted**: **the tax reversal may not reduce
the current period's tax liability — depends on jurisdiction. Flag.**

**Credit memo with no original invoice**: **document the business reason; recommend an approval
workflow.** **[auto]** to detect, and worth listing every one in the period rather than only the credit at
hand.

**Inventory return where the item is damaged**: **the returned inventory's value may be less than original
cost. Capture the full credit to the customer, but bring inventory back at NRV. The difference is a
write-down** (Loss on Returns / Inventory Write-Down). **[manual]** — the books cannot tell you the goods
came back broken, and bringing damaged stock back at full cost overstates inventory.

**A credit exceeds the invoice balance** — *Mosofin-specific and exactly checkable*. It needs management
approval. Report every instance found in the period, not only the one being processed — the historic ones
were never approved either.

**Tax on the credit does not mirror the original** — *Mosofin-specific*. Compute the expected reversal from
the original's tax codes and compare. A mismatch over- or under-claims tax and is invisible without the
original.

**A vendor credit posted to income instead of the original expense account** — *Mosofin-specific and
common*. The original bill shows where the cost went; the credit should reverse it there. Posting it to
income leaves the expense overstated and the margin wrong in two places.

**A second journal proposed when a credit is applied** — *Mosofin-specific*. Application is a sub-ledger
event; the general ledger already reflects the credit. A second entry double-counts it.

**Unapplied vendor credits ageing on account** — *Mosofin-specific and valuable*. Money the entity has
already negotiated and is not taking. Sweep for them every run and total them.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
credits are therefore unreviewed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A refund proposed on fixture data would send
real money against an imaginary invoice.

**A stored reason-to-treatment map is stale** — *Mosofin-specific*. Where a reason code starts producing
overridden treatments, revisit the map.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's approval threshold or tax position to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every credit memo references the original invoice** (or explicitly documents why none)
- **Tax reversal mirrors the original tax exactly** (or proportionally for partial)
- **The JE balances to the penny**
- **Application tracking shows the open balance at all times**
- **No silent absorption of timing or currency differences**
- File naming consistent

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **All four Step 2 validations were run against the live original** — existence, balance, period,
  currency — and every failure is listed, across the whole period rather than only the credit at hand
- **The tax reversal was checked against the original invoice's tax codes**, not merely computed
- **The reason is recorded and supplied**, never inferred from the document type
- **Vendor credits are posted back to the account the original cost was booked to**, read from the
  original bill
- **No second journal is proposed on application**
- **The unapplied credit register is produced in both directions**, with vendor credits listed first by
  value
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no refund is proposed on mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No counterparty names with credit amounts, reasons or dispute detail are persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no credit was issued, no refund sent, no credit applied
