<!-- credit-card-reconciliation · method.md · read for: the domain work itself — every Step, quality checks, entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Parse the statement
- Step 2 — Tie statement balance to GL
- Step 3 — Match receipts to transactions
- Step 4 — Code transactions to GL accounts
- Step 5 — Tax handling
- Step 6 — Flag exceptions
- Step 7 — Construct the JE (hand off to journal-entry-builder)
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the card charges, the
liability balance, the payments and the chart of accounts do not depend on each other. Never serialize
them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the credit card liability account(s)**, and the expense accounts used for card
  coding — usually **[auto]**
- *`search_purchases`* / *`get_purchase`* — **every card charge posted in the period**, with merchant,
  amount, date and coding — usually **[auto]**
- *`get_general_ledger`* on the card liability account — **the full movement: charges, payments,
  interest, fees** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* / *`get_general_ledger`* — **the card liability balance at
  the statement closing date and at period end** — usually **[auto]**
- *`search_bill_payments`* / *`search_transfers`* — **payments made to the card** — usually **[auto]**
- *`search_purchases`* over **several prior months** — **the recurring-subscription and duplicate tests**
  — usually **[auto]**
- *`search_vendors`* / *`get-vendor`* — merchant records and their default coding — usually **[auto]**
- *`search_attachables`* / *`get_attachable`* — **evidence that a receipt file exists** against a
  transaction — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — tax codes in use — usually **[auto]**
- *`search_employees`* — cardholders, where they are set up as employees — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it cannot support a posted entry, and it must
never be used to raise an exception against a named employee.

## Step 1 — Parse the statement

For each transaction — **[manual]** from the statement, **[auto]** for the corresponding posted charge:

- **Transaction date**
- **Posting date** (may differ — **relevant for period cutoff**)
- **Merchant / vendor name** (often cryptic — normalize per `gl-coding-assistant`)
- **Amount** (charge or credit)
- **Currency** (statement currency vs. transaction currency for foreign transactions)
- **FX rate used** (if multi-currency)
- **Foreign transaction fee** (if any)
- **Cardholder** (if multi-card on one statement)
- **Reference / transaction ID**

Capture — **[manual]** from the statement:

- **Opening balance**
- **Total new charges**
- **Total credits / refunds**
- **Total interest / fees charged**
- **Payments made**
- **Closing balance**

**[auto]** for the book equivalents of the last five: charges, credits, interest and fees, and payments
are all readable from the card liability account's movement. That gives you the book side of every
statement total, which is what Step 2 needs.

**Prove the statement before using it:** opening + charges − credits + interest/fees − payments =
closing. Agree the opening balance to the prior statement's closing balance. A gap usually means a
missing page or a misread line — resolve it before Step 2. Ask for last month's reconciling items
(recommended intake); confirm each has cleared this period, and **escalate any that has not** — a
book-only charge that never reaches the statement is a duplicate or an error, not timing.

## Step 2 — Tie statement balance to GL

The credit card liability on the GL should reconcile to the statement closing balance, considering —
**[gated]**, since one side is `[manual]`:

- **Charges posted to GL but on the statement after period end** → reconciling item (timing)
- **Charges on the statement but not yet posted to GL** → reconciling item (timing)
- **Payments in transit** → reconciling item
- **FX revaluation differences** (for foreign-currency cards)

**Tie-out date.** Read the GL liability balance **as of the statement closing date**, not the accounting
period end — otherwise every charge and payment between the two dates becomes a bridge item.
Separately, confirm that all charges from the statement close to the period end are recorded (from the
next statement or the issuer's online activity), and propose an accrual for any that are not.

**Match each statement line to a posted charge first** — exact amount and transaction date within the
posting lag (state the window used), then amount and merchant, then reference. Record the method for
each match. Unmatched statement lines are `$Z`; unmatched book lines are `$Y`, or duplicates and
mis-postings to investigate.

Format (the card liability is a credit balance — what you owe the issuer):

```
GL Credit Card Liability balance (at statement close)    $X
- Charges in GL not yet on statement                     $Y
+ Charges on statement not yet in GL                     $Z
+ Payments in transit (in GL, not yet on statement)      $A
+/- Credits/refunds, issuer interest/fees on one side only  $C
+/- FX revaluation timing differences                    $B
= Adjusted GL                                            $X−Y+Z+A±C±B

Statement Closing Balance                                $W

Reconciled difference                                    Adjusted GL − $W  (should be 0)
```

*Worked example:* the statement closes at $950. The GL holds $1,000 because a $50 charge was booked on
30 September and reaches the card on 1 October. $1,000 − $50 = $950 = statement; difference nil. A
charge on the statement but missing from the books makes the statement higher, so it is added.

**[auto]** for `$X` and for identifying charges posted near the period boundary that are likely to be the
`$Y` items. **[manual]** for `$W` and `$Z`. **If no statement was supplied, do not build this bridge** —
say the tie-out was not performed, and present the posted-charge review instead.

## Step 3 — Match receipts to transactions

For each transaction, match a receipt — **[manual]**, with one `[auto]` support noted below:

- **Receipt management tool export** (Expensify, Brex, Ramp, etc.) often pre-matches; **verify**
- **Receipts uploaded separately**: match by date + amount + merchant
- **Multiple receipts for one transaction** (split bill, partial pre-pay): **all should sum to the
  transaction amount**
- **One receipt covering multiple transactions** (e.g. a hotel folio covering several daily charges):
  **cross-reference**

Match status per transaction:

- 🟢 **Matched** — receipt confirms the transaction
- 🟡 **Below threshold** — no receipt required per policy
- 🔴 **Missing receipt above threshold** — exception, needs follow-up
- ⚠️ **Disputed** — cardholder claims the charge is wrong / fraudulent
- 🔁 **Refunded** — original charge + matching refund both present

**[auto]** support: where the connector exposes attachments (*`search_attachables`*), you can identify
**which posted charges have no attached file at all**. That is a strong first pass at the 🔴 list — it
finds the transactions where no receipt was even captured — but **it is not a match**: a file being
present says nothing about whether it is the right receipt for the right amount.

**[auto]** for 🔁 **Refunded**: an original charge and an offsetting credit from the same merchant are
directly detectable in the posted transactions.

## Step 4 — Code transactions to GL accounts

Use `gl-coding-assistant` for each transaction. **The user's COA drives account selection.**
**[auto]** to read how each charge was *actually* coded, and to propose coding for anything uncoded.

Corporate-card transactions are often a mix:

- **Subscriptions and software**
- **Travel**
- **Meals** (with **cardholder business purpose required**)
- **Office supplies, equipment**
- **Marketing / advertising spend** (often the biggest line for ad-buying cards)
- **Personal charges** (not allowed on a corp card; **flag**)

**For multi-line transactions** (e.g. a hotel folio that includes room + meals + incidentals), **split
coding may be needed. Capture line detail from receipts where possible** — **[manual]**, since the split
lives on the receipt, not the statement line.

**[auto]** and worth reporting: charges coded to a **suspense, uncategorised or "ask my accountant"**
account. Those are transactions nobody has decided about, and they are usually where the personal
charges and the capital purchases hide.

## Step 5 — Tax handling

If the entity's jurisdiction allows **input-tax recovery** on card transactions — **[manual]** for the
rules, **[gated]** for the amounts:

- **Tax must be visible on the receipt** — some jurisdictions require a **valid tax invoice, not just a
  credit-card slip**. This is the point most often missed: the card slip proves payment, not tax
- **Decompose the receipt total into pre-tax + tax** for any recoverable lines
- **Foreign-currency transactions**: handle tax per the entity's policy — **often tax on foreign
  transactions isn't recoverable**

**If no jurisdiction is provided or the policy is unclear, capture tax separately on receipts where shown
and flag for user review.** **[auto]** to show which tax codes were actually applied to posted charges
(*`search_tax_codes`*, *`get_purchase`*) — including any charge with a recoverable tax code but no
attached receipt, which is a recovery claim with no support behind it.

## Step 6 — Flag exceptions

For each statement — verdicts vary sharply, so mark each:

- **Missing receipts (above policy threshold)** — **[gated]** via attachment metadata; **[manual]** to
  confirm
- **Charges without a business purpose** — **[manual]**; a business purpose is not a ledger field
- **Possible personal-use charges** (groceries, personal services, weekend non-business locations) —
  patterns from `expense-report-processor` — **[gated]**: merchant names and dates are **[auto]**, the
  judgment is not
- **Duplicate transactions** — same merchant and amount within a few days (transaction vs posting
  date, or the same charge imported twice); same-day is the high-confidence tier — **[auto]**, and worth
  running every month
- **Disputed charges** (cardholder marked or known issues) — **[manual]**
- **Charges from sanctioned countries** (compliance flag) — **[manual]**; merchant country is rarely in
  the books, and **no sanctions list is available**; screening belongs to whoever owns sanctions compliance
- **Charges exceeding the cardholder's single-transaction limit** — **[gated]**: amounts are **[auto]**,
  the limit is **[manual]**
- **Charges with no merchant identification** — **[auto]**

**Three additional `[auto]` tests worth running every month** (each addresses an edge case the original
raises):

- **Recurring subscriptions** — same merchant, same amount, repeating monthly across several periods.
  Present the list with the annualised cost; this reliably surfaces software nobody uses
- **Capitalization-threshold breaches** — charges above the entity's capitalisation limit coded to an
  expense account
- **Charges posted to suspense or uncategorised accounts**

## Step 7 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit. **Mosofin does not post** — these are proposals.

The posting depends on when the entity records card activity.

**Option A — Post each transaction to expense at the time of charge** (most accurate; typical for entities
using receipt management tools that sync to GL):

```
DR  Expense accounts (per coding)               $net of tax
DR  Input Tax Recoverable                       $tax (if applicable)
    CR  Credit Card Liability                      $card amount (gross)
Memo: Card transactions for [cardholder] [period]
```

When the card is paid:

```
DR  Credit Card Liability                       $payment
    CR  Cash / Bank                                $payment
Memo: Card payment [date]
```

**Option B — Post the statement total to liability and clear at payment** (simpler; less granular GL):

```
At statement receipt:
DR  Expense accounts                            $new charges − credits (split by code)
    CR  Credit Card Liability                     $new charges − credits
Memo: Card statement [period]
```

Interest and fees go in their own lines (template below). **Payments are recorded when made (DR
Liability / CR Bank), not in this entry** — crediting the closing balance would double-count the opening
balance or expense the payments.

**Recommend Option A for better visibility.**

**[auto]** to determine which the entity is *already* using: individual charges posted through the period
indicate Option A; a single monthly entry indicates Option B. **Say which you found**, because it changes
whether this step proposes entries or reviews existing ones.

**For refunds and credits: opposite direction.**

**For interest / fees charged by the card issuer:**

```
DR  Interest Expense / Bank Fees                 $interest / fee
    CR  Credit Card Liability                       $interest / fee
```

**Personal charge confirmed by the reviewer** — propose only after a person confirms the charge is
personal:

```
DR  Owner's Draws / Shareholder Loan (owner's card) or Due from Employee (staff card)   $amount
    CR  [expense account originally coded]                                              $amount
```

Which owner account applies (draws, distribution or loan) depends on the entity type and the owner's
policy — **ask**, never choose.

Use the **real account names from the connected chart of accounts** (*`search_accounts`*, **[auto]**).

## Step 8 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Reconciliation Summary**

- Statement period, cardholder, statement balances
- GL balance and reconciling items
- Total transactions, total matched, total exceptions
- Recommended JE posting

Add a header block: workspace name; the entity by `display_name`; each excluded company file and why;
**whether a statement was supplied** (and therefore whether this is a reconciliation or a posted-charge
review); whether any figure rests on `mock` data.

**Sheet 2: Transaction Detail**

| Date | Posted Date | Merchant (Cleaned) | Description | Amount | Currency | FX Fee | GL Account | Tax Code | Receipt Status | Business Purpose Captured | Notes |

Add a **Source** column — statement, ledger, or both — so unmatched items on either side are visible.

**Sheet 3: Exceptions**

| Line | Issue | Severity | Action Required |

Including the three automated tests: duplicates, recurring subscriptions (with annualised cost), and
capitalisation-threshold breaches.

**Sheet 4: GL Posting**

Pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 5: Source Receipts Reference**

For the audit trail — which receipt matches which transaction. **Distinguish "a file is attached" from "a
receipt was matched and verified".**

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be verified and what the user must supply |

Rows for the statement, the receipts, business purpose and sanctions screening read `manual` with their
gaps named. That is the correct, expected result.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `CC_Recon_[Cardholder]_[YYYY-MM].xlsx`

In a multi-entity run, include the entity: `CC_Recon_[EntityDisplayName]_[Cardholder]_[YYYY-MM].xlsx`.
Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something, **name the tool that would have covered it** instead of estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

This runs monthly, so the evolution step pays back quickly.

On an explicit yes, persist the **decisions**:

- **The card register**: which cards exist, which liability account each maps to, and which entity each
  belongs to — **by role, not by card number**
- **The receipt policy threshold** and the **capitalisation threshold**
- **The merchant-to-account coding map** — the recurring merchants and where each is coded. The biggest
  monthly time saving, and it makes miscoding visible
- **Known recurring subscriptions** that have been reviewed and approved, so the monthly list surfaces
  only what is new
- **The posting option in use** (A or B), and the statement-period-to-accounting-period relationship
- **The tax treatment** for domestic and foreign card transactions
- **Cardholder single-transaction limits**, by role
- The replay recipe: the exact sequence of reads that produced the posted-charge population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist card numbers (even partial), individual cardholders' names with their spending, receipt
images, or transaction detail.** Card numbers are payment credentials; an employee's spending pattern is
personal data and, in the case of a suspected personal charge, a sensitive allegation. **Persist the
policy and the coding map, keyed by role.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — Card liability account 2100; receipt threshold $75; capitalisation $2,500; Option A posting" —
not "receipt threshold $75". Thresholds and card programmes differ between entities, and an unlabelled
threshold applied to the wrong company file either floods the exception list or suppresses real ones.
Record the chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`, once per card. One reconciliation, one
JE set.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one `data_source_id`,
every charge carrying its entity's `display_name`. Then:

- **A card issued to one entity but used for another's expenses** is the common cross-entity case. Those
  charges are **not that entity's expense** — they create an **intercompany balance**: entity A paid for
  entity B's cost. Identify them, and route them to an intercompany reconciliation rather than coding them
  as expense in the wrong company.
- **A shared card programme across entities** produces one statement covering several legal entities.
  Reconcile the statement to the **combined** book activity, then allocate per entity — and treat the
  split as an allocation, not a reconciliation.
- **Compare exception rates across entities.** One entity with far more missing receipts than its
  siblings is a policy-enforcement problem, not an accounting one.
- **Thresholds and policies may differ per entity** — apply each entity's own.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
