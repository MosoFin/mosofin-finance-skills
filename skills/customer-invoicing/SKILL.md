---
name: customer-invoicing
description: "Use this skill whenever the user wants to generate customer invoices, draft invoice templates, validate invoice content, or build batched invoices from their Mosofin workspace. Triggers include: 'create an invoice for [customer]', 'draft invoices for this month's billing', 'generate invoices from this list', 'invoice template', 'invoice with multi-currency', 'invoice with progress billing', or any task that produces a customer-facing invoice document. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then pre-fills customer, item, price, tax code, terms and the next invoice number from live data — and can validate invoices already issued against the same rules. Mosofin cannot create an invoice in the accounting system; it prepares the document and the data for a human to enter or import. Do NOT use for parsing vendor invoices — use invoice-data-extractor. Do NOT use for subscription scheduling — use recurring-transaction-builder. Outputs invoice documents, the corresponding AR / revenue / tax JEs, and a coverage sheet."
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
# Customer Invoicing (Mosofin)

Generates customer-facing invoices with full required content for any jurisdiction, including line
items, taxes, payment terms, and remit-to details. Produces the matching **AR / Revenue / Tax** journal
entry.

**In plain words:** an invoice is a legal document, not just a request for money. Most tax regimes
specify exactly what must appear on one before your customer can reclaim the tax — and if a field is
missing, they may refuse to pay until you reissue it. This skill builds invoices that carry everything
they need, and checks the ones you have already sent.

This skill is **jurisdiction-agnostic** and **chart-of-accounts-agnostic**. Tax handling, mandatory
invoice fields, and document numbering schemes vary widely by country — **the skill applies what the
user specifies**.

It is **workspace-scoped**: customer records, items, prices, tax codes, terms and the existing invoice
sequence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## What this skill is, in a read-only workspace

**Mosofin cannot create an invoice.** It is read-only, so it cannot write a document into the accounting
system, allocate a number in that system's sequence, or send anything to a customer. **The invoice
document and the data are the deliverable; entering or importing them is a human action.** Say so plainly
rather than implying an invoice has been raised.

That constraint splits this skill into **two genuinely useful modes**, and the second is the one most
teams have never run:

**1. Prepare.** Build the invoice with almost everything pre-filled from the books:

- **Customer name, address and tax ID** — from the customer record
- **Your own legal name, address and registration** — from the company profile
- **Items, descriptions, SKUs and standard prices** — from the item list
- **Tax codes and rates in use** — from the tax catalogue
- **Payment terms** — the customer's own terms, and what prior invoices to them actually carried
- **The next invoice number** in the entity's existing sequence — an input the original marks *Required*
  and the workspace can simply answer

**2. Validate.** Run the same rules against **invoices already issued**. Step 1's mandatory-field check,
Step 2's line validation and Step 3's arithmetic check are all `[auto]` over existing invoices — plus
**duplicate numbers and gaps in the sequence**, which is a control matter: a missing number usually means
an invoice was deleted, and in many jurisdictions a gap in the sequence is itself a compliance problem.

**What stays `[manual]`:** what to bill and for how much, the jurisdiction's specific mandatory-field
list, exemption certificates, progress-billing milestones, and any e-invoicing submission.

**Mosofin sends nothing.** Every draft is marked for review.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before drafting anything. This ordering is the contract. Do not
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

Confirming carefully matters here: **the entity issuing the invoice is the entity whose legal name and
tax registration go on it.** Drafting from the wrong company file produces a document that is legally
wrong on its face.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set, **and ask which entity is actually selling**. This is not a
  presentational question: **each entity has its own legal name, its own tax registration and its own
  invoice number sequence.** Draft from that entity's file only. See the cross-entity step.

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
- **No write tool exists on this surface**, and none will be substituted. Mosofin is read-only by design.
  If the user expects the invoice to appear in their system, say clearly that it will not.
- **A near-substitute is not a substitute.** **A customer record is not a validated tax registration.**
  The tax ID on file is what someone typed; whether it is currently valid is a check against the tax
  authority's own service, which is not available here. For cross-border B2B and reverse charge that
  validity is the whole basis of the treatment — flag it as `[manual]`.
- **The invoice search usually needs a date range.** To find the highest number in the sequence you may
  need to search recent periods deliberately rather than relying on a default window.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for the selling entity.

**Derive silently** what the profile answers — and here it fills a Required input directly:

- **Seller's legal name and address** — which goes on the invoice face
- **Base currency**
- Fiscal calendar, country / region — which **suggests** the jurisdiction but does not settle it

**Ask the user** what actually changes the work — the original Inputs table, minus what the connected
books already answer:

| What to confirm | Required? | Notes |
|---|---|---|
| **Customer** — name, address, tax ID | **Required — usually [auto]** | Pulled from the customer record. **Confirm the tax ID is current**; the record holds what was typed. |
| **Entity (seller)** — legal name, address, tax registration | **Required — [auto]** for name and address; **[manual]** for the registration number if not in the profile | |
| **Line items** — description, qty, unit price, tax code | **Required — [gated]** | **What to bill is [manual]**; descriptions, standard prices and tax codes pull from the item list. |
| **Invoice date** | **Required** | Never default it. Note the tax point may differ — see Step 1. |
| **Payment terms** | **Required — usually [auto]** | The customer's terms pull; confirm. |
| **Currency** | **Required — usually [auto]** | From the customer or the entity. |
| **Jurisdiction** | **Required — [manual]** | Drives mandatory fields and tax. **Never infer from the profile's country** — where you are registered and where the supply takes place can differ. |
| **Customer PO / reference** | Recommended — **[gated]** | Prior invoices to this customer show whether they require one. |
| **Sales tax / VAT / GST rates per line** | Required if tax applies — **usually [auto]** | The tax catalogue in use pulls; **whether a rate is correct for this supply is [manual]**. |
| **Invoice numbering scheme** | **Required — usually [auto]** | **The next number in sequence is readable.** Confirm the scheme (prefixes, resets, per-entity sequences). |
| **Chart of accounts** | **Required — usually [auto]** | For the revenue, tax and deferred revenue accounts. |
| **Mode** — prepare new invoices, or validate existing ones | **Required** | They are different jobs; see above. |
| **Confirm scope** | **Required** | Read back the selling entity by `display_name` and any excluded company files. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The jurisdiction's mandatory-field list and any exemption certificate will be `[manual]`. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the jurisdiction, a
tax rate, the invoice date, or the numbering scheme.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The jurisdiction's field list, the numbering scheme and the account map persist; **the next invoice number
is always re-read**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the customer record,
the item list, the tax catalogue, the terms and the recent invoice sequence do not depend on each other.
Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, for the selling entity:

- *`get_company_info`* — **the seller's legal name, address and base currency** — usually **[auto]**
- *`search_customers`* / *`get_customer`* — **the customer's name, address, tax ID and default terms** —
  usually **[auto]**
- *`search_items`* / *`read_item`* — **descriptions, SKUs, standard prices and default income accounts**
  — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* / *`search_tax_agencies`* — **the tax codes and rates in
  use** — usually **[auto]**
- *`search_terms`* / *`get_term`* — the terms catalogue, including any early-pay discount — usually
  **[auto]**
- *`search_invoices`* over recent periods — **the existing number sequence, for the next number and the
  gap check** — usually **[auto]**
- *`read_invoice`* on recent invoices to this customer — **what they were last billed, on what terms, with
  what PO reference** — usually **[auto]**
- *`search_accounts`* — the revenue, output tax and deferred revenue accounts — usually **[auto]**
- *`get_customer_balance`* / *`get_aged_receivables`* — what they already owe, worth knowing before
  invoicing more — usually **[auto]**
- *`search_estimates`* — a quote that this invoice may be billing against — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — an invoice drafted from it would go to a real
customer with invented details, and a number drawn from a fixture sequence would collide with the real
one.

## Step 1 — Apply jurisdiction-mandated invoice fields

**Most jurisdictions require specific fields on a valid (tax-reclaimable) invoice. Ask the user for their
jurisdiction's required content, or include the common set and let them validate.**

Common required fields across jurisdictions — verdicts noted, since roughly half are `[auto]`:

- **Seller's legal name, address, and tax registration number** — **[auto]** for name and address
- **Customer's legal name and address** (and tax registration if B2B in many VAT / GST regimes) —
  **[auto]** from the customer record
- **Unique sequential invoice number** — **[auto]** to derive the next in sequence
- **Invoice date** — **[manual]**
- **Tax point / date of supply** (**may differ from the invoice date**) — **[manual]**, and frequently
  overlooked: the tax point, not the invoice date, decides which period the tax falls in
- **Description of goods / services** — **[auto]** from the item list
- **Quantity and unit** — **[manual]**
- **Unit price exclusive of tax** — **[auto]** for the standard price
- **Tax rate per line** — **[auto]** for the rate; **[manual]** for whether it is the right one
- **Tax amount per line and total** — **[auto]** arithmetic
- **Total exclusive of tax** — **[auto]**
- **Total inclusive of tax** — **[auto]**
- **Currency** — **[auto]**
- **Payment terms / due date** — **[auto]**
- **Any specific phrases the jurisdiction requires** (e.g. "Reverse charge", "Zero-rated export", "Tax
  invoice") — **[manual]**, and their absence is a common reason a customer's tax authority disallows
  their claim and they come back asking for a reissue

**If the user is in a jurisdiction with electronic invoicing mandates** — e-invoicing portals, QR codes,
government clearance — **flag it: the skill can produce the data but submission requires the relevant
platform.** Mosofin cannot submit to a government portal.

**In validate mode**, run this list against existing invoices and report every missing field.

## Step 2 — Validate line items

Each line — **[auto]** for all five checks, whether on a draft or on an existing invoice:

- **Description is non-blank and specific**
- **Qty > 0, unit price > 0** — **allow zero only with an explicit reason** (e.g. a free trial line)
- **Tax code valid for the jurisdiction**
- **Currency matches the invoice header**
- **Product / service code (SKU) if the entity uses one**

**Compute line totals: qty × unit price = line subtotal; subtotal × tax rate = line tax; subtotal + line
tax = line total.**

**[auto]** and worth adding in prepare mode: **compare the price being charged against the item's standard
price and against what this customer was last charged** (*`read_item`*, *`read_invoice`*). A price that
departs from both is either a deliberate concession or a keying error, and it is much cheaper to ask now.

## Step 3 — Compute totals

- **Subtotal** (sum of line subtotals)
- **Total tax by rate** (e.g. $X at 5%, $Y at 20%)
- **Discount** (if any) applied at invoice or line level — **specify which**
- **Shipping / freight** (if applicable)
- **Total exclusive of tax**
- **Total inclusive of tax**
- **Amount due**

**For tax-inclusive jurisdictions, show pre-tax and tax separately even if list prices were
tax-inclusive.**

All **[auto]** arithmetic. In **validate mode this is the arithmetic check** — recompute every existing
invoice's totals from its lines and report any that do not agree. Rounding differences at the line-versus-
total level are the usual cause and are worth quantifying rather than ignoring.

## Step 4 — Construct the AR / Revenue / Tax JE

Hand off to `journal-entry-builder`. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a
proposal:

```
DR  Accounts Receivable                            $total inclusive
    CR  Revenue (per product/service line)           $subtotal
    CR  Output Tax / VAT / GST Payable               $tax
    CR  Other (shipping income, etc.)                $other
Memo: Invoice [#] — [Customer]
```

**If revenue recognition is deferred** (e.g. a subscription invoiced annually in advance), book:

```
DR  Accounts Receivable                            $total inclusive
    CR  Deferred Revenue                             $subtotal
    CR  Output Tax Payable                           $tax
```

**And schedule periodic recognition. Hand to `revenue-recognition-asc606` for ASC 606 compliance.**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*, **[auto]**) —
including the **default income account already set against each item** (*`read_item`*), which is usually
the correct one and saves a decision per line.

Note that in most accounting systems, **entering the invoice generates this entry automatically.** So in
prepare mode this JE is documentation of what will happen; in validate mode it is a check that what did
happen was right — particularly the deferred-revenue case, which systems rarely handle without help.

## Step 5 — Generate the invoice document

**Format the invoice as a clean, professional document.** The format depends on user preference (PDF,
HTML, or system input):

- **Header**: seller logo, name, address, tax IDs, contact
- **Bill-to**: customer name, address, tax ID
- **Invoice metadata**: number, date, due date, currency, PO reference
- **Line items**: table with description, qty, unit price, tax %, line total
- **Totals**: subtotal, tax breakdown, total due
- **Payment instructions**: how and where to pay
- **Footer**: any required statutory text

**If the user requests PDF: read `/mnt/skills/public/pdf/SKILL.md` first.**

**Mark every generated document as a draft for review.** Mosofin has not created it in the accounting
system and has not sent it. Two specific cautions:

- **Payment instructions carry bank details.** Confirm them with the user from a trusted source rather
  than reproducing them from memory or from an old document — invoice payment-detail fraud works by
  altering exactly this block.
- **The number on the draft is a proposal.** Until the invoice is actually entered, someone else may take
  that number.

## Step 6 — Output

**For a single invoice** → invoice document + JE inputs.
**For a batch** → an `.xlsx` with one row per invoice + a JE batch import.

**Sheet 1: Invoice Register**

| Inv # | Date | Due Date | Customer | Currency | Subtotal | Tax | Total | Status |

Add a header block: workspace name; **the selling entity by `display_name`**; each excluded company file
and why; the mode (prepare / validate); whether any figure rests on `mock` data.

**Sheet 2: Line Detail**

| Inv # | Line | Description | Qty | Unit Price | Subtotal | Tax Rate | Tax | Total | GL Revenue Account |

Add a **Source** column per field — pulled from the books, or supplied.

**Sheet 3: GL Posting**

Pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 4: Validation Results — NEW, Mosofin-specific**

| Inv # | Check | Result | Detail |

Covering mandatory fields, line validations, the arithmetic check, **duplicate invoice numbers**, and
**gaps in the number sequence**.

**Sheet 5: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be evidenced and who supplied it |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Invoices_[YYYY-MM-DD]_batch[N].xlsx`

In a multi-entity run, include the entity: `Invoices_[EntityDisplayName]_[YYYY-MM-DD]_batch[N].xlsx`.
Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the jurisdiction's field list, an exemption certificate — **name the source required**
instead of estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The jurisdiction's mandatory-field list** and the required statutory phrases. The most valuable item
  here: it is stable, it is genuinely hard to look up, and getting it wrong causes reissues
- **The numbering scheme** — prefixes, sequence rules, whether it resets, and whether each entity has its
  own
- **The invoice template**: layout, statutory footer text, and which fields appear where
- **The account map**: revenue accounts by item or service line, output tax, deferred revenue
- **Customer-specific requirements** — who requires a PO number, who is tax-exempt (with the certificate
  reference, not the certificate), who is billed under reverse charge, who withholds at source
- **The tax treatment per supply type**, including zero-rated and reverse-charge cases
- **Whether e-invoicing submission applies**, and through which platform
- The replay recipe: the exact sequence of reads that produced the pre-filled data

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; **no `.html`, `.css`, or `.svg` files** — which matters here, because
an invoice template is a natural thing to want to store that way. Keep the template as structured
description, not markup. Or write preference files alongside the installed skill.

**Never persist customer tax IDs, bank details, or invoice contents.** Tax IDs are personal or
commercially identifying data; **bank details are the target of invoice payment fraud**, and an invoice
template stored with live payment instructions is exactly what an attacker would want to alter. Persist
the *structure and the rules*, and keep payment details in the system that controls them.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading Ltd — invoice prefix NT-, sequence continuous; statutory footer required; reverse charge for EU
B2B services" — not "invoice prefix NT-". **Each entity has its own legal identity, tax registration and
number sequence**, and an unlabelled numbering scheme applied to the wrong company file produces
duplicate numbers across two legal entities. Record the chosen **scenario** (single vs multi, and which
entity sells) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and **the next invoice number is state**, re-read every time.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One legal identity, one sequence.

**Multi-entity.** The selling entity is chosen at Gate 1, and **the draft is built from that entity's file
only**. Then:

- **Each entity has its own legal name, tax registration and number sequence.** Never draw the customer's
  details from one entity's records and the seller's details from another's — the resulting document is
  legally wrong and, in a VAT regime, unusable by the customer.
- **The same customer may exist in several entities' records with different details.** Use the selling
  entity's record; it is the one the contract sits under.
- **Number sequences must not collide.** Where entities share a numbering convention, confirm each has its
  own range or prefix. Two legal entities issuing invoice "1042" is a real problem at audit.
- **Invoicing between group entities is an intercompany transaction.** It still needs a proper invoice
  where the jurisdictions require one, and it must be eliminated on consolidation — see
  `consolidation-and-eliminations` and `intercompany-reconciliation`.
- **The gap-and-duplicate check runs per entity**, since each sequence is its own.

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
| **Seller's legal name, address, base currency** | `get_company_info` | none (uses the connected company) |
| **Customer name, address, tax ID, default terms** | `search_customers` / `get_customer` | `query`/`name`, `active_only`; `id` |
| **Item descriptions, SKUs, prices, income accounts** | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| **Tax codes, rates and agencies in use** | `search_tax_codes` / `search_tax_rates` / `search_tax_agencies` | `query`/`name`, `active_only` |
| **Terms, including early-pay discounts** | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| **The invoice sequence — next number, gaps, duplicates** | `search_invoices` | `start_date`, `end_date` (required), `query`/`name` (DocNumber), `max_results`, `offset` |
| **What this customer was last billed, and on what terms** | `read_invoice` | `id` |
| Revenue, output tax and deferred revenue accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| What the customer already owes | `get_customer_balance` / `get_aged_receivables` | `report_date`, `customer` |
| A quote this invoice may bill against | `search_estimates` / `get_estimate` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Coding dimensions | `search_classes` / `search_departments` | `query`/`name`, `active_only` |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no invoice-creation tool, no tax-registration validation service and no e-invoicing submission
endpoint on this surface.**

---

## Plain-language glossary

- **Tax invoice** — an invoice meeting the legal requirements that let your customer reclaim the tax on it.
- **Tax point / date of supply** — the date that decides which tax period a sale falls in. **Not always
  the invoice date.**
- **Output tax** — tax you charge a customer. **Input tax** — tax you pay a supplier and reclaim.
- **Reverse charge** — a rule where the customer accounts for the tax instead of the supplier, common in
  cross-border B2B services. The invoice shows no tax and carries a required legend.
- **Zero-rated** — taxable at 0%, which is different from exempt: it still counts as a taxable supply.
- **Exemption certificate** — a customer's proof that they need not be charged tax.
- **Withholding tax** — tax the customer deducts from your payment and remits to their government on your
  behalf.
- **E-invoicing mandate** — a requirement to submit invoice data to a government portal, not merely send
  it to the customer.
- **Sequential numbering** — invoices numbered in an unbroken series; gaps can be a compliance problem
  because they suggest deleted documents.
- **SKU** — a product or service code.
- **Progress billing** — invoicing in stages as a long job advances.
- **Retainage / retention** — a portion the customer withholds until the job is signed off.
- **Deferred revenue** — money invoiced for work not yet done; a liability, not income.
- **Sales discount** — a reduction for paying early, recorded separately rather than netted off revenue.
- **Remit-to** — where and how the customer should send payment.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-currency**: the invoice currency may differ from the functional currency. **The customer pays in
the invoice currency; the entity books in functional. Use the invoice date's FX rate for the AR booking.
FX gain / loss at receipt time.** The rate itself is **[manual]** — no rate source here.

**Customer PO required**: **some customers won't pay an invoice without their PO number on it. Validate
before sending.** *Mosofin note*: **detectable** — check whether prior invoices to this customer carried a
PO reference, and flag its absence before the invoice goes out rather than thirty days later.

**Progress billings** (construction, long projects): **bill against completed milestones. Each invoice
references the contract and the milestone(s) billed.** May trigger POC accounting via
`construction-percentage-of-completion`.

**Retainage**: **invoice the gross but expect partial payment, with the rest held until project
completion. Track the retainage receivable separately** — otherwise the aging shows a permanently overdue
balance that is not actually late.

**Credit terms with early-pay discount**: **state it on the invoice** (e.g. "2/10 Net 30"). **At payment
time, if the customer takes the discount, reduce AR / revenue net or use a Sales Discount contra
account.**

**Tax-exempt customers**: **capture the customer's exemption certificate. Apply zero tax. Mark "Tax
Exempt — Certificate #…" on the invoice.** The certificate is **[manual]**, and invoicing a customer
tax-free without one on file is the entity's exposure, not theirs.

**Cross-border B2B**: in many VAT jurisdictions, B2B cross-border services use **reverse charge** —
**invoice with 0% tax and the legend "Reverse charge — recipient to account for VAT". Apply only if the
jurisdiction's rules support it**, and only where the customer's tax registration is valid — which is
**[manual]** to verify.

**Customer in a jurisdiction requiring withholding tax**: the customer may withhold at source. **Book gross
AR but expect a partial cash receipt plus a withholding tax credit. Coordinate with the customer** — and
see `cash-application`, where the short receipt shows up.

**Refunds and credits**: a **separate document (credit memo)** — see `credit-memo-and-refund-handler`.
Never amend an issued invoice to reflect a credit.

**Re-issued / corrected invoice**: **usually requires voiding the original and issuing a new one with a new
number — depends on the jurisdiction's rules.** *Mosofin note*: a voided number still occupies the
sequence, which is why the gap check must distinguish voids from missing documents.

**Mandatory e-invoicing jurisdictions**: **data must be submitted to a government portal, not just sent to
the customer. The skill prepares the data; submission is via the platform** — and Mosofin cannot submit.

**The invoice was not actually created** — *Mosofin-specific, and the expectation to manage up front*.
Mosofin is read-only. The document and the data are prepared; entering or importing them is a human
action, and until that happens the invoice does not exist and its number is not reserved.

**A gap in the invoice number sequence** — *Mosofin-specific and directly detectable*. Usually a deleted or
voided invoice. In several jurisdictions an unexplained gap is a compliance finding, so report gaps with
their numbers rather than only a count.

**A duplicate invoice number** — *Mosofin-specific*. Two documents with the same number is a genuine
problem, and in a multi-entity workspace it most often arises from two entities sharing a convention
without separate ranges.

**A price departing from both the standard price and the customer's history** — *Mosofin-specific*. Either
a concession or a keying error. Cheap to ask about before issuing; expensive afterwards.

**The tax ID on file is stale** — *Mosofin-specific*. The record holds what was typed, possibly years ago.
For reverse charge and cross-border treatment the registration's current validity is the basis of the tax
position, and it cannot be checked here.

**A company file is connected but not active** — *Mosofin-specific*. If it is the selling entity, no
invoice can be prepared from it. Name it and stop rather than drafting from a sibling.

**A result comes back with `mock: true`** — *Mosofin-specific*. A draft built on fixture data would carry
invented customer details to a real customer, and a fixture-derived number would collide with the real
sequence.

**A stored template holds live payment details** — *Mosofin-specific*. Do not persist them. Payment
instructions are the target of invoice fraud and belong in the system that controls them.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's numbering scheme or tax treatment to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Mandatory jurisdiction fields included or flagged for the user to confirm**
- **Each line has description, qty, price, tax — no blanks**
- **Math verified: subtotal + tax = total, line by line and in summary**
- **Invoice number unique within the entity's numbering scheme**
- **JE balances and books AR / Revenue / Tax separately**
- File naming consistent
- **Currency identified by ISO code**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- **The selling entity is named by `display_name`**, and its legal name and registration come from that
  entity's own profile — never a sibling's
- Every excluded company file is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The output states plainly that Mosofin did not create the invoice** and that the number is proposed,
  not reserved
- **The next invoice number was read from the live sequence**, and the **gap and duplicate checks were
  run** with any gaps listed by number
- **Every pre-filled field states whether it came from the books or was supplied**
- **The tax point is captured separately from the invoice date** where they differ
- **Prices are compared against the item's standard price and the customer's own history**, and departures
  flagged
- **Every draft document is marked for review**, and payment instructions are confirmed from a trusted
  source rather than reproduced from memory
- Account names in every proposed JE are the **real names from the connected chart of accounts**, using the
  item's own default income account where one exists
- In validate mode, **every existing invoice's mandatory fields, line validity and arithmetic were checked**
  and the results reported
- `mock` status is reported wherever it applies, and **no invoice is drafted to a real customer on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No customer tax IDs, bank details or invoice contents are persisted** into a skill bundle; every
  persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no invoice was created, numbered, posted or sent
