<!-- payroll-reconciliation · method.md · read for: Stages 3–6 — Steps 0–8 (read the GL side, the four tie-outs, wage bases, exceptions, output, evolve) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Reconcile payroll register to GL (expense and gross)
- Step 2 — Reconcile net pay to bank
- Step 3 — Reconcile withholding and employer liabilities
- Step 4 — Reconcile to tax filings (quarter/year-end)
- Step 5 — Reconcile taxable wage bases
- Step 6 — Investigate and resolve exceptions
- Step 7 — Output
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The wage bases and the filings are legitimately `[manual]`,
and reporting Step 5 as not performed is the honest result where the register is absent.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the movements, the payments and
the journals do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **every payroll expense and liability account** — usually **[auto]**
- *`get_profit_and_loss`* — **wages and employer cost expense for the period, on every account that receives
  payroll** (direct labour in cost of sales, officer pay, departmental wages — the list confirmed with the
  user) — the Step 1 target — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* at both period ends — **the liability roll-forward anchors**
  — usually **[auto]**
- *`get_general_ledger`* on **every payroll account** — **movements, ageing, and the manual adjustments** —
  usually **[auto]**. **The central read**
- *`search_payments`* / *`search_checks`* — **net pay disbursements and remittances**, by payee — usually
  **[auto]**
- *`search_journal_entries`* — **the payroll journals, and any manual entry to a payroll account** — usually
  **[auto]**
- *`search_employees`* — **headcount only** — usually **[auto]**
- *`get_company_info`* — legal name, country, **fiscal calendar** — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that reconciliation to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a payroll reconciliation feeds tax filings and
employee wage statements**, and a fixture-based tie means nothing to either.

## Step 1 — Reconcile payroll register to GL (expense and gross)

**Confirm what the payroll system reports matches what was booked** — **[gated]**: **the GL side is
`[auto]`**, the register side is not:

- **Total gross wages per the register(s) = wages / salaries expense posted to the GL for the period**
- **Employer costs per the register = employer cost expense in the GL**
- **Investigate differences: missing runs, manual adjustments, misclassified postings, capitalized labor
  (legitimately not in expense), timing**

**Build a register-to-GL bridge reconciling any difference to explained items.**

**Mosofin contribution — five of the six causes are detectable.** **[auto]**:

| Cause | How it shows |
|---|---|
| **Accrued wages** | **closing accrued payroll less opening accrued payroll** (and its reversal) — the register is on a pay-date basis, GL expense on an earned basis — from the accrued-payroll GL |
| **Missing runs** | **a pay period with no journal** — the payroll journal pattern has a gap |
| **Manual adjustments** | **a journal to a payroll account with no payroll run behind it** — see below |
| **Misclassified postings** | **payroll-cycle amounts in a non-payroll account**, or the reverse |
| **Capitalized labor** | **a debit to an asset account on the payroll journal date** |
| **Timing** | a run dated in one period and posted in another |

**The manual adjustment check deserves its own emphasis**, since the edge cases name it as a tie-breaker:
**list every entry to a payroll account that is not part of a payroll run**, with its date, amount, account
and memo. **In most broken register-to-GL reconciliations, the answer is on that list.**

## Step 2 — Reconcile net pay to bank

- **Total net pay per the register(s) = net pay disbursed per the bank** — direct deposits + checks —
  **[gated]**
- **Account for timing** — a pay date spanning a bank cutoff — **uncashed checks, returned payments** —
  **[gated]**: **returned payments and reissues are readable**
- **Where a payroll clearing account is used, confirm it nets appropriately** — hand detail to
  `payroll-clearing-reconciliation`

**State which side of "bank" was used.** **Recorded disbursements are `[auto]`; the bank statement is
`[manual]`** — and **tying net pay to recorded disbursements proves the bookkeeping, not that the money
left.** The same distinction as `bank-reconciliation` and `merchant-and-payment-processor-rec`.

## Step 3 — Reconcile withholding and employer liabilities

For each liability type — **income tax withholding, social / payroll contributions employee and employer,
retirement, benefits, garnishments** — **[gated]**:

```
Opening liability balance (from GL)
+ Amounts accrued this period (from register/JE)
− Amounts remitted this period (from bank/remittance records)
= Closing liability balance (should equal GL)
```

**Opening and closing are `[auto]`; remittances are `[auto]` from payments; accruals are `[manual]` without
the register — though the payroll journal's credit is a stated proxy.**

**Confirm the closing GL balance for each liability equals what's genuinely still owed (and not yet due).
Flag:**

- **Unremitted liabilities past their due date** — **penalty risk** — **[gated]**: the balance and its age
  are `[auto]`, **the due date is `[manual]`** — a fixed day, or a rule applied **per pay date** (for
  example, the Wednesday after a Saturday–Tuesday pay date)
- **Liabilities that should be zero but aren't** — over-accrual, missed remittance, or misposting —
  **[auto]** given the expected pattern; see `payroll-clearing-reconciliation` Step 0b
- **Negative liability balances** — **[auto]**, ⭐ **always an exception**: a posting error, an over-remittance to claim back, or a prepayment to reclassify. Never left in a liability account at a reporting date. One query, run it
  every period

**The overdue flag is the one with consequences.** **An unremitted withholding past its due date accrues
penalties and interest**, and in many jurisdictions **payroll taxes carry personal liability for
directors** — which is a materially different exposure from an ordinary overdue payable. **Given the due
dates, the flag is arithmetic; without them it cannot be raised.** Ask for them.

## Step 4 — Reconcile to tax filings (quarter/year-end)

**When filings are prepared**, **tie the payroll records to the filed figures** —
**[gated]**: the GL side `[auto]`, **the filings `[manual]`**:

- **Total taxable wages per the GL / register = taxable wages on the filing**
- **Total tax withheld / contributed per the GL = tax reported on the filing**
- **Year-end employee wage statements (totals) = sum of registers = filed totals**, agreed to **GL wages
  through a bridge**: accrual movement, capitalised labour, pre-tax deductions, imputed income
- **Reconcile any differences** — e.g. non-taxable items, pre-tax deductions affecting taxable wage bases
  differently

**This is critical: filings, wage statements, and the GL must agree, or it surfaces in audits and employee
tax filings.**

**Note the first bullet contains the Step 5 problem.** **"Taxable wages per the GL" is not available** — the
GL holds gross, not taxable. **Where the register is absent, the taxable-wages comparison is NOT PERFORMED**,
for the same reason as Step 5. Tie only **tax reported on the filing to tax credited to the liability
accounts (per GL)**, and gross per GL to the filing's gross or total-pay line where the form has one. Report
any gross-to-taxable gap as **unexplained, needs register**.

**The year-end statement tie has a deadline.** **Differences must be resolved before statements are issued
to employees**, because a wrong statement means amended filings and employees amending their own tax
returns. **[auto]** contribution: **the GL wage total is exact and available immediately**, which makes the
comparison possible as soon as the register is.

## Step 5 — Reconcile taxable wage bases

**Different taxes apply to different wage bases** — some withholdings are on gross, some on gross less
pre-tax deductions, some capped at a ceiling. **Reconcile each tax's wage base:**

- **Gross wages**
- **Less pre-tax deductions** — retirement, certain benefits — where applicable
- **Subject to caps / ceilings** where applicable
- **= Taxable base for that specific tax**

**Confirm each tax was computed on the correct base. Mismatched bases are a common error.**

**[manual]**, entirely, and **this is where the register is irreplaceable.**

**Why it cannot be approximated here:** **caps apply per employee, not in aggregate.** An entity whose
employees have collectively earned well above a ceiling may still have most of them below it. **There is no
aggregate arithmetic that recovers a per-employee capped base**, and **pre-tax deductions vary by employee
election.** **The GL's single gross figure cannot be decomposed into them.**

**With the register, per-employee arithmetic is done in the session only**, to test caps and pre-tax
elections. **Only aggregates and counts are reported** — *"14 employees at the cap; capped base 1,982,400;
tax per register agrees"* — and an exception is referred to by reference number.

**Where the register is unavailable, report this step as NOT PERFORMED**, name what it would have shown, and
**do not present a gross-based rate check as a substitute** — it will mismatch for every affected employee
and the mismatch will look like an error when it is not.

## Step 6 — Investigate and resolve exceptions

For every reconciling item — **[gated]**:

- **Classify: timing, error, missing transaction, legitimate difference** — **[auto]** support from Step 1's
  cause table
- **Quantify** — **[auto]**
- **Determine the correction** — adjusting JE, remittance, filing amendment — **[manual]** judgment;
  the JE via `payroll-journal-entry-builder`
- **Document**

**Note the three correction types have very different urgencies.** **An adjusting JE is internal. A missed
remittance accrues penalties from its due date. A filing amendment may require amended employee wage
statements** — and the third is the one people discover last. **Order the exception list by consequence, not
by amount.**

## Step 7 — Output

Deliver an `.xlsx` reconciliation workpaper:

**Sheet 1: Reconciliation Summary** — **each reconciliation (register↔GL, net pay↔bank, liabilities,
filings) with status (tied / exceptions) and total unreconciled.** Add the Mosofin header: workspace name;
the entity by `display_name`; **which sources were read and which supplied**; **whether Step 5 was
performed**; whether any figure rests on `mock` data; **Prepared by / date; Reviewed by / date**.

**Sheet 2: Register-to-GL Bridge** — **gross and employer cost, register vs. GL, reconciling items**, with
**the manual adjustments listed separately**.

**Sheet 3: Net Pay to Bank** — **disbursements tie-out**, stating **recorded or bank-verified**.

**Sheet 4: Liability Roll-Forward** — **per liability: opening + accrued − remitted = closing, vs. GL, with
overdue / anomaly flags**, and **Opening agreed to prior reconciliation: Y/N**. **Negative balances listed
explicitly.**

**Sheet 5: Filing Reconciliation** — **wages and taxes per GL vs. filings vs. wage statements** (quarter and
year-end).

**Sheet 6: Taxable Wage Base Reconciliation** — **each tax's base derived and confirmed** — **or marked NOT
PERFORMED with the reason**.

**Sheet 7: Exceptions & Corrections**

| Item | Type | Amount | Root Cause | Correction | Owner | Status |

**Ordered by consequence**, with **due-date exposure flagged**.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Payroll_Reconciliation_[Period]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where a reconciliation could
not be performed — Step 5 without a register, the bank without a statement — **say so** rather than
reporting a tie.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** — every payroll expense and liability account and what it holds
- **The taxable wage base rules** per tax — **pre-tax deductions, caps, ceilings** — **the input Step 5
  depends on entirely**, and it changes annually with statutory limits
- **The remittance due dates** per liability, and the cadence
- **The reconciliation set** — which tie-outs are performed monthly, quarterly and annually
- **Known recurring reconciling items** — expressed as rules: "capitalised development labour is charged to
  the software asset, so the register exceeds wage expense by that amount"
- **The third-party provider arrangement**, and **who is responsible for remitting**
- **The materiality tolerance** per reconciliation
- **Whether a payroll platform is connected**, and which figures it supplies
- The replay recipe: the exact sequence of reads that produced the GL side

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data, and never persist balances, wage figures or exceptions.**
All state, and the personal data rule is absolute.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — PAYE 2210 due 22nd monthly, NI 2211/2212 due 22nd monthly, pension 2230 due 19th, wage base:
gross less salary-sacrifice pension, no cap" — not "PAYE 2210 due 22nd". **Wage base rules and due dates are
jurisdiction-specific**, and applying one entity's to another produces false overdue flags and false base
mismatches. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One register, one GL, one set of
filings.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one `data_source_id`, every
figure carrying its entity's `display_name`. Then:

- **A shared payroll service means one register covers several entities**, and **each entity's GL holds only
  its share.** **The register-to-GL tie must be run per entity against that entity's slice** — comparing the
  whole register to one entity's GL will fail by the others' payroll.
- **Filings are per employer**, and **the employer is the legal entity.** **Reconcile filings to the entity
  that filed them**, not to the group.
- **Wage bases and caps apply per employer per employee.** An employee who moved between group entities
  mid-year **may restart a cap in the new entity** depending on jurisdiction — a real and easily missed
  effect.
- **A payment by one entity covering another's liabilities** is an intercompany balance, not a remittance
  for that entity. It belongs in an intercompany reconciliation.
- **Run the negative-balance and overdue checks per entity.** A group view nets them away.
- **Currency**: payroll liabilities denominated in another currency revalue between accrual and remittance —
  the translation itself is an FX revaluation task.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each reconciliation's verdict per
company file.

---
