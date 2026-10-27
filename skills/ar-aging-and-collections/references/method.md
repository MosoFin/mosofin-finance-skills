<!-- ar-aging-and-collections · method.md · read for: Stages 3–6 — sections 1–2 at Stage 3, 3–5 at Stage 4, 6 at Stage 5, 7 at Stage 6, plus the entity and validation scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- 1. Pull and confirm
- 2. Normalize
- 3. Reconcile
- 4. Ask for material gaps
- 5. Analyze
- 6. Deliver
- 7. Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios
- Validation scenarios


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
   Step 3. On both the summary and the detail, pass the as-of date **and `aging_method =
   Report_Date`** (aged to the as-of date, not to today) — a month-end aging run weeks later
   is otherwise aged weeks too old.
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
**[auto]** where both capabilities exist — **and by bucket, not only by customer total.** A
bucket-level difference with matching totals means the report was aged to a different date;
re-pull before going further. The `Days Past Due` recomputed in Step 2 from due dates is the
authority over the report's own bucket labels.

- **Combine 91-120 and Over 120 before comparing** with a summary's single `91+` bucket.
- **If totals differ, pull detail again without invoice-only filtering** and identify the
  reconciling rows — credits, payments, journal entries, or other transaction types.
- **Use a 0.01 currency-unit tolerance.**
- **Disclose unresolved variance; never force a tie.**
- **Call this a summary-to-detail reconciliation unless a GL control balance was separately
  tested.** The **general ledger control balance** is the single A/R total in the books
  (*`get_balance_sheet`*, **[auto]**); testing against it is a stronger check and deserves the
  stronger name only when it was actually done.
- **Then tie to the A/R control account.** Pull the A/R balance from the balance sheet as of
  the same date and on the same basis (*`get_balance_sheet`*, **[auto]**; upload path: the
  trial balance). Agree the **net** aging total to it at 0.01, listing each A/R account
  separately. Any difference goes to Exceptions with an amount and a likely cause (journal
  entry to A/R, a second A/R account, FX). Only when this agrees may the output say
  "reconciled to the general ledger".

## 4. Ask for material gaps

After pulling the data, **ask one consolidated question** — only for missing inputs that change
the requested output. **Core aging does not require dispute flags, payment history, DSO, or
collection policy; omit and disclose these when not requested.**

Example:

> The connected books supplied the aging and balances but not reliable dispute, credit-hold,
> strategic-tier, or collection-policy fields. Please provide any relevant flags and approved
> escalation wording. For exact DSO, also provide credit sales and the measurement period.

## 5. Analyze

Calculate when supported — **[auto]** arithmetic over the pulled data. Compute Total A/R,
overdue %, over-90 and DSO on the **net** open balance that ties to the summary; show gross
invoices and unapplied credits / payments as separate lines above it. Customers with a **net
credit balance** go to Exceptions as "credit balance — refund or reclassify" (it is owed to
the customer, not a receivable) and are left out of the collection plan and concentration
ranking. The Collection Plan ranks on each customer's balance net of unapplied items.

- **Total A/R, overdue total, overdue percentage, and amount / percentage over 90 days**
- **Weighted average days past due** — weighting by open balance and **flooring current
  (not-yet-due) invoices at zero**, so invoices not yet due do not offset late ones
- **Top-five customer concentration** — how much of the total is owed by the largest five.
  Concentration is a risk measure: one customer at 40% of A/R is a different business from
  fifty at 2% each
- **`DSO = ending A/R / credit sales for period × days in period`** — **days sales
  outstanding**, the average number of days it takes to get paid. **Credit sales** on the
  Mosofin path = invoices dated in the period less credit memos dated in the period
  (*`search_invoices`*, *`search_credit_memos`* with the period dates) — **[auto]**; show the
  derivation. Upload path: ask for an Invoice List or Sales by Customer **filtered to
  transaction type Invoice** for the period

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
   excluded one and why, and whether any figure rests on `mock` data; and "Prepared by (agent
   run, date) · Reviewed by ____ · Date ____"
2. **Aging Summary** — customers, buckets, totals, metrics, next action
3. **Aging Detail** — normalized invoice rows
4. **Collection Plan** — ranking, reason, owner / status blanks, next action
5. **Drafts** — review-only reminder text, every one marked `REVIEW REQUIRED - NOT SENT`
6. **Exceptions** — credits, net credit balances, missing dates / currency, disputes, and
   reconciliation variance, with columns Item | Amount | Cause | Proposed action | Owner | Due
7. **Coverage — NEW, Mosofin-specific** — one row per task in Steps 1–5:

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

Rows for disputes, credit holds, strategic tier and payment history will read `manual` with
their gaps named. That is the correct, expected result — not a defect.

If creating XLSX, use the available spreadsheet skill and name it
`QuickBooks_AR_Aging_Collections_YYYY-MM-DD.xlsx` — or, where the datasource is not
QuickBooks, `[Datasource]_AR_Aging_Collections_YYYY-MM-DD.xlsx`. In a multi-entity run,
include the entity: `…_AR_Aging_Collections_YYYY-MM-DD_[EntityDisplayName].xlsx`, plus one
combined file. Every file states which datasource and `display_name` it covers.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

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
  and routed to an intercompany reconciliation.

Capability is checked **per entity** at Gate 2: the aging detail capability may be listed for
one company file and not its sibling, so the same task can be `[auto]` for one and `[manual]`
for another. The coverage sheet shows this per entity.

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
