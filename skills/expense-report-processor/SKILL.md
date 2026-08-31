---
name: expense-report-processor
description: "Use this skill whenever the user wants to process, review, or post employee expense reports against their Mosofin workspace. Triggers include: uploading an expense report export (Concur, Expensify, Brex, SAP Concur, Pleo, Spendesk, Soldo, or any other T&E tool), pasting an expense report, 'review these expense claims', 'check this expense report against policy', 'code these employee expenses', 'post the expense report to the GL', or any reference to T&E (travel & entertainment) reimbursements. Also trigger for per-diem calculations, mileage reimbursements, and corporate card reconciliation tied to employee submissions. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then codes against the real chart of accounts, matches claims against transactions already posted, and checks the reimbursement and card-clearing balances. Do NOT use for vendor invoices — use invoice-data-extractor. Do NOT use for petty cash — use petty-cash-management. Outputs a policy-validated, GL-coded expense report ready for reimbursement and posting, with a coverage sheet."
---

<!-- shared:onboarding start -->
## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** — but every step becomes manual.

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

### First-run onboarding

Work through these once per workspace. **The skill does not read any data until you
have explicitly confirmed step 3.**

| # | Step | What happens |
|---|---|---|
| 1 | **Have an active subscription** | The Mosofin gateway returns data only for an authenticated, subscribed account. Unauthenticated calls are rejected. |
| 2 | **Connect the gateway** | Add the Mosofin MCP server — `https://mcp.mosofin.com/mcp`. Follow [**Connect MosoFin to Claude**](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) for the exact steps in your destination. Authentication is **OAuth** — no credentials are stored locally, and **this skill never asks you for a password, token or account number.** |
| 3 | **Confirm your workspace** | Gate 0 below. The skill reads your workspaces back **by name** and waits for an explicit yes. Silence is not a yes. |
| 4 | **Confirm the company file** | Gate 1. Which set of books, by name — never by internal id. |
| 5 | **Capability check** | Gate 2. The skill reads what your subscription and connection actually permit **today** and annotates every task accordingly. |
| 6 | **Profile** | Gate 3. On the first run this is a short interview. On later runs the skill reads what was already learned and asks only what is still open. |

### Where the setup instructions live — [docs.mosofin.com](https://docs.mosofin.com)

Mosofin connects a **source** (your books) to a **destination** (where you are reading
this skill). Both sides have to be set up once. If any step above is unclear, or a gate
below reports that it cannot reach your data, start here:

| If you need to… | Read |
|---|---|
| Do the whole setup start to finish | [Quickstart](https://docs.mosofin.com/start-here/quickstart) |
| Create an account or sign in | [Sign in and account basics](https://docs.mosofin.com/start-here/register-a-mosofin-account) |
| Create the workspace this skill will read | [Set up your first workspace](https://docs.mosofin.com/start-here/create-your-first-data-flow) |
| **Connect Mosofin to your destination** | [Destinations overview](https://docs.mosofin.com/source-and-destination/destinations) → [Claude](https://docs.mosofin.com/source-and-destination/destinations/claude) → [Connect MosoFin to Claude](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) |
| Connect the books themselves | [Sources overview](https://docs.mosofin.com/source-and-destination/sources) → [Connect QuickBooks](https://docs.mosofin.com/source-and-destination/sources/quickbooks/connect-quickbooks) |
| See which data and tools are exposed | [Available financial data](https://docs.mosofin.com/source-and-destination/sources/quickbooks/data-overview) · [API tools reference](https://docs.mosofin.com/source-and-destination/sources/quickbooks/api-tools) |
| Fix a connection that will not authenticate | [Common issues](https://docs.mosofin.com/source-and-destination/destinations/claude/common-issues) · [Claude FAQ](https://docs.mosofin.com/source-and-destination/destinations/claude/faq) |
| Check your subscription, seats or limits | [Billing](https://docs.mosofin.com/account/billing) · [Usage and plan limits](https://docs.mosofin.com/account/plan-limits) |
| Get a person involved | [Contact support](https://docs.mosofin.com/troubleshooting/contact-support) |

### What the subscription requirement means in practice

- **The gateway is read-only.** Nothing in this skill posts an entry, files a return,
  sends a message, or moves money. **Every output is a proposal for a person to act on.**
- **Access is workspace-scoped.** The skill sees only the workspaces and company files
  your subscription grants, and only the tools enabled for them.
- **Permissions are read fresh on every run.** If your plan, connection or tool
  permissions change, the skill's behaviour changes with them. It never assumes
  yesterday's access.
- **You are told what was actually available.** Every run produces a coverage sheet
  recording which capabilities were live, which were gated, and which were unavailable.

### Running without a connection

The skill **degrades rather than failing**. Every step that would have been automatic
becomes `[manual]`, and you supply the data by export instead. The output says so
explicitly — you will always be able to tell which figures came from your books and
which you provided by hand.

---

<!-- shared:onboarding end -->
# Expense Report Processor (Mosofin)

Reviews employee expense reports for **policy compliance**, codes them to **GL accounts**, flags exceptions,
and produces a reimbursement-ready summary plus posting instructions. Designed for AP teams processing
**T&E** (travel and entertainment) and out-of-pocket reimbursements anywhere in the world.

**In plain words:** staff spend their own money, or the company card, and want it back or accounted for.
The job is to check each line against the rules, put it in the right account, catch what should not be
claimed, and work out what the employee is actually owed.

This skill is **jurisdiction-agnostic**. **It does NOT bake in any country's mileage rate, per-diem table,
receipt thresholds, deductibility rules, or gift caps.** All such values come from the user's policy or the
user's stated jurisdiction's current rules. If the user does not provide them, **ask — never guess
jurisdiction-specific numbers.**

It is **workspace-scoped**: the chart of accounts, the employee list, the already-posted transactions and
the balances come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense.** The original had to work
without a COA and fall back to placeholders. **Here the real chart of accounts is available**, so coding is
to real accounts — and that is a change in what the skill claims, stated openly rather than left implied.

## What the workspace changes about this skill

The original is unusually honest about what it can and cannot do without each input. **Four of those inputs
stop being asks in a Mosofin workspace**, so the honesty table is rewritten rather than repeated:

| Original input | Original fallback | In a Mosofin workspace |
|---|---|---|
| **Chart of accounts** | "codes to category names only, labeled **PLACEHOLDER — REMAP REQUIRED**" | **`[auto]`.** The real COA is one read. **No placeholders.** |
| **Employee details** | Recommended; asked for | **`[auto]`.** Names, IDs, departments where set up. |
| **Functional currency** | "Default: from data" | **`[auto]`** from the company profile. |
| **Tax codes / recoverability setup** | Needed jurisdiction input | **`[gated]`.** The tax codes the entity actually uses are readable; **the rules governing them are still `[manual]`.** |

**And it adds a check the original could not perform at all:**

**The duplicate test against what is already posted.** The original's duplicate detection compares the
report against itself — same vendor, amount and date twice. **The workspace lets you compare the report
against the books.** Corporate card transactions are already in the ledger. **An out-of-pocket claim for
something the company card already paid is the classic double reimbursement**, and here it is a query rather
than a hope.

Two more that follow from the same access:

- **Historical coding.** How this entity has coded airfare, or client meals, or that specific merchant, in
  the past. **A grounded suggestion beats a generic mapping** — and it is what the reviewer would have
  checked anyway.
- **The clearing and payable balances.** Corporate Card Clearing should clear; Employee Reimbursement
  Payable should reflect what is genuinely owed. **Residual balances in either are unmatched activity**,
  and they are readable.

**What the workspace still cannot give you:**

- **The policy.** Always `[manual]`. Without it, policy validation does not run — that limit is unchanged.
- **The receipts.** Receipt *images* are not on this surface. The report's receipt-attached flag is
  evidence about the T&E tool, not about the receipt.
- **Mileage rates, per-diem tables, deductibility rules, gift caps.** All `[manual]`, all jurisdiction- and
  policy-specific.
- **The submitted report itself**, when it lives in Concur or Expensify rather than in the accounting
  system.

**Mosofin is read-only.** It cannot approve a claim, reject a line, pay a reimbursement or post an entry.
Everything below is a *proposal*.

---

# PART A — Prerequisites: confirm scope, discover the capability map

Run Gates 0 → 1 → 2 → 3 in this order, before processing anything. This ordering is the contract. Do not
skip a gate because a previous conversation covered it — connections, permissions, and company files
change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

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

**Check specifically for a connected T&E or spend-management platform** — Concur, Expensify, Brex, Ramp,
Pleo, Spendesk, Soldo. **If one is live, the expense report itself becomes `[auto]`**, which converts the
skill's largest manual input. If none is, the report is supplied by hand and labelled as such. Either way
the accounting datasource still supplies the COA, the employees and the posted transactions.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. **The employee-to-entity question is the one that matters**: staff are
  employed by one entity but may incur costs on behalf of another. See the cross-entity step.

Refer to companies by `display_name`; never show the raw `data_source_id`.

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
  - **A posted expense transaction is not a submitted claim.** The ledger shows what was recorded, not what
    an employee asked for and a manager approved.
  - **A receipt-attached flag is not a receipt.** It is a field in another system.
  - **The tax code on a transaction is not proof of recoverability.** The code is a setting; the entitlement
    is a rule.
  - **An employee record is not an approval hierarchy.** Who may approve whose claim is not in the ledger.
- **If the COA read is `disabled`, the skill degrades to the original's placeholder behaviour** — say so
  explicitly rather than quietly coding to invented accounts.

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar,
country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Expense report** | **Required — [manual]** unless a T&E platform is connected | The claims themselves. |
| **T&E policy document or parameters** | **Required for meaningful policy validation — [manual]** | **Without it, Step 2 does not run.** Say so rather than inventing limits. |
| **Receipts** | Recommended — **[manual]** | Images are not on this surface. |
| ~~Employee details~~ | **Now [auto]** | From `search_employees`; confirm only if a claimant is not found. |
| ~~Chart of accounts~~ | **Now [auto]** | From `search_accounts`. **No placeholder coding.** |
| **Tax jurisdiction** | Recommended — **[manual]** for the rules | The **codes in use** are `[auto]`; the entitlement rules are not. |
| **Mileage rate** (per-km or per-mi) | Required if mileage claims present — **[manual]** | **Never supply a prevailing rate from memory.** |
| **Per-diem table** | Required if per-diems are claimed — **[manual]** | Same rule. |
| ~~Functional currency~~ | **Now [auto]** | From the company profile. |
| **FX rate source** | Required if multi-currency — **[manual]** | Central bank close, accounting system rate, or report-date rate. **Do not assume a source.** |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the report period. |
| **Confirm any profile contradiction** | **Required if one appears** | e.g. claims in a currency the entity does not transact in. |
| **Confirm manual evidence** | **Required** | The policy, the rates and the receipts are `[manual]`. Record what was supplied and as at when. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default a mileage rate, a
per-diem, a receipt threshold, a deductibility split, a gift cap, or an FX source.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what changed.
The policy parameters, the category-to-account map, the rates in force and the FX source persist; **the
claims and the balances are re-obtained every run**.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** Policy validation without a policy is the original's own
documented limit and remains so.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

Pull the `[auto]` / `[gated]` reads **before** parsing, because the COA and the posted transactions are
what make the coding and the duplicate check real rather than generic.

**Batch independent reads into one message** — the accounts, the employees, the posted expenses and the
balances do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the real chart of accounts**, including the travel, meals, entertainment, gift
  and clearing accounts — usually **[auto]**
- *`search_employees`* — **the claimant list**, with departments where set up — usually **[auto]**
- *`search_purchases`* / *`search_expenses`* / *`search_bills`* — **transactions already posted in the
  period**, which is the duplicate-check population — usually **[auto]**
- *`search_credit_card_charges`* or the card account in *`get_general_ledger`* — **corporate card
  activity** — usually **[auto]**
- *`get_general_ledger`* on **Corporate Card Clearing** and **Employee Reimbursement Payable** — usually
  **[auto]**
- *`get_balance_sheet`* — the **payable and Due-from-Employee balances** — usually **[auto]**
- *`search_vendors`* — merchant recognition — usually **[auto]**
- *`get_profit_and_loss`* by department / class — **historical coding patterns** — usually **[auto]**
- *`search_departments`* / *`search_classes`* — the dimensions available for allocation — usually **[auto]**
- *`get_company_info`* — legal name, **functional currency**, country — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the COA read,
  say explicitly that coding has degraded to placeholders.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate check against fixture transactions
proves nothing**, and must not be reported as a clean result.

## Step 1 — Parse the report

Extract per line — **[manual]** unless a T&E platform is connected:

- Employee name
- Expense date
- Category (Airfare, Lodging, Meals, Ground Transport, Mileage, Supplies, Other)
- Vendor / merchant
- Description / business purpose
- Amount (gross; **tax and tip separately if shown**)
- Currency
- Payment method (employee cash / card, corporate card, reimbursement requested?)
- Receipt attached: Y/N
- Reference number / unique line ID

**Tool-specific normalization tips:**

- **Concur**: handles **split transactions across categories — preserve splits, don't merge.**
- **Expensify**: **SmartScan confidence — flag low-confidence OCR'd lines.**
- **Brex / Ramp / Pleo / Spendesk**: **corporate card transactions already paid — distinguish from
  out-of-pocket.**
- **Soldo / Mooncard / Pleo**: **prepaid card transactions — treat as company-paid.**

That distinction is now load-bearing: **company-paid lines are the ones that should already exist in the
ledger**, and Step 2's duplicate check depends on classifying them correctly.

**Normalize messy data:**

- **Mileage entries** → capture **distance and unit (mi or km), and rate (or flag as missing)**
- **Foreign currency** → **preserve original**; use the provided FX rate or **flag for the user to supply**
- **Tip separately captured if shown**

**Mosofin addition — match each claimant to an employee record.** **[auto]** via *`search_employees`*. A
claimant with no employee record is worth flagging: a leaver, a contractor claiming on an employee form, or
a misspelling.

## Step 2 — Validate against policy

**Policy validation only runs if the user provided a policy.** If no policy, **skip this step and move to
Step 3** — GL coding, math check and obvious-personal flags only. **[manual]** on the policy throughout;
the arithmetic against it is `[auto]`.

When a policy is provided, validate per its rules. Common dimensions:

### Receipt requirements

Apply **the user's** policy thresholds. Common patterns to look for in the policy:

- **A minimum amount above which receipts are required**
- **Specific categories that always require receipts regardless of amount** — commonly lodging, client
  entertainment, anything reimbursable cross-border
- **Tax-authority requirements for the entity's jurisdiction** — if the policy doesn't address this, **flag
  for the user to confirm**

**Flag missing-receipt items per the policy's stated rules.** **[gated]**: the threshold comparison is
arithmetic, but **the receipt flag comes from the T&E tool and the image is not visible here.** Report it as
"per the report", not as verified.

### Per-diem

If the entity uses per-diems for lodging and/or meals — **[manual]** table, `[auto]` comparison:

- **Compare claimed amount to the per-diem table provided**
- **Flag any claim exceeding the per-diem**
- **For mixed regimes** (per-diem M&IE + actual lodging) — **flag meal receipts as potential duplicate
  claims**

### Meals & entertainment

- **Per-person caps from policy**
- **Alcohol allowed / restricted per policy**
- **Client meals: require attendees + business purpose per policy**
- **Deductibility treatment per jurisdiction** (if the user provided the jurisdiction): some jurisdictions
  allow full deduction, some partial, some none — **split the GL coding accordingly only if the user
  provided the rule**

**[auto]** contribution: whether the COA *has* separate deductible and non-deductible accounts is readable
(*`search_accounts`*). If it does not, that is the Step 3 flag, raised early.

### Airfare / rail / sea travel

- **Class restrictions per policy** (economy, premium economy, business)
- **Booking source restrictions**
- **Personal segment allocation if the trip extends personal days**

### Lodging

- **Per-night caps from policy**
- **Resort / cleaning / incidental fees — reimbursable per policy**
- **Personal nights — non-reimbursable**

### Ground transport

- **Ride-share, taxi, rental car — per policy**
- **Mileage at the rate provided by the user / policy / jurisdiction's prevailing rate** — **[manual]**,
  and **never supplied from memory**

### Entertainment

- **Deductibility flag per the entity's jurisdiction** (only if the user provided it)
- **Per policy: allowed / restricted / requires pre-approval**

### Gifts

- **Cap per recipient per policy**
- **Deductibility cap per jurisdiction** (only if the user provided the rule)

### Personal-expense patterns (red flags)

**These are universal red flags regardless of jurisdiction** — and they are pattern checks, so `[auto]`
against the parsed report:

- **Weekend charges in non-business locations**
- **Personal retail / grocery / liquor / personal services**
- **Family-member-named travel or accommodation**
- **Recurring personal subscriptions**

**Flag as "Policy violation — possible personal" for manager review.** *Mosofin note*: a recurring personal
subscription often also appears in the ledger month after month (*`get_general_ledger`*), which turns a
suspicion into a documented pattern with a start date.

### Duplicate detection

- **Same vendor + amount + date submitted twice by the same employee** — `[auto]` within the report
- **Same expense claimed on both employee report and corporate-card reconciliation** — **`[auto]` against
  the ledger, and this is the check the original could only describe.** Match each claim line against
  posted card transactions on vendor, amount and a date window. **A claim for a charge the company already
  paid is a double reimbursement**, and it is the highest-value finding this skill produces.

**Match tolerances**: exact amount and same merchant is a strong match; allow a **±3 day** window for
posting lag, and treat a near-amount match (tip added later) as a **review**, not a reject. Where the
merchant name differs between the card feed and the claim, fall back to amount plus date — and say the
match was made on those alone.

See `duplicate-invoice-detection` for the full matching discipline; the same reasoning applies.

## Step 3 — Code to GL accounts

**Hand off the coding logic to the `gl-coding-assistant` skill's conceptual category mappings.** **Account
numbers come from the user's COA only. Never invent account numbers.** **[auto]** here — the COA is
connected.

Common T&E category → conceptual GL category (mapped to the user's COA):

- **Airfare** → Travel — Airfare
- **Lodging** → Travel — Lodging
- **Meals (business, deductible portion)** → Meals (deductible)
- **Meals (non-deductible portion, per jurisdiction)** → Meals (non-deductible)
- **Ground transport / mileage** → Travel — Local Transport
- **Conferences / training** → Training & Development
- **Office supplies** → Office Supplies
- **Software / subscriptions** → Software Subscriptions
- **Client gifts (deductible portion)** → Client Gifts
- **Client gifts (non-deductible portion)** → Non-deductible / disallowed
- **Entertainment (deductible per jurisdiction)** → Entertainment
- **Entertainment (non-deductible per jurisdiction)** → Entertainment — Non-Deductible
- **Communications** → Telephone & Internet
- **Miscellaneous** → Other — **flag for review**

**If the user's COA does not separately track deductible vs. non-deductible portions, flag and suggest
creating sub-accounts or using a class / department dimension.** **[auto]** to determine — read the COA and
the available dimensions and say which is actually available in this entity.

**Mosofin addition — ground each mapping in history.** **[auto]**: before proposing an account, check how
this entity has coded the same category, and the same merchant, previously (*`get_general_ledger`*,
*`get_profit_and_loss`*). **Report the suggestion with its support** — "Travel — Airfare (6410); this
merchant coded there 12 of 12 times" — and **flag where history is inconsistent**, because an inconsistent
history is itself worth knowing before the reviewer perpetuates it.

## Step 4 — Calculate reimbursement

For each employee:

| Component | Calculation |
|-----------|-------------|
| **Total claimed** | Sum of all approved lines |
| **Less: Corporate-card-paid items** | Reduce reimbursement |
| **Less: Policy violations / disallowed** | Removed |
| **Less: Personal portion** | Allocated to employee |
| **Plus: Mileage at provided rate** | Distance × rate |
| **Net reimbursable to employee** | Sum |

**[auto]** arithmetic; the rate and the policy calls behind it are `[manual]`.

**Multi-currency: convert to functional currency using a stated FX source** — ask the user: **central bank
close, accounting system rate, or report-date rate from a stated provider. Do not assume a source.** The
**functional currency itself is now `[auto]`** from the profile; the *rate source* is not.

**Mosofin addition — reconcile to the payable.** **[auto]**: the proposed net reimbursable, added to the
existing **Employee Reimbursement Payable** balance, should explain that account's movement once paid.
**A payable balance that does not correspond to outstanding claims means either a claim was paid twice or
one was never paid** — both worth surfacing.

## Step 5 — Construct the GL posting

**Hand off to the `journal-entry-builder` skill.** Provide it with:

- **Posting date**
- **Employee name and period**
- **Sum of expenses by GL account** (using the user's COA — **`[auto]`, real accounts**)
- **Sum of input tax recoverable** (if the jurisdiction supports it and the user has provided the rule)
- **Reimbursable amount** → **AP / Employee Reimbursement Payable**
- **Corporate-card-paid amount** → **Corporate Card Clearing**

**The JE skill produces the balanced entry. This skill provides the inputs.** **Mosofin does not post** —
the entry is a proposal, whichever skill assembles it.

**Mosofin addition — the clearing account test.** **[auto]**: **Corporate Card Clearing should clear.**
Read its balance and its ageing (*`get_general_ledger`*). A persistent residual means card charges posted
with no matching claim, or claims posted with no matching charge — the two halves that were supposed to
meet. **Report the residual with its oldest item**, because age is what tells you whether it is timing or a
genuine break.

## Step 6 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Summary**
- **Employee(s), report period**
- **Total claimed / approved / rejected**
- **Reimbursement amount**
- **Policy violations summary**
- **Policy assumptions used** — if any were not explicit in the policy doc, **list them here for the user to
  confirm**

Plus the Mosofin header block: workspace name; the entity by `display_name`; each excluded company file and
why; whether any figure rests on `mock` data; **and whether a policy was supplied at all**.

**Sheet 2: Line Detail**

| Line # | Date | Category | Vendor | Description | Amount | Currency | FX Rate | Functional Amount | GL Account | Tax Code | Policy Check | Receipt? | Notes |

Add two Mosofin columns: **Already Posted?** (the duplicate-check result, with the matched transaction) and
**Coding Support** (how this entity coded the same thing before).

**Sheet 3: Exceptions**

| Line # | Issue | Severity | Recommended Action |

Severities:
- 🔴 **Reject** — Policy violation, must be removed
- 🟡 **Review** — Manager judgment required
- 🟢 **Approve with Note** — Minor flag

**A confirmed match against an already-posted card transaction is a 🔴 Reject**, not a review — the money
has already left the company.

**Sheet 4: GL Posting Inputs** — pass-through to `journal-entry-builder`.

**Sheet 5: Ledger Checks — NEW, Mosofin-specific**

| Check | Result | Detail |

Covering: duplicate matches against posted transactions; the Corporate Card Clearing residual and its
ageing; the Employee Reimbursement Payable reconciliation; claimants with no employee record.

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Policy | `mock` | Gap |

**If no policy was supplied, every Step 2 row reads `manual — not performed`.** That is the honest entry,
and it is more useful than a validation that did not happen.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**Output naming:** `[Employee]_ExpenseReport_[YYYY-MM].xlsx`

For a batch, `[Batch]_ExpenseReport_[YYYY-MM].xlsx`. Every file states which datasource and `display_name`
it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the policy, the rates, the receipts — **name the source required** instead of estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The policy parameters in force**: receipt thresholds, per-person caps, class restrictions, per-night
  caps, gift caps, alcohol rules, pre-approval requirements — **with the policy version and date**
- **The mileage rate and per-diem table in force**, with **effective dates** — these change annually, so a
  stored rate without a date is a liability
- **The category-to-account map** — the single biggest time saver, and now grounded in the real COA
- **The clearing and payable account map**: Corporate Card Clearing, Employee Reimbursement Payable, Due
  from Employee
- **The deductible / non-deductible treatment** and whether the COA supports it
- **The FX rate source**
- **The T&E platform in use** and its parsing quirks — splits, OCR confidence, prepaid vs. card
- **The duplicate-match tolerances** — the date window and amount tolerance agreed with this client
- The replay recipe: the exact sequence of reads that produced the COA, the posted-transaction population
  and the balance checks

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist employee names, individual claims, claim amounts, card numbers, home addresses, or
travel itineraries.** Expense data is personal data about identifiable people — where they went, when, and
with whom. **Persist the policy and the mapping; never the claims.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — receipts required above 25, mileage 0.45/mi effective 2026-01-01, meals 50% non-deductible split
to 6455, card clearing 2150" — not "receipts above 25". **Thresholds and account numbers differ by
company file**, and an unlabelled threshold applied to the wrong entity rejects valid claims or passes
invalid ones. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the claims, the balances and the clearing residual are all state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One COA, one employee list, one set of
posted transactions to check against.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every claim and account carrying its entity's `display_name`. Then the points specific to expenses:

- **Ask which entity employs each claimant, and which entity bears the cost.** They differ often —
  an employee of the services company travelling to a client of the trading company. **The duplicate check
  must run against the entity whose card paid**, which may not be the entity employing the claimant.
- **A claim charged to the wrong entity is an intercompany balance**, not just a coding error. Flag it for
  `consolidation-and-eliminations` rather than silently recoding.
- **Policies may differ by entity** — different countries, different caps, different mileage rates.
  **Never apply one entity's per-diem table to another's staff.** Store rates keyed by entity.
- **Corporate cards are often issued centrally.** The clearing account may sit in one entity while the
  expenses belong to several, so **the clearing test runs where the card is, and the coding runs where the
  cost is.**
- **Currency differs by entity**, so the FX conversion and the rate source must be applied per entity, not
  once for the group.

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
| **The real chart of accounts — no placeholders** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The claimant list and departments** | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| **Transactions already posted — the duplicate population** | `search_purchases` / `search_expenses` / `search_bills` | `start_date`, `end_date` (required) |
| **Corporate card activity** | `search_credit_card_charges` / `get_general_ledger` | `start_date`, `end_date`; `account` |
| **Clearing and payable movements and ageing** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Payable and Due-from-Employee balances | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Merchant recognition | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **Historical coding patterns** | `get_profit_and_loss` / `get_general_ledger` | `start_date`, `end_date`, `summarize_column_by` |
| Dimensions available for allocation | `search_departments` / `search_classes` | `query`/`name`, `active_only` |
| Legal name, **functional currency**, country | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There are no receipt images, no policy documents, no mileage rates and no per-diem tables on this
surface.**

---

## Plain-language glossary

- **T&E (travel and entertainment)** — the category of spending staff incur on the company's behalf.
- **Out-of-pocket** — the employee paid with their own money and wants it back.
- **Corporate card** — the company already paid; nothing is owed to the employee. **The distinction drives
  the whole reimbursement calculation.**
- **Prepaid card** — a company-funded card loaded in advance; also company-paid.
- **Per-diem** — a fixed daily allowance instead of reimbursing actual costs. **M&IE** — meals and
  incidental expenses.
- **Mileage rate** — an amount per mile or kilometre covering fuel and wear when staff drive their own car.
- **Deductible / non-deductible** — whether the tax authority lets the business subtract the cost from its
  taxable profit. Meals and entertainment are commonly restricted.
- **Input tax recovery** — reclaiming sales tax or VAT paid on a business purchase.
- **Reverse charge** — a VAT mechanism where the buyer, not the seller, accounts for the tax on a
  cross-border service.
- **Clearing account** — a temporary holding account where two halves of a transaction meet. **It should
  return to zero**; a residual is unmatched activity.
- **Due from Employee** — money the employee owes the company, usually a personal charge on a company card.
- **GL coding** — deciding which account each line belongs in.
- **SmartScan / OCR** — automatic reading of a receipt image; **it makes mistakes, and confidence scores
  exist for a reason.**
- **Split transaction** — one charge divided across several categories.
- **FX rate source** — which published rate is used to convert a foreign amount, and as at when.

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**International travel with multiple currencies**: **capture in original. Convert at the FX source provided
by the user (or ask). Flag rates that look off.** *Mosofin note*: the functional currency is `[auto]`; the
rate source is not.

**Conference packages with mixed components**: a single charge covering registration + meals + lodging —
**request an itemized receipt. If not available, ask the user how to allocate; do not pick an allocation
arbitrarily.**

**Spousal / accompanied travel**: **allocate the spousal portion. Mark non-reimbursable per policy, or
treat as taxable compensation if company-paid** — per the jurisdiction's payroll rules; **flag for the
user.**

**Gift cards**:
- **For clients** → reimbursable per policy; deductibility per jurisdiction
- **For employees** → **typically taxable compensation in most jurisdictions — flag for payroll handling**

**Tips**: **reimbursable per policy. Flag unusual tip percentages for review.** *Mosofin note*: a tip added
after authorization is why the card amount and the claimed amount can differ slightly — allow for it in the
duplicate tolerance rather than calling it a non-match.

**Cash transactions without receipts**: **per policy threshold. If no policy, flag every receiptless line.**

**Mileage without logged business purpose / start–end**: **insufficient documentation. Flag for additional
info.**

**Corp card with personal charge**: **the employee owes the company. Code as Due from Employee, not
expense.** *Mosofin note*: that balance is readable — **an ageing Due-from-Employee balance is money nobody
chased.**

**Late submissions**: **per policy.**

**Pre-paid expenses on the report** (a deposit for next quarter's conference): **code to Prepaid Expenses
(BS), not expense. Flag for amortization via `prepaid-amortization-schedule`.**

**Tax-inclusive receipts in jurisdictions that allow input-tax recovery**: **decompose the receipt total
into pre-tax + tax. If the receipt doesn't show tax explicitly, ask the user how to handle** — some
jurisdictions require an explicit tax invoice for recovery.

**Cross-border meals or services**: **may trigger reverse-charge VAT in the entity's jurisdiction. Flag —
do not silently apply.**

**A claim matches a transaction already posted** — *Mosofin-specific, and the highest-value finding*. The
company card already paid it. **Reject, do not review** — and check whether earlier periods carry the same
pattern for the same claimant.

**The Corporate Card Clearing account never clears** — *Mosofin-specific*. Report the residual **with its
oldest item**. Age distinguishes ordinary timing from a real break.

**A claimant has no employee record** — *Mosofin-specific*. A leaver, a contractor on the wrong form, or a
misspelling. Ask before coding.

**Historical coding for the same merchant is inconsistent** — *Mosofin-specific*. Say so rather than
picking the most recent. An inconsistent history usually means the category was never decided.

**The COA read is disabled** — *Mosofin-specific*. **The skill degrades to the original's placeholder
behaviour.** Label every account **PLACEHOLDER — REMAP REQUIRED** and say why, rather than inventing
numbers.

**The COA has no non-deductible accounts** — *Mosofin-specific check on an original flag*. Read the COA and
the available dimensions, then say which of sub-accounts or a class is actually available here.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded, and say that
duplicate checking against that entity's card activity did not run.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A duplicate check against fixture
transactions proves nothing.** Never report it as clean.

**A stored mileage rate or per-diem is reused without a date** — *Mosofin-specific*. These change annually.
**Store effective dates, and re-confirm at each year boundary.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's caps to another's staff.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every line has a GL account suggestion** (from the user's COA) **and a policy check** — or a
  "no policy provided" note
- **Currency normalization is documented** — FX rate, source, date
- **Exceptions categorized by severity**
- **Reimbursement calculation reconciles line-by-line**
- **Receipt status tracked per line**
- **All policy assumptions explicitly listed on the Summary tab**
- **GL posting balances to the penny** (verified via `journal-entry-builder`)
- **File naming consistent**: `[Employee or Batch]_ExpenseReport_[YYYY-MM].xlsx`
- **No invented rates, thresholds, or account numbers**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Coding is to real accounts from the connected COA**; placeholders appear only when the COA read is
  unavailable, and the degradation is stated
- **Every claim line was checked against transactions already posted**, and matches are reported as
  rejections with the matched transaction named
- **The match tolerances used** — date window and amount tolerance — **are stated**
- **The Corporate Card Clearing residual is reported with its ageing**, and the Employee Reimbursement
  Payable is reconciled to outstanding claims
- **Each coding suggestion carries its historical support**, and inconsistent history is flagged rather
  than resolved silently
- **Claimants with no employee record are flagged before coding**
- Where **no policy was supplied**, Step 2 is reported as **not performed** — never as passed
- Receipt status is reported **as per the report**, never as verified, since images are not on this surface
- In a multi-entity run, **the employing entity and the bearing entity are distinguished**, the duplicate
  check runs against the entity whose card paid, and cross-entity charges are raised as intercompany
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no duplicate check is reported as clean against mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No employee names, individual claims, amounts, card numbers, addresses or itineraries are persisted**
  into a skill bundle; every persisted preference states the datasource and `display_name` it covers, and
  stored rates carry effective dates
- Nothing was written back to any system — no claim approved, rejected, paid or posted
