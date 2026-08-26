---
name: journal-entry-builder
description: "Use this skill whenever the user wants to construct, format, or validate a journal entry against their Mosofin workspace. Triggers include: 'book a JE for...', 'create a journal entry to record...', 'how do I record this transaction', 'make me an accrual JE', 'reclass these entries', 'reverse this entry', or any request involving debits and credits to specific accounts. Also trigger for adjusting entries, correcting entries, closing entries, intercompany entries, and import-ready JE files for accounting systems. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds entries against the real chart of accounts and validates them against the books — checking that accounts exist, signs match account types, the period is open, and no prior accrual already covers the item. Mosofin never posts: every entry is a proposal for a person to post. Do NOT use for GL coding decisions only — use gl-coding-assistant. Do NOT use for full period close — use month-end-close-checklist. Outputs balanced journal entries with supporting narration, validation results, and a coverage sheet."
---

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

# Journal Entry Builder (Mosofin)

Constructs **properly balanced journal entries** for any accounting scenario — **standard, adjusting,
accrual, deferral, reclass, reversing, intercompany, or closing**. Outputs entries that **balance to the
penny**, with complete narration and **import-ready format** for the user's accounting system.

**In plain words:** every accounting event gets recorded as at least two lines that cancel out — something
gained against something given up. Getting the two sides right, against the right accounts, on the right
date, with an explanation someone can follow a year later, is the whole job.

This skill is **system-agnostic**. **It does not invent account numbers or assume any jurisdiction's tax
rules.**

It is **workspace-scoped**: the chart of accounts, the account types, the existing balances and the
validation evidence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart rather than accepting any list. That is a narrowing, stated rather than implied.

## Mosofin never posts — and this is the skill where that matters most

**Dozens of skills in this pack end by handing off here.** Depreciation, accruals, impairments, releases
from restriction, elimination entries, shrinkage, deferred tax — **all of them arrive at this skill to
become an entry.**

> **Mosofin is read-only. It cannot post a journal entry, and it will not.** **Everything this skill
> produces is a proposal** — a fully constructed, validated, import-ready entry **for a person to review and
> post.**
>
> **That is not a limitation to apologise for; it is the correct division.** Posting is an authorised act
> with a preparer and a reviewer behind it, and an entry arriving pre-validated with its support attached is
> what makes that review fast. **Say "proposed entry" on every output**, and never imply anything has been
> recorded.

## What the workspace changes: validation stops being aspirational

The original's Step 6 asks you to *verify* nine things. **In a Mosofin workspace, six of them become
queries** rather than intentions:

| Validation | Original | Here |
|---|---|---|
| **Debits = Credits** | arithmetic | arithmetic — **[auto]** |
| **All accounts exist in the COA** | verify against a supplied list | **[auto]** against the live chart |
| **Date is within an open accounting period** | "warn if not" | **[gated]** — often determinable |
| **Sign conventions match account types** | judgment | **[auto]** — **account types are readable** |
| **Memo explains the business purpose** | judgment | judgment |
| **References to source documents** | judgment | **[gated]** — the document may be in the system |
| **Reversing flag set correctly** | judgment | judgment |
| **No P&L accounts in a pure BS reclass** | verify | **[auto]** — account types again |
| **Tax lines present where warranted** | jurisdiction | **[gated]** — codes readable, rules not |

**And it adds the check the Pitfalls section names first, which is the most valuable one here:**

> **Pitfall 1 — "Recording a payment when an accrual already exists → double-counts."** **[auto]**: **the
> accrual balance is readable.** Before proposing a payment or invoice entry, **check whether an accrual for
> the same item is sitting open.** This is the classic double-count, it is invisible at the moment of
> posting, and it is one query.

Three more from the same section:

- **Pitfall 2 — a receipt where an invoice exists** should clear AR, not go to revenue. **[auto]**: the open
  invoice is findable.
- **Pitfall 5 — a loan payment booked entirely as expense.** **[auto]**: the loan liability balance and its
  movement are readable, which shows the principal portion.
- **Manual JEs to revenue, cash, AR or AP control accounts** — the original flags these as auditor red
  flags. **[auto]**: whether the target is a control account is readable from the chart, so the flag raises
  itself.

**What stays outside:** the transaction or event being recorded — that is the user's — the materiality
threshold, the tax rules, and any source document not held in the system.

---

# PART A — Prerequisites: confirm scope, discover the capability map

Run Gates 0 → 1 → 2 → 3 in this order, before building anything. This ordering is the contract. Do not
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

**When this skill is invoked as a handoff from another skill**, the gates have usually run already in the
same conversation. **Confirm the entity in one line rather than repeating the sequence** — but **never build
against an entity that was not confirmed.**

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**This gate answers the original's "Accounting system" input.** **The connected platform is known** — so the
import format in Step 7 is determinable rather than a question. **Ask only when the platform's import
template is itself the uncertainty.**

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; **the entry is built against that chart.**
- **Multi-entity** — ask which set, **and which entity this entry belongs to, before building it.** For an
  **intercompany** entry, **both entities are in scope** and both sides are built. See the cross-entity step.

Refer to companies by `display_name`; never show the raw `data_source_id`.

## Gate 2 — Discover enabled tools → build the capability map

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

For **each in-scope datasource** (and **per company file** when several are live — pass
`data_source_id`), call `get_datasource_tools`. Bucket every tool by `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Resolve **every validation in Part B** against these buckets. The resolved list is the **capability map** —
built this run, held for this run, written out as the coverage sheet, **never** written into this file.

**If the chart read is `disabled`, the original's fallback applies in full** — descriptive account names
labelled **"PLACEHOLDER — REMAP REQUIRED"**. **Say which fallback is in use and why**; do not invent numbers.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly styled — some
  underscored, some hyphenated.
- **A near-substitute is not a substitute:**
  - **A validated entry is not a posted entry.** Nothing here records anything.
  - **An account existing is not an account being appropriate.** The chart says it exists; judgment says it
    fits.
  - **An open period in the system is not an open period for reporting.** Statements may already be issued
    even where the software permits posting.
  - **A balance in an accrual account is not proof the accrual covers this item** — it is a prompt to
    check.
- **There is no posting capability, no materiality policy and no tax rule engine on this surface.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope entity.

**Derive silently** what the profile answers: legal name, **functional currency**, fiscal calendar and
year-end, country / region.

**Ask the user** what actually changes the work — the original Inputs table, **minus the four the connected
books now answer**:

| What to confirm | Required? | Notes |
|---|---|---|
| **Transaction or event to record** | **Required — [manual]** | The user's. |
| **Posting date** | **Required** | **[gated]** to validate against period status. |
| ~~Chart of accounts~~ | **Now [auto]** | Real accounts, real types. **No placeholders unless the read fails.** |
| ~~Entity / company~~ | **Now [auto]** | Confirmed by `display_name`. |
| ~~Functional currency~~ | **Now [auto]** | From the profile. |
| **Reference / source document** | Recommended — **[gated]** | Findable where the document is in the system. |
| ~~Accounting system~~ | **Now [auto]** | From Gate 1. **Ask only for the import template if needed.** |
| **Reversal flag** | Optional | |
| **Tax jurisdiction** | Required if tax effects involved — **[gated]** | **Country `[auto]`; the rules `[manual]`.** |
| **Materiality threshold** | Recommended — **[manual]** | Needed for the large-entry flag; **do not assume one.** |
| **Confirm scope** | **Required** | Read back the entity by `display_name` and the period. |
| **Confirm manual evidence** | **Required** | The event, the tax rules and the threshold are `[manual]`. |

**If no chart of accounts is available**: **ask the user for the specific account names and numbers they
use. Do not invent.** Acceptable fallback: **descriptive account names with a clear "PLACEHOLDER — REMAP
REQUIRED" label.**

Ask as **one short batch**. Propose defaults where reasonable — but **never** default an account, a tax
treatment, or a materiality threshold.

**On later runs**, read stored preferences first (Step 9), confirm in one line, and ask only what changed.
The account map, the entry templates, the import format and the numbering convention persist; **balances and
validation results are re-obtained every time.**

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The event itself and the tax rules are legitimately
`[manual]`.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the chart, the balances and the validation populations do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical batch, per in-scope entity:

- *`search_accounts`* — **the chart with account numbers, names and types** — usually **[auto]**. **The
  single most important read here**
- *`get_trial_balance`* / *`get_balance_sheet`* — **current balances on the accounts being touched** —
  usually **[auto]**
- *`get_general_ledger`* on **the accrual, prepaid, deferred and clearing accounts** — **the Pitfall 1
  check** — usually **[auto]**
- *`search_invoices`* / *`search_bills`* — **whether a document already exists for this item** — usually
  **[auto]**
- *`search_journal_entries`* — **the numbering convention in use, and whether the period still accepts
  entries** — usually **[auto]**
- *`get_company_info`* — legal name, **functional currency**, year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that validation to **[manual]** and record the gap. **If it is the chart
  read, state that placeholder coding is in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **an entry validated against fixture accounts may
reference accounts that do not exist in the real chart**, and it would be imported.

## Step 1 — Identify the JE type

| Type | When to use | Typically reverses? |
|------|-------------|---------------------|
| **Standard** | Recording an actual transaction — cash receipt, payroll, sale | No |
| **Accrual** | **Expense incurred but not yet invoiced or paid, or revenue earned but not invoiced** | **Usually yes, first day of next period** |
| **Deferral** | **Cash received or paid in advance of revenue or expense recognition** | **No** — released over time |
| **Adjusting** | **Period-end true-up** — depreciation, amortization, FX reval, accruals | Sometimes |
| **Correcting** | **Fixing a prior error** | **No** — document the original |
| **Reclass** | **Moving balance from one account to another, no economic event** | No |
| **Reversing** | **Reverses a prior accrual on the first day of the next period** | **Is itself the reversal** |
| **Closing** | **Year-end close of P&L to Retained Earnings** | No |
| **Intercompany** | **Cross-entity transactions; mirror entries in both entities** | **Mirrored** |
| **Opening Balance** | **New entity setup / system migration** | No |

**State the JE type explicitly in the header.**

*Mosofin note on Closing*: **check whether the platform closes the year automatically** before proposing a
closing entry — see `closing-entries-and-trial-balance`. **[auto]**: P&L accounts at zero after year-end
with no visible closing journal means the system did it, and **a manual closing entry would double-close
retained earnings.**

## Step 2 — Apply the accounting equation

**Every JE must balance: Total Debits = Total Credits.**

**Normal balance rules:**

| Account type | Increases with | Decreases with |
|--------------|----------------|----------------|
| **Asset** | Debit | Credit |
| **Liability** | Credit | Debit |
| **Equity** | Credit | Debit |
| **Revenue** | Credit | Debit |
| **Expense** | Debit | Credit |
| **Contra-asset** (e.g. Accumulated Depreciation) | **Credit** | **Debit** |
| **Contra-revenue** (e.g. Sales Returns) | **Debit** | **Credit** |

**Walk through substance:**

1. **What did the entity receive?** → **Debit** (asset / expense) or Credit reduction
2. **What did the entity give up?** → **Credit** (asset reduced) or Debit reduction
3. **What obligation was created or settled?** → **Credit** (created) or **Debit** (settled)

**[auto]** enforcement: **account types are readable**, so **the sign convention is checkable rather than
assumed.** A debit to a revenue account, or a credit to an expense account, is not wrong in itself — but
**it is unusual enough to warrant the memo saying why**, and the check surfaces it.

## Step 3 — Construct the entry

Standard format:

```
Date: YYYY-MM-DD
Entry #: [auto or user-supplied]
Type: [Standard / Accrual / Reclass / etc.]
Reference: [Invoice #, contract, supporting doc]
Memo: [One line describing the business event]

Account No. | Account Name | Debit | Credit | Line Memo
------------|--------------|-------|--------|----------
[from user's COA] | [from user's COA] | $X | | [purpose]
[from user's COA] | [from user's COA] | | $X | [purpose]

Total                                 | $X | $X | ✓ Balanced
```

**Required for every entry:**

- **Posting date**
- **Entry type**
- **Header memo** — business purpose in plain language
- **≥ 2 lines** — one DR, one CR
- **Line-level memos when multiple debits or credits**
- **Balance check at bottom**

**Mosofin additions to the header, since the entry travels beyond this conversation:**

- **PROPOSED ENTRY — NOT POSTED**, stated plainly
- **The entity by `display_name`**
- **The validation result** from Step 6
- **The source**: which skill or analysis produced it, and the tool calls behind any figure

**Account numbers and names come from the live chart** (*`search_accounts`*, **[auto]**) — **exactly as they
appear there**, including formatting, so the import matches.

## Step 4 — Common JE patterns

`DR` is a debit, `CR` a credit. **Every pattern below is a proposal.**

### Accrual (expense incurred, not yet invoiced)
```
DR  Expense account                       $X
    CR  Accrued Liabilities (BS)              $X
Memo: Accrue [service] for [period] — invoice expected [date]
```
**Flag as reversing on first day of next period.**

### Prepaid expense (paid in advance)
```
At payment:
DR  Prepaid Expense (BS)                  $X
    CR  Cash / AP                             $X

Periodic amortization:
DR  Expense                               $X / periods
    CR  Prepaid Expense                       $X / periods
```
**Suggest `prepaid-amortization-schedule` for the full schedule.**

### Deferred revenue
```
At receipt:
DR  Cash                                  $X
    CR  Deferred Revenue (BS)                 $X

As earned:
DR  Deferred Revenue                      $X / period
    CR  Revenue                               $X / period
```

### Depreciation
```
DR  Depreciation Expense                  $X
    CR  Accumulated Depreciation              $X
Memo: Periodic depreciation — [asset class or specific asset]
```

### Reclass between accounts
```
DR  Correct Account                       $X
    CR  Incorrect Account                     $X
Memo: Reclass [item] from [wrong] to [correct]; original entry #, date
```
**[auto]**: **the original entry is findable** (*`search_journal_entries`*, *`get_general_ledger`*), so the
memo's entry number and date can be filled from the ledger rather than from memory.

### Correcting prior error

**Never delete or alter the original entry if posted.** Either:

- **Reverse and rebook** — full reversal + correct entry — **preferred for material errors or audit-trail
  needs**
- **Net correction** — just the difference — **for small true-ups**

**Reference the original entry # in the memo either way.**

*Mosofin note*: **Mosofin cannot delete or alter anything**, which enforces the first sentence structurally.
And **the original entry is readable**, so the reversal can be built from what was actually posted rather
than from what someone remembers posting.

### Intercompany

**Always create mirror entries in both entities:**
```
Entity A (lender):
DR  Intercompany Receivable — Entity B    $X
    CR  Cash                                  $X

Entity B (borrower):
DR  Cash                                  $X
    CR  Intercompany Payable — Entity A       $X
```
**Flag for `intercompany-reconciliation` at period end.**

**[gated]**, and stronger here than the original assumes: **where both entities are connected, both sides
are built against their own real charts** — the account names differ between entities and **using the
correct ones in each is the difference between an entry that imports and one that fails.** **Where the
counterparty is not connected, build the near side and say the far side could not be built against a real
chart.**

### Reversing entries

**Date: first day of next period. Flip debits and credits from the original. Reference the original entry
#.** **[auto]**: the original is readable, so the flip is mechanical and the reference is exact.

### Closing entries (year-end)

**Close revenues and expenses to Income Summary — or directly to Retained Earnings if the system supports
it. Verify net result ties to P&L net income / loss.** **[auto]** to verify: *`get_profit_and_loss`* gives
the figure the entry must produce.

## Step 5 — Tax effects (jurisdiction-driven)

**Only include tax lines if the user provided a jurisdiction and the transaction has tax implications.**

**For sales / output side:**
- **VAT / GST / sales tax collected → Liability** (Tax Payable / Output Tax)
- **Multi-jurisdiction sales → separate lines per jurisdiction**
- **Tax-exempt or zero-rated → no tax line; note the exemption reason**

**For purchases / input side:**
- **Recoverable input tax** (where the jurisdiction allows it) **→ Asset** (Input Tax Receivable)
- **Non-recoverable input tax → included in expense**

**If the jurisdiction's rules aren't clear, ask the user. Do not assume.**

**[gated]**: **the tax accounts and any configured tax codes are `[auto]`**, so a tax line can name a real
account and a real code — **but which code applies remains `[manual]`.** See `gl-coding-assistant`, where
the same split appears.

## Step 6 — Validation

Before delivering, verify — **and here most of these are performed, not merely intended**:

- ✅ **Debits = Credits, to the penny** — **[auto]**
- ✅ **All accounts exist in the provided COA** — **[auto]** against the live chart. **An account that does
  not exist is a hard stop**, not a warning
- ✅ **Date is within an open accounting period (warn if not)** — **[gated]**: **entries existing after a
  date, or the platform's own period status, indicate it.** **Warn about reporting status too** — a period
  the software will accept may already have been reported
- ✅ **Memo explains the business purpose** — not "JE" or "adjustment"
- ✅ **References to source documents included** — **[gated]**; findable where the document is in the system
- ✅ **Reversing flag set correctly if applicable**
- ✅ **Sign conventions match account types** — **[auto]** from account types
- ✅ **No P&L accounts used for pure BS reclasses without a stated reason** — **[auto]** from account types
- ✅ **Tax lines present if jurisdiction + transaction warrant** — **[gated]**

**Mosofin additions to the validation set — the Pitfall checks, run as queries:**

- ✅ **No existing accrual already covers this item** — **[auto]**. **The Pitfall 1 double-count check.**
  Read the relevant accrual account before proposing a payment or invoice entry
- ✅ **No open invoice exists for a receipt being booked to revenue** — **[auto]**. Pitfall 2
- ✅ **A loan payment is split between interest and principal** — **[auto]** support from the liability
  balance. Pitfall 5
- ✅ **The target is not a control account** — **[auto]**: **manual entries to revenue, cash, AR or AP
  control accounts are auditor red flags**, and whether an account is one is readable
- ✅ **The entry does not exceed materiality without a review flag** — **[gated]**; **the threshold is
  `[manual]`**
- ✅ **A clearing or suspense account used here is expected to clear** — **[auto]** to report its current
  balance and age

**Report the validation result with the entry.** A proposal that says "validated: 9 of 9 checks passed;
account 6410 confirmed in chart; period open; no matching accrual found" is one a reviewer can post
quickly. **One that says "validated" is not.**

## Step 7 — Output format

**Single JE → markdown table inline. Multiple JEs / import-ready file → `.xlsx` or `.csv`.**

**Generic columns:**

| Date | Entry # | Account No. | Account Name | Debit | Credit | Memo | Reference | Class/Dept | Currency |

**System-specific column headers** — **and the connected platform is known from Gate 1**, so **use its
format by default** rather than asking:

- **QuickBooks Online**: `JournalNo`, `JournalDate`, `Line Description`, `Account`, `Debit`, `Credit`
- **Xero**: `*Narration`, `*Date`, `Description`, `*AccountCode`, `*TaxRate`, `*Amount`
- **NetSuite**: `External ID`, `Date`, `Account`, `Debit`, `Credit`, `Memo`, `Subsidiary`, `Department`,
  `Class`
- **Sage Intacct / 50 / 200**: **format varies — ask the user for the import template**
- **Microsoft Dynamics 365 / Business Central**: `Journal Batch`, `Posting Date`, `Document No.`,
  `Account Type`, `Account No.`, `Description`, `Amount`, `Bal. Account Type`, `Bal. Account No.`
- **Zoho Books / FreshBooks / Wave / Other**: **ask for the import template**

**If unknown, use the generic columns and let the user remap.**

**Add two sheets to any `.xlsx`:**

**Sheet: Validation Results — NEW, Mosofin-specific**

| Entry # | Check | Result | Evidence |

All nine original checks plus the six Mosofin ones, **each with the tool result behind it**.

**Sheet: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

If creating xlsx, read: `/mnt/skills/public/xlsx/SKILL.md`

**File naming:** `[EntityName]_JE_[Description]_[YYYY-MM-DD].xlsx`

`[EntityName]` is the company file's `display_name`. **Every file states that the entries are proposals.**

**Grounding:** every account traces to the live chart; every validation traces to a tool result in this
conversation. End with a single **Data sources** line. Where a check could not run, **name it as not run**.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** for recurring entry types: accruals, prepaids, deferred revenue, accumulated
  depreciation, clearing, intercompany, suspense
- **The entry templates** this entity actually uses — **the most valuable stored asset here**, since a
  template that names the right accounts turns each period's entry into a fill-in
- **The import format** for the connected platform, including any local template quirks
- **The entry numbering convention**
- **The memo conventions** — what this entity's reviewers expect to see
- **The materiality threshold** for the review flag, with its date
- **The reversal policy** — which accrual types reverse automatically and which are cleared on settlement
- **The intercompany account pairs** across entities, keyed by both names
- **The tax code mapping** for common transaction types
- The replay recipe: the exact sequence of reads that performed the validations

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist amounts, balances, entry contents or transaction details.** All state. **Persist the
templates and the mappings; never the entries.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — accruals to 2110, prepaids to 1310, clearing 1999, QBO import format, JE numbering
JE-YYYYMM-nnn" — not "accruals to 2110". **Account numbers are chart-specific and therefore
entity-specific**, and an entry built with another entity's numbers will either fail to import or post to
the wrong account. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one entry, one validation.

**Multi-entity.** **Confirm which entity each entry belongs to before building it** — the first question,
not the last. Then:

- **Build each entry against its own entity's chart.** **[auto]** per entity. **Account numbers differ**,
  and an entry built with the wrong entity's numbers is the most common cross-entity failure here.
- **Intercompany entries are built in both entities**, mirrored, **each against its own chart**. Where the
  counterparty is not connected, **say the far side could not be built against a real chart** rather than
  guessing at its account names.
- **Validate both sides.** The near side's accrual check, period check and account check all apply equally
  to the far side — see `intercompany-reconciliation`, which is where these entries end up being tested.
- **Currencies differ by entity.** Each entry is in its entity's functional currency; **a cross-currency
  intercompany pair will not mirror in local amounts**, and that is expected — see
  `foreign-currency-translation-asc830`.
- **Consolidation-only entries belong to neither entity's books.** Elimination entries from
  `consolidation-and-eliminations` are built for the consolidation ledger and **must be labelled so nobody
  imports them into a subsidiary.**
- **Numbering conventions differ by entity.** Store them separately.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each validation's verdict per
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
| **The chart: numbers, names and types — the primary read** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Current balances on the accounts being touched** | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| **Accrual, prepaid, deferred and clearing balances — the Pitfall 1 check** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Whether a document already exists for this item** | `search_invoices` / `search_bills` | `start_date`, `end_date` (required) |
| **The numbering convention, and the original entry for a reversal or reclass** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Net income for a closing entry | `get_profit_and_loss` | `start_date`, `end_date` |
| Legal name, **functional currency**, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no posting capability, no materiality policy and no tax rule engine on this surface.**

---

## Plain-language glossary

- **Journal entry (JE)** — the record of an accounting event as balancing debits and credits.
- **Debit and credit** — the two sides. **Not good and bad**: what each does depends on the account type.
- **Normal balance** — the side an account usually sits on. **Contra accounts sit on the opposite side to
  what their category suggests.**
- **Accrual** — recording something that has happened before the paperwork arrives. **Deferral** — holding
  back something paid or received before it has been earned or used.
- **Reversing entry** — undoing an accrual on the first day of the next period, so the real invoice posts
  cleanly.
- **Reclass** — moving a balance between accounts with no economic event behind it.
- **Correcting entry** — fixing an error. **Never by editing the original**, which destroys the audit trail.
- **Mirror entry** — the matching entry in the other entity of an intercompany transaction.
- **Closing entry** — clearing profit and loss accounts to retained earnings at year end.
- **Control account** — a summary account fed by a subledger, like AR or AP. **Manual entries into one are
  an auditor red flag** because they bypass the subledger.
- **Clearing / suspense account** — a temporary holding place. **It should return to zero.**
- **Plug** — a figure inserted to make something balance. **Never acceptable without explaining what it
  is.**
- **Import template** — the column layout a particular accounting system expects.
- **Materiality threshold** — the size above which an entry needs extra review.
- **Proposal** — an entry prepared but not posted. **Everything this skill produces.**

---

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-currency entries**: **each line must be in the same currency, or include explicit FX rate columns.
For cross-currency entries, post in functional currency with an FX gain / loss plug. Flag for
`multicurrency-fx-revaluation`.**

**Penny imbalances from rounding allocations**: **do not pad with a "Rounding" plug. Allocate the rounding
to the largest line and note in the memo.**

**Entries crossing fiscal years**: **warn. Year-end accruals should reverse in Period 1 of the new year, not
in adjustment periods.**

**Entries to Suspense / Clearing accounts**: **always temporary. Flag any open clearing-account balance.**
*Mosofin note*: **the balance and its age are readable** — report them with the entry.

**Cash basis entities**: **accruals and deferrals are inappropriate on a pure cash basis. Confirm basis and
flag if mismatch.** *Mosofin note*: **the accounting method used by the books is readable**, so the mismatch
is detectable rather than assumed.

**Large or unusual JEs**: **if a single entry exceeds the entity's materiality threshold — ask the user; do
not assume — flag for review per `journal-entry-review`.**

**Manual JEs to revenue, cash, AR, or AP control accounts**: **these are red flags for auditors. Flag and ask
the user to confirm the business reason; recommend a subledger transaction where possible.** *Mosofin note*:
**whether an account is a control account is readable**, so this flag raises itself.

**An account in the proposed entry does not exist in the chart** — *Mosofin-specific*. **A hard stop, not a
warning.** The import would fail or, worse, create the account.

**The period is open in the software but already reported** — *Mosofin-specific*. **Two different
questions.** Warn on both.

**A payment entry where an accrual is already open** — *Mosofin-specific, and the highest-value check*.
**The classic double-count.** Read the accrual account first.

**A receipt booked to revenue where an invoice is open** — *Mosofin-specific*. It should clear AR.

**A loan payment booked entirely to expense** — *Mosofin-specific*. **Only interest is expense.** The
liability movement shows the split.

**A closing entry proposed where the platform closes automatically** — *Mosofin-specific*. **Double-closes
retained earnings.** See `closing-entries-and-trial-balance`.

**An entry built against the wrong entity's chart** — *Mosofin-specific*. The most common cross-entity
failure. **Confirm the entity before building.**

**An elimination entry imported into a subsidiary** — *Mosofin-specific*. **Consolidation-only entries belong
to neither entity's books.** Label them.

**The chart read is unavailable** — *Mosofin-specific*. Placeholder coding applies, **and the output must say
so**. Never invent numbers.

**A result comes back with `mock: true`** — *Mosofin-specific*. **An entry validated against fixture accounts
may reference accounts that do not exist**, and it would be imported.

**The entry is described as posted** — *Mosofin-specific, and prohibited*. **Mosofin posts nothing.** Every
output says proposal.

**A stored template applied to a different entity** — *Mosofin-specific*. Account numbers are chart-specific.
Key templates by entity.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the validation as `[gated]` in the coverage sheet.

---

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every entry balances to the penny**
- **Every line has an account, an amount in either Debit or Credit — never both — and a memo**
- **Header memo explains the business event in plain language**
- **Account names and numbers match the user's COA exactly**
- **Entry type, date, reference always present**
- **Reversing entries clearly flagged with the reversal date**
- **File naming**: `[EntityName]_JE_[Description]_[YYYY-MM-DD].xlsx`
- **Never use "Plug", "Misc", "Other", or "Suspense" without explaining what needs to be resolved**
- **Never use account numbers not in the user's COA**

**Mosofin additions:**

- **Every entry is labelled a proposal and nothing is described as posted**
- The workspace was confirmed **by name** and the entity confirmed by `display_name` before the entry was
  built
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every account was confirmed to exist in the live chart**, and a missing account is a hard stop; where
  the chart could not be read, **the placeholder fallback is stated**
- **Sign conventions were checked against real account types**, and any unusual direction carries a reason
  in the memo
- **Period status was checked**, and the warning distinguishes software-open from already-reported
- **The Pitfall checks were run**: no open accrual already covers the item, no open invoice exists for a
  receipt booked to revenue, a loan payment is split, and the target is not a control account
- **Clearing and suspense balances touched by the entry are reported with their age**
- **The validation result is delivered with the entry**, check by check, with the evidence behind each
- **The import format matches the connected platform** by default rather than by question
- **Where an original entry is referenced** — a reversal, reclass or correction — **its number and date come
  from the ledger**, not from memory
- In a multi-entity run, **each entry is built against its own entity's chart**, intercompany entries are
  mirrored against both real charts where both are connected, and **consolidation-only entries are labelled
  so they are never imported into a subsidiary**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no entry is offered for import on fixture-validated
  accounts**
- Every account traces to the live chart and every validation to a tool result; the answer ends with a
  single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No amounts, balances, entry contents or transaction details are persisted** into a skill bundle; every
  persisted template states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted, reversed, altered or deleted**

---

## Pitfalls Specific to JE Construction (not covered above)

**Preserved from the original, with the Mosofin verdict on each — four of the seven are now checkable.**

1. **Recording a payment when an accrual already exists** → **double-counts. Always check if a prior accrual
   covers the same item, and clear it.** — **[auto]**: **read the accrual account before proposing the
   entry.** The highest-value check in this skill.
2. **Using Cash for AR-related receipts** → **if an invoice exists, the receipt clears AR, not direct to
   revenue.** — **[auto]**: the open invoice is findable.
3. **Booking depreciation directly to the asset account** → **must use Accumulated Depreciation
   (contra-asset).** — **[auto]**: **whether a contra account exists is readable**, and the account type
   check catches the direct posting.
4. **Recording owner contributions as revenue** → **goes to Equity.** — **[auto]**: account type check.
5. **Recording full loan payment as expense** → **only interest is expense; principal reduces the loan
   liability.** — **[auto]** support: the liability balance and movement show the split; **the amortization
   schedule is `[manual]`.**
6. **Reversing entries dated the last day of the prior period** → **must be the FIRST day of the new
   period.** — **[auto]**: a date check.
7. **Forgetting the tax line** when a transaction has tax effects in the entity's jurisdiction —
   **under- or over-states the liability.** — **[gated]**: the tax accounts and codes are readable; **the
   rules are not.**
