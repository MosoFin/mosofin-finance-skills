---
name: vendor-statement-reconciliation
description: "Use this skill whenever the user wants to reconcile vendor statements to the AP subledger and GL against a connected Mosofin workspace, identify missing invoices or credits, duplicates and disputes, and propose actions and entries. Triggers include: vendor statement recon, AP statement tie-out, supplier statement mismatch, cleaning up AP balances, 'which suppliers should we be reconciling', 'do we have unrecorded liabilities', 'are there credits we never claimed'. Reads the full AP subledger, payment register and vendor spend profile through the Mosofin read-only gateway; the vendor statement itself is a document the supplier sends. Produces a reconciliation table, exceptions list and next actions. Proposes only — Mosofin posts nothing."
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
# Vendor Statement Reconciliation — Mosofin Seed

Reconciles vendor statements — the supplier's own open balance or ageing — to the AP subledger and the general ledger, identifies missing and duplicate items, and drives resolution.

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## This is a genuine external reconciliation

Worth saying plainly, because it is unusual in this pack.

Most reconciliations here tie one part of a ledger to another part of the same ledger, and I have had to say repeatedly that they **agree by construction** — the balancing balance sheet in `financial-statement-builder`, the segment reconciliation in `segment-reporting`, the detail-to-summary tie in `quickbooks-ar-aging-collections`, the equity roll-forward in `statement-of-equity-changes`.

**This one is different.**

> **A vendor statement is independent evidence, prepared by a third party from their own records.**

That makes it the same kind of thing as a bank statement — and **it is the same kind of control**. `bank-reconciliation` and this skill are the two genuine external reconciliations on the cash-and-payables side, and they earn their place for the same reason: **the other side of the comparison was produced by somebody with no access to your books.**

### Which makes it the primary control over completeness of AP

**Completeness is the hardest assertion to test.** `internal-audit-workpaper` makes the point and `sox-controls-design-and-testing` repeats it: a full-population test of what is in the ledger still cannot prove that nothing is missing, because absence leaves no trace.

**A vendor statement is one of the few things that can.** The supplier lists what they believe you owe them. **Anything on their list and not on yours is a candidate unrecorded liability** — and unrecorded liabilities are the classic AP misstatement, understating both payables and expense.

**So the accounting significance of this skill is larger than "tidying up AP suggests."** At a period end it is the substantive completeness procedure over payables.

### The clean split

| Side | Where it lives | Verdict |
|---|---|---|
| **AP subledger and vendor ledger** | **The workspace** — every invoice, credit, payment, in full detail | **`[auto]`** |
| **Payment register** | **The workspace** | **`[auto]`** |
| **The vendor statement** | **A PDF the supplier emailed.** Not in any accounting system. | **`[manual]`** |
| **The dispute log** | Notes, emails, someone's spreadsheet | **`[manual]`** |

**One side is exact and complete; the other has to be obtained.** Which is exactly what makes the reconciliation worth doing.

### And a contribution the original does not have

The source assumes **a statement in hand** and reconciles it. It says nothing about **which vendors ought to be reconciled at all** — which, in practice, is the decision that determines whether the control works.

**`[auto]` answers it**: rank the whole vendor population by balance, by spend, by activity, and by whether a statement has ever been reconciled. **A large supplier whose statement has never been reconciled is precisely where an unrecorded liability sits undisturbed.** See Step 0.

### Three near-substitutes

**1. The AP balance is not what you owe.** It is what you have **recorded**. The gap between the two is the entire subject of this skill, and treating the ledger balance as the liability assumes away the question.

**2. A statement is not an invoice.** Step 5 is careful about this — *record confirmed missing items **with support*** — and the qualifier is load-bearing. **You cannot book a liability from a statement line alone**: you need the invoice, both for the accounting and for input tax recovery. A statement tells you an invoice may exist; it is not the invoice.

**3. Matching on amount is not matching.** Recurring suppliers issue identical amounts month after month. **An amount match without a document number or a date is a coincidence dressed as a match**, and it produces two errors at once — see Step 2.

**And a fourth, which cuts the other way: the statement can be wrong too.** It is the vendor's view of the relationship, produced from their system, subject to their errors. An item on the statement and not on your books may be an invoice they never sent, one they sent to the wrong entity, or one already settled and not applied on their side. **The reconciliation is two-way.**

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

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

## Gate 0 — Confirm the workspace before anything else

1. Call `list_workspaces` with no arguments.
2. If the status is `confirmed`, there is one workspace. **Read its name back and wait for an explicit yes.**
3. If the status is `selection_required`, ask: **"Is this a single-workspace task or a multi-workspace one?"**
   - Single: ask which one by name, then `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. Never print the internal numeric id, never ask for it, and if it appears in an error, name the workspace instead.

**Why this gate matters here.** In a group sharing suppliers, **a statement addressed to one entity reconciled against another's ledger will show every invoice as missing** — a spectacular and entirely artificial set of exceptions. **Confirm which entity the statement is addressed to**, and see the note below.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The AP side must be exported. The reconciliation works as the original describes. **Step 0's prioritisation does not run.** |
| **Exactly one company file** | Confirm the `display_name` — **and that it is the entity the statement addresses.** |
| **Several company files** | **Groups share suppliers.** See below — this is a common and confusing failure. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. Stop — **a partial AP ledger makes recorded invoices look missing**, which points the reconciliation in exactly the wrong direction. |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

**The shared-supplier problem, and it is worth anticipating.** Where a group buys from one supplier through several entities, **the supplier may issue one statement covering all of them, or separate statements per account.**

- **One combined statement**: reconciling it against a single entity's ledger produces false "missing invoice" exceptions for everything belonging to the siblings. **`[auto]` where the other entities are connected** — read all of them and match across, then split the result by entity.
- **Separate statements**: check the account reference on the statement matches the entity being reconciled. **A statement for the wrong account is the commonest cause of a reconciliation that will not converge.**

And the related trap from `vendor-onboarding-and-w9-tin`: **if the supplier exists twice in one vendor master, half the invoices are under the other record** and will present as missing. **Run the duplicate check before concluding anything.**

---

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Map what you can actually do

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

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each tool.

| `effective_policy` | Verdict | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch with other independent reads. |
| `permission` | `[gated]` | Expect `approval_required`. Explain what and why, get a yes, re-invoke with `approved=true`. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | `[manual]` | Not available. The step remains; the user performs it. |

Every verdict below is a **default written before the gateway was consulted.** Where Gate 2 disagrees, **Gate 2 wins** for this run. Do not carry a capability map between runs.

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** The AP ageing, the full vendor transaction ledger, the payment register, the vendor master and spend by vendor are independent. **Read beyond the cutoff date** — payments in transit and post-cutoff activity are needed to explain differences, and a read stopping at the cutoff cannot distinguish a timing difference from a missing item.

### The `mock: true` flag

Fixture data has **an AP ledger with no missing invoices, no unclaimed credits and no duplicates** — and no vendor statement at all to reconcile it against.

Label it in the file name and on the reconciliation summary.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Interview for:

1. **The vendor statement(s).** `[manual]` — the whole point, and not obtainable from the workspace.
2. **The cutoff date.** `[manual]` — and see Step 1; **a statement's cutoff and yours frequently differ.**
3. **The dispute log.** `[manual]`.
4. **The reconciliation policy** — which vendors, how often, who owns exceptions. `[manual]`, **and Step 0 informs it.**

**Decisions are the user's; state is the workspace's.**

---

## How to read the verdicts

- **`[auto]`** — Mosofin can do this from live reads, unattended.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` and the `data_source_id`.
- **`[manual]`** — not on this surface, or not a machine's judgment. **The step stays. The user performs it.**

**Everything here is a proposal.** The gateway is read-only. Mosofin posts nothing and contacts no supplier.

---

## Step 0 — Decide which vendors to reconcile *(Mosofin addition)*

**`[auto]`. One read, and it should precede any individual reconciliation.**

**Reconciling every supplier statement is not feasible and not necessary.** The question is which ones, and the answer is a ranking the workspace can produce exactly:

| Signal | Why it ranks |
|---|---|
| **Largest AP balances at the cutoff** | Where a difference is most material. |
| **Largest annual spend** | Where the volume of transactions makes error most likely. |
| **Vendors never reconciled** | **The highest risk of all** — an unrecorded liability that has never been looked for. |
| **Vendors with a credit balance in AP** | **Almost always wrong.** A debit balance on the supplier's account means either a payment misapplied, a duplicate payment made, or a credit note that should have been claimed. **Money, usually yours.** |
| **Vendors with old open items** | Invoices unpaid for months are either disputed, already paid and misapplied, or never should have been recorded. |
| **Vendors whose invoice pattern broke** | **Regular monthly billing that stopped** — either the relationship ended, or invoices are arriving and not being entered. |
| **High GRNI** | Goods received not invoiced — see `three-way-match` exception 7. The supplier's statement will show those invoices. |

**Rank by amount, and report which vendors have never been reconciled.**

**The credit-balance row deserves emphasis** because it is money and it is free to find: **a supplier account in credit means the business has paid more than it owes**, and the causes — duplicate payment, misapplied payment, unclaimed credit note — are all recoverable. **One query across the whole ledger.**

**The last row is the completeness signal**: a supplier who invoiced monthly for two years and has sent nothing for three months is either gone or **their invoices are not reaching the ledger.** The second case is exactly an unrecorded liability, and the pattern break is visible without any statement at all.

---

## Inputs

All five preserved.

| Input | Format | Required | Mosofin source | Verdict |
|---|---|---|---|---|
| **Vendor statement** | PDF / CSV | **Required** | **Not in the books. The supplier sends it.** | `[manual]` |
| **AP ageing / vendor ledger** | Export | **Required** | **`[auto]`, in full detail** — no export needed | **`[auto]`** |
| Payment register | AP payments + bank info | Recommended | **`[auto]`** | `[auto]` |
| Dispute log | Notes of disputed invoices | Recommended | **Not in the books** — disputes are correspondence | `[manual]` |
| **Cutoff date** | Month-end date | **Required** | **`[auto]` for yours; the statement carries its own** — see Step 1 | Split |

---

## Workflow

### Step 1 — Normalise both datasets

`[auto]` for the ledger side; `[manual]` extraction for the statement.

Standardise all five fields:

- **Document number**
- **Type** — invoice, credit, payment
- **Date / due date**
- **Amount / currency**
- **PO / reference**

**`[auto]` for the ledger side, completely** — every field is a database field.

**`[manual]` for the statement**, which is a PDF. Where it arrives as CSV, extraction is mechanical; where it is a scanned image, it is not. See `invoice-data-extractor` for the extraction discipline.

#### Three normalisation traps, all `[auto]` to handle and all routinely missed

**Document numbers are text.** Leading zeros, prefixes, and the supplier's internal reference versus the number printed on the invoice. **`INV-0042`, `42` and `0042` are one document**, and a match on the raw string finds none of them. Normalise both sides the same way and **record the normalisation applied** — the same discipline `quickbooks-ar-aging-collections` applies to preserving document numbers as text.

**Cutoff dates differ.** **The supplier's statement cutoff is very often not your period end.** A statement dated the 25th against a ledger at the 30th will show five days of legitimate difference in both directions. **Establish both dates explicitly** and treat the gap as a known reconciling window rather than a set of exceptions.

**Sign conventions differ.** Suppliers present credits and payments with varying signs and column layouts. **Normalise to a consistent convention before matching**, or credits will present as invoices and the reconciliation will not converge.

---

### Step 2 — Match statement items to the AP ledger

**`[auto]` once the statement is normalised.** The four-tier matching order preserved exactly:

1. **Document number**
2. **Amount + date proximity**
3. **PO + amount**
4. **Fuzzy reference / description**

**The order is a confidence hierarchy and it should be respected as one.** Tier 1 is near-certain; tier 4 is a suggestion.

**Two Mosofin requirements**, both carried across from `three-way-match`'s line matching, because the failure mode is identical:

**Record the match tier for every matched item.** A reviewer needs to see which matches are confident and which are inferred. A reconciliation where half the matches came from tier 4 is a different document from one where they all came from tier 1.

**Never force an uncertain match.** **An unmatched item is a question; a wrongly matched item is two wrong answers** — one item is marked resolved that is not, and another is left as an exception that is not real. **Leave doubtful items unmatched and let a person look.**

**And the amount-match caution from the near-substitutes**: tier 2 exists because document numbers are often absent or mangled, and it is genuinely useful — **but with a recurring supplier billing the same amount monthly, amount plus date proximity can match the wrong month.** Where several candidates tie, **report the ambiguity rather than picking one.**

---

### Step 3 — Explain differences

**All six preserved, and the verdicts differ sharply.**

| Difference | Meaning | Verdict |
|---|---|---|
| **Missing invoice on books** | On the statement, not in your ledger | **`[auto]` to identify — and it is the finding that matters most.** See below. |
| **Missing credit memo on books** | The supplier has credited you and you have not recorded it | **`[auto]` — and this is money owed to you.** See below. |
| **Payments in transit** | Paid by you, not yet received or applied by them | **`[auto]`** — match against the payment register and the dates |
| **Misapplied payment** | Paid, but they applied it to a different invoice | **`[auto]` to detect** — the payment appears on both sides against different documents |
| **Duplicates** | The same invoice recorded twice on either side | **`[auto]`** — see `duplicate-invoice-detection` |
| **Disputes** | Withheld deliberately | **`[manual]`** — the dispute log is correspondence, not ledger data |

#### Missing invoices, and why they are the point

**This is the unrecorded liability**, and it is the reason the reconciliation is a completeness control.

An invoice on the supplier's statement and not in your ledger means one of:

- **it was never received** — and is a genuine unrecorded liability
- **it was received and not entered** — sitting in someone's inbox or a pending queue
- **it was entered under a different vendor record** — run the duplicate-vendor check first
- **it was entered to a different entity** in the group
- **it does not exist** — the supplier's error, or an invoice sent to someone else

`[auto]` can distinguish several of these: the duplicate-vendor case, the wrong-entity case where entities are connected, and the entered-late case where the invoice appears after the cutoff.

**What remains is `[manual]` and needs the invoice**, per the second near-substitute: **you cannot book from the statement line.** Request the invoice copy, and **at a period end, accrue where the liability is confirmed but the document has not arrived** — which is the same accrual as the GRNI position in `three-way-match`. See `accruals-and-prepayments` and `month-end-close-checklist`.

#### Missing credits, which nobody looks for

**The mirror case, and it is in the client's favour**, which is exactly why it goes unfound: nobody chases a supplier about money the supplier owes them.

A credit note on the statement and not in your ledger is **a reduction in what you owe that has not been taken** — and if the invoice it relates to has already been paid in full, **it is cash you are owed.**

`[auto]` finds them across the whole statement. **Report them prominently and separately from the adverse differences**, because a reconciliation presented as a list of problems buries the one item that returns money.

---

### Step 4 — Resolution playbook

`[manual]`. All three preserved:

- **Owner**
- **Next action**
- **Target close date**

**Every exception gets all three.** `[auto]` can propose the action from the difference type — request invoice copy, request credit note, investigate application, reverse duplicate — **and the owner and the date are human commitments.**

**One `[auto]` addition worth having**: **ageing of exceptions across reconciliations.** An exception raised three months running and still open is not an exception; it is a state. Where the reconciliation is a recurring process, **carry the exception list forward and age it** — the items that never close are the ones that need escalating rather than re-raising.

---

### Step 5 — Accounting actions

`[auto]` to draft; **`[manual]` to post.** All three preserved:

- **Reverse duplicates**
- **Reclass mis-postings**
- **Record confirmed missing items with support**

> **"with support"**

**The qualifier is preserved and it is the important part.** A statement line is not support. **Recording a liability needs the invoice** — for the amount, for the coding, for the tax treatment, and for input tax recovery, which generally requires a valid invoice and not a statement (see `vat-gst-international` Step 5).

**Where the liability is confirmed and the document has not yet arrived, the answer is an accrual, not an invoice posting.** They are different entries with different consequences: an accrual reverses and is replaced when the invoice arrives; a posted invoice without the document leaves a payable nobody can support and, in a VAT jurisdiction, an input tax claim that may be disallowed.

Hand drafted entries to `journal-entry-builder`. **Marked PROPOSED — NOT POSTED.**

---

## Outputs

All four of the original's outputs preserved, plus two additions. Delivered as an `.xlsx` workpaper.

**Sheet 1: Reconciliation Summary**
| Statement balance | Ledger balance | Difference | Explained | Unexplained |

**With both cutoff dates shown**, per Step 1, and the fixture flag.

**Sheet 2: Matched Item List**
| Statement doc | Ledger doc | Type | Date | Amount | Match tier | Notes |

**The Match tier column is the Mosofin addition** and it is what makes the sheet reviewable.

**Sheet 3: Exceptions Table**
| # | Item | Type of difference | Amount | Root cause | Owner | Next action | Target date | Age |

**Root cause, owner and next action are the original's** — **Age is added**, for recurring reconciliations.

**Sheet 4: Recommended JEs**
Book errors and confirmed missing entries. **Marked PROPOSED — NOT POSTED**, and **accruals distinguished from invoice postings.**

**Sheet 5: Vendor Prioritisation** *(Mosofin addition)*
The Step 0 ranking — which suppliers should be reconciled, which never have been, which carry credit balances, which show a broken invoice pattern.

**Sheet 6: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

File naming: `Vendor_Statement_Recon_[VendorName]_[YYYY-MM-DD].xlsx`

Entity `display_name` on every sheet — **and the statement's addressee**, per Gate 1.

---

## Edge Cases

*(A Mosofin addition — the original has no Edge Cases section.)*

**The statement is for a different entity in the group.** Every invoice presents as missing. **Check the account reference before reconciling** — the commonest cause of a reconciliation that will not converge.

**The supplier exists twice in the vendor master.** Half the invoices sit under the other record. **Run the duplicate-vendor check first.** See `vendor-onboarding-and-w9-tin`.

**Different cutoff dates.** A window of legitimate difference in both directions. Establish both dates and treat the gap as known, not as exceptions.

**The statement is an open-item list; your ledger is a balance-forward.** Or the reverse. **The two cannot be compared line for line** until one is converted. Establish which each is before matching.

**A statement showing only overdue items.** Some suppliers issue chasing statements rather than full ones. **Reconciling to it will show every current invoice as unmatched** — which is meaningless. Confirm the statement's scope.

**The supplier's error.** An invoice on the statement that was genuinely never issued to you, or was settled and not applied on their side. **The reconciliation is two-way**, and pushing back is legitimate — `[manual]`.

**Payments made to an old bank account.** A payment you made and they did not receive. **Serious**, and it connects to `vendor-onboarding-and-w9-tin`'s bank-change detection: if the details were changed fraudulently, the supplier's statement is the thing that reveals it — **which is another reason the reconciliation matters.**

**Foreign currency statements.** The supplier states in their currency; your ledger may hold both. **Match on document and quantity of currency, not on the converted amount** — the converted figures will differ by the rate used and by revaluation. See `multicurrency-fx-revaluation`.

**Rebates and volume credits.** Frequently agreed commercially and not invoiced or credited for months. **They may appear on neither side** and are a completeness question of their own. `[manual]` — ask.

**Consignment or self-billed arrangements.** Where you raise the document rather than the supplier, the statement may be blank or structured differently. **Confirm the arrangement** before treating the absence of invoices as a finding.

**A statement that has never been requested.** The most consequential edge case, and the reason Step 0 exists: **for a supplier whose statement has never been reconciled, the reconciliation is not routine maintenance — it is a first-time substantive test**, and the exceptions may be years old.

---

## Output Quality Standards

*(A Mosofin addition — the original has no Output Quality Standards section.)*

- **Both cutoff dates are stated**, and the window between them treated as known difference.
- **The statement's scope is confirmed** — full open-item, overdue-only, or balance-forward.
- **The entity and account reference on the statement match the ledger being reconciled.**
- **The duplicate-vendor check runs before any "missing invoice" conclusion.**
- **Every matched item shows its match tier.**
- **Uncertain matches are left unmatched**, not forced.
- **Missing credits are reported separately and prominently** — they are money in the client's favour.
- **Missing invoices are classified** by likely cause, not lumped together.
- **Confirmed missing items are accrued, not posted as invoices**, until the document arrives.
- **Every exception has a root cause, an owner, a next action and a target date.**
- **Exceptions are aged across reconciliations**, so the ones that never close are visible.
- **Vendors are prioritised by amount and by whether they have ever been reconciled.**
- **Nothing is presented as posted.**
- **File naming consistent.**

---

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`), **and the entity the statement addresses**
- **Statement cutoff date and ledger cutoff date**
- **Statement scope** — full, overdue-only, balance-forward
- Vendor, and its account reference on the statement
- **Fixture flag** — any `mock: true`? In bold.

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict.

**Section C — Steps by verdict**
Every step. **A reader should see that one side of this reconciliation was read in full and the other was supplied.**

**Section D — What was not done, and why**
- **The vendor statement** — **the supplier sends it; it is not in any accounting system**
- **The dispute log** — correspondence
- **Invoice copies** for confirmed missing items — **required before posting, not before accruing**
- **Contact with the supplier**
- **Posting.** The gateway is read-only

**Section E — Unknowns carried forward**
Unmatched items on both sides. Missing invoices awaiting copies. Credits not yet claimed. Exceptions open from prior reconciliations, with their age. Vendors on the Step 0 list not yet reconciled.

**Section F — Parameters used**
Cutoff dates. Normalisation applied to document numbers. Match tiers used and any fuzzy thresholds. Currency basis. **A reconciliation that cannot be reproduced cannot be rolled forward**, and this one should roll forward.

---

## Seed to evolved: what happens on the first real run

**What must never be frozen into a seed:** the capability map — Gate 2 reads it fresh.

**What is worth persisting into the workspace-scoped skill:**

1. **Which vendors are on the reconciliation programme**, at what frequency — the output of Step 0, turned into a policy.
2. **Each supplier's statement conventions** — cutoff date, scope, document number format, currency, sign convention. **This is what makes the second reconciliation quick and the first one slow.**
3. **The account reference per supplier per entity**, so the wrong-entity trap is closed.
4. **The normalisation rules** for each supplier's document numbers.
5. **Open exceptions, with their age and owner**, carried forward — **the single most valuable item**, because an exception list that resets each period never resolves anything.
6. **Known permanent differences** — a consignment arrangement, a self-billing agreement — so they are not re-raised.
7. **Vendors reconciled and when**, so "never reconciled" stays accurate.

Persist through `create_skill`, scoped to the workspace. **Client facts belong in a client-scoped skill, never back in the seed.**

**The evolved version opens with the exception list carried forward and the vendors due for reconciliation this period** — which turns a periodic clean-up into a running control.

---

## Anti-patterns

- **Reconciling whichever statement happened to arrive.** Step 0 says which ones matter.
- **Concluding "unrecorded liability" before checking for a duplicate vendor record.**
- **Reconciling a statement addressed to a sibling entity.**
- **Ignoring the cutoff difference.** Five days of activity is not a set of exceptions.
- **Comparing an open-item statement to a balance-forward ledger** line for line.
- **Matching on amount alone** with a recurring supplier.
- **Forcing an uncertain match.** It creates two errors, not one.
- **Reporting matches without their tier.**
- **Burying missing credits in a list of problems.** They are money owed to the client.
- **Posting an invoice from a statement line.** Accrue; post when the document arrives.
- **Assuming the statement is right.** It is the vendor's view and it can be wrong.
- **Converting foreign currency before matching.** Match on document and currency amount.
- **Letting exceptions reset each period.** Age them; the ones that never close are the finding.
- **Treating this as housekeeping.** It is the primary completeness control over payables.
- **Saying "posted".** The gateway reads.

---

## Related skills

| Skill | Relationship |
|---|---|
| `bank-reconciliation` | The other genuine external reconciliation on this side of the ledger. |
| `three-way-match` | GRNI — goods received not invoiced — which the supplier's statement will show as invoices. |
| `duplicate-invoice-detection` | Duplicates on either side. |
| `vendor-onboarding-and-w9-tin` | Duplicate vendor records, and the bank-change detection this reconciliation can confirm. |
| `invoice-data-extractor` | Extracting the statement where it arrives as a document. |
| `accruals-and-prepayments` | Accruing confirmed liabilities where the invoice has not arrived. |
| `month-end-close-checklist` | Where the reconciliation belongs as a recurring close task. |
| `journal-entry-builder` | Formats the proposed entries. |
| `vat-gst-international` | Why input tax recovery needs the invoice, not the statement. |
| `multicurrency-fx-revaluation` | Foreign currency statements and why converted amounts differ. |
| `internal-audit-workpaper` / `sox-controls-design-and-testing` | Completeness as the assertion hardest to test — and why this reconciliation is the control that addresses it. |
| `accounts-payable-automation` | The upstream process whose failures show up here. |
