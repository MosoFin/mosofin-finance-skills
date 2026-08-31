---
name: gl-coding-assistant
description: "Use this skill whenever the user wants to assign GL account codes, expense categories, or tax codes to transactions in their Mosofin workspace. Triggers include: pasting a list of transactions and asking 'what account should this go to', 'code these expenses', 'categorize these transactions', 'suggest a GL account for [vendor/description]', or uploading a bank/credit card export that needs categorization. Also trigger when the user mentions an uncoded transaction, an unclassified vendor, or asks Claude to map descriptions to accounts. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then codes against the real chart of accounts and grounds every suggestion in how this entity has actually coded the same vendor before. Do NOT use for building the chart of accounts itself — use chart-of-accounts-designer. Do NOT use for posting actual journal entries — use journal-entry-builder. Outputs a coded transaction list with confidence ratings, reasoning, evidence, and a coverage sheet."
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
# GL Coding Assistant (Mosofin)

Suggests the correct **general ledger account**, **expense category**, and **tax code** for transactions
based on vendor, description, amount, and context. Designed to **accelerate bookkeeper coding decisions
while flagging ambiguous items for human review**.

**In plain words:** every payment has to be filed under the right heading so the accounts mean something.
Most of them are obvious once you know how this business files things. This works out which heading each
one belongs under, says how sure it is, and separates the easy ones from the ones a person should look at.

This skill is **jurisdiction-agnostic**. **It does NOT invent account numbers and does NOT assume any
country's tax rules.** All account references come from the entity's actual chart of accounts; all tax logic
is driven by the entity's jurisdiction.

It is **workspace-scoped**: the chart of accounts, the vendor list, the tax codes and — most importantly —
**the entity's own coding history** come from tool calls against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's real
chart rather than accepting any list. That is a narrowing, and it is stated rather than left implied.

## What changes in a Mosofin workspace: Tier 1 stops being optional

The original's classification hierarchy leads with **Tier 1 — exact vendor match**, using "the user's prior
mappings", which it lists as an **optional** input that "improves accuracy". In practice almost nobody
maintains that file.

**Here, the prior mappings are the general ledger.**

> **How this entity has coded every vendor before is readable, with counts.** Not "Amazon usually goes to
> Office Supplies" as a guess, but **"this entity coded this vendor to 6120 Office Supplies in 43 of 45
> prior transactions, most recently last month."** That is the difference between a suggestion and an
> evidenced recommendation, and it makes the highest-confidence tier both automatic and auditable.

Four more things follow from the same access:

1. **The chart of accounts is `[auto]`.** The original's "stop and ask" rule and its **PLACEHOLDER — REMAP
   REQUIRED** fallback survive as a degradation path, not the normal case.
2. **You can find the work yourself.** **Uncategorized, suspense and "ask my accountant" accounts are
   readable** — so the skill can locate what actually needs coding rather than waiting for someone to paste
   a list. That is often the more useful opening move.
3. **Transfer detection becomes real.** The original infers a transfer from a one-sided bank export —
   "same amount, opposite sign, within ~3 days". **With the ledger, both sides are visible.**
4. **The tax codes actually configured in this entity are readable**, so a tax-code suggestion can name a
   code that exists rather than describing a concept.

**And one caution that matters more than all four:**

> **Frequency is not correctness.** If this entity has been coding something to the wrong account for two
> years, the history will recommend continuing with high confidence and good evidence. **Report the
> consistency, not the conclusion** — and where a vendor's history is *inconsistent*, say so rather than
> picking the most common or the most recent. An inconsistent history usually means the category was never
> actually decided.

**Mosofin is read-only.** It cannot code, recode or post anything. Every suggestion below is a *proposal*
for a person to apply.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before coding anything. This ordering is the contract. Do not
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

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and confirm which entity each batch of transactions belongs to before
  coding any of them.** Coding is entity-specific: the same vendor may map to different accounts in
  different company files, because the charts differ. See the cross-entity step.

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
  - **Coding history is not correctness.** The central caution above.
  - **A vendor's default account on its master record is not how it has actually been coded** — defaults
    are set once and then overridden transaction by transaction. **Read the history, not the default.**
  - **A tax code applied previously is not proof of recoverability.** The code is a setting.
  - **Two matching amounts are not a transfer** until both legs are seen in the entity's own accounts.
- **If the COA read is `disabled`, the original's fallbacks apply in full** — category names only, or an
  explicitly authorized placeholder labelled **PLACEHOLDER — REMAP REQUIRED BEFORE POSTING**. **Say which
  fallback is in use and why.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, base currency, fiscal calendar, **country /
region** — the jurisdiction — and **industry**.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Transactions to code** | **Required** — **[auto]** if already in the system, **[manual]** if a bank or card export | **Offer to find them**: uncategorized and suspense accounts are readable. |
| ~~Chart of accounts~~ | **Now [auto]** | From `search_accounts`. **No placeholders unless the read is unavailable.** |
| ~~Entity jurisdiction~~ | **Now [auto]** | Country from the profile — **but the tax *rules* remain `[manual]`.** |
| ~~Entity industry~~ | **Now [auto]** | From the profile where set. |
| ~~Vendor-to-account mappings (prior coding)~~ | **Now [auto], and promoted** | **Derived from ledger history with counts.** The strongest evidence available. |
| **Coding policy / rules** | Optional — **[manual]** | Any house rules that override history. |
| **Capitalization threshold** | Optional, **ask if relevant** — **[manual]** | **Do not pick a threshold.** Needed for the Tier 4 and Step 4 checks. |
| **Tax code list** | Required for tax codes — **[gated]** | **The codes configured here are `[auto]`;** which one applies is `[manual]`. |
| **Confirm scope** | **Required** | Read back the entity by `display_name` and the batch being coded. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. transactions in a currency the entity does not use. |
| **Confirm manual evidence** | **Required** | The policy, the threshold and the tax rules are `[manual]`. |

**If no chart of accounts is available**, the original's rule stands: **stop and ask. Do not invent account
numbers.** Two acceptable fallbacks:

1. **The user provides a category list** (description only) and coding is to category names with no numbers.
2. **The user explicitly authorizes a placeholder COA** — output clearly labelled **"PLACEHOLDER — REMAP
   REQUIRED BEFORE POSTING"**.

**If no jurisdiction is available and the user asks for tax codes, ask. Do not assume.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a capitalization
threshold or a tax treatment.

**On later runs**, read stored preferences first (Step 6), confirm in one line, and ask only what changed.
**See the Learning Loop below — it and the evolution step are the same mechanism.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The capitalization threshold and the tax rules are
legitimately `[manual]`.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the vendors, the history and the tax codes do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the real chart of accounts**, including **uncategorized and suspense accounts** —
  usually **[auto]**
- *`search_vendors`* + *`get_vendor`* — the vendor master and any default accounts — usually **[auto]**
- *`get_general_ledger`* — **the coding history**, which is the Tier 1 evidence — usually **[auto]**
- *`search_purchases`* / *`search_bills`* / *`search_expenses`* — **prior transactions by vendor with their
  accounts** — usually **[auto]**
- *`get_general_ledger`* on **Uncategorized Expense / Income and any suspense account** — **the work waiting
  to be done** — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — **the codes configured in this entity** — often **[auto]**
- *`search_accounts`* on **bank and credit card accounts** — for transfer detection — usually **[auto]**
- *`search_employees`* — for related-party name comparison — usually **[auto]**
- *`get_company_info`* — legal name, currency, **country, industry** — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the COA read,
  say explicitly which fallback is now in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **coding history from fixtures is not this
entity's history**, and a Tier 1 match against it is worthless. Downgrade every history-based confidence to
Low and say why.

## Step 1 — Parse and normalize

For each transaction extract — **[gated]**: `[auto]` for transactions already in the system, `[manual]` for
a pasted export:

- **Date**
- **Vendor / payee** — normalize: **strip corporate suffixes ("INC", "LLC", "LTD", "GMBH", "PTY"), trailing
  numeric IDs, payment-processor prefixes ("SQ *", "TST*", "POS DEBIT", "PAYPAL *", "WISE *")**
- **Description / memo**
- **Amount (signed)**
- **Source account** (bank, credit card, etc.) — if provided

**Normalize examples:**

- **"AMZN MKTP US*1A2B3C" → "Amazon"**
- **"SQ *COFFEE SHOP" → "Coffee Shop (via Square)"**
- **"PAYPAL *VENDORNAME 12345" → "VendorName (via PayPal)"**

**Mosofin addition — match the normalized name to the vendor master.** **[auto]** via *`search_vendors`*.
Three outcomes, each worth reporting differently:

- **Matches an existing vendor** → the full coding history is available. Best case.
- **Matches nothing** → a new vendor, so Tier 1 cannot apply. Fall to Tier 2.
- **Matches several similar vendors** → **a duplicate vendor record**, which is a data-quality finding in
  its own right and means the history is split across records. Report it; see
  `duplicate-invoice-detection` for the matching discipline.

## Step 2 — Classify each transaction

**Apply this decision hierarchy in order. Stop at the first confident match.**

### Tier 1 — Exact vendor match (Confidence: High) — **[auto]**

**If the vendor exists in the user's prior mappings, use that account.**
**Reasoning: "Matches prior coding for [vendor]."**

**In a Mosofin workspace this tier is read, not supplied.** Query the ledger history for this vendor
(*`get_general_ledger`*, *`search_purchases`*) and report **the account, the count and the recency**:

> *"6120 Office Supplies — this entity's coding for this vendor in 43 of 45 prior transactions, most
> recently 2026-07-14."*

**Three history shapes, three different answers:**

| History | Confidence | What to say |
|---|---|---|
| **Consistent** — one account dominates | 🟢 **High** | The account, with the count. |
| **Inconsistent** — split across accounts | 🟡 **Medium**, flagged | **Report the split.** Do not pick the most common or the most recent. The category was probably never decided. |
| **Changed** — one account, then another, cleanly | 🟡 **Medium** | Use the newer, **and say a change occurred and when** — it may be a deliberate reclassification or an error. |

**Frequency is evidence of practice, not of correctness.** Where history conflicts with a supplied coding
policy, **the policy wins and the conflict is reported.**

### Tier 2 — Vendor-type pattern match (Confidence: High) — **[gated]**

**Map common vendor types to the closest matching account in the user's COA. Never output an account that
isn't in the COA the user provided.**

| Vendor type | Conceptual category to map into user's COA |
|-------------|---------------------------------------------|
| **Cloud infrastructure providers** | Hosting / Cloud Services |
| **SaaS productivity tools** | Software Subscriptions |
| **Payment processor fees** | Merchant Processing Fees |
| **Ride-share / taxi** | Travel — Ground Transport |
| **Hotels / lodging** | Travel — Lodging |
| **Airlines** | Travel — Airfare |
| **Office supply retailers** | Office Supplies |
| **Payroll service providers** | Payroll Services |
| **Accounting software** | Software — Accounting |
| **Job boards / recruiting** | Recruiting |
| **Ad platforms** | Advertising — Digital |
| **Utilities (power, gas, water)** | Utilities |
| **Telecom carriers** | Telephone & Internet |
| **Insurance carriers** | Insurance |
| **Government tax authorities** | Tax payments — to specific tax liability |

**If the user's COA has no matching account for a vendor type, flag it and ask the user which account to
use.** **[auto]** to determine — the real chart is readable, so **whether a matching account exists is a
fact here, not a question.** Where none exists, say so precisely: *"no Hosting or Cloud Services account
exists in this chart; the nearest is 6300 Software Subscriptions — confirm."*

### Tier 3 — Keyword inference (Confidence: Medium) — **[auto]**

| Keywords | Conceptual category |
|----------|---------------------|
| **"subscription", "license", "monthly plan"** | Software Subscriptions |
| **"consulting", "advisory"** | Professional Services |
| **"legal", "attorney", "barrister", "solicitor"** | Legal Fees |
| **"audit", "bookkeeping", "CPA", "chartered accountant"** | Accounting / Audit Fees |
| **"rent", "lease" (non-equipment)** | Rent / Occupancy |
| **"freight", "shipping", "courier", "postage"** | Shipping & Postage |
| **"training", "course", "conference"** | Training & Development |
| **"restaurant", "café", "meals"** | Meals |
| **"fuel", "petrol", "diesel"** | Vehicle / Fuel |
| **"repair", "maintenance"** | Repairs & Maintenance |
| **"bank fee", "wire fee", "transaction charge"** | Bank Charges |
| **"interest"** | Interest Expense |
| **"loan payment"** | **Split**: Interest Expense + Loan Principal (BS) |
| **"dividend", "distribution"** | Owner Distributions / Dividends |
| **"refund", "credit" + positive amount** | Contra to original expense account |

### Tier 4 — Amount heuristics (Confidence: Medium-Low) — **[auto]**

- **Recurring same-amount monthly charges → likely subscription.** *Mosofin note*: **the full history is
  available**, so recurrence is a measured fact — "same amount on the same day for 11 consecutive months" —
  rather than a guess from one export.
- **Round-number month-end amounts → likely rent, payroll, or owner draw**
- **Many small food-vendor charges → Meals**
- **Amounts ≥ entity capitalization threshold → flag as possible Fixed Asset** — **ask the user for the
  threshold if unknown; do not assume**

### Tier 5 — Cannot classify (Confidence: Low)

**Mark as "Needs Review" with reason. Do not guess.**

## Step 3 — Tax codes (jurisdiction-driven)

**Only suggest tax codes if the user provided a jurisdiction AND a tax code list.** **[gated]** — the
**jurisdiction is now `[auto]`** from the profile and **the configured codes are `[auto]`**, but **which code
applies remains `[manual]`.**

**Common jurisdiction patterns recognized structurally, without baking in rates or rules:**

- **Single-rate VAT / GST** — standard / zero / exempt / out-of-scope
- **Multi-rate VAT with reduced rates**
- **Federal + sub-national stacked indirect taxes**
- **US-style sales tax** — paid by buyer at POS, **generally not input-creditable**
- **No indirect tax for the entity** — small supplier exemption, free zone, etc.

**For each transaction suggest a tax code based on:**

- **Vendor's tax registration status** (if known)
- **Nature of supply** — goods / services, domestic / cross-border
- **Recoverability under the entity's regime**

**Cross-border / reverse charge**: **if a vendor appears outside the entity's jurisdiction, flag for
possible reverse-charge or import-VAT treatment. Surface for review — do not silently apply.** **[auto]**
support: the vendor's address is readable, and the entity's country is readable, so **the cross-border flag
itself is determinable** even though the treatment is not.

**If no tax code list is available, output "Tax code: TBD — confirm with tax setup."** *Mosofin note*: where
the platform exposes the entity's configured codes, **name the codes that exist** rather than only "TBD" —
it turns a blank into a short list to choose from.

## Step 4 — Special-case rules

**Capitalization threshold check** — **[gated]**

For equipment, computers, furniture, vehicles and so on, **if the amount ≥ the entity's capitalization
threshold, flag**:

> **"Possible capital expenditure — consider Fixed Asset. Capitalization threshold: [user-provided or
> 'unknown — please confirm']."**

**Do not pick a threshold. Ask the user if not provided.** See
`fixed-asset-register-and-depreciation`, whose threshold scan is the same test run in the other direction.

**Personal-use detection** — **[auto]** on the patterns

Flag patterns suggesting personal rather than business use:

- **Groceries, personal retail**
- **Travel timing inconsistent with business** — weekend, vacation destinations
- **Personal services** — gym, spa, grooming
- **Family-member-named bookings**

**Surface as: "Possible personal — confirm business purpose."** **Surface, never conclude** — and where a
name match against the employee or owner list drives the flag, say that is what drove it.

**Split-transaction detection** — **[auto]**

**Single transactions likely covering multiple categories** — e.g. a warehouse-club run with mixed items —
**flag for split coding.**

**Inter-account transfer detection** — **[auto], and now genuinely determinable**

**Same amount, opposite sign, within ~3 days, between the entity's own accounts → flag as transfer, not
P&L.** **With ledger access both legs are visible**, so this moves from inference to observation: name the
matching transaction and its account. **The entity's own bank and card accounts are readable**
(*`search_accounts`*), which is what makes "between the entity's own accounts" checkable at all.

**Owner / related-party transactions** — **[gated]**

**Payments to / from owners, shareholders, directors, or related entities → flag for Due to / from accounts
or distributions.** **[auto]** support: compare vendor names against the employee list and against the other
connected company files' legal names. **A vendor whose name matches another entity in the group is an
intercompany transaction**, not a third-party expense.

**Loan payments** — **[gated]**

**Always split between Interest Expense (P&L) and Principal (BS liability reduction). Ask for the split if
not obvious from the source.** **[auto]** support: the loan liability account and its movement are readable,
which often reveals the principal portion directly — but **the amortization schedule is `[manual]`** (see
`debt-and-covenant-tracking`).

## Step 5 — Output

**Pasted lists → markdown table inline. Uploaded files → `.xlsx`.**

| Date | Vendor (Cleaned) | Description | Amount | Suggested GL Account | Tax Code | Confidence | Reasoning | Flags |

**Add two Mosofin columns**: **Evidence** — the history count behind a Tier 1 match, or the tier used — and
**Verdict** (`[auto]` / `[gated]` / `[manual]`).

**Confidence:**

- 🟢 **High** — exact vendor match or unambiguous pattern
- 🟡 **Medium** — keyword or amount-based inference
- 🔴 **Low** — needs review

**Flags:**

- 🏛️ **Possible CapEx**
- 👤 **Possible personal**
- ✂️ **Possible split**
- 🔁 **Possible transfer**
- ⚠️ **Unusual amount**
- 🌍 **Cross-border / reverse-charge candidate**
- 🔗 **Related-party**

**Two Mosofin flags added:**

- 📊 **Inconsistent history** — this vendor has been coded to more than one account
- 👥 **Duplicate vendor record** — the history is split across records

**End with summary: total coded, % by confidence band, count of flagged items.** Plus the Mosofin header
block: workspace name; the entity by `display_name`; each excluded company file and why; whether any read
returned `mock` data; **and whether the COA was read or a fallback is in use.**

**For an `.xlsx`, add two sheets:**

**Sheet: Uncoded Population — NEW, Mosofin-specific** — what is sitting in uncategorized and suspense
accounts, with ages and amounts. **This is the work list**, and it is often more useful than the batch that
prompted the request.

**Sheet: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict | Tool used / external source | As-at date | Policy | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Output naming:** `[EntityName]_Coded_Transactions_[YYYY-MM-DD].xlsx`

`[EntityName]` is the company file's `display_name`.

**Grounding:** every suggestion traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the threshold, the tax rules — **name the source required** instead of assuming.

## Step 6 — Evolve the skill (Mosofin-specific, final step)

**The Learning Loop below and this step are the same mechanism.** The original already asks whether a
correction should become a rule for future runs; **this is where that rule is actually kept.**

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The vendor-to-account rules the user confirmed or corrected** — expressed as **vendor type or rule**
  wherever possible, and **as a specific vendor only where the user chose that**
- **The house coding policy** — any rule that overrides history
- **The capitalization threshold**, with its effective date
- **The tax code mapping** — which configured code applies to which kind of supply
- **The account map**: which accounts are uncategorized or suspense, which are the bank and card accounts
  for transfer detection, which is the intercompany account
- **The normalization rules** — the processor prefixes and vendor aliases specific to this entity's feeds
- **Known inconsistencies deliberately left alone**, and why
- The replay recipe: the exact sequence of reads that produced the history and the uncoded population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist transaction lists, amounts, or the coding history itself.** The history is state and is
re-read every run — that is the point of reading it. **Persist the rules; never the transactions.** And
**never persist a "possible personal" or related-party flag against a named individual** — see
`fraud-detection-and-forensics` for why an unrebutted suspicion must not be carried forward.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — cloud hosting to 6310, threshold 1,000 from 2025-01-01, uncategorized is 8999" — not "cloud
hosting to 6310". **Account numbers are chart-specific and therefore entity-specific**, and applying one
company file's mapping to another files costs under headings that may not even exist. Record the chosen
**scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Learning Loop

**Preserved from the original, and now with somewhere to put the result.**

**If the user corrects a coding suggestion, apply the same logic to similar future transactions in the same
session.** At the end:

> **"I noticed you recoded [vendor] from [A] to [B]. Want me to note this as a rule for future runs?"**

**On yes, that rule goes into the Step 6 preferences** — keyed by datasource and `display_name` — and is
read back at the start of the next run, where it **overrides the ledger history**. A user correction is a
decision; the history is only practice.

**Encourage the user to maintain a vendor-to-account mapping file for reuse.** *Mosofin note*: **that file
is now largely redundant** — the ledger is the mapping, and the stored rules cover the exceptions. **What is
still worth maintaining by hand is the exception list**: the vendors where the obvious answer is wrong.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one history, one set of
rules.

**Multi-entity.** Steps 0–5 run **once per entity**, each call targeting exactly one `data_source_id`, every
suggestion carrying its entity's `display_name`. Then:

- **Confirm which entity each transaction belongs to before coding it.** This is the first question, not the
  last. A batch spanning two company files coded against one chart produces accounts that do not exist in
  the other.
- **The same vendor maps to different accounts in different entities**, because the charts differ. **Read
  each entity's history separately.** Never carry a Tier 1 match across company files.
- **A vendor whose name matches another connected entity is an intercompany transaction.** **[auto]** to
  detect — compare vendor names against the other files' legal names — and it should be coded to an
  intercompany account, not an expense. See `consolidation-and-eliminations`.
- **A transfer between two group entities is not an inter-account transfer.** The original's transfer rule
  covers movements between the entity's *own* accounts. Money moving to a sibling company is an
  intercompany balance in both sets of books.
- **Thresholds and tax codes may differ by entity** — different sizes, different jurisdictions. Store them
  keyed by entity.

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
| `create_skill` | Persists the evolved skill. Step 6. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The real chart of accounts, plus suspense accounts** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The coding history — Tier 1 evidence** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Prior transactions by vendor, with their accounts** | `search_purchases` / `search_bills` / `search_expenses` | `start_date`, `end_date` (required) |
| Vendor master, defaults, addresses | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **The tax codes configured in this entity** | `search_tax_codes` / `search_tax_rates` | varies |
| Related-party name comparison | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| Loan balances, for the interest / principal split | `get_balance_sheet` / `get_general_ledger` | `start_date`, `end_date`, `account` |
| **Country, industry, currency** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no tax rule engine, no capitalization policy and no receipt image on this surface.**

---

## Plain-language glossary

- **GL coding** — deciding which account a transaction belongs in.
- **Chart of accounts (COA)** — the list of headings this business uses.
- **Uncategorized / suspense account** — where transactions sit when nobody has decided yet. **A growing
  balance there is a backlog.**
- **Vendor normalization** — stripping the noise a bank feed adds to a merchant name.
- **Payment-processor prefix** — the "SQ *" or "PAYPAL *" that shows who processed the payment rather than
  who sold you anything.
- **Tier / decision hierarchy** — trying the most reliable rule first and only falling back when it does not
  apply.
- **Confidence rating** — how much the suggestion should be trusted before someone checks it.
- **Tax code** — the label controlling how sales tax or VAT is treated on a transaction.
- **Input credit / recoverability** — whether tax paid on a purchase can be reclaimed.
- **Reverse charge** — where the buyer, not the seller, accounts for tax on a cross-border service.
- **Capitalization threshold** — the amount above which a purchase becomes an asset rather than an expense.
- **Contra** — an entry reducing another account rather than creating a new one. **A refund is a contra, not
  income.**
- **Inter-account transfer** — moving your own money between your own accounts. **Not income and not
  expense.**
- **Related party** — an owner, director, employee or connected business. Their transactions need separate
  treatment.
- **Split coding** — dividing one payment across several accounts.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**No COA provided** → **ask. Don't invent accounts.** *Mosofin note*: normally `[auto]`; this applies when
the read is unavailable, and **the fallback in use must be stated.**

**No jurisdiction provided** → **skip tax codes or mark "TBD".** *Mosofin note*: the country is `[auto]`;
**the rules are not**, so a known country does not license a tax treatment.

**Multi-currency transactions** → **code based on nature; do not convert FX here. Flag for the
`multicurrency-fx-revaluation` skill.**

**Reimbursable vs. own-cost** → **if the entity passes through expenses to clients, ask whether there's a
separate Recoverable / Reimbursable account.** **[auto]** to check whether such an account exists.

**Credit card payments to the card** → **flag as transfer (bank → CC liability), not expense.**

**Vendor invoices with multiple line items** → **suggest per-line coding if detail exists; flag for split if
only a total is available but the invoice covers mixed categories.** **[auto]**: where the bill is already in
the system, **the line detail is readable** (*`get_bill`*).

**Refunds and chargebacks** → **contra to the original expense, not "Other Income".** **[auto]** support:
the original expense is findable by vendor and amount.

**Bulk-batched amounts** — e.g. a single PAYROLL line → **flag for `payroll-journal-entry-builder`.**

**Coding history is consistent but wrong** — *Mosofin-specific, and the central caution*. Two years of
consistent miscoding produces a confident, well-evidenced recommendation to continue. **Frequency is
practice, not correctness**, and a supplied policy overrides it.

**Coding history is inconsistent** — *Mosofin-specific*. **Report the split; do not pick.** The category was
probably never decided, and deciding it is the useful output.

**The vendor's default account differs from its actual history** — *Mosofin-specific*. Defaults are set once
and overridden thereafter. **Read the history.**

**Duplicate vendor records split the history** — *Mosofin-specific*. Neither record shows the full picture,
and both will be miscounted. Flag it.

**The uncategorized account is growing** — *Mosofin-specific, and worth surfacing unprompted*. It is the
backlog, with ages and amounts, and it is readable in one call.

**A vendor is another group entity** — *Mosofin-specific*. An intercompany balance, not a third-party
expense. Detectable by comparing names across connected files.

**A group transfer is flagged as an inter-account transfer** — *Mosofin-specific*. The original's rule covers
the entity's **own** accounts. Money to a sibling company is intercompany in both ledgers.

**A batch spans two entities** — *Mosofin-specific*. Confirm entity before coding, not after.

**A result comes back with `mock: true`** — *Mosofin-specific*. **Fixture history is not this entity's
history.** Downgrade every history-based confidence to Low and say why.

**A stored rule conflicts with the ledger history** — *Mosofin-specific, and the rule wins*. A user
correction is a decision; history is only practice. **Say that the two disagree.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's account numbers to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every transaction has a Confidence rating**
- **Every "Needs Review" item has a reason**
- **Account numbers and names come from the user's COA only — never invented**
- **Tax codes only when jurisdiction + tax code list provided**
- **Reasoning is one sentence**
- **Output naming**: `[EntityName]_Coded_Transactions_[YYYY-MM-DD].xlsx`

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**; **the
  entity each transaction belongs to was confirmed before coding**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Coding is to real accounts from the connected chart**; a fallback is used only when the read is
  unavailable, and **which fallback is in use is stated**
- **Every Tier 1 match carries its evidence** — the account, the count and the recency — rather than
  asserting a prior mapping
- **Inconsistent history is reported as inconsistent**, not resolved by picking the commonest or the most
  recent
- **Frequency is never presented as correctness**, and a supplied policy overrides history with the conflict
  reported
- **Vendor-type gaps are stated as facts** — whether a matching account exists in this chart, and what the
  nearest is
- **Transfer detection names both legs** and the accounts they sit in
- **Related-party and personal flags are surfaced, never concluded**, and the basis for each is stated
- **The uncoded population is reported** — uncategorized and suspense balances with ages
- **Duplicate vendor records are flagged** where they split a history
- In a multi-entity run, **no Tier 1 match is carried across company files**, and vendors matching another
  group entity are raised as intercompany
- Every suggestion carries its verdict (`[auto]` / `[gated]` / `[manual]`) and its evidence, in the coverage
  sheet
- `mock` status is reported wherever it applies, and **history-based confidence is downgraded on mock data**
- Every suggestion traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No transaction lists, amounts or coding history are persisted** into a skill bundle, and **no personal
  or related-party flag against a named individual is ever stored**; every persisted preference states the
  datasource and `display_name` it covers
- Nothing was written back to any system — no transaction coded, recoded or posted
