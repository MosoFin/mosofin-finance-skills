<!-- recurring-transaction-builder · method.md · read for: Stages 1 and 3–6 — the verdicts, the Inputs table, Steps 1–6 (with 2b–2d and 5b), seed to evolved, anti-patterns. Edit here, not in SKILL.md. -->

## Contents

- How to read the verdicts
- Inputs
- Workflow
- Seed to evolved: what happens on the first real run
- Anti-patterns


## How to read the verdicts

This skill uses three, with one distinction worth drawing:

- **`[auto]`** — Mosofin does this unattended. **Two sub-kinds**, and Sheet 5 distinguishes them:
  - **`[auto: computed]`** — pure calculation from what the user supplied. Needs no ledger. Works even with no datasource connected.
  - **`[auto: read]`** — requires a live read of the workspace. Without a connection, the same check runs on the user's uploaded exports, labelled user-supplied.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` (**reads only — never for a write**) and the `data_source_id`.
- **`[manual]`** — not on this surface, or not a machine's to do. **The step stays. The user performs it.**

**Nothing here is posted, created or scheduled.** Every occurrence is a proposal for a human to load.

---

## Inputs

All twelve preserved.

| Input | Format | Required | Mosofin source | Verdict |
|-------|--------|----------|----------------|---------|
| Transaction type | Recurring JE / Bill / Invoice / Subscription | **Required** | Not in the books | `[manual]` |
| Counterparty | Vendor or customer name | Required for AP/AR | **Verifiable** against the vendor and customer lists | `[manual]` to state, `[auto: read]` to verify |
| Amount and currency | Per occurrence | **Required** | Not in the books for a *new* schedule; **readable for an existing charge** | `[manual]`, or `[auto: read]` for discovery |
| Start date | First occurrence | **Required** | Not in the books | `[manual]` |
| End date or number of occurrences | One of the two | **Required** | Not in the books | `[manual]` |
| Cadence | Daily / Weekly / Bi-weekly / Semi-monthly / Monthly / Quarterly / Semi-annually / Annually / Custom | **Required** | Not in the books; **inferable from posting history** for an existing charge | `[manual]`, `[auto: read]` to infer |
| Day-of-period rule | First day / Last day / Specific day / Last business day / N business days into period | **Required** | Not in the books | `[manual]` |
| Coding and posting template | GL accounts for a JE; account or item for a bill; product / service item for an invoice (on QuickBooks Online an invoice line takes an item mapped to an income account) | **Required** | **Verifiable against the live chart and item list** — see Step 2b | `[manual]` to specify, `[auto: read]` to verify |
| Payment terms | E.g. Net 30 — drives the due date | **Required for bills and invoices** | **Verifiable** against the configured terms | `[manual]` to specify, `[auto: read]` to verify |
| Tax code | Per the user's jurisdiction and tax setup | Required if tax applies | **Verifiable** against the configured tax codes | `[manual]` to specify, `[auto: read]` to verify |
| Description / memo template | Text with variables `{month}`, `{year}` | Recommended | Not in the books | `[manual]` to supply, `[auto: computed]` to resolve |
| Escalation rule | Fixed / Annual % / CPI-linked / Step-up at date | Optional | **Not in the books — it is in the contract.** See Step 4. | `[manual]` |
| Stop / pause conditions | Termination clauses | Optional | In the contract | `[manual]` |
| Partial first / last period treatment | Pro-rate on days, or per the contract | Required when start or end is mid-period | Not in the books | `[manual]` |
| Holiday calendar and roll direction | Jurisdiction calendar; forward or backward | Required for business-day rules | Not in the books — a client fact | `[manual]` |
| Closed-through (lock) date | Date | Required when any occurrence is backdated | Not always readable — ask | `[manual]` |

---

## Workflow

### Step 1 — Identify the recurring transaction type

`[manual]`. All four preserved.

| Type | Use case | Note |
|------|----------|------|
| **Recurring JE** | Depreciation, prepaid amortisation, accrual reversals, allocations | The template comes from `journal-entry-builder`. See also `prepaid-amortization-schedule` and `fixed-asset-register-and-depreciation`, both of which generate exactly this shape. |
| **Recurring Bill** | Monthly rent, SaaS subscriptions, vendor retainers | The duplicate check in Step 2c matters most here — a duplicated recurring bill is a duplicated payment. |
| **Recurring Invoice** | Subscription billing, retainer billing, lease income | A duplicated recurring invoice is a customer billed twice, which is worse commercially than it is financially. |
| **Subscription Schedule** | Customer-facing SaaS or service subscription with billing cycles | Carries service-period dates; see Step 5. |

---

### Step 2 — Validate the schedule

The original's four confirmations, all preserved, all `[auto: computed]`:

- **Start date is reasonable** — not in the distant past unless deliberately backfilling. **Ask the closed-through (lock) date**, and mark any occurrence on or before it **"Closed period — do not load without accountant approval"** — loading it would change figures already issued
- **End date or count is specified.** **Open-ended recurrences require management approval — flag if the user wants one truly indefinite.** Preserved with emphasis: an unbounded recurring payment is a standing instruction with no review date, and those are how subscriptions outlive the thing they paid for.
- **Cadence is one of the supported intervals**
- **Day-of-period rule is unambiguous** — "1st of month" or "last business day", not "monthly"

> **For business-day-aware schedules, identify the holiday calendar to use (the entity's jurisdiction). If not provided, ask. Do not pick a default.**

Preserved exactly, and it is the same discipline that applies to tax rates: **do not supply a value that varies by jurisdiction and changes over time.** A holiday calendar is not in the accounting system either — it is a client fact, so ask once and persist it (Gate 3).

---

### Step 2b — Validate against the live chart *(Mosofin addition)*

`[auto: read]`. One batched read, and it catches a class of failure the original cannot see at all.

The original builds a schedule around accounts, counterparties and tax codes that the **user names**. It has no way to check any of them are real. A connected workspace does:

| Check | Why it matters |
|---|---|
| **Every GL account in the template exists** | A recurring JE pointed at a deleted account fails on every run, or posts to suspense. **Every month. Silently.** |
| **Every account is active**, not archived or made inactive | Same failure, and harder to spot, because the account still appears in old reports. |
| **Every account is of the right type** — an expense line pointing at a balance sheet account, or a debit template pointing at an income account | Catches transposed account numbers, which look plausible and post cleanly to the wrong place. |
| **The counterparty exists** in the vendor or customer list, spelled as given | A near-miss creates a *second* vendor record. Then the payments split across two, the statement never reconciles, and nobody knows why. See `vendor-statement-reconciliation`. |
| **The tax code exists** and is active | A missing tax code either blocks the load or posts the transaction untaxed. |
| **The item exists and is active**, with its income or expense account (bills and invoices coded by item) | An invoice line validated against a "revenue account" checks the wrong object; the item decides where the income lands. |
| **The account is not one the client has flagged as closed to posting** | Some charts mark control accounts as no-post; a template aimed at one will fail. |

**Why this check earns its place.** Validating a one-off entry saves one correction. **Validating a recurring template saves a monthly error that compounds until someone happens to look.** The whole point of automation is that nobody looks — which is exactly why the thing being automated has to be right before it starts.

---

### Step 2c — Check whether it already exists *(Mosofin addition)*

`[auto: read]`, and this is the check most likely to prevent real money going out of the door.

**First, read the platform's own recurring-template list** (QuickBooks recurring transactions; Xero repeating invoices and bills) where the Gate 2 catalog exposes a read for it; otherwise ask the user for the Recurring Template List export. Match on counterparty, amount and next date. A template set up last week, set to start next month, or set as a reminder or draft has no postings yet and passes a history-only check.

**Then read the ledger for what is already recurring.** For the counterparty in question, look at the trailing twelve to twenty-four months:

- Is there **already a charge of this amount, from this counterparty, on this cadence**? If so, a recurring template may already exist and this schedule would duplicate it.
- Is there a **similar but not identical** charge — same vendor, similar amount, similar timing? That is either the same arrangement with an escalation already applied, or a second arrangement. Ask which.
- Does the vendor have **two records** with similar names? Then some of the history is under one and some under the other, and the duplicate check needs both.

**A duplicated recurring bill is a duplicated payment, repeated monthly, to a real supplier who will not necessarily mention it.** A duplicated recurring invoice is a customer billed twice, which costs less and damages more. Both are prevented by one read before the schedule is built rather than a reconciliation six months after.

---

### Step 2d — Find what should be recurring but is not *(Mosofin addition)*

`[auto: read]`. The inverse of the skill's usual job, and it changes what the skill is for.

The original waits to be told what to automate. **Ask the ledger instead.** Scan the trailing twelve months for the signature of a manually repeated transaction:

- the **same counterparty**
- a **near-identical amount**
- a **regular interval** — monthly, quarterly
- **entered by hand**, one at a time, every period

That pattern is an automation candidate, and the list is usually longer than anyone expects. It is also self-prioritising: rank by frequency times effort, and the top of the list is where the client's month-end time is actually going.

**Two cautions on the output.**

**Do not present the list as a plan.** Some of those charges *should* be entered by hand — a variable amount that only looks stable, a payment that genuinely warrants a look each month, a vendor under review. Repetition is not the same as suitability for automation, and the person who has been keying it every month may have a reason.

**And an amount that has been identical for fourteen months may not stay identical.** See the near-substitute note above: the posting history is not the contract. Check the agreement before automating a figure into the future.

---

### Step 3 — Generate the occurrences

`[auto: computed]`, in full. This needs no ledger and works with no datasource connected.

One row per future occurrence, with all six fields preserved:

- **Occurrence number** (1, 2, 3, …)
- **Scheduled date**
- **Amount**, with the escalation rule applied
- **Period covered** — for accruals and subscriptions
- **Memo**, with variables resolved: `{month}`, `{year}`, `{quarter}` substituted
- **All other fields from the template**

**Calendar edge cases**, all three preserved and all `[auto: computed]`:

- **Monthly on the 31st**: roll to the last day of months with fewer than 31 days. Note that this is a **roll**, not a skip — February gets an occurrence on the 28th or 29th, not no occurrence at all. Skipping short months is a real bug and it silently drops one or two occurrences a year.
- **Semi-monthly** — the 15th and the last day, say: handle month-end shifts.
- **Weekday-only rules**: roll to the nearest prior or next business day **per policy** — the policy from Gate 3, applied consistently in one direction throughout. Never forward in one month and backward in the next; that produces a schedule nobody can predict and a reconciliation nobody can complete.
- **A roll never moves an occurrence out of the period it belongs to.** For period-end JEs (accruals, depreciation, amortisation), keep the calendar month-end date; business-day rules apply to bills, invoices and payments. Where a forward roll would cross a month end, roll back for that occurrence and note it in the memo.

`[auto: read]` addition — **a sanity check against the ledger's own history.** Where the same charge has been posted before, compare the generated dates against the dates it has actually landed on historically. A schedule that says the 1st while the charge has consistently hit on the 3rd is either a roll policy that does not match reality or a template that was going to be wrong. Cheap to check, and it is checking the design against observed behaviour rather than against itself.

---

### Step 4 — Apply escalation

`[auto: computed]` for the arithmetic. `[manual]` for the rule, always.

All four preserved:

- **Fixed**: the same amount every occurrence.
- **Annual % increase**: bump the amount at each anniversary. Be explicit about which anniversary — the contract date or the calendar year — and about whether the increase compounds.
- **CPI / index-linked**: **ask the user for the index source and the inflation assumption. Do not assume a rate.**
- **Step-up at date**: change the amount on specified dates.

> **Document the escalation logic in each row's memo.**

Preserved, and it is what makes a schedule auditable a year later: the row itself says why its amount differs from the row above it.

**The CPI rule deserves the same emphasis as the holiday calendar**, and for the same reason. An inflation assumption is a forecast that varies by jurisdiction, by index, and by month. **Nothing in this file supplies one and nothing persisted from a prior run may supply one either** — persist the *index source* the client uses, never the *rate*. This is the identical discipline that applies to tax rates and to covenant definitions.

`[auto: read]` supporting observation: where the charge has history, **whether escalations have actually been applied in the past, and when.** A rent that has not moved in four years, under a lease with an annual review, is either a review that was never applied or a lease whose terms differ from what is being assumed. Both are worth raising before building three more years on the assumption.

---

### Step 5 — Construct the underlying transaction template

`[auto: computed]` to construct. **`[manual]` to create in the accounting system** — that is a write, and there is no write path.

All four preserved:

**Recurring JE** — hand off to `journal-entry-builder`. The same template for every occurrence, with date and memo variables substituted. Validated against the live chart at Step 2b.

**Recurring Bill** (vendor) — a bill record per occurrence: vendor, invoice date, due date (from the payment terms), line items, GL coding or item, tax code. Vendor, item and tax code verified at Step 2b.

**Recurring Invoice** (customer) — an invoice record per occurrence: customer, invoice date, due date (from the payment terms), line items with their product / service item, tax code. Where the invoice covers a service period beyond the invoice month, code the line to **Deferred Revenue** (or the platform's deferred-revenue item) and add a release schedule by service period; code to revenue only when the service period falls within the posting month.

**Subscription Schedule** — **include the service period dates on each occurrence.** The original notes why and it is worth restating: **the service period, not the invoice date, drives deferred revenue.** A subscription invoiced annually in advance produces twelve months of deferred revenue on the invoice date, released one month at a time, and a schedule that omits the period dates cannot support that. Recognising the deferred revenue is a revenue-recognition task.

**And the handoff, stated plainly.** What Mosofin produces is a **specification**: every field, validated, with every occurrence computed. What creates the recurrence is a person entering that specification into the accounting system's own recurring-transaction feature, or loading the occurrences as a batch.

**The specification is not the thing.** Say so on the file. See Step 6.

---

### Step 5b — Audit whether the template actually ran *(Mosofin addition)*

`[auto: read]`, and this is the part of the skill that pays off every month rather than once.

**Recurring entries stop.** They stop when an account is renamed, when a template hits its end date, when someone deactivates it during a clean-up, when a vendor record is merged. **The failure is silent** — nothing errors, an entry simply does not appear — and it is typically discovered at a year end, eight months late, by which point eight months of close files are wrong.

So, for every recurring arrangement known to the workspace — on the first run, seed the register from the platform's recurring-template list (Step 2c):

- **Did an occurrence post in each expected period?** List the periods where none did.
- **Was the amount what the schedule expected?** A changed amount is either an escalation that was applied without updating the schedule, or a manual override.
- **Did it post to the expected accounts?**
- **For accrual-type recurrences: did the reversal post?** See Sheet 4 below — this one is worth its own paragraph.

`prepaid-amortization-schedule` relies on exactly this check for its Test 0a, and the two skills should give the same answer. **This is the ongoing job**: the user sets the automation up once; Mosofin confirms it is still running, every period, at the cost of one query.

---

### Step 6 — Output

An `.xlsx` workpaper. All four of the original's sheets, plus two additions.

**Sheet 1: Schedule Summary**
- Type, counterparty, start, end, cadence
- Total occurrences, total amount, total tax
- Escalation rule
- Posting cadence
- Stop conditions

**Mosofin additions to the header of this sheet**, and they belong at the top where they cannot be missed:

- **NOT POSTED — every occurrence in this file is Pending.**
- **Validation status**: validated against `[company display_name]`'s chart on `[date]`, or against the uploaded files (labelled user-supplied); **NOT VALIDATED** only for a check whose data was neither read nor supplied.
- **Fixture flag**, if any read returned `mock: true`.

**Sheet 2: Occurrence Schedule**
| # | Scheduled Date | Period From | Period To | Amount | Tax | Total | Memo | Status (Pending / Posted / Skipped) |

**The Status column is the control against double-loading**, not a formality. Every row starts **Pending**. After the batch is loaded, it is reconciled back against the ledger and the statuses are updated from what actually posted — not from what was intended.

**Sheet 3: Per-Occurrence JE / Bill / Invoice Detail**
Each occurrence expanded with full posting lines, formatted for the target system. Add a **Validated** column per line, carrying the Step 2b result for that account or code.

**Sheet 4: Reversal Schedule** (accruals only)
Where the recurring JE is an accrual, the corresponding reversing entries on the first day of each following period.

**`[auto: read]` addition, and it is a strong one: check that prior reversals actually posted.** An accrual that was raised and never reversed is **counted twice** — once in the accrual and once when the real invoice arrives — and it persists until somebody analyses the account. Reading accrual entries against their expected reversals is one query and it finds a genuinely material error. See `journal-entry-review` and `month-end-close-checklist`.

**Sheet 5: Validation and Discovery** *(Mosofin addition)*
Three blocks, all `[auto: read]`:

- **Validation results** from Step 2b — every account, counterparty and tax code, with pass or fail
- **Duplicate check** from Step 2c — existing recurring charges matching this one
- **Automation candidates** from Step 2d — manually repeated transactions, ranked, **presented as candidates and not as a plan**

**Sheet 6: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet, including the `[auto: computed]` versus `[auto: read]` split.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

File naming: `[Counterparty or Description]_RecurringSchedule_[YYYY-MM-DD].xlsx`

The entity `display_name` goes in the file name and on every sheet — a schedule is validated against one chart and must not be loaded into another book.

---

## Seed to evolved: what happens on the first real run

**What must never be frozen into a seed:** the capability map, read fresh at Gate 2 — and, in this skill's own domain, **any rate**: no inflation assumption, no tax rate, no holiday calendar baked into the file.

**What is worth persisting after the first run:**

1. **The holiday calendar and the roll policy.** Standing client facts, asked once, used forever.
2. **The CPI index source** the client uses — never the rate.
3. **The chart mapping**: which accounts these recurring entries hit, validated, so Step 2b starts from a known-good set.
4. **The register of recurring arrangements** — what exists, its cadence, its expected amount, its accounts. **This is the file that makes Step 5b's run-audit possible**, and without it there is nothing to audit against.
5. **The pro-ration convention** and the open-ended horizon the client prefers.
6. **Automation candidates already reviewed and declined**, with the reason. Re-proposing the same automation every quarter, after the client has explained why it is entered by hand, is how a tool becomes irritating.
7. **Escalation terms once obtained**, since they come from contracts and are expensive to gather.
8. **Any observed policy that differed from this file's defaults.**

**Ask before saving anything.** Only after the user has **seen the results**, ask — explicitly, at that point, not earlier — whether to save these as their own customized version. A general "yes, go ahead" from earlier does not count. Decline, or no answer, and nothing is written.

Persist through `create_skill`, scoped to the workspace. **Client facts belong in a client-scoped skill, never back in the seed.**

**The evolved version's most valuable output is not a new schedule. It is the monthly answer to "did everything that should have run, run?"** — which is a report the client currently gets from nobody.

---

## Anti-patterns

- **Implying that automation now exists** because a schedule was produced. The schedule is a specification; the template is a thing inside the accounting system, created by a person.
- **Saying "ready to post" without saying "not posted."** Every occurrence is Pending.
- **Delivering a loadable file with no double-load control.** Twenty-four rent bills loaded twice is real money.
- **Building a schedule without checking whether the recurrence already exists.** One read prevents a duplicated monthly payment.
- **Validating nothing and looking exactly as if you had.** Put the validation status in the header.
- **Pointing a template at an account nobody checked exists.** It will fail every month, quietly.
- **Creating a second vendor record** through a near-miss on the name.
- **Assuming a rate** — inflation, tax, or otherwise. The original forbids it; so does this file.
- **Defaulting a holiday calendar.** Ask.
- **Rolling forward one month and backward the next.**
- **Skipping February** on a monthly-on-the-31st schedule instead of rolling it.
- **Averaging a variable component into a fixed schedule.** That is an undecided accrual that will drift.
- **Converting occurrences to functional currency** at today's rate. The rate at posting will be different.
- **Extrapolating a schedule from posting history without reading the contract.** Fourteen identical months do not rule out a step-up in month fifteen.
- **Presenting automation candidates as a plan.** Some things are keyed by hand on purpose.
- **Saying "posted", "created" or "scheduled".** The gateway reads.

---
