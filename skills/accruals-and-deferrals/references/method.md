<!-- accruals-and-deferrals · method.md · read for: Stages 3–6 — Steps 0–9, the accruals and deferrals themselves, and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Identify accrual categories
- Step 2 — Identify deferral categories
- Step 3 — Compute each accrual / deferral
- Step 4 — Construct the JEs (hand off to journal-entry-builder)
- Step 5 — Reversing entries
- Step 6 — Roll-forward by category
- Step 7 — Materiality
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Everything below is the professional procedure, unchanged in step count, order, or
substance. What has been added is the plain-language wording, the `[auto]` / `[gated]` /
`[manual]` verdict per task, and the tool that typically evidences it.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence. Many accruals here are inherently manual — a bonus pool lives in a
compensation committee's decision, not in the ledger — and saying so is the honest answer.

Tool names in *italics* are the **typical** evidence tool. Resolve the real name and its
policy from your Gate 2 catalog — the italic name is a pointer, not a promise.

## Step 0 — Fetch the evidence (grounding)

Before Step 1, pull the reads the capability map marked `[auto]` or `[gated]`. **Batch
independent reads into one message** — the chart of accounts, the trial balance, the prior
period's journal entries, and a vendor spend report do not depend on each other. Never
serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — the chart of accounts, to locate the accrued-liability,
  accrued-revenue and deferred-revenue accounts — usually **[auto]**
- *`get_trial_balance`* — every account's balance at period end, the starting point for each
  roll-forward — usually **[auto]**
- *`get_balance_sheet`* — accrued liabilities and deferred revenue as presented — usually
  **[auto]**
- *`get_general_ledger`* — the transaction-level detail behind those balances — usually
  **[auto]**
- *`search_journal_entries`* — last period's accruals and their reversals — usually **[auto]**
- *`get_profit_and_loss`* — expense run-rates used to sanity-check estimates — usually
  **[auto]**
- *`get_company_info`* — fiscal calendar and base currency — usually **[auto]**

Handle the envelopes you get back:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true` (**reads only — never for a write**).
- `entity_required` → more than one company file is live and you passed none. Ask by
  `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error itself; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag** on every result. `mock: true` is fixture data — it can show the
shape of a schedule but **cannot support a booked entry**. If any proposed accrual rests on
mock data, say so at the top and do not present the entry as ready to post.

## Step 1 — Identify accrual categories

Work out what already happened in the period that the books haven't caught yet.

Common accruals:

**Compensation-related** — **[manual]** for the amounts (pay rates, bonus plans and accrual
policies generally live in payroll or HR systems, not the ledger), **[auto]** for the
population and for what has already been booked (*`search_employees`*,
*`get_general_ledger`* on the payroll accounts):

- **Bonus accrual** — annual bonuses earned through period-end but not yet paid
- **Commission accrual** — sales commissions earned but not yet paid
- **Vacation / PTO accrual** — vacation ("paid time off") employees have earned but not used;
  you owe it whether or not they take it
- **Severance / restructuring accrual**
- **Payroll accrual for partial pay periods crossing the cutoff** — the days worked before
  period-end in a pay period that pays out after it

**Interest-related** — **[auto]** for the loan balance carried on the balance sheet and for
interest already posted (*`get_balance_sheet`*, *`get_general_ledger`*, *`search_accounts`*);
**[manual]** for the rate, the day-count convention and the last payment date, which come
from the loan agreement:

- Interest accrued on loans where the entity is the **borrower**
- Interest accrued on loans / investments where the entity is the **lender**
- Interest on overdue A/R or A/P, if applicable

**Service / utility** — **[auto]**: the last invoice and the historical run-rate are in the
books (*`search_bills`*, *`get_vendor_expenses`*, *`get_general_ledger`*):

- **Utilities** (electricity, gas, water) — service received through period-end, bill arrives
  later
- **Internet / telecom** — same pattern
- **Cleaning, security, maintenance** — typically billed monthly **in arrears** (after the
  service, not before)

**Revenue accruals** (earned but not invoiced) — **[auto]** where the work is tracked in the
connected books (*`search_time_activities`* for unbilled hours, *`search_estimates`* for
contracted work, *`search_invoices`* to see what has already been billed), **[manual]**
(judgment) where the earned fraction is a judgment:

- Service performed but invoice not yet issued
- Subscription services consumed but billed in arrears
- Royalty income earned but not received
- Interest income from investments

**Other** — **[gated/manual]**: the population is visible (*`get_vendor_expenses`*,
*`search_bills`*), the estimate of unbilled work is not:

- **Audit fees** — services rendered through period-end, invoice may arrive after close
- **Legal fees** — services rendered, invoice may not arrive
- **Professional fees** in general
- **Tax accruals** — income tax, property tax accrued (basis in Step 3)

## Step 2 — Identify deferral categories

Now the mirror image: money already in hand that you haven't earned yet.

Common deferrals:

**Deferred revenue (a liability — you owe the customer service, not money)** — **[auto]** for
the balance and the underlying receipts (*`get_balance_sheet`*, *`search_accounts`*,
*`search_payments`*, *`search_deposits`*, *`search_sales_receipts`*), **[manual/gated]** for
the service period each receipt covers, which comes from the contract:

- Customer payments received **in advance** of service delivery
- Annual subscription paid upfront, recognised over the year
- Pre-paid **retainers** from customers (money held against future work)
- **Gift cards** sold and not yet redeemed — and not yet **escheated** (handed to the state
  as unclaimed property)
- **Loyalty points liability** — points customers have earned and can still spend

**Deferred expense (an asset)** — these are **prepaid expenses** (you paid ahead for
something you'll consume later); handled by `prepaid-amortization-schedule`. Mentioned here
for completeness so the category isn't lost.

## Step 3 — Compute each accrual / deferral

For each item, use the relevant basis. The arithmetic is **[auto]** once the inputs exist;
the verdict below is about where the *inputs* come from.

**Bonus accrual** — **[manual]** inputs:
- Cumulative bonus accrual = **management's best estimate of the year's payout** (the amount
  expected to be paid, not discounted by its likelihood — ASC 450/710, IAS 19) × (months
  elapsed in the bonus year ÷ 12), or per the bonus plan's own earning pattern; the estimate's
  owner is named
- This period's entry = that figure − the balance already accrued
- Apply **employer-side payroll taxes** on the same basis

**Commission accrual** — **[auto]** for closed deals through period-end, which are visible in
the books (*`search_invoices`*, *`get_customer_sales`*); **[manual]** for the plan's terms:
- Commissions earned per the commission plan on deals closed through period-end
- Track whether commissions are payable on **booking** (deal signed), **billing** (invoice
  issued), or **collection** (cash received) — the plan decides, and it changes the amount

**Vacation / PTO accrual** — **[manual]**:
- For each employee: **unused vacation balance at period end** (earned − taken, after any cap
  or forfeiture) × current pay rate, plus employer taxes — ASC 710-10-25 accrues rights earned
  and not yet used
- Some entities have payroll software compute this automatically; others track it separately
- The liability typically also includes the payroll taxes due when the vacation is paid out

**Interest accrual** — balance **[auto]**, terms **[manual]**:
- For loans with monthly interest payments, accrue interest from the last payment date to
  period end:
  - `Interest = Principal × Annual Rate × (Days since last interest period ÷ Days in year)`
  - Use the **day-count convention** specified in the loan — the agreed rule for counting
    days, e.g. actual/365, actual/360, or 30/360 (which pretends every month has 30 days).
    Different conventions give different answers on the same loan.
- For loans with periodic **compounding** (interest charged on unpaid interest), compute per
  the compounding schedule

**Utility / service accrual** — **[auto]**: all three bases can be derived from the connected
books:
- Estimate the period-end portion using either:
  - The last invoice's daily rate × days through period-end, less days already invoiced
  - The contracted monthly amount × the proportion of days
  - The prior year's same period — less reliable, but used when there is no other data

**Revenue accrual (services performed)** — **[auto/gated]**:
- **Time-and-materials** engagements (billed by hours worked): unbilled hours × rate —
  *`search_time_activities`* gives the hours where time is tracked in the connected books
- **Milestone** projects: progress earned through period-end × contract value (per
  the revenue recognition standard)
- **Subscription** services billed in arrears: pro-rated revenue

**Audit / legal / professional fee accrual** — **[manual]**:
- Estimate based on engagement letters and work done
- For ongoing matters, ask the provider how much work has been done

**Payroll accrual (partial pay period)** — **[manual]** unless the payroll platform is
connected:
- Gross pay for the pay period straddling period end × (workdays in the period up to period
  end ÷ workdays in the pay period), plus employer taxes and benefits
- Source: the payroll register for that pay run and the pay calendar

**Tax accruals** — **[manual]**:
- Property tax: the annual assessment ÷ 12 per month, from the assessment notice
- Income tax: take the provision figure from the user or the tax preparer; computing it
  (ASC 740 / IAS 12) is out of scope

## Step 4 — Construct the JEs (hand off to journal-entry-builder)

A **journal entry (JE)** is the two-sided record that moves the numbers. `DR` is a debit and
`CR` a credit; every entry balances. `BS` means the balance sheet. **Mosofin does not post
these** — it drafts them for a human.

**Accrual (expense)**:
```
DR  Expense account                                  $accrual amount
    CR  Accrued Liabilities (BS, per user's COA)        $accrual amount
Memo: Accrue [category] for [period]

Compensation accruals only:
DR  Payroll tax expense                              $employer tax
    CR  Accrued payroll taxes (BS)                      $employer tax
```

Where the stated policy is auto-reverse, a **reversing** accrual reverses on the first day of
the next period; under a direct-settlement policy no reversal is drafted. Cumulative accruals
(Step 6) are adjusted to the computed balance instead.

**Accrual (revenue)**:
```
DR  Accrued Revenue / Unbilled Receivables           $accrual amount
    CR  Revenue                                          $accrual amount
Memo: Accrued revenue for [service/period]
```

Reverses on the first day of the next period where the stated policy is auto-reverse (or
the entry is cleared when the invoice is issued). *Unbilled receivables* = work you've done and can bill for, but haven't yet.

**Deferral (revenue)** — the receipt is already in the books; **never re-book it**:
```
(a) Receipt already posted to income — period-end adjustment:
DR  Revenue                                          $unearned (net of tax)
    CR  Deferred Revenue (BS, per user's COA)           $unearned (net of tax)

(b) Receipt already posted to Deferred Revenue — no receipt entry.

Each period as earned:
DR  Deferred Revenue                                 $period revenue
    CR  Revenue                                          $period revenue
Memo: Recognize earned portion — [contract] — [period]
```

*Output tax* is sales tax / VAT / GST you collected on the customer's behalf — it was never
your revenue. **Check the tax split on the existing receipt**; it is not re-booked here.

This is typically built as a schedule (similar to prepaid amortisation but on the revenue
side). ASC 606 / IFRS 15 compliance itself is a revenue recognition task.

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which account you chose.

## Step 5 — Reversing entries

**Reversing** accruals reverse on the first day of the next period — the entry is undone so
that when the real invoice arrives it can post normally without double-counting. **Cumulative**
accruals (bonus, PTO, interest accrued but not yet due, severance) are adjusted to the computed
balance instead.

When the actual invoice / payment arrives in the new period, it posts cleanly to the expense
or revenue account, cancelling against the reversal.

For accruals where the actual invoice / payment will hit the accrual account **directly**
(without first reversing), no reversal is needed. **State the policy** — this is the reversal
policy confirmed at Gate 3.

Hand off the full set of reversing entries to `journal-entry-builder`, dated the first day of
the new period. **[auto]** to check whether last period's reversals actually posted
(*`search_journal_entries`* on the first days of the current period) — an accrual that was
never reversed is the most common cause of the compounding problem flagged in Step 6.

## Step 6 — Roll-forward by category

A **roll-forward** shows how a balance got from where it started to where it ended. It is
the proof that nothing is stuck.

For each accrual category — **[auto]** where the accrual account is identifiable in the
ledger (*`get_general_ledger`*, *`get_trial_balance`*, *`search_journal_entries`*):

**Agree each opening balance to last period's closing schedule** (or state that none exists);
differences go to exceptions.

```
Opening accrual balance
+ Current period accrual booked
- Reversal of prior period accrual
- Settlement of accrual (e.g., bonus paid)
+/- Adjustments / true-ups
= Closing balance
```

A **true-up** is the correction you make when the real amount turns out different from what
you estimated.

For **reversing** accruals, the closing balance should equal this period's accrual. For
**cumulative** accruals (bonus, PTO, interest accrued but not yet due, severance), the closing
balance should equal the obligation computed at period end (ASC 710 / IAS 19), and the period's
entry is the change.

**A balance above that expected figure means a reversal did not post or an item was booked
twice: investigate.**

## Step 7 — Materiality

**Materiality** is the size below which a difference isn't worth chasing. Apply the threshold
from Gate 3. Items below it can be skipped (or accrued at zero). **Track the cumulative
total of the immaterial items** — individually small, collectively they can still matter, and
the total is what an auditor asks for.

If the user declined to set a threshold, say so and apply none, rather than picking one.

## Step 8 — Output

Offer an `.xlsx` workpaper: ask the user whether they want it as an Excel file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Sheet 1: Summary**

| Category | Reversing / Cumulative | Period Accrual | Reversal of Prior | Net Period Impact | Closing Balance |

Add a header block: workspace name; each in-scope company file by `display_name`; each
excluded company file and why; whether any figure rests on `mock` data.

**Sheet 2: Category Detail**

For each category:
- Computation methodology
- Inputs and supporting data — **and where each input came from**: a named tool, or the user
- Result
- JE entry

**Sheet 3: Period JEs**

All accrual / deferral entries for the period, marked clearly as **proposals**.

**Sheet 4: Reversal Entries**

All reversing entries for the next period.

**Sheet 5: Deferred Revenue Roll-Forward**

Specifically for deferred revenue, which often has a structured schedule.

| Contract | Customer | Received | Service start | Service end | Earned to date | Unearned at period end | Current / non-current |

**Sheet 6: Roll-Forward by Category**

**Sheet 7: Materiality / Excluded Items**

List of items below threshold not accrued, with the cumulative total.

**Sheet 8: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus estimated. One row per accrual and deferral
item in Steps 1–7:

| Item | Category | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: a tool enabled for one company file may
be disabled for its sibling, so the same accrual can be `[auto]` for one and `[manual]` for
another.

**File naming:** `Accruals_Deferrals_[YYYY-MM].xlsx`

In a multi-entity run: `Accruals_Deferrals_[YYYY-MM]_[EntityDisplayName].xlsx`, plus one
combined file named for the set. Every file states, on its summary sheet, exactly which
datasource and which `display_name` it covers.

**Grounding:** every figure must trace to a tool result in this conversation or to labelled
user-supplied evidence. Do not tag individual figures with citations; end the answer with a
single **Data sources** line grouping the calls by datasource. Where the data does not cover
something, **name the tool that would have covered it** instead of estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** The first run discovered the workspace and interviewed
you. That does not need to happen again.

After the user has **seen the results** and approved them, ask — explicitly, at that point,
not earlier — whether to save this as their own customized version. A general "yes, go ahead"
from the start of the conversation does not count.

On an explicit yes, persist the **decisions**:

- The Gate 3 answers: accrual and deferral categories in scope, materiality threshold,
  reporting framework, tax jurisdiction, reversal policy
- The account mapping: which specific accrued-liability, accrued-revenue, deferred-revenue
  and expense accounts each category posts to, by their real names in the chart of accounts
- The computation basis chosen per category (e.g. "utilities: last invoice's daily rate";
  "bonus: best-estimate payout × months elapsed ÷ 12"), including the day-count convention
  used for interest
- Recurring items that accrue every period, so they are proposed automatically next time
- Standing exclusions and why
- The replay recipe: the exact sequence of reads that produced this period's schedule

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
and asset files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files.
Or write them as preference files alongside the installed skill, per the user's setup.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — materiality $500, bonus accrual 1/12 of $240k pool, reverses day 1" —
not "materiality $500". One location's bonus plan is not another's, and an unlabelled
preference is ambiguous the moment a second company file connects. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace, not to the user's decisions. They change between runs and are re-discovered
by Gates 1–2 every time. **Decisions are the user's; state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged to the user** — never silently dropped, never applied
to a different entity.

---

## Both entity scenarios

**Single-entity.** The workflow above, exactly as written, against one `data_source_id`. One
schedule, one set of JEs, one workpaper.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every accrual and roll-forward carrying that entity's `display_name`. Then
one cross-entity step:

- **A roll-up** — accruals aggregate cleanly across entities in a way that information
  returns do not, so a combined accrued-liabilities figure is meaningful. But it is only
  meaningful if each contributing entity is shown on its own line first.
- Watch for the accrual that belongs to **one** entity but was estimated from **another's**
  run-rate — label it, and do not let a shared-service cost get accrued twice.
- Where entities transact with each other, an accrual in one may be a deferral in the other;
  flag the pair rather than netting them silently, for an intercompany reconciliation.

Capability is checked **per entity** at Gate 2, and the coverage sheet shows each item's
verdict per company file.

---
