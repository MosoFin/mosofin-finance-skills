---
name: credit-card-reconciliation
description: "Use this skill whenever the user wants to reconcile a corporate or business credit card statement to the GL with receipt matching, working from their Mosofin workspace. Triggers include: 'reconcile the corporate card', 'match receipts to the credit card statement', 'corp card rec', 'reconcile [Amex / Visa / Mastercard / Brex / Ramp / Pleo / Spendesk] statement', 'who spent what on the card', or uploading a credit card statement plus a set of receipts. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then reads every card charge posted to the ledger — running duplicate, recurring-subscription and capitalization-threshold tests — while stating plainly that the statement and the receipts sit outside any accounting datasource. Do NOT use for personal employee expense reports — use expense-report-processor. Do NOT use for bank reconciliation — use bank-reconciliation. Outputs a reconciled credit card workpaper with receipt status, GL coding, exceptions, the posting JE, and a coverage sheet."
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
# Credit Card Reconciliation (Mosofin)

Reconciles **credit card statements to the general ledger**, matches **receipts** to transactions, and
produces the posting **journal entry**. Designed for monthly corporate-card processing.

**In plain words:** a company card gets used dozens or hundreds of times a month by people who are not
the bookkeeper. At month end somebody has to check that every charge on the card statement is in the
books, coded to the right account, backed by a receipt, and actually for the business. This skill does
that check and writes the entry.

This skill is **jurisdiction-agnostic** — it applies whatever tax rules the user identifies.

It is **not** system-agnostic. It is **workspace-scoped**: card charges, the card liability balance, and
the chart of accounts come from tool calls against a company file connected to your Mosofin workspace in
this conversation, or from something you supplied by hand and that is labelled as such.

## What a connected workspace gives you here — and what it does not

**The same structural limit as `bank-reconciliation`:** Mosofin connects the **accounting system**, not
the card issuer. **The statement is `[manual]`, and so are the receipts.** Without a statement there is
no reconciliation — only a review of what was posted.

**But the book side is richer than in a bank reconciliation**, and that matters. Card charges are
normally posted **individually** in the accounting system — each with its merchant, date, amount and
account code — rather than as a single monthly total. So a great deal is `[auto]`:

- **Every card charge posted in the period**, with its merchant, amount, date and GL coding
- **The card liability balance** and its movement, including payments made to the card
- **Three tests worth running every month**, each of which the original raises and none of which needs a
  statement:
  - **Duplicate charges** — same merchant, same amount, same day
  - **Recurring subscriptions** — same merchant, same amount, month after month. The original notes that
    these "accumulate; periodically review for unused subscriptions". **Here that review is a query**,
    and it routinely finds software nobody has opened in a year
  - **Capitalization-threshold breaches** — charges above the entity's capitalisation limit sitting in an
    expense account rather than fixed assets

**Say which you did.** A "review of posted card charges" and a "reconciliation to the card statement" are
different pieces of work with different assurance, and only the second is a reconciliation.

**Mosofin is read-only.** Every entry below is a *proposal* for a human.

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

This gate matters here because card data names individual employees and their spending — reading the
wrong entity's card activity is a privacy problem, not only a data one.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check every connected row for a card or spend-management platform** — Brex, Ramp, Pleo, Spendesk and
similar. If one is connected, **the statement and often the receipts become `[auto]`**, and this skill
transforms from a review into a genuine two-sided reconciliation. That is the single most valuable check
in this gate.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting exactly
  one `data_source_id`, and every charge carries its entity's `display_name`. **A card issued to one
  entity but used for another's expenses** is a real and common pattern — see the cross-entity step,
  because it creates an intercompany balance rather than an expense.

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
- **Card charges usually post as purchase or expense transactions, not journals.** Check which search
  tool returns them; looking only at journal entries will find almost nothing.
- **A near-substitute is not a substitute.** **The card liability balance is not a statement.** It is
  what the books say you owe, which is exactly the figure the statement is meant to test. Comparing it
  to itself proves nothing. If no statement is available, say the tie-out could not be performed.
- **An attachment listing is not a receipt.** Where the connector exposes attachments, it can show that
  *a file exists* against a transaction — useful evidence of receipt capture, and **not** proof that the
  receipt supports the amount or shows a business purpose.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which determines which card transactions
count as foreign — fiscal calendar, country / region, time zone.

**Ask the user** what actually changes the work — the original Inputs table, minus what the profile
answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Credit card statement** — PDF, CSV or XLSX from the issuer | **Required — [manual]** unless a card platform is connected | Ask for it explicitly. Without it, say what the output will and will not be. |
| **Receipts for the period** | **Required for receipt matching — [manual]** | Or a receipt-tool export. Attachment metadata is not a receipt. |
| **Cardholder name** | **Required — [manual]** | And which employee or role each card belongs to. |
| **Statement period** — date range | **Required** | Note whether it matches the accounting period — see the edge case. |
| **Statement balances** — opening, charges, payments, closing | **Required — [manual]** | From the statement. |
| **GL credit card liability balance at period end** | **Required for tie-out — usually [auto]** | Pulled from the trial balance. Confirm which account. |
| **Chart of accounts** | **Required — usually [auto]** | Pulled. |
| **Tax jurisdiction** | Required if tax recoverability applies — **[manual]** | Drives Step 5. |
| **Receipt policy threshold** — below which no receipt is required | Recommended — **[manual]** | Needed to distinguish an acceptable missing receipt from an exception. |
| **Capitalization threshold** | Recommended — **[manual]** | Enables the capital-purchase test. |
| **Per-card-program quirks** | Optional — **[manual]** | Auto-categorisation from spend platforms needs verifying, not trusting. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The statement, the receipts and the thresholds will all be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the receipt
threshold, the capitalisation threshold, or the period.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The card list, the cardholders, the thresholds and the merchant-to-account coding map should not be
re-asked every month.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the card charges, the
liability balance, the payments and the chart of accounts do not depend on each other. Never serialize
them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the credit card liability account(s)**, and the expense accounts used for card
  coding — usually **[auto]**
- *`search_purchases`* / *`get_purchase`* — **every card charge posted in the period**, with merchant,
  amount, date and coding — usually **[auto]**
- *`get_general_ledger`* on the card liability account — **the full movement: charges, payments,
  interest, fees** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **the card liability balance at period end** — usually
  **[auto]**
- *`search_bill_payments`* / *`search_transfers`* — **payments made to the card** — usually **[auto]**
- *`search_purchases`* over **several prior months** — **the recurring-subscription and duplicate tests**
  — usually **[auto]**
- *`search_vendors`* / *`get-vendor`* — merchant records and their default coding — usually **[auto]**
- *`search_attachables`* / *`get_attachable`* — **evidence that a receipt file exists** against a
  transaction — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — tax codes in use — usually **[auto]**
- *`search_employees`* — cardholders, where they are set up as employees — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it cannot support a posted entry, and it must
never be used to raise an exception against a named employee.

## Step 1 — Parse the statement

For each transaction — **[manual]** from the statement, **[auto]** for the corresponding posted charge:

- **Transaction date**
- **Posting date** (may differ — **relevant for period cutoff**)
- **Merchant / vendor name** (often cryptic — normalize per `gl-coding-assistant`)
- **Amount** (charge or credit)
- **Currency** (statement currency vs. transaction currency for foreign transactions)
- **FX rate used** (if multi-currency)
- **Foreign transaction fee** (if any)
- **Cardholder** (if multi-card on one statement)
- **Reference / transaction ID**

Capture — **[manual]** from the statement:

- **Opening balance**
- **Total new charges**
- **Total credits / refunds**
- **Total interest / fees charged**
- **Payments made**
- **Closing balance**

**[auto]** for the book equivalents of the last five: charges, credits, interest and fees, and payments
are all readable from the card liability account's movement. That gives you the book side of every
statement total, which is what Step 2 needs.

## Step 2 — Tie statement balance to GL

The credit card liability on the GL should reconcile to the statement closing balance, considering —
**[gated]**, since one side is `[manual]`:

- **Charges posted to GL but on the statement after period end** → reconciling item (timing)
- **Charges on the statement but not yet posted to GL** → reconciling item (timing)
- **Payments in transit** → reconciling item
- **FX revaluation differences** (for foreign-currency cards)

Format:

```
GL Credit Card Liability balance              $X
+ Charges in GL not yet on statement          $Y
- Charges on statement not yet in GL          $Z
+ Payments in transit                         $A
+/- FX revaluation timing differences         $B
= Adjusted GL                                 $X+Y-Z+A+B

Statement Closing Balance                     $W

Reconciled difference                         $X+Y-Z+A+B − $W  (should be 0)
```

**[auto]** for `$X` and for identifying charges posted near the period boundary that are likely to be the
`$Y` items. **[manual]** for `$W` and `$Z`. **If no statement was supplied, do not build this bridge** —
say the tie-out was not performed, and present the posted-charge review instead.

## Step 3 — Match receipts to transactions

For each transaction, match a receipt — **[manual]**, with one `[auto]` support noted below:

- **Receipt management tool export** (Expensify, Brex, Ramp, etc.) often pre-matches; **verify**
- **Receipts uploaded separately**: match by date + amount + merchant
- **Multiple receipts for one transaction** (split bill, partial pre-pay): **all should sum to the
  transaction amount**
- **One receipt covering multiple transactions** (e.g. a hotel folio covering several daily charges):
  **cross-reference**

Match status per transaction:

- 🟢 **Matched** — receipt confirms the transaction
- 🟡 **Below threshold** — no receipt required per policy
- 🔴 **Missing receipt above threshold** — exception, needs follow-up
- ⚠️ **Disputed** — cardholder claims the charge is wrong / fraudulent
- 🔁 **Refunded** — original charge + matching refund both present

**[auto]** support: where the connector exposes attachments (*`search_attachables`*), you can identify
**which posted charges have no attached file at all**. That is a strong first pass at the 🔴 list — it
finds the transactions where no receipt was even captured — but **it is not a match**: a file being
present says nothing about whether it is the right receipt for the right amount.

**[auto]** for 🔁 **Refunded**: an original charge and an offsetting credit from the same merchant are
directly detectable in the posted transactions.

## Step 4 — Code transactions to GL accounts

Use `gl-coding-assistant` for each transaction. **The user's COA drives account selection.**
**[auto]** to read how each charge was *actually* coded, and to propose coding for anything uncoded.

Corporate-card transactions are often a mix:

- **Subscriptions and software**
- **Travel**
- **Meals** (with **cardholder business purpose required**)
- **Office supplies, equipment**
- **Marketing / advertising spend** (often the biggest line for ad-buying cards)
- **Personal charges** (not allowed on a corp card; **flag**)

**For multi-line transactions** (e.g. a hotel folio that includes room + meals + incidentals), **split
coding may be needed. Capture line detail from receipts where possible** — **[manual]**, since the split
lives on the receipt, not the statement line.

**[auto]** and worth reporting: charges coded to a **suspense, uncategorised or "ask my accountant"**
account. Those are transactions nobody has decided about, and they are usually where the personal
charges and the capital purchases hide.

## Step 5 — Tax handling

If the entity's jurisdiction allows **input-tax recovery** on card transactions — **[manual]** for the
rules, **[gated]** for the amounts:

- **Tax must be visible on the receipt** — some jurisdictions require a **valid tax invoice, not just a
  credit-card slip**. This is the point most often missed: the card slip proves payment, not tax
- **Decompose the receipt total into pre-tax + tax** for any recoverable lines
- **Foreign-currency transactions**: handle tax per the entity's policy — **often tax on foreign
  transactions isn't recoverable**

**If no jurisdiction is provided or the policy is unclear, capture tax separately on receipts where shown
and flag for user review.** **[auto]** to show which tax codes were actually applied to posted charges
(*`search_tax_codes`*, *`get_purchase`*) — including any charge with a recoverable tax code but no
attached receipt, which is a recovery claim with no support behind it.

## Step 6 — Flag exceptions

For each statement — verdicts vary sharply, so mark each:

- **Missing receipts (above policy threshold)** — **[gated]** via attachment metadata; **[manual]** to
  confirm
- **Charges without a business purpose** — **[manual]**; a business purpose is not a ledger field
- **Possible personal-use charges** (groceries, personal services, weekend non-business locations) —
  patterns from `expense-report-processor` — **[gated]**: merchant names and dates are **[auto]**, the
  judgment is not
- **Duplicate transactions on the same day** — **[auto]**, and worth running every month
- **Disputed charges** (cardholder marked or known issues) — **[manual]**
- **Charges from sanctioned countries** (compliance flag) — **[manual]**; merchant country is rarely in
  the books, and **no sanctions list is available** — see `aml-kyc-procedures`
- **Charges exceeding the cardholder's single-transaction limit** — **[gated]**: amounts are **[auto]**,
  the limit is **[manual]**
- **Charges with no merchant identification** — **[auto]**

**Three additional `[auto]` tests worth running every month** (each addresses an edge case the original
raises):

- **Recurring subscriptions** — same merchant, same amount, repeating monthly across several periods.
  Present the list with the annualised cost; this reliably surfaces software nobody uses
- **Capitalization-threshold breaches** — charges above the entity's capitalisation limit coded to an
  expense account
- **Charges posted to suspense or uncategorised accounts**

## Step 7 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit. **Mosofin does not post** — these are proposals.

The posting depends on when the entity records card activity.

**Option A — Post each transaction to expense at the time of charge** (most accurate; typical for entities
using receipt management tools that sync to GL):

```
DR  Expense accounts (per coding)               $charges
DR  Input Tax Recoverable                       $tax (if applicable)
    CR  Credit Card Liability                      $charges + tax
Memo: Card transactions for [cardholder] [period]
```

When the card is paid:

```
DR  Credit Card Liability                       $payment
    CR  Cash / Bank                                $payment
Memo: Card payment [date]
```

**Option B — Post the statement total to liability and clear at payment** (simpler; less granular GL):

```
At statement receipt:
DR  Expense accounts                            $statement charges (split by code)
    CR  Credit Card Liability                     $statement closing balance
Memo: Card statement [period]
```

**Recommend Option A for better visibility.**

**[auto]** to determine which the entity is *already* using: individual charges posted through the period
indicate Option A; a single monthly entry indicates Option B. **Say which you found**, because it changes
whether this step proposes entries or reviews existing ones.

**For refunds and credits: opposite direction.**

**For interest / fees charged by the card issuer:**

```
DR  Interest Expense / Bank Fees                 $interest / fee
    CR  Credit Card Liability                       $interest / fee
```

Use the **real account names from the connected chart of accounts** (*`search_accounts`*, **[auto]**).

## Step 8 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Reconciliation Summary**

- Statement period, cardholder, statement balances
- GL balance and reconciling items
- Total transactions, total matched, total exceptions
- Recommended JE posting

Add a header block: workspace name; the entity by `display_name`; each excluded company file and why;
**whether a statement was supplied** (and therefore whether this is a reconciliation or a posted-charge
review); whether any figure rests on `mock` data.

**Sheet 2: Transaction Detail**

| Date | Posted Date | Merchant (Cleaned) | Description | Amount | Currency | FX Fee | GL Account | Tax Code | Receipt Status | Business Purpose Captured | Notes |

Add a **Source** column — statement, ledger, or both — so unmatched items on either side are visible.

**Sheet 3: Exceptions**

| Line | Issue | Severity | Action Required |

Including the three automated tests: duplicates, recurring subscriptions (with annualised cost), and
capitalisation-threshold breaches.

**Sheet 4: GL Posting**

Pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 5: Source Receipts Reference**

For the audit trail — which receipt matches which transaction. **Distinguish "a file is attached" from "a
receipt was matched and verified".**

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be verified and what the user must supply |

Rows for the statement, the receipts, business purpose and sanctions screening read `manual` with their
gaps named. That is the correct, expected result.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `CC_Recon_[Cardholder]_[YYYY-MM].xlsx`

In a multi-entity run, include the entity: `CC_Recon_[EntityDisplayName]_[Cardholder]_[YYYY-MM].xlsx`.
Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something, **name the tool that would have covered it** instead of estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

This runs monthly, so the evolution step pays back quickly.

On an explicit yes, persist the **decisions**:

- **The card register**: which cards exist, which liability account each maps to, and which entity each
  belongs to — **by role, not by card number**
- **The receipt policy threshold** and the **capitalisation threshold**
- **The merchant-to-account coding map** — the recurring merchants and where each is coded. The biggest
  monthly time saving, and it makes miscoding visible
- **Known recurring subscriptions** that have been reviewed and approved, so the monthly list surfaces
  only what is new
- **The posting option in use** (A or B), and the statement-period-to-accounting-period relationship
- **The tax treatment** for domestic and foreign card transactions
- **Cardholder single-transaction limits**, by role
- The replay recipe: the exact sequence of reads that produced the posted-charge population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist card numbers (even partial), individual cardholders' names with their spending, receipt
images, or transaction detail.** Card numbers are payment credentials; an employee's spending pattern is
personal data and, in the case of a suspected personal charge, a sensitive allegation. **Persist the
policy and the coding map, keyed by role.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — Card liability account 2100; receipt threshold $75; capitalisation $2,500; Option A posting" —
not "receipt threshold $75". Thresholds and card programmes differ between entities, and an unlabelled
threshold applied to the wrong company file either floods the exception list or suppresses real ones.
Record the chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`, once per card. One reconciliation, one
JE set.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one `data_source_id`,
every charge carrying its entity's `display_name`. Then:

- **A card issued to one entity but used for another's expenses** is the common cross-entity case. Those
  charges are **not that entity's expense** — they create an **intercompany balance**: entity A paid for
  entity B's cost. Identify them, and route them to `intercompany-reconciliation` rather than coding them
  as expense in the wrong company.
- **A shared card programme across entities** produces one statement covering several legal entities.
  Reconcile the statement to the **combined** book activity, then allocate per entity — and treat the
  split as an allocation, not a reconciliation.
- **Compare exception rates across entities.** One entity with far more missing receipts than its
  siblings is a policy-enforcement problem, not an accounting one.
- **Thresholds and policies may differ per entity** — apply each entity's own.

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
| **Card charges posted, with merchant, amount and coding** | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required), `max_results`, `offset`; `id` |
| **Card liability movement: charges, payments, interest, fees** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Card liability balance at period end** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Card liability and expense accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Payments made to the card** | `search_bill_payments` / `search_transfers` | `start_date`, `end_date` (required) |
| Merchant records and default coding | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Spend by merchant (recurring-subscription test) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| **Evidence a receipt file exists** | `search_attachables` / `get_attachable` | `query`/`name`; `id` |
| Tax codes applied to charges | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Cardholders set up as employees | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| Refunds and credits from merchants | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Coding dimensions | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Corporate card** — a company card used by employees, where the company owes the balance.
- **Statement period** — the card issuer's billing cycle, which often does not match your accounting
  month.
- **Transaction date vs. posting date** — when you spent it, versus when the issuer recorded it.
- **Closing balance** — what the statement says you owe.
- **Reconciling item** — a legitimate reason the books and the statement differ, usually timing.
- **Payment in transit** — a payment sent but not yet showing on the statement.
- **Pre-authorization hold** — an amount a merchant reserves before the final charge is known.
- **Settled charge** — the final amount that actually goes through.
- **Chargeback / dispute** — challenging a charge with the issuer.
- **Cash advance** — withdrawing cash on a card; usually expensive and usually against policy.
- **Cashback / rewards** — value returned by the issuer; income or a cost reduction, per policy.
- **FX fee / foreign transaction fee** — the issuer's charge for a purchase in another currency.
- **Folio** — an itemised hotel bill covering several nights and charges.
- **Input tax recovery** — reclaiming sales tax / VAT / GST on business purchases.
- **Valid tax invoice** — the document most tax regimes require to reclaim tax. **A card slip is not
  one.**
- **Capitalization threshold** — the value above which a purchase becomes a fixed asset rather than an
  expense.
- **Suspense / uncategorised account** — where transactions go when nobody has decided what they are.
- **Business purpose** — the record of *why* a charge was incurred; required for meals and travel in most
  policies.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multiple cards on one statement** (a corporate programme covering several employees): **reconcile per
card, then sum to statement.** Each cardholder may have their own coding patterns and receipt habits —
and the exception rate per cardholder is usually the more useful management figure.

**Pre-authorization holds vs. settled charges**: a hotel may pre-authorise a higher amount than the final
settled charge. **The statement shows the settled amount. Watch for any held-but-released amounts that
don't fully reverse.**

**Foreign-currency transactions**: the statement may show the converted amount plus an FX fee. **Capture
the original currency, the original amount, and the conversion. Tax recovery on foreign transactions is
often disallowed** — flag.

**Cash advances**: usually high-fee, **often a policy violation. Flag.** **[auto]** to detect where the
merchant or transaction type identifies them.

**Chargebacks and disputes**: **track the dispute amount; don't recognize the credit until the issuer
resolves.** The statement may show the disputed amount as both a charge and a credit at different times.

**Annual fees, rewards, cashback**: book **annual fees as Bank Fee** or a specific account; **rewards /
cashback as Other Income** (or contra-expense per policy). Both are **[auto]** to spot in the liability
account's movement.

**Card payments from non-business funds** (e.g. an owner pays a personal card with business funds — a
common small-business error): **flag as a related-party / equity transaction, not as expense.**
**[auto]** to detect the reverse and equally common case: a business card paying for something personal.

**Recurring subscriptions on the card**: **these accumulate; periodically review for unused
subscriptions.** *Mosofin note*: **this is now a monthly query, not an occasional intention.** Present the
recurring list with annualised cost.

**Card used for capital purchases** (equipment over the entity's capitalisation threshold): **flag for
Fixed Asset coding, not expense.** **[auto]** once the threshold is known.

**Lost / stolen card with fraudulent charges**: **separate the fraudulent charges; they should be credited
by the issuer. Document the dispute.**

**Statement period crossing the entity's accounting period** (e.g. a 16th-to-15th statement against
calendar-month reporting): **cut by accounting period dates and accrue charges in the period of
incurrence.** This is the single most common source of a card reconciliation that will not tie, and it is
structural rather than an error.

**Brex / Ramp / Pleo and similar with integrated receipt capture**: data is more structured, but **verify
the AI-suggested coding** — especially these systems' auto-categorisation. *Mosofin note*: if such a
platform is connected, this skill becomes genuinely two-sided; check at Gate 1.

**No statement was supplied** — *Mosofin-specific, and the default in an accounting-only workspace*. The
tie-out cannot be performed. Deliver the posted-charge review and the automated tests, and **label it as
a review, not a reconciliation.**

**The card liability balance compared to itself** — *Mosofin-specific*. The GL balance is the figure the
statement is meant to test; it cannot test itself. Never present a book-to-book agreement as a
reconciliation.

**An attached file treated as a matched receipt** — *Mosofin-specific*. Attachment metadata proves a file
exists, not that it supports the amount or shows a business purpose. Keep the two columns separate.

**A recoverable tax code with no receipt** — *Mosofin-specific and directly detectable*. A tax recovery
claim with no supporting invoice is an exposure; list them.

**A charge sitting in a suspense or uncategorised account** — *Mosofin-specific*. Nobody has decided what
it is, and this is where personal charges and capital purchases hide. Report them all.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
card activity is therefore unreviewed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Never raise an exception against a named
employee, or post an entry, on fixture data.

**A stored coding map is stale** — *Mosofin-specific*. A merchant whose service changed may now belong in
a different account. Re-check the map when a merchant's coding is overridden repeatedly.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's thresholds to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Statement closing balance ties to GL ± reconciling items**
- **Every transaction has a GL account suggestion** (from the user's COA)
- **Receipt status documented per transaction**
- Exceptions categorized by severity
- Multi-currency transactions show original and converted amounts
- Tax handling per the user's jurisdiction
- File naming consistent
- **No silent absorption of reconciling differences**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The output states whether a statement was supplied**, and where it was not, is labelled a
  posted-charge review rather than a reconciliation
- **"A file is attached" and "a receipt was matched and verified" are reported as separate facts**
- **The duplicate, recurring-subscription and capitalisation-threshold tests were run** and their results
  stated, including when nil
- **Charges in suspense or uncategorised accounts are listed**
- **Recoverable tax claimed with no supporting receipt is flagged**
- The posting option actually in use (A or B) is identified from the ledger and stated
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no exception is raised against a named employee on
  mock data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No card numbers, individual cardholder spending, receipt images or transaction detail are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — every entry is a proposal for a human to post
