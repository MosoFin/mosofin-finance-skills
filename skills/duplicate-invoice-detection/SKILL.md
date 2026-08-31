---
name: duplicate-invoice-detection
description: "Use this skill whenever the user wants to detect duplicate or fraudulent invoices in AP from their Mosofin workspace. Triggers include: 'check for duplicate invoices', 'find duplicate payments', 'scan AP for duplicates', 'detect invoice fraud', 'have we paid this twice', uploading a payment history or AP register, or any AP control review focused on payment integrity. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then runs the detection rules directly against live bills, payments and the vendor master — nine of the ten rules are pure queries. The bank-account rule cannot run, because Mosofin deliberately does not expose vendor bank details. Do NOT use for general fraud detection across all transaction types — use fraud-detection-and-forensics. Outputs a duplicate-suspect list with confidence ratings, supporting evidence, and a coverage sheet."
---

<!-- shared:onboarding-inline start -->
## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** in the onboarding linked below — but every step becomes manual.

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
# Duplicate Invoice Detection (Mosofin)

Scans the **accounts payable register** for likely duplicate invoices and payments. Designed to catch the
common patterns: **the same invoice resubmitted, the same amount paid twice via different paths, slightly
altered invoice numbers, and vendor variants used to evade duplicate checks.**

**In plain words:** businesses pay the same bill twice more often than they realise. A supplier chases an
invoice that was already paid, someone enters it again, and it goes out a second time. Sometimes it is an
honest mistake; sometimes someone is exploiting the fact that nobody checks. This skill finds both.

This skill is **jurisdiction-agnostic**.

It is **not** system-agnostic. It is **workspace-scoped** — and that turns out to be its great advantage.

## This is the best-fitting skill in the pack

Most skills here need something the accounting system does not hold — a bank statement, a valuation, a
contract. **This one needs the AP register and the vendor master, and the workspace holds both,
completely.** So the detection rules are not a procedure to be performed; **they are queries**.

**Nine of the ten rules run directly:**

| Rule | Runs? |
|---|---|
| 1 — Exact invoice number + same vendor | **`[auto]`** |
| 2 — Same amount + vendor + invoice date | **`[auto]`** |
| 3 — Same amount + vendor + dates within N days | **`[auto]`** |
| 4 — Same amount + similar vendor name | **`[auto]`** |
| 5 — Invoice number sequence anomaly | **`[auto]`** |
| 6 — Same invoice number across vendor IDs | **`[auto]`** |
| 7 — **Same bank account, different vendors** | **`[manual]` — see below** |
| 8 — Round-number clusters | **`[auto]`** |
| 9 — Paid via two different channels | **`[gated]`** |
| 10 — Credit memo never applied | **`[auto]`** |

**And the one exception matters, because it is the fraud rule.** Rule 7 catches **two vendor records
sharing one bank account** — which is either a duplicated vendor or a deliberate fraud setup, and it is
the only rule aimed squarely at *fraud* rather than *error*. **Mosofin does not expose vendor bank
details**, deliberately: bank details are the single highest-value target in payment fraud, and this
surface does not carry them.

So be precise about what this skill delivers here: **a thorough duplicate-*error* detector, plus most of
the fraud-adjacent patterns (vendor aliases, sequence anomalies, cross-record reuse) — with the
bank-account test needing to be run in the AP or banking system itself.** Say so; do not let a clean
result imply the fraud test passed.

**Mosofin is read-only.** It cannot void a duplicate, merge vendor records, or recover a payment. Every
action below is a *proposal*.

---

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

Run Gates 0 → 1 → 2 → 3 in this order, before scanning anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between runs.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

<!-- shared:scope-protocol start -->
### First — is Mosofin connected at all?

**Before Gate 0, check whether the Mosofin tools are present** — `list_workspaces` and
the rest of the gateway.

**If they are not present** — the skill was copied on its own, the connector was never
added, or there is no subscription — **skip Gates 0-2 entirely.**
**Do not make connecting a condition of helping.** Say once, plainly, that Mosofin is not connected
and this run will be manual, then **carry on with the skill's normal workflow**: ask
for what each step needs — a trial balance, a statement, an export, the documents
themselves — and do the accounting work on what the user provides.

In that mode:

- every step is `[manual]`; there are no `[auto]` verdicts to claim, and none may be
  implied
- the coverage sheet records that **the gateway was absent** — not that checks passed
- the accounting logic, edge cases and output standards are **unchanged**. That is the
  part of this skill that never depended on a connection
- mention **once** that connecting Mosofin would automate the manual steps, with a link
  to [docs.mosofin.com](https://docs.mosofin.com). Do not raise it again, and never
  withhold work to press the point

**Present but not authenticated is not the same as absent.** If the tools are there and
a call returns a `reconnect_url` or an auth error, surface it and let the user choose —
reconnect, or continue manually. Do not silently fall back.

**If the tools are present, onboarding is required** and the gates below run as written.

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

Settle the entity scenario — and here it produces a genuinely additional detection pattern:

- **Single-entity** — ask which company by `display_name`; the scan runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The scan runs **once per entity**, every call targeting exactly one
  `data_source_id`. **Then run the cross-entity scan**: the same supplier invoice paid by two group
  entities is a duplicate that neither entity's own scan can see, and it is a well-known pattern in
  groups with shared suppliers and decentralised AP. See the cross-entity step.

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

Resolve **every rule in Step 2** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated, and this skill uses both a bill *search* and a single-bill *read*.
- **Pull the whole population, not a page of it.** Duplicate detection is a comparison across every record;
  a truncated result set produces **false negatives that look like clean results**. Use pagination
  deliberately, and **state the record count scanned** — a scan of 500 bills out of 4,000 is not a scan.
- **A near-substitute is not a substitute.** A **vendor spend summary** is a total per supplier; it cannot
  compare individual invoices, which is the entire task. If the bill-level search is disabled, this skill
  cannot run — say so rather than reporting no duplicates found.
- **There is no vendor bank detail on this surface.** Rule 7 is `[manual]`; do not look for a substitute.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: base currency — which tells you whether the multi-currency
caution in Rule 3 and the edge cases applies at all — fiscal calendar and year-end, which matters for the
cross-period pattern.

**Ask the user** what actually changes the work — the original Inputs table, minus what the connected books
already answer:

| What to confirm | Required? | Notes |
|---|---|---|
| **AP / payment register** | **Required — [auto]** | **Do not ask for an export; read it.** Confirm the population and the record count. |
| **Period to scan** | **Required** | Never default it. **Scan wider than the current period** — duplicates frequently straddle a boundary. |
| **Vendor master** | Recommended — **[auto]** | Read. Needed for the alias rules. |
| **Prior duplicate-detection results** | Optional — **[manual]** | So previously cleared clusters are not re-raised. |
| **Sensitivity setting** — Strict / Standard / Permissive | Optional — **[manual]**, default Standard | See Step 3. |
| **N for Rule 3** — the date window | Optional | Default 7 days; confirm if the entity's invoicing pattern is unusual. |
| **Known legitimate recurring suppliers** | Recommended | Rent, subscriptions and retainers legitimately repeat at identical amounts. Naming them up front removes most false positives. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and whether a cross-entity scan applies. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | Rule 7 is `[manual]`. Say so before reporting results. |

Ask as **one short batch**. Propose defaults where reasonable — the sensitivity and the date window have
sensible defaults and can be stated rather than asked — but **never** default the period or the entity.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The cleared-cluster list, the recurring-supplier list and the sensitivity setting persist; **the scan is
always re-run**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a rule because no tool covers it.** Rule 7 is `[manual]` and must still appear in the output,
marked as not run.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — bills, payments,
vendors and credits do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_bills`* — **the whole bill population for the period**, paginated to completion — usually
  **[auto]**
- *`get-bill`* — one bill's detail: number, date, amount, PO reference, lines — usually **[auto]**
- *`search_bill_payments`* / *`get_bill_payment`* — **what was actually paid, when, and how** — usually
  **[auto]**
- *`search_purchases`* — direct payments and card charges that bypassed the bill process — usually
  **[auto]**
- *`search_vendors`* / *`get-vendor`* — **the vendor master, including inactive records** — usually
  **[auto]**
- *`search_vendor_credits`* — **credits never applied** (Rule 10) — usually **[auto]**
- *`get_vendor_expenses`* — spend per supplier, for context and clustering — usually **[auto]**
- *`get_aged_payables`* — open items, to separate paid from unpaid duplicates — usually **[auto]**
- *`search_payment_methods`* — how methods are labelled, for Rule 9 — usually **[auto]**
- *`search_purchase_orders`* — PO references, for the same-amount-different-PO edge case — usually
  **[auto]**
- *`get_company_info`* — base currency and year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that rule to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate finding accuses someone of an error
or worse**, and a recovery request sent to a real supplier on fixture evidence is embarrassing at best.

## Step 1 — Normalize the data

For each record — **[auto]**:

- **Strip whitespace, normalize case** on vendor name and invoice number
- **Remove punctuation and special characters from invoice numbers** — some systems prefix or suffix
- **Group records by vendor** — use vendor ID as primary; **also link by vendor name fuzzy match for
  aliases**
- **Convert amounts to a common currency for comparison** if the register is multi-currency — **but flag
  any FX-related comparisons separately**

Two additions worth making explicit, because both cause false negatives:

- **Include inactive vendor records** in the master. A duplicate paid through a since-deactivated vendor
  record is exactly the pattern Rule 6 is looking for, and an active-only search will miss it.
- **Include voided and reversed records in the read**, then exclude them from the live scan and report them
  separately — per the edge case. Reading them is how you confirm the void was actually processed.

## Step 2 — Apply duplicate-detection rules

**Run each rule and assign confidence.** Rules ordered from highest confidence to lowest.

**Rule 1 — Exact invoice number + same vendor (Confidence: Very High)** — **[auto]**
Same vendor + identical invoice number = **almost certainly a duplicate entry. Even if dates and amounts
differ slightly, this is highly suspicious.** Flag.

**Rule 2 — Same amount + same vendor + same invoice date (Confidence: High)** — **[auto]**
Same vendor, same date, same amount, different invoice numbers = **could be two legitimate same-day
invoices or could be a duplicate with an altered invoice number.** Flag for review.

**Rule 3 — Same amount + same vendor + dates within N days (Confidence: Medium)** — **[auto]**
**N defaults to 7.** Same vendor, identical amount, near dates = possible duplicate.

**Rule 4 — Same amount + similar vendor name + same period (Confidence: Medium)** — **[auto]**
Vendor name slightly altered — **"Acme Corp" vs "Acme Corporation" vs "Acme Inc."**. Use string-similarity
matching (**Jaro-Winkler ≥ 0.85** or similar). Flag for review. Present the similarity score with each
match so a reviewer can judge it.

**Rule 5 — Invoice number sequence anomaly (Confidence: Medium-Low)** — **[auto]**
Invoice numbers from a vendor **typically increase monotonically. A sudden number out of sequence —
particularly a number lower than ones already paid — is suspicious.** Flag.

**Rule 6 — Same invoice number across different vendor IDs (Confidence: High)** — **[auto]**
Same invoice number paid to different vendor records = **likely a vendor master duplicate** (two vendor
records for the same vendor) **AND a duplicate payment**. Two findings from one match.

**Rule 7 — Same bank account, different vendors (Confidence: High)** — **`[manual]` — CANNOT RUN HERE**
Two vendor records sharing one bank account = **likely either the same vendor under two records or a fraud
setup. Flag both.**

**This rule cannot be executed from a Mosofin workspace.** Vendor bank details are not exposed on this
surface. **It must be run in the AP or banking system directly**, and it should be — it is the highest-value
fraud test in the list. **Report it as not run**, with a named owner, rather than omitting it.

**Rule 8 — Round-number duplicate amounts within short windows (Confidence: Low)** — **[auto]**
**Many vendors do issue same-amount recurring invoices (rent, subscriptions). Don't auto-flag, but check
for an above-threshold cluster.**

**Rule 9 — Identical invoice attributes but one paid via cheque, one via wire (Confidence: High)** —
**[gated]**
**Paid through two channels = classic duplicate-payment pattern.** The payment method is recorded in most
systems (*`search_bill_payments`*, *`search_payment_methods`*); where it is not, this rule degrades to
Rule 2 and should be marked as such.

**Rule 10 — Credit memo never applied (Confidence: Low for duplicate, but flag for AP hygiene)** —
**[auto]**
**A credit memo sitting open while subsequent invoices to the same vendor were paid in full = the credit
was never applied. Not a duplicate per se but worth surfacing** — and worth surfacing prominently, because
**it is money the entity is owed and has not taken.** See `credit-memo-and-refund-handler`.

## Step 3 — Sensitivity tuning

- **Strict**: flag any rule match with **Medium+** confidence
- **Standard** (default): flag any rule match with **High+** confidence
- **Permissive**: only flag **Very High** confidence matches

**[manual]** to set; **[auto]** to apply. **State the setting used on the output** — a "clean" result under
Permissive means something very different from a clean result under Strict, and the two are
indistinguishable without the label.

## Step 4 — Vendor alias detection

For each suspected duplicate, also check whether the vendors involved should be **merged in the vendor
master** — verdicts differ per check:

- **Same legal name with formatting differences** — **[auto]**
- **Same tax ID across different vendor records** — **[gated]**: readable where the vendor record carries a
  tax identifier; **[manual]** where it does not
- **Same bank account** — **[manual]**, per Rule 7
- **Same remit-to address** — **[auto]** where the address is on the vendor record, and a useful
  substitute signal for the bank-account test: **two vendor records at one address is the same shape of
  finding**, even though it is weaker evidence

**If so, recommend a vendor master merge plus retroactive duplicate cleanup.** Mosofin cannot merge
records — this is a proposal, and merging vendors is not reversible in most systems, so it warrants care.

## Step 5 — Recoverability assessment

For confirmed duplicates that have already been paid — **[auto]** to determine paid status
(*`search_bill_payments`*, *`get_aged_payables`*):

- **Status: paid out of the business**
- **Recovery options:**
  - **Vendor credit on the next invoice** — preferred; most cooperative vendors will issue a credit memo
  - **Refund from the vendor** — request explicitly
  - **Set off against an open balance** — **[auto]** to check whether one exists, which decides whether
    this option is even available
- **For open (unpaid) duplicates, simply void or remove the duplicate before payment** — and these are the
  valuable ones: **a duplicate caught before payment costs nothing to fix.** Sort the output so unpaid
  duplicates appear first

**Quantify the dollar exposure: total amount in flagged duplicates by confidence level.**

## Step 6 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Summary**

- **Period scanned, record count** — and **state the population scanned versus the population available**,
  so a truncated scan is visible
- **Total flagged by confidence level**
- **Total exposure ($) by confidence level**
- **Already-paid vs. open**
- **Recovery actions proposed**

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one and
why; **the sensitivity setting used**; **that Rule 7 was not run**; whether any figure rests on `mock`
data.

**Sheet 2: Flagged Pairs (and Groups)**

| Cluster ID | Vendor (Primary) | Records in Cluster | Rule Matched | Confidence | Amount per Record | Cluster Total | Paid Status | Recovery Action |

**Each cluster expanded to show the 2+ underlying records side by side** — this is what lets a reviewer
agree or dismiss in seconds rather than investigating.

**Sheet 3: Detail**

Per-record fields including **everything used to match**: vendor name (raw + normalized), invoice # (raw +
normalized), date, amount, payment method, payment date, status.

**Sheet 4: Vendor Aliases to Merge**

| Alias Group | Vendor IDs | Vendor Names | Recommended Master Record | Justification |

**Sheet 5: Recovery Plan**

Per cluster, the recommended action and the contact to pursue it. **Unpaid duplicates first.**

**Sheet 6: Rules Run — NEW, Mosofin-specific**

| Rule | Verdict (auto / gated / manual — not run) | Records evaluated | Matches found | Note |

**Rule 7 appears here marked not run, with its owner.** A rules-run sheet is what turns "no duplicates
found" into a defensible statement.

**Sheet 7: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict | Tool used | Population scanned | Policy | `mock` | Gap |

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `Duplicate_Invoice_Scan_[YYYY-MM-DD].xlsx`

In a multi-entity run: `Duplicate_Invoice_Scan_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus one
cross-entity file. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where a rule could not be
run, **say so** rather than reporting it as finding nothing.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

This is a scan that should run every month, so the evolution step matters: **without it, the same false
positives come back every time and the report stops being read.**

On an explicit yes, persist the **decisions**:

- **Cleared clusters** — pairs and groups reviewed and dismissed, with the reason and the date. **The
  single most valuable artefact here**, because a recurring false positive is what kills a control report
- **Known legitimate recurring suppliers** — rent, subscriptions, retainers — so Rule 8 stays quiet
- **Confirmed vendor aliases** that have been merged, and those deliberately kept separate
- **The sensitivity setting** and the Rule 3 date window
- **The recovery playbook** — who to contact per supplier, and whether they prefer credit or refund
- **Whether Rule 7 is run elsewhere**, by whom, and how often
- The replay recipe: the exact sequence of reads that produced the population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist vendor bank details, invoice-level data, or any suspicion attached to a named person.** Bank
details are the fraud target this skill exists to protect; **a stored note that a named employee's
transactions were flagged is an allegation**, and duplicates are usually error rather than misconduct.
Persist **cleared cluster references and supplier-level settings**, not the accusations.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — recurring at fixed amount: landlord, insurer, three SaaS suppliers; sensitivity Standard; Rule 3
window 7 days" — not "sensitivity Standard". Suppliers and billing patterns differ by entity, and an
unlabelled recurring-supplier list applied to the wrong company file suppresses real duplicates. Record the
chosen **scenario** (single vs multi, and whether cross-entity scanning applies) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One population, one rule set.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every cluster carrying its entity's `display_name`. **Then run the cross-entity scan**, which finds
duplicates no single-entity scan can:

- **The same supplier invoice paid by two group entities.** Common wherever suppliers serve several group
  companies and AP is decentralised — and **completely invisible to each entity's own scan**, because each
  sees only one payment. Match on **vendor name plus invoice number plus amount across entities**; Rule 1
  applied across the group is the highest-value cross-entity test available.
- **A supplier existing under different vendor records in different entities** is normal and expected —
  do not propose merging vendor masters across legal entities. The alias analysis is *within* an entity;
  the duplicate analysis is *across*.
- **An invoice legitimately split between entities** — a shared service recharged in parts — is not a
  duplicate. Check whether the amounts sum to the invoice total rather than each equalling it.
- **Intercompany invoices** between group entities will match themselves across the two sets of books by
  construction. Exclude group entities from the counterparty population before running the cross-entity
  scan, or every intercompany charge appears as a duplicate.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each rule's verdict per company
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
| **The whole bill population — paginate to completion** | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One bill's number, date, amount, PO reference | `get-bill` | `id` |
| **What was actually paid, when and how** | `search_bill_payments` / `get_bill_payment` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Direct payments bypassing the bill process | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required); `id` |
| **The vendor master — include inactive records** | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`, `max_results`, `offset`; `id` |
| **Credits never applied (Rule 10)** | `search_vendor_credits` / `get_vendor_credit` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Spend per supplier, for clustering | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Open vs. paid status | `get_aged_payables` / `get_vendor_balance` | `report_date`, `vendor` |
| Payment methods, for Rule 9 | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| PO references, for the different-PO case | `search_purchase_orders` / `get_purchase_order` | `start_date`, `end_date` (required); `id` |
| Manual entries that bypassed AP | `search_journal_entries` | `start_date`, `end_date` (required) |
| Base currency and year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no vendor bank detail on this surface — Rule 7 cannot be run here.**

---

## Plain-language glossary

- **AP register** — the list of supplier bills and what has been paid against them.
- **Duplicate payment** — paying the same bill twice.
- **Vendor master** — the list of supplier records. **Vendor alias** — the same supplier existing under
  more than one record.
- **Remit-to address** — where a supplier asks to be paid.
- **Fuzzy / string-similarity matching** — comparing names that are close but not identical.
  **Jaro-Winkler** is one scoring method; 0.85 is a common threshold.
- **Monotonic** — always increasing. Invoice numbers from one supplier usually are.
- **Cluster** — a group of records suspected of being the same underlying invoice.
- **Confidence level** — how strong the evidence for a match is.
- **Sensitivity** — how eagerly the scan flags: strict flags more, permissive flags less.
- **Set-off** — deducting what you are owed from what you owe.
- **Void / reversal** — cancelling a record after it was entered.
- **Tranche** — one part of a payment made in instalments.
- **False positive** — a flag that turns out to be legitimate. **False negative** — a real duplicate the
  scan missed.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Legitimate identical recurring invoices** (rent, monthly subscriptions): vendors do issue identical
amounts repeatedly. **Check invoice dates spread across months — if they're 30-ish days apart, that's a
pattern, not a duplicate. Filter these out at Rule 8 unless the dates overlap.** *Mosofin note*: store the
recurring suppliers at Step 7 so they stop recurring as false positives.

**Cross-period duplicates** (one invoice paid in December, another in January with the same number):
**flag — fiscal-year-boundary fraud is a known pattern.** *Mosofin note*: this is why the scan window
should extend beyond the period being reviewed.

**Vendor reissues an invoice** (original lost or corrected): both versions may exist in the register but
**only one paid. Verify against the payment ledger, not just the invoice register.** **[auto]** — and this
check is why the payment search matters as much as the bill search.

**Vendor merger / acquisition**: two vendor records may legitimately have shared a bank account during a
transition. **Flag and confirm.**

**Partial payments**: a vendor's invoice paid in two tranches **isn't a duplicate. Distinguish by checking
total paid against invoice total.** **[auto]**.

**Different currencies, same vendor**: amounts may "match" only after FX conversion. **Be cautious —
FX-converted matches are not high confidence. Flag for human review.**

**Voided / reversed entries**: **ignore voided records in the live duplicate scan, but include them in a
separate sheet to confirm voids were processed correctly.**

**Internal credit memo applied as a payment**: **not a duplicate payment, but may look like one in the
register if not coded properly.**

**Same vendor, same amount, different POs**: **legitimate if each PO references a different deliverable.
Check the PO reference field.** **[auto]** where bills carry PO references.

**Rule 7 could not be run** — *the central Mosofin-specific gap*. Vendor bank details are not on this
surface. **Report the rule as not run with a named owner**; a clean scan does not mean the fraud test
passed.

**A truncated population scanned** — *Mosofin-specific and a silent failure mode*. Duplicate detection
compares every record against every other; a partial population produces **false negatives that look
exactly like a clean result**. Paginate to completion and state the record count.

**Inactive vendor records excluded** — *Mosofin-specific*. A duplicate routed through a deactivated vendor
record is precisely what Rule 6 hunts. Search including inactive records.

**A duplicate paid by two group entities** — *Mosofin-specific*, and invisible to any single-entity scan.
Run the cross-entity match.

**Intercompany invoices flagged as duplicates** — *Mosofin-specific*. In a cross-entity scan, group
entities appear on both sides by construction. Exclude them from the counterparty population first.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say that its
payments were not scanned. In this skill an unscanned entity is an unchecked payment population.

**A result comes back with `mock: true`** — *Mosofin-specific*. A duplicate finding implies an error or
worse, and a recovery request to a real supplier on fixture evidence is worse than no scan.

**A previously cleared cluster reappears** — *Mosofin-specific*. Without the cleared list, the same false
positives return monthly and the report stops being read. Persist them and suppress them with their
reason visible.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the rule as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every flagged cluster has a confidence level and a rule reason**
- **Side-by-side comparison shows why the records were matched**
- **Recovery action assigned for each flagged item**
- **Total exposure quantified by confidence**
- **Vendor-master merge candidates surfaced separately**
- File naming consistent
- **No silent suppression of legitimate same-amount recurring patterns**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**,
  with the unscanned-population consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **A rules-run sheet states which of the ten rules ran**, over how many records, and what each found —
  **including Rule 7 marked not run, with an owner**
- **The population scanned is stated against the population available**, and pagination was run to
  completion
- **Inactive vendor records and voided entries were included in the read**, then handled per their rules
- **The sensitivity setting is stated on the output**, so a clean result is interpretable
- **Fuzzy matches show their similarity score** and the alternatives considered
- **Unpaid duplicates are listed first** — they cost nothing to fix
- **Unapplied vendor credits are surfaced prominently** as money owed to the entity
- In a multi-entity run, **the cross-entity scan was run** with group entities excluded from the
  counterparty population
- Every rule carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that tool's
  policy, in the coverage sheet
- `mock` status is reported wherever it applies, and **no recovery request rests on mock data**
- Every figure traces to a tool result in this conversation; the answer ends with a single **Data sources**
  line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No vendor bank details, invoice-level data, or suspicion attached to a named person are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no record voided, no vendor merged, no recovery requested
