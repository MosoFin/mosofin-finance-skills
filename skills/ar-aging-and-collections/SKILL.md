---
name: ar-aging-and-collections
description: "Use the confirmed Mosofin workspace and its connected accounting datasource to pull live A/R, build and reconcile an aging, prioritize collections, calculate receivables metrics, and draft review-only reminders. Trigger for 'run an AR aging,' 'who owes us money,' 'prioritize collections,' 'calculate DSO,' or 'draft overdue-invoice reminders.' Workspace-scoped: require the Mosofin workspace and an active connection, discover which read-only tools are enabled, and resolve every task against that capability map before reading data. Do not use for cash application, bad-debt write-offs, invoice creation, or sending reminders."
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

# A/R Aging and Collections (Mosofin)

Builds an **accounts receivable (A/R) aging**, reconciles it, prioritizes collections, computes
receivables metrics, and drafts review-only reminders.

**In plain words:** this answers *who owes us money, how late are they, and who should we
chase first?* An **aging** sorts every unpaid customer invoice by how overdue it is.
**Collections** is the work of getting that money in.

Use this skill only after the Mosofin workspace and the company file are confirmed. Pull live
data through the Mosofin datasource gateway, then ask once for material fields the connector
cannot supply. **Never write to the accounting system and never contact customers.**

**Mosofin is read-only.** It cannot create an invoice, apply a payment, write off a balance,
place a credit hold, or send a reminder. Every draft below is text for a human to review and
send themselves.

---

# PART A — Prerequisites: confirm scope, discover the capability map

Run Gates 0 → 1 → 2 → 3 in this order, before any data read. This ordering is the contract.
Do not skip a gate because a previous conversation covered it — connections, permissions, and
company files change between runs.

Call the Mosofin tools by the **bare names your own tool list exposes** — `list_workspaces`,
`get_agent_datasources`, `get_datasource_tools`, `invoke_datasource_api_tool`, `get_skills`,
`get_my_skill`, `create_skill`. Do not add a `mosofin_` prefix and do not hardcode a
client-side `mcp__…` namespace; that string is composed by whichever MCP client is running.

## Gate 0 — Confirm the workspace

1. Call `list_workspaces` with **no arguments**.
2. If **multiple** workspaces are returned, ask whether this is a single- or multi-workspace
   task, ask which workspace(s) **by name**, confirm them with `workspace_ids=[…]` and
   `mode="single"` / `mode="multi"`, and use only the returned opaque `ws_…` handle(s).
   **Never expose internal numeric IDs.**
3. If **one** workspace is returned, read its name back and **wait for explicit user
   confirmation** before continuing.

## Gate 1 — Discover live datasources and settle the entity scenario

4. Call `get_agent_datasources` for the confirmed workspace. Require an **ACTIVE** datasource
   (`connected: true`). Rows with `connected: false` are **excluded and named as excluded** —
   an aging that silently omits an entity understates what the group is owed.
5. If **multiple company files are active**, ask the user to choose by `display_name`. Pass
   the chosen `data_source_id` on every subsequent Mosofin call; **never show that ID**.

**If the datasource is disconnected, expired, or not ACTIVE, stop.** Show the Mosofin
`reconnect_url`, tell the user to reconnect in Mosofin, and wait for confirmation before
retrying. **Do not substitute CSVs or guessed numbers while the user is asking for live
Mosofin data.**

Settle the entity scenario:

- **Single-entity** — one company by `display_name`; the workflow runs against that one
  `data_source_id`.
- **Multi-entity** — ask which set. The workflow runs **once per entity**, every call
  targeting exactly one `data_source_id`, and every aging row, metric and draft carries its
  entity's `display_name`. Two entities' receivables are never blended into one figure
  without that label — and DSO in particular is meaningless when blended, because each
  entity has its own sales base.

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

6. Call `get_datasource_tools` for each in-scope datasource — and **per company file** when
   several are live, since **permissions are per company**. Bucket every tool by
   `effective_policy`:

| `effective_policy` | The task becomes | What you do |
|---|---|---|
| `enabled` | **[auto]** | Pull the evidence directly. |
| `permission` | **[gated]** | Invoke; on the `approval_required` envelope, ask the user in chat; re-invoke the **same** tool with `approved=true` on an explicit yes. |
| `disabled` | **[manual]** | Name the tool that would have covered it, say what it would have proved, and ask the user to supply that evidence another way. |

Use only tools whose effective policy is `enabled` or `permission`; **never use `disabled`
tools.** Resolve **every task in Part B** against these buckets. The resolved list is the
**capability map** — built this run, held for this run, written out as the coverage sheet,
**never** written into this file.

**The connector catalog is authoritative for exact `tool_name` values. Do not invent a tool
name.** Names are not uniformly styled — some underscored, some hyphenated — so take the exact
string from the Gate 2 listing. On an `UNKNOWN_TOOL` error, read the valid names from the
error itself.

Two capability judgments specific to this skill:

- **Aging summary versus aging detail are different capabilities.** A summary gives totals per
  customer per bucket; a detail gives one row per invoice. **If no complete A/R detail
  capability is listed, do not claim that an invoice search is a complete historical aging
  population** — most invoice searches default to a recent date range and will silently omit
  old unpaid invoices, which are precisely the ones collections cares about. Request the
  smallest equivalent export for the tie-out instead.
- **A customer balance report is not an aging.** It gives one total per customer with no
  due-date buckets, so it cannot say what is overdue or by how long. Never present it as an
  aging. Where the aging report is unavailable but invoice-level data is complete, you may
  **reconstruct** the aging from invoices, payments and credits — label it as reconstructed
  and tie it back.

7. Route every data read through `invoke_datasource_api_tool` with the confirmed
   `workspace_id` and the selected `data_source_id` when required. Reads are live and
   read-only; **check each response's `mock` field and say when a result is fixture data.**

## Gate 3 — Profile the entity, then interview the user

Call the platform's company-profile tool (on QuickBooks, `get_company_info`).

**Derive silently** what the profile answers — and confirm the company before reporting:

- Company name and address — **confirm the company before reporting**; if it is not the
  expected one, ask the user to reconnect or select the correct company
- Base / functional currency
- Fiscal calendar and year-end, time zone

**Ask the user**, as **one consolidated question**, only for missing inputs that change the
requested output. See Step 4 — core aging does not require dispute flags, payment history,
DSO, or collection policy.

### Input plan

| Input | Typical read | Rule | If unavailable |
|---|---|---|---|
| **Company** | Company profile / datasource connection | Confirm company before reporting | Ask user to reconnect or select the correct company |
| **As-of date** | User request or current date | Pass a concrete `YYYY-MM-DD` date | Ask only if ambiguous. **Never silently default it** |
| **Open invoices** | A/R aging **detail** capability if exposed; otherwise the catalog's invoice search / report | Prefer a complete as-of report; **do not rely on a recent-only invoice query** | Ask for an A/R Aging Detail export after explaining the missing connector capability |
| **Independent totals** | A/R aging **summary** capability | Pull unfiltered for the same date | Derive from detail and **disclose that there is no independent tie-out** |
| **Credits / payments** | A/R detail without a transaction-type filter, or payment / credit search tools | Pull only when invoice detail does not reconcile | Ask for unapplied credits / payments or a full detail export |
| **Invoice enrichment** | Invoice search / single-invoice read | Query selected IDs or document numbers only | Leave unavailable enrichment fields blank |
| **Currency** | Report / invoice response | **Preserve each currency separately** | Ask before presenting unlabeled consolidated totals |
| **Exact DSO denominator** | Credit sales and period | **Require explicit credit sales** | Ask the user; offer a labeled total-income proxy only with approval |
| **Disputes, credit holds, strategic tier, payment history** | Not reliably exposed by aging reads — **[manual]** | **Never infer** | Ask only when needed for the requested prioritization |
| **Collection policy / brand voice** | User-provided policy — **[manual]** | Apply only supplied terms | Use neutral language without fees or threats |
| **Confirm scope** | — | Read back in-scope and excluded company files by `display_name` | — |
| **Confirm manual evidence** | — | For each `[manual]` gap, ask whether the user can supply it, and how | — |

**On later runs**, read stored preferences first (Step 7), confirm them in one line, and ask
only what is new, changed, or contradicted. Strategic tiers, collection policy and brand voice
in particular should not be re-asked every cycle.

## Guardrails

- **Never** create / update records, apply payments, write off balances, or send reminders.
- **Mark all correspondence `REVIEW REQUIRED - NOT SENT`.**
- **Do not invent** disputes, credit holds, payment promises, late fees, service suspension,
  or legal action.
- **The A/R aging may be accrual-only in the available connector.** If cash basis is
  requested, explain the limitation and **ask whether accrual basis is acceptable before
  reading data** — do not read first and caveat afterwards.
- End a live-data response with **one `Data sources` line** naming the Mosofin calls used and
  their retrieval time.

---

# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## 1. Pull and confirm

**Batch independent reads into one message** — the aging summary, the aging detail, and any
enrichment query do not depend on each other. Never serialize them. The server is
**stateless**: pass `data_source_id` on **every** call, including retries.

1. **Resolve the Mosofin workspace and company file** using Gates 0–1 above.
2. **Discover or match the A/R aging summary capability** — semantically equivalent to an
   "Aged Receivables" report — **[auto]** (*`get_aged_receivables`*).
3. **Discover or match the A/R aging detail capability** — semantically equivalent to an
   "Aged Receivable Detail" report. **[auto] if listed; [manual] if not** — in which case
   request the export named in the input plan.
4. **Invoke detail for the chosen date**, with invoice-only filtering when supported.
5. **Invoke unfiltered summary for the same date** — this is the independent total used in
   Step 3.
6. **Use invoice search only for selected enrichment** (*`search_invoices`*). **Its
   recent-date default can omit old unpaid invoices**, so it is an enrichment tool here, never
   the population.

**For one customer, use an exact customer name.** Resolve a fuzzy name before pulling the
report (*`search_customers`*, **[auto]**) and **state the match** you resolved to — a short trading name
matching to a longer registered legal name is a judgment the user should see.

## 2. Normalize

Create **one row per invoice**:

| Customer | Customer ID | Invoice # | Invoice ID | Invoice Date | Due Date | Days Past Due | Bucket | Original | Open Balance | Currency | Source |
|---|---|---|---|---|---:|---|---:|---:|---|---|---|

- **`Days Past Due = as-of date − due date`**; zero or less is **Current**.
- **Use open balance, not original amount, for aging totals.** The original amount is what was
  invoiced; the open balance is what is still owed after payments and credits.
- **Preserve IDs / document numbers as text** — leading zeros and prefixes are lost if they are
  treated as numbers.
- **Leave absent fields blank; do not fabricate them.**
- **Set Source to the exact Mosofin tool used**, or to the user-supplied fallback.

**Default buckets: Current, 1-30, 31-60, 61-90, 91-120, Over 120.**

**A summary report may return a single `91+` bucket; split it using due dates from the
detail.** If detail is unavailable, say the 91+ bucket could not be split rather than
presenting an unsupported breakdown.

## 3. Reconcile

**Compare invoice-detail totals with the A/R aging summary, by customer and in total** —
**[auto]** where both capabilities exist.

- **Combine 91-120 and Over 120 before comparing** with a summary's single `91+` bucket.
- **If totals differ, pull detail again without invoice-only filtering** and identify the
  reconciling rows — credits, payments, journal entries, or other transaction types.
- **Use a 0.01 currency-unit tolerance.**
- **Disclose unresolved variance; never force a tie.**
- **Call this a summary-to-detail reconciliation unless a GL control balance was separately
  tested.** The **general ledger control balance** is the single A/R total in the books
  (*`get_balance_sheet`*, **[auto]**); testing against it is a stronger check and deserves the
  stronger name only when it was actually done.

## 4. Ask for material gaps

After pulling the data, **ask one consolidated question** — only for missing inputs that change
the requested output. **Core aging does not require dispute flags, payment history, DSO, or
collection policy; omit and disclose these when not requested.**

Example:

> The connected books supplied the aging and balances but not reliable dispute, credit-hold,
> strategic-tier, or collection-policy fields. Please provide any relevant flags and approved
> escalation wording. For exact DSO, also provide credit sales and the measurement period.

## 5. Analyze

Calculate when supported — **[auto]** arithmetic over the pulled data:

- **Total A/R, overdue total, overdue percentage, and amount / percentage over 90 days**
- **Weighted average days past due** — weighting by open balance and **flooring current
  invoices at zero**, so invoices paid early do not mask late ones
- **Top-five customer concentration** — how much of the total is owed by the largest five.
  Concentration is a risk measure: one customer at 40% of A/R is a different business from
  fifty at 2% each
- **`DSO = ending A/R / credit sales for period × days in period`** — **days sales
  outstanding**, the average number of days it takes to get paid

**If total accrual-basis income substitutes for credit sales, label it `Approximate DSO
(total-income proxy)`** — **[gated]**: total income (*`get_profit_and_loss`*, **[auto]**)
includes cash sales that were never receivable, so the proxy flatters the number. Offer it
only with the user's approval, and never present it unlabeled.

**Rank overdue customers primarily by age and open balance** — **[auto]**. **Use payment
history, disputes, credit holds, or strategic status only when supplied** — **[manual]**;
never infer them from the ledger. **Route disputes to resolution rather than collection
pressure**: chasing a disputed invoice as though it were simply late damages the relationship
and does not get it paid.

**Suggested action bands:**

- **1-30** — friendly reminder
- **31-60** — formal follow-up / payment-date request
- **61-90** — management review / direct contact
- **Over 90** — escalation review under the user's approved policy

**Bankruptcy or insolvency notices stop ordinary dunning and require professional review.**
*Dunning* is the routine sequence of payment reminders; continuing it after an insolvency
notice can breach a legal stay and expose the entity.

## 6. Deliver

Return the requested subset, or a workbook containing:

1. **Run Context** — workspace and company by name, as-of date, accounting basis, extraction
   time, sources, missing fields. **Add:** each in-scope company file by `display_name`, each
   excluded one and why, and whether any figure rests on `mock` data
2. **Aging Summary** — customers, buckets, totals, metrics, next action
3. **Aging Detail** — normalized invoice rows
4. **Collection Plan** — ranking, reason, owner / status blanks, next action
5. **Drafts** — review-only reminder text, every one marked `REVIEW REQUIRED - NOT SENT`
6. **Exceptions** — credits, missing dates / currency, disputes, and reconciliation variance
7. **Coverage — NEW, Mosofin-specific** — one row per task in Steps 1–5:

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

Rows for disputes, credit holds, strategic tier and payment history will read `manual` with
their gaps named. That is the correct, expected result — not a defect.

If creating XLSX, use the available spreadsheet skill and name it
`QuickBooks_AR_Aging_Collections_YYYY-MM-DD.xlsx` — or, where the datasource is not
QuickBooks, `[Datasource]_AR_Aging_Collections_YYYY-MM-DD.xlsx`. In a multi-entity run,
include the entity: `…_AR_Aging_Collections_YYYY-MM-DD_[EntityDisplayName].xlsx`, plus one
combined file. Every file states which datasource and `display_name` it covers.

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

## 7. Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved
them, ask — explicitly, at that point, not earlier — whether to save this as their own
customized version. A general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **Strategic tiers per customer**, and any standing credit holds with the reason and date
  opened — pure judgment the books never hold, and the thing that otherwise gets re-asked
  every cycle
- **The collection policy and brand voice**: approved wording, the payment contact address,
  the escalation ladder, and what must never be said (late fees, legal action, suspension)
- **The action bands**, if the user overrode the defaults
- **The DSO basis** — whether exact credit sales are available and where they come from, or
  whether the labeled proxy was approved
- **Bucket definitions**, if non-default, and whether the 91+ split is available
- Standing disputes and their owners
- The replay recipe: the exact sequence of reads that produced this aging

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Do not persist customer contact details, outstanding balances, or draft correspondence.**
Those are a snapshot of one moment and personal data besides; persist the *policy and the
tiers*, never the ledger.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Customer A: strategic tier A, escalation owner Kim" — not "Customer A:
tier A". The same customer can be strategic to one entity and marginal to another, and an
unlabeled tier applied to the wrong company file misdirects a real collections effort. Record
the chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's;
state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One aging, one collection
plan, one workbook.

**Multi-entity.** Steps 1–6 run **once per entity**, each call targeting exactly one
`data_source_id`, every aging row, metric and draft carrying that entity's `display_name`.
Then one cross-entity step:

- **A side-by-side comparison plus a group total for A/R.** Total receivables aggregate
  meaningfully; **DSO does not** — each entity has its own sales base, so a blended DSO is a
  number with no denominator. Report DSO per entity, and a group DSO only if group credit
  sales were supplied.
- **Shared customers are the point of the comparison.** One customer owing three entities may
  be a concentration risk invisible at each one alone, may warrant a single coordinated
  approach rather than three separate reminders, and may be disputed at one entity while being
  chased at another — which is exactly how a relationship gets damaged.
- **Intercompany receivables** — where one entity owes another — are excluded from collections
  and routed to `intercompany-reconciliation`.

Capability is checked **per entity** at Gate 2: the aging detail capability may be listed for
one company file and not its sibling, so the same task can be `[auto]` for one and `[manual]`
for another. The coverage sheet shows this per entity.

---

## Mosofin read-call reference

Use the logical Mosofin gateway below; **exact tool names come from `get_datasource_tools`**:

```json
{
  "datasource": "<datasource id, e.g. quickbooks>",
  "tool_name": "<catalog tool name>",
  "workspace_id": "<confirmed ws_... handle>",
  "data_source_id": "<selected company file id when required>",
  "params": {"report_date": "YYYY-MM-DD"}
}
```

Typical connector semantics — **verify each against your Gate 2 catalog; policies and
availability vary by workspace and by company file**:

- **`get_aged_receivables`** — as-of A/R aging summary; may be accrual-only. Key arguments:
  `report_date`, `customer`, `aging_method` (Current / Report_Date), `days_per_aging_period`,
  `num_periods`.
- **An A/R aging detail capability, when listed** — invoice-level customer, due date,
  transaction type, and open amount.
- **`search_invoices`** — selected invoice enrichment; **requires `start_date` and `end_date`**
  for transaction searches, which is exactly why it is not a complete aging population.
- **`read_invoice`** — one invoice in full. Key argument: `id`.
- **`search_payments`, `search_credit_memos`, `search_refund_receipts`** — reconciliation
  diagnostics. All require `start_date` and `end_date`.
- **`get_customer_balance`** — total owed per customer. Useful for a tie-out; **not an aging**.
- **`get_customer_sales`** — sales by customer, for concentration and for a credit-sales basis.
- **`search_customers` / `get_customer`** — customer master, for fuzzy-name resolution and
  contact fields.
- **`get_balance_sheet`** — the A/R control balance, for a true GL tie-out.
- **`get_general_ledger`** — transaction detail behind the A/R balance.
- **`get_profit_and_loss`** — **requires `start_date` and `end_date`**; use only for an
  approved approximate DSO proxy.
- **`get_company_info`** — company confirmation, base currency, fiscal calendar.

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this reference and the live description disagree, the live
description wins.

**Mosofin is strictly read-only. Do not call any send-reminder, create, update,
payment-application, or write-off capability.** None is exposed; do not look for one.

Envelope handling: `approval_required` → ask in chat, re-invoke the same tool with
`approved=true`. `entity_required` → ask by `display_name`, then pass that `data_source_id`.
`tool_policy_disabled` → convert to `[manual]` and record the gap. Dead connection → surface
the `reconnect_url`.

---

## Validation scenarios

*The original carried a concrete demo fixture — one company's name, customers, invoice numbers,
balances and a fixed aging date. That has been generalized here: a seed installs into **any**
workspace, and baking one workspace's data into it is the exact anti-pattern the gates exist to
prevent. **Every scenario the fixture encoded is preserved below**, as conditions and expected
behaviours. A user who wants a concrete fixture with their own figures should build it into
their **evolved** skill at Step 7, seeded through a separate approved sandbox process — this
skill must never seed records itself.*

Each row is a case the aging must handle correctly. Use them to sanity-check a run.

| # | Scenario | Expected behaviour |
|---|---|---|
| 1 | **Invoice due on the as-of date** | Days past due = 0 → **Current**, not overdue |
| 2 | **Ordinary overdue invoice, strategic customer** | Falls in its date bucket; strategic tier affects *ranking and tone*, never the bucket |
| 3 | **Invoice with a partial payment applied** | Age on the **open balance**, not the original amount; show both |
| 4 | **Disputed invoice** | Bucket normally, but **route to the dispute owner, not to collection pressure** |
| 5 | **Customer on credit hold** | Flag it; management review; never draft an ordinary reminder |
| 6 | **Chronic late payer** | Treat as a **pattern**, not automatic delinquency; acknowledge the pattern in the draft |
| 7 | **Bankruptcy / insolvency notice** | **Stop ordinary dunning.** No reminder draft. Route to professional review |
| 8 | **Unapplied credit exists for the customer** | Reconcile separately; **confirm allocation** before chasing the gross balance |
| 9 | **Invoice missing a due date** | **Do not guess a bucket.** Ask: "What due date or payment terms should I use for this invoice?" |
| 10 | **Foreign-currency invoice** | **Keep it separate** until an FX rate is supplied; never fold it into a base-currency total unlabeled |
| 11 | **Payment in flight, not yet posted** | **Do not double-count.** Confirm posting status before including or excluding |
| 12 | **Credit memo outstanding** | Reconcile separately; show gross and net totals distinctly |
| 13 | **Summary returns a single `91+` bucket** | Split it using due dates from the detail; if no detail, say it could not be split |
| 14 | **Exact DSO requested** | Require **credit sales** and the period. `DSO = A/R ÷ credit sales × days` |
| 15 | **Only total income available for DSO** | Offer the proxy **only with approval**, labeled `Approximate DSO (total-income proxy)`; it reads lower than the true figure because it includes cash sales |
| 16 | **Detail and summary totals disagree** | Re-pull unfiltered, identify reconciling rows, apply the 0.01 tolerance, **disclose any unresolved variance — never force a tie** |
| 17 | **Fuzzy customer name given** | Resolve against the customer master and **state the match** before pulling |
| 18 | **A result carries `mock: true`** | Say so; do not present fixture data as a live aging or base a collections action on it |

**Draft expectations across these scenarios:** a reminder requesting a payment date for the
ordinary overdue case; a **dispute note rather than a collection demand** for the disputed one;
a management-review note for the credit hold; a formal follow-up acknowledging the pattern for
the chronic late payer; and **no ordinary dunning draft at all** for the insolvency case. Every
draft neutral, concise, professional, addressed to the user's supplied payment contact, with
**no mention of late fees, legal action, or service suspension**, and every one marked
`REVIEW REQUIRED - NOT SENT`.

---

## Plain-language glossary

- **Accounts receivable (A/R)** — money customers owe you.
- **Aging** — a list of unpaid invoices sorted by how overdue they are.
- **Bucket** — a band of lateness (e.g. 31-60 days past due).
- **Days past due** — how long an invoice has been overdue, counted from its due date.
- **Open balance** — what is still owed after payments and credits, as opposed to the original
  invoice amount.
- **Current** — not yet overdue.
- **DSO (days sales outstanding)** — the average number of days it takes to get paid.
- **Credit sales** — sales made on credit (invoiced), as opposed to paid on the spot. The
  correct denominator for DSO.
- **Concentration** — how much of the total is owed by a small number of customers; a risk
  measure.
- **Weighted average days past due** — the average lateness, weighted by how much money is at
  stake.
- **Dunning** — the routine sequence of payment reminders.
- **Credit hold** — deliberately pausing further service or credit for a customer.
- **Unapplied credit** — a credit sitting on a customer's account, not yet matched to an
  invoice.
- **Payment in flight** — money sent but not yet recorded or cleared.
- **Credit memo** — a document reducing what a customer owes.
- **Insolvency / bankruptcy** — a formal process when a customer cannot pay their debts; it
  changes what you are legally allowed to do.
- **Accrual basis** — income recorded when earned. **Cash basis** — recorded when paid.
- **GL control balance** — the single A/R total in the general ledger that the detail must
  agree with.
- **Tie-out** — the proof that two sets of numbers agree.
- **Provenance** — the record of exactly which call produced a figure and when.

---

## Edge Cases

*Drawn from the original's rules, guardrails and fixture conditions, plus the ones Mosofin's
workspace model introduces. The full scenario list is in Validation scenarios above.*

**Cash basis requested but the connector's aging is accrual-only** — explain the limitation and
**ask whether accrual basis is acceptable before reading data**. Do not read first and caveat
after; the user may not want the accrual view at all.

**No A/R detail capability is listed** — do **not** treat an invoice search as a complete
historical population. Its recent-date default omits exactly the old unpaid invoices
collections exists to chase. Request the smallest equivalent export and disclose the gap.

**No independent summary to tie to** — derive totals from detail and **disclose that there was
no independent tie-out**. A reconciliation against itself is not a reconciliation.

**Unresolved variance between detail and summary** — disclose it with the amount and what you
checked. **Never force a tie.**

**A customer balance report is offered as an aging** — it is not. One total per customer with
no buckets cannot answer what is overdue. Mark the task `[manual]` or reconstruct from
invoice-level data and label the reconstruction.

**Multiple currencies** — preserve each separately. Ask before presenting any consolidated
total, and never present one unlabeled.

**Fuzzy customer name** — resolve against the customer master and state the match. Two
customers with similar names are common, and chasing the wrong one is a real cost.

**Disputes, credit holds, tiers and payment history are not in the books** — *Mosofin-specific,
and the main `[manual]` cluster here*. **Never infer them.** An invoice is not disputed because
it is old, and a customer is not on hold because they stopped paying. Ask only when the
requested output needs them.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say whose receivables are therefore missing. Show the `reconnect_url`, and **do not substitute
CSVs or guessed numbers while the user is asking for live data**.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
aging's shape but must never drive a collections action against a real, named customer.

**The same customer appears in several connected company files** — *Mosofin-specific*. Report
per entity, then compare. Coordinate before sending three separate reminders, and check whether
the invoice is disputed at one entity while being chased at another.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag
it. Never apply it to a different entity; never drop it silently.

**A stored strategic tier or credit hold is stale** — *Mosofin-specific*. A hold that has been
resolved will otherwise suppress legitimate collections forever. Re-confirm standing flags on
each run.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---

## Completion checks

- **Mosofin workspace and company file are confirmed before reads**, by name, with an explicit
  user yes
- **Every call carries the current workspace and company scope** — `data_source_id` on every
  call, including retries
- **Response provenance and `mock` status are checked** and reported
- **A/R Detail is the invoice population and is reconciled to Summary, or the missing tie-out
  is disclosed**
- **Connector-supplied, calculated, user-supplied, and unavailable fields are distinguished**
  in every output
- **Unsupported fields are requested only when material**
- **No data was changed and no reminder was sent**

**Mosofin additions:**

- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- Every task in Steps 1–5 carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool
  used, and that tool's policy, in the coverage sheet
- Every `[manual]` item names the tool that would have covered it and what the user must
  supply — no task is silently dropped
- **No tool name was invented**; every one came from the Gate 2 catalog
- A customer balance report was never presented as an aging; any reconstructed aging is labeled
  as reconstructed and tied back
- Aging totals use **open balance**, not original amount
- Each currency is preserved separately; no unlabeled consolidated total
- DSO states its denominator; any proxy is labeled `Approximate DSO (total-income proxy)`
- Every draft is marked `REVIEW REQUIRED - NOT SENT` and contains no invented dispute, hold,
  promise, fee, suspension, or legal threat
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- No customer contact details, balances, or draft correspondence are persisted into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
