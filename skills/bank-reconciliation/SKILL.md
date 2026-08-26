---
name: bank-reconciliation
description: "Use this skill whenever the user needs to reconcile a bank account (cash GL) to bank statements for a period, working from their Mosofin workspace. Triggers include: bank recon, reconcile bank, cash reconciliation, bank statement tie-out, unreconciled items, outstanding checks, deposits in transit, or investigating recon differences. Workspace-scoped: it confirms the workspace, discovers which company files are connected and which read-only tools are enabled, then builds the complete book side from live ledger data and prepares the bridge — while stating plainly that the bank statement is outside any accounting datasource and must be supplied before a reconciliation can actually be completed. Produces a recon output, variance explanations, a clean list of required journal entries or corrective actions, and a coverage sheet."
---

## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** — but every step becomes manual.

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

# Bank Reconciliation (Mosofin)

Reconciles the cash balance per the **general ledger (GL)** to the **bank statement** balance for
a specified period, explains timing differences, and identifies errors requiring correction.

**In plain words:** your books say you have one amount of cash; the bank says another. Usually
both are right — cheques you wrote haven't been cashed yet, money you banked hasn't landed yet,
and the bank has charged fees you didn't know about. **Reconciling** is proving that the two
figures differ *only* for reasons you can name. Anything left over is an error, and finding it is
the point.

This skill supports single or multiple bank accounts.

It is **workspace-scoped**: every ledger balance, payment and deposit comes from a tool call
against a company file connected to your Mosofin workspace in this conversation, or from
something you supplied by hand and that is labelled as such.

## The defining limitation — read this before promising a reconciliation

A bank reconciliation has two sides. **Mosofin can read one of them.**

Mosofin connects the **accounting system**. It reads the GL cash balance, every payment, every
deposit and every transfer recorded in the books. It **cannot read a bank statement, a bank feed,
or a downloaded transaction file**, and no accounting datasource exposes one.

> **Without a bank statement, a bank reconciliation cannot be performed.** Not partially, not
> approximately. Comparing the books to the books is not a reconciliation — it is a total
> agreeing with itself. Never label such an output a bank reconciliation, and never report a
> cash balance as "reconciled" on that basis.

**What this skill genuinely does from a connected workspace, and it is worth doing:**

- Builds **the entire book side** of the bridge from live data — the GL ending balance and every
  transaction behind it.
- Produces the **candidate lists**: payments recorded but plausibly not yet cleared (potential
  outstanding cheques), deposits recorded near period end (potential deposits in transit).
- **Detects book-side errors without the statement** — duplicate entries, wrong-account postings,
  wrong dates, and transactions after the cutoff.
- **Flags stale items** against the escalation rules in Quality checks.
- Prepares a **reconciliation template with the book side complete**, so that when the statement
  arrives the remaining work is matching, not rebuilding.

Then it **asks for the statement** and says exactly what it could not conclude without it.

If a **banking or payments platform is a connected datasource** in this workspace, that changes
everything — check at Gate 1 before assuming the statement is unavailable.

**Mosofin is read-only.** It cannot post an adjusting entry, mark an item cleared, or sign off a
reconciliation. Every entry below is a *proposal* for a human.

---

# PART A — Prerequisites: confirm scope, discover the capability map

Run Gates 0 → 1 → 2 → 3 in this order, before reconciling anything. This ordering is the
contract. Do not skip a gate because a previous conversation covered it — connections,
permissions, and company files change between periods.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a client-side
`mcp__…` namespace; that string is composed by whichever MCP client is running.

## Gate 0 — Confirm the workspace

Call `list_workspaces` with **no arguments**.

- **One workspace** → read the workspace **name** back and **wait for an explicit yes**.
- **Two or more** (`selection_required`) → ask **in chat** whether this is single- or
  multi-workspace, then which workspace(s) **by name**, then call again with
  `workspace_ids=[…]` and `mode="single"` / `mode="multi"`.

Never auto-pick. Never print an internal numeric tenant id — name the workspace, pass the opaque
`ws_…` handle.

## Gate 1 — Discover live datasources and settle the entity scenario

Call `get_agent_datasources` with the confirmed `workspace_id`.

- `connected: true` → **in scope**.
- `connected: false` → **excluded, and named as excluded**. Surface any `reconnect_url`.

**Check every connected row for a banking or payments platform.** This is the highest-value check
in the whole gate for this skill: a connected bank feed converts the reconciliation from
`[manual]` to genuinely two-sided. Do not assume the workspace is accounting-only without
looking.

Settle the entity scenario:

- **Single-entity** — ask which company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call targeting
  exactly one `data_source_id`, and every balance, unmatched item and proposed entry carries its
  entity's `display_name`. **Never reconcile one entity's GL cash to another entity's statement.**
  Where several entities genuinely share one bank account, that is a specific and awkward case —
  see the edge case.

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

Resolve **every task in Part B** against these buckets. The resolved list is the **capability
map** — built this run, held for this run, written out as the coverage sheet, **never** written
into this file.

Rules that bite hardest here:

- **Read the real tool name from the catalog, never from memory.** Names are not uniformly
  styled — some underscored, some hyphenated.
- **A near-substitute is not a substitute, and here it is the central trap.** A **balance sheet**
  cash figure, a **cash flow statement**, and a **deposit listing** are all views of the *book*
  side. None of them is the bank's view. Assembling them into something that looks like a
  two-column reconciliation produces a document that asserts a control was performed when it was
  not. If the statement is absent, the output is a *book-side preparation*, and it must be
  labelled that way.
- **The connected books may not expose a "cleared" or "reconciled" flag.** Most read-only
  connectors do not. That means **outstanding cheques and deposits in transit cannot be
  identified with certainty from the books alone** — only proposed as candidates by date. Say
  "candidate", not "outstanding".

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`) for each in-scope
entity.

**Derive silently** what the profile answers: base currency (which determines whether an FX line
belongs in the bridge at all), fiscal calendar, country / region, and **time zone** — which
matters here, because whether a transaction falls on the statement's last day can depend on it.

**Ask the user** what actually changes the work — the original Inputs table, minus what the
profile answered:

| What to confirm | Required? | Notes |
|---|---|---|
| **Bank account(s) in scope** — account name(s), **account numbers masked** | **Required — partly [auto]** | The chart of accounts pulls the cash accounts; ask which are in scope. **Never display or store a full account number.** |
| **Reconciliation period** — start / end dates | **Required** | Never default the period. |
| **Bank statement** — PDF/CSV, or the ending balance plus statement lines | **Required — [manual]**, always | Ask for it explicitly and early. If it cannot be supplied, say what the output will and will not be before doing the work. |
| **GL activity for cash account(s)** — date, description, amount, counterparty, reference | **Required — usually [auto]** | Pulled from the connected books. |
| **Prior month reconciliation status** — prior recon report or last reconciled date | Recommended — **[manual]** | Without it, opening outstanding items are unknown and the bridge starts blind. Ask for at least the last reconciled date. |
| **Cutoff policy** — posting cutoffs, deposit processing, cheque clearing | Recommended — **[manual]** | Sets the date windows in Step 3 and the escalation ages in Quality checks. |
| **Materiality threshold** | Recommended | Ask; do not assume. Note that the final tie is **to the cent** regardless — materiality governs which *items* get chased, not whether the bridge balances. |
| **Confirm scope** | **Required** | Read back in-scope and excluded company files by `display_name`, and the accounts in scope by name. |
| **Confirm any profile contradiction** | **Required if one appears** | |
| **Confirm manual evidence** | **Required** | The statement and the prior recon will both be `[manual]`. Record what was not supplied. |

Ask as **one short batch**. Propose defaults where reasonable — but **never** default the period,
the account, or the entity.

**On later runs**, read stored preferences first (Step 7), confirm in one line, and ask only what
is new, changed, or contradicted. The account list, cutoff policy and escalation ages should not
be re-asked every month.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*,
not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the cash
ledger, the deposits, the payments and the transfers do not depend on each other. Never serialize
them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — to identify the cash / bank accounts by their real names — usually
  **[auto]**
- *`get_trial_balance`* / *`get_balance_sheet`* — the GL cash ending balance — usually **[auto]**
- *`get_general_ledger`* on each cash account for the period — every book-side movement, the core
  of this skill — usually **[auto]**
- *`search_deposits`* / *`get_deposit`* — money banked, and the deposit-in-transit candidates —
  usually **[auto]**
- *`search_bill_payments`* / *`get_bill_payment`* — supplier payments, the outstanding-cheque
  candidates — usually **[auto]**
- *`search_purchases`* — cheques, card spend and direct debits — usually **[auto]**
- *`search_payments`* / *`search_sales_receipts`* — customer receipts — usually **[auto]**
- *`search_transfers`* — movements between the entity's own accounts, which appear on both sides
  and are a classic double-count — usually **[auto]**
- *`search_journal_entries`* — manual entries hitting cash, a frequent error source — usually
  **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with `approved=true`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the bridge's format
but **cannot support a completed reconciliation**, because a reconciliation is a control and
performing it on fixtures records a control as operating when it did not.

## Step 1 — Establish the two starting points

Capture:

- **Bank statement ending balance** as of the statement end date — **[manual]**
- **GL cash account ending balance** as of the same date — **[auto]**
  (*`get_trial_balance`*, *`get_balance_sheet`*, *`get_general_ledger`*)

**Confirm both are for the same account and currency.** This sounds trivial and is a common real
error: an entity with several accounts at the same bank, or a foreign-currency account carried in
the base currency, will produce a bridge that can never balance. State the account name, the
currency, and the date on both sides before going further.

If the statement balance is not available, **stop and say so here** — do not proceed to build a
bridge with one side missing and present it as a reconciliation. Continue instead with the
book-side preparation described at the top of this file, clearly labelled.

## Step 2 — Build the reconciliation bridge

Two ladders that must meet in the middle.

```
Bank statement ending balance
+ Deposits in transit
- Outstanding checks / payments
+/- Bank errors (rare; document)
= Adjusted bank balance

Book balance (GL ending balance)
+ Bank interest and other credits not recorded
- Bank fees and other debits not recorded
+/- Errors on books
= Adjusted book balance
```

**Adjusted bank balance must equal adjusted book balance.**

- **Deposits in transit** — money you banked that the bank hasn't credited yet. **[gated]**:
  the deposits are **[auto]** (*`search_deposits`*), but *which* are still in transit needs the
  statement. Without it, list them as **candidates** by date.
- **Outstanding cheques / payments** — payments you issued that haven't been cashed. Same split:
  the payments are **[auto]** (*`search_bill_payments`*, *`search_purchases`*); which are still
  outstanding needs the statement.
- **Bank errors** — rare, and **[manual]**. Document them; banks do make mistakes and they are
  worth pursuing.
- **Interest and credits not recorded / fees and debits not recorded** — **[manual]** to identify
  without the statement, since by definition they are not in the books. This is the same blind
  spot described in `bank-fee-and-interest-analysis`.
- **Errors on books** — **[auto]** and the strongest automated contribution here: duplicates,
  wrong amounts, wrong dates, wrong accounts, all detectable in the ledger alone.

## Step 3 — Match transactions (bank vs GL)

Work down the methods; record which one produced each match, because a level-1 match and a level-4
match carry very different confidence.

Matching process — **[gated]**, requiring both sides:

1. **Exact amount + date window match** (same day to ± 3 business days) — the strongest.
2. **Exact amount + fuzzy description match** — for when the bank's wording differs from yours.
3. **Reference match** (cheque number, ACH ID, wire reference, merchant descriptor) — often the
   most reliable of all where the reference survives on both sides.
4. **Split / combined matches** — one bank line covering several book entries, or vice versa.
   Common with batched deposits and card settlements, and the level where false matches start.

**[auto]** even without a statement: run the *book side against itself* to find duplicates — the
same amount, counterparty and date recorded twice. That is not matching, but it removes a
frequent cause of an unbalanced bridge before the statement even arrives.

## Step 4 — Classify all unmatched items

**Unmatched bank items** — **[manual]** without the statement, since these are things only the
bank knows:

- **Bank fees**
- **Interest earned**
- **Returned items / NSF** — a customer's payment bounced ("non-sufficient funds")
- **Chargebacks** — a card issuer reversing a payment
- **Merchant processor netting / reserves** — the processor taking its fee before paying you, or
  holding back a reserve
- **Loan payments (principal / interest)** — often taken automatically by direct debit
- **FX gains / losses** (if applicable)
- **Unknown (needs research)** — an honest category; give it an owner and a date

**Unmatched GL items** — **[auto]** to list, **[gated]** to classify:

- **Deposits in transit**
- **Outstanding checks**
- **Timing differences**
- **Book errors** — duplicate entry, wrong account, wrong amount, wrong date. **[auto]** to detect
  all four from the ledger alone (*`get_general_ledger`*, *`search_journal_entries`*), which makes
  this the part of Step 4 that can be completed before the statement arrives

## Step 5 — Propose corrections / journal entries

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — these are
proposals.

JE templates:

**Record bank fee**
```
DR Bank Fees Expense                 XXX
    CR Cash (Bank Account)               XXX
```

**Record interest income**
```
DR Cash (Bank Account)              XXX
    CR Interest Income                  XXX
```

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which you chose. Every proposed entry
names the statement line that evidences it — an entry proposed without that evidence is a guess
at what the bank did.

## Step 6 — Close out and document

Deliver:

- **Reconciliation summary table** — both ladders, meeting or not meeting
- **Unreconciled items list with owner + next action** — every item, including the "unknown"
  category
- **Proposed JEs with memos and support** — marked as proposals
- **Sign-off checklist** — **[manual]**. Mosofin cannot sign anything. Preparer and reviewer are
  named humans, and they should not be the same person

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This runs every month, so the evolution step pays back quickly.

On an explicit yes, persist the **decisions**:

- **The bank account list** — by account name and the entity that owns it, with **masked**
  identifiers only
- **The cutoff policy** — posting cutoffs, deposit processing times, typical cheque clearing
  windows — which sets the Step 3 date windows
- **The escalation ages** — the deposit-in-transit and outstanding-cheque thresholds from Quality
  checks, if the entity uses different ones
- **The materiality threshold** for chasing items
- **Recurring statement items** — the standing monthly fee, the regular loan direct debit, the
  processor's settlement pattern — so each is recognised rather than re-researched every month
- The account mapping for fees, interest and FX
- Where the statement comes from and who supplies it
- The replay recipe: the exact sequence of reads that produced the book side

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Never persist bank account numbers, statement contents, balances, or unreconciled item detail.**
Account numbers are payment credentials and the top fraud target; balances and item lists are the
period's evidence and belong in the close file. Persist the *policy, the thresholds and the
account names*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Operating account (…4471): cheques clear in ~5 days, escalate DIT over 10
business days" — not "cheques clear in ~5 days". Entities bank differently, and an unlabelled
clearing window applied to the wrong company file mis-ages every item. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to
the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is
the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Outputs

1. **Reconciliation summary** — with a header stating the workspace, the entity `display_name`,
   the account by name, the period, **whether a bank statement was supplied**, and whether any
   figure rests on `mock` data.
2. **Matched transaction list** — each with the matching method (1–4) that produced it.
3. **Unmatched lists with classification** — bank side and book side, per Step 4.
4. **Exception log with recommended next actions** — each with an owner and a target date.

**Coverage sheet — NEW, Mosofin-specific.**

One row per task in Steps 1–6:

| Task | Entity (`display_name`) | Account | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

If no statement was supplied, the rows for the bank side, the matching step and the unmatched-bank
classification all read `manual` with the gap "bank statement not supplied", and **the summary
says the reconciliation was not completed**. That is the correct, expected output — not a defect,
and not something to disguise with a book-side total.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

**File naming — Mosofin addition** (the original left it unstated, and multi-account, multi-entity
output needs it): `Bank_Rec_[AccountName]_[YYYY-MM].xlsx`, and in a multi-entity run
`Bank_Rec_[EntityDisplayName]_[AccountName]_[YYYY-MM].xlsx`. Every file states which datasource,
which `display_name` and which account it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead of
estimating.

---

## Quality checks

- **Same statement end date on both sides**
- **No duplicates in the GL export** — **[auto]** to test, and worth doing on every run
- **Deposits-in-transit older than 10 business days escalated** — money banked that the bank has
  not credited after two weeks is usually a lost deposit or a booking error, not timing
- **Outstanding checks older than 90 days escalated** — a cheque uncashed for a quarter may be
  lost, may be a duplicate payment about to be made, and in many jurisdictions eventually becomes
  unclaimed property
- **Adjusted balances tie to the cent** — not to materiality. A bridge that nearly balances has an
  unidentified item in it

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The output states plainly whether a bank statement was supplied**, and if not, is labelled a
  book-side preparation rather than a reconciliation
- **A book-side total is never presented as a reconciled cash balance**
- Outstanding cheques and deposits in transit identified without a statement are labelled
  **candidates**, never confirmed outstanding items
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- Every matched item records the matching method that produced it
- Every proposed entry names the statement line that evidences it
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no reconciliation is signed off on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids, no raw `data_source_id` values, and **no unmasked bank account
  numbers** appear in anything the user sees or in any persisted preference
- Nothing was written back to any system — every entry is a proposal, and nothing was marked
  cleared or signed off

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`, once per bank account in
scope.

**Multi-entity.** Steps 0–6 run **once per entity and per account**, each call targeting exactly
one `data_source_id`, every balance and item carrying its entity's `display_name`. Then one
cross-entity step:

- **A group cash position summary** — total reconciled cash by entity and account, with each
  entity's reconciliation status shown separately. **Group cash is only as reliable as the least
  reconciled account in it**, so report the status, not just the total.
- **Intercompany transfers appear on both entities' books** — one entity's payment is another's
  receipt. Match them across entities (*`search_transfers`*, *`search_deposits`*) and confirm both
  legs were recorded; a transfer recorded once is a classic cause of an unbalanced bridge at one
  entity and an unexplained credit at the other.
- **A bank account shared across entities** — where several entities genuinely transact through
  one account, no single entity's GL can reconcile to the full statement. Say so explicitly,
  reconcile the statement to the *combined* book activity, and treat the per-entity split as an
  allocation question, not a reconciliation.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
company file and per account.

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
| Identify the cash / bank accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| GL cash ending balance | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Every book-side cash movement | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Deposits (deposit-in-transit candidates) | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| Supplier payments (outstanding-cheque candidates) | `search_bill_payments` / `get_bill_payment` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Cheques, card spend, direct debits | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required); `id` |
| Customer receipts | `search_payments` / `search_sales_receipts` | `start_date`, `end_date` (required), `customer_id` |
| Transfers between own accounts | `search_transfers` / `get_transfer` | `start_date`, `end_date` (required); `id` |
| Manual entries hitting cash | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Refunds issued | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required); `id` |
| Cash movement over the period | `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by` |
| Payment methods in use | `search_payment_methods` | `query`/`name`, `active_only` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Bank reconciliation** — proving the difference between your books and the bank's records is
  fully explained.
- **General ledger (GL)** — the complete record of every transaction in the books.
- **Book balance** — cash according to your books. **Statement balance** — cash according to the
  bank.
- **Bridge** — the two ladders of adjustments that bring both balances to the same adjusted figure.
- **Deposit in transit (DIT)** — money you banked that the bank hasn't credited yet.
- **Outstanding cheque** — a payment you issued that hasn't been cashed yet.
- **Cutoff** — the point at which a period stops accepting transactions.
- **NSF (non-sufficient funds)** — a payment that bounced.
- **Returned item** — a receipt reversed because it failed.
- **Chargeback** — a card issuer reversing a payment.
- **Merchant netting** — the card processor deducting its fee before paying you.
- **Reserve** — money a processor holds back against future chargebacks.
- **ACH ID / wire reference / merchant descriptor** — identifiers that let you match a bank line
  to a book entry.
- **Split / combined match** — one bank line covering several book entries, or the reverse.
- **Tie to the cent** — the bridge must balance exactly, not approximately.
- **Unclaimed property** — money (like an uncashed cheque) that must eventually be handed to the
  state.
- **Journal entry (JE)** — the balanced two-sided record. **DR** = debit, **CR** = credit.

---

## Edge Cases

*The original did not carry an Edge Cases section; these are Mosofin additions plus the hazards
implicit in the steps above.*

**No bank statement was supplied** — the default situation in an accounting-only workspace. Do the
book-side preparation, label it as such, and say the reconciliation was not completed. Never
produce a two-column document that implies otherwise.

**The connector exposes no "cleared" flag** — outstanding cheques and deposits in transit can only
be proposed as **candidates** by date. Label them that way.

**No prior reconciliation is available** — opening outstanding items are unknown, so an item
appearing unmatched may be months old. Say the bridge starts unqualified and recommend
establishing a baseline.

**A foreign-currency account carried in the base currency** — the bridge will never balance if one
side is converted and the other is not. Reconcile in the account's own currency, then translate;
see `multicurrency-fx-revaluation`.

**A transfer between the entity's own accounts recorded once** — appears as an unexplained debit on
one account and an unexplained credit on another. Always check transfers on both accounts before
classifying either as an error.

**A batched deposit or card settlement** — one bank line, many book receipts, often net of fees.
Match the batch, expect the net, and gross up the fee rather than forcing the amounts to agree.

**A duplicate payment about to be reissued** — an old outstanding cheque that is really lost will
be reissued, and if the original then clears the entity pays twice. Escalate cheques over 90 days
rather than rolling them forward.

**Deposits in transit that never clear** — after ten business days this is a missing deposit or a
booking error, not timing. Investigate rather than carrying it forward.

**Someone reconciles to materiality** — the bridge ties **to the cent**. A "close enough" bridge
has an unidentified item in it, and unidentified items are where fraud and error live.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
which accounts are therefore unreconciled. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A reconciliation is a control;
performing it on fixture data records a control as operating when it did not.

**A bank account is shared by several entities** — *Mosofin-specific*. No single entity's GL can
tie to the whole statement. Reconcile the statement to combined activity and treat the split as an
allocation.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.
