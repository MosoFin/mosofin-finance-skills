<!-- merchant-and-payment-processor-rec · method.md · read for: Stages 3–6 — the reconciliation itself. Edit here, not in SKILL.md. -->

# PART B — The domain work

## Contents

- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Understand the processor's data structure
- Step 2 — Decompose the gross-to-net flow
- Step 3 — Identify the relevant timing of each component
- Step 4 — Reconcile processor clearing account
- Step 5 — Tie payouts to bank deposits
- Step 6 — Handle multi-currency
- Step 7 — Tax handling
- Step 8 — Construct the JEs
- Step 9 — Output
- Step 10 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The bank statement is `[manual]` by construction, and
saying so is the honest result.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the revenue history and the
deposits do not depend on each other. **Where the processor is connected, batch its reads too**, so both
sides are as at the same instant.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **processor clearing, revenue, merchant processing fees, refunds / sales returns,
  chargebacks, output and input tax accounts** — usually **[auto]**
- *`get_general_ledger`* on **the clearing account** — **the roll-forward and the ageing** — usually
  **[auto]**. **Identify the clearing account from where the processor sales land, not from its name**:
  in QuickBooks it is often Undeposited Funds / Payments to deposit, or whatever account the
  processor's sync app posts to
- *`get_balance_sheet`* / *`get_trial_balance`* — the clearing balance at both period ends — usually
  **[auto]**
- *`get_profit_and_loss`* **by month** — **revenue, fees, refunds and chargebacks: the net-revenue test** —
  usually **[auto]**
- *`search_deposits`* — **recorded payouts into the bank account** — usually **[auto]**
- *`search_invoices`* / *`search_sales_receipts`* — the underlying sales, where recorded individually —
  usually **[auto]**
- *`get_company_info`* — legal name, **functional currency**, country — usually **[auto]**

**Where the processor is connected**, add its charge, refund, chargeback, fee and payout reads **in the same
message.**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in `mosofin-protocol.md`.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

### Reading an upload (the manual path)

When the processor side — or the books — arrive as files instead of tool reads, turn each file into the
same evidence before Step 1. **Do not guess at a column you cannot identify; ask.**

**Stripe's payout reconciliation report** documents these columns
([Stripe docs](https://docs.stripe.com/reports/report-types/payout-reconciliation)):

| Column | What it is | Use it for |
|---|---|---|
| `gross` | Gross amount of the transaction | Gross sales, refunds and chargebacks, split by `reporting_category` |
| `fee` | Fees paid for this transaction | The processor fee total — the number the net-revenue test needs |
| `net` | Net amount of the transaction | What reached the payout |
| `reporting_category` | Stripe's grouping of balance transactions | Separating charges, refunds, disputes and fees |
| `automatic_payout_id` | The automatic payout this transaction settled in | Rebuilding each payout from its transactions |
| `automatic_payout_effective_at` | When the payout is expected in the bank | Tying payouts to the deposits in the books |
| `currency` | ISO code for `gross`, `fee` and `net` | Never summing two currencies together |
| `balance_transaction_id`, `created` | Identifier and timestamp | Tracing and period cut-off |

Stripe states amounts in **major units** — dollars for USD — so no division by 100 is needed. On a manual
payout schedule `automatic_payout_id` is empty; group by date range instead and say so.

**Other processors** (Square, PayPal and the rest): find the equivalent gross, fee, net, type, payout and
date columns, show the user the mapping, and **confirm it before using it.**

**Before trusting any upload, check and report:**

- **gross − fee = net**, in total and for each payout. A break means a column is mapped wrongly or rows are
  missing.
- The file covers **exactly the Stage 1 period** — no rows outside it, no missing days at either end.
- One currency per total. Split anything that mixes them.
- The row count and the gross, fee and net totals, stated back to the user.

Check the **`mock` flag** **on both sides**. `mock: true` on the processor side means **the reconciliation
is against fixture activity** and proves nothing.

## Step 1 — Understand the processor's data structure

**Each processor differs slightly, but most provide:**

| Data type | Description |
|-----------|-------------|
| **Charges / transactions** | Individual customer payments |
| **Refunds** | Reversed transactions to customers |
| **Chargebacks** | Disputed reversals via card network |
| **Fees** | Per-transaction or volume-based fees |
| **Adjustments** | Manual processor adjustments |
| **Payouts / settlements** | Bank deposits from processor to merchant |

**The amount the processor owes the entity (the clearing balance) = gross collected − fees − refunds −
chargebacks − holds. Settlements pay down this balance.**

**[gated]**: **`[auto]` where the processor is connected**, `[manual]` from an export otherwise. **Read the
processor's own definitions** of available, pending and reserve — **they differ by processor and the
difference lands directly in Step 4's comparison.**

## Step 2 — Decompose the gross-to-net flow

For the period, capture:

```
Gross customer charges (tax included)               $A
Less: Refunds processed                             ($B)
Less: Chargebacks                                   ($C)
Less: Processor fees                                ($D)
Plus/less: Adjustments (refunds of fees, etc.)      ±$F
Equals: Net settled to entity                       = $A − B − C − D ± F
```

**Gross means the amount charged to customers, tax included.** Ordinary processors (Stripe, Square,
PayPal and similar) pay the tax out to the merchant, who remits it — so tax stays inside the settled
amount. **Deduct tax only for transactions where the processor or marketplace remits it**
(marketplace-facilitator sales — see the edge case), and list those separately.

**Compare to actual bank deposits (payouts).**

**[gated]** on the processor side; **[auto]** on the ledger side — **each component has a
corresponding GL account**, so **the same decomposition can be built from the books and the two compared.**
**That comparison is the reconciliation**, and where the processor is not connected it is still worth
building the GL-side decomposition, because **it is what reveals a missing component** — no chargeback
account, no fee account, refunds netted against revenue.

## Step 3 — Identify the relevant timing of each component

**Each component has different recognition timing:**

- **Gross customer charges**: **revenue at the point of sale** (under the entity's revenue recognition policy)
- **Refunds**: **contra-revenue at the time of refund** (per `credit-memo-and-refund-handler`)
- **Chargebacks**: **contra-revenue + chargeback fee at the time the chargeback is processed**
- **Processor fees**: **expense at the time of the transaction**, or on aggregate per the entity's policy
- **Payouts**: **cash transfers from processor balance to bank**

**Common timing mismatches:**

- **Charges accumulate during the period; payouts arrive a day or two later**, or in batches per processor
  schedule
- **Chargebacks can arrive weeks after the original sale**
- **Reserve / hold balances** — the processor may hold a portion as a rolling reserve

**[auto]** support: **the lag between charge and payout is measurable** from the ledger where both are
recorded, and **it should be stable.** **A lengthening lag is the earliest visible sign of a payout pause or
a risk review** — the Step 9 pause-or-freeze exception, caught before the balance balloons.

## Step 4 — Reconcile processor clearing account

**The "Processor Clearing" or "Merchant Account Receivable" account in the GL represents the balance owed by
the processor to the entity.**

```
Opening clearing balance
+ Gross customer charges (revenue recognized)   } = gross charged to customers
+ Tax collected (if applicable)                 }   (Step 2's $A)
- Refunds
- Chargebacks
- Processor fees
± Adjustments
- Transferred to reserve receivable / + released from reserve
- Payouts received in bank
= Closing clearing balance
```

**Should match the processor's reported "Available Balance" at period end** — **plus any "Pending" /
"In Transit" amounts depending on definition.**

**[auto]** on the GL side, **[gated]** overall. **This is the core reconciliation**, and three things about
it:

1. **The roll-forward must tie to the clearing account.** Opening and closing balances are readable —
   **report the difference, including zero.**
2. **The comparison to the processor's balance needs the processor's definition.** "Available" excludes
   pending and reserve in most processors; **the GL clearing balance usually includes them.** **Comparing
   the wrong pair produces a difference that is definitional, not an error** — state which definition you
   used.
3. **Age the clearing balance.** **[auto]**: **amounts sitting beyond the normal payout window** are the
   Step 9 exception, and ageing is what finds them.

**Before concluding there is no clearing account**, check Undeposited Funds / Payments to deposit and
any account the processor's sync app posts to — the clearing account is wherever the processor sales
land. **Where no clearing account exists at all**, that is a structural finding: **the entity is almost certainly
posting the net payout straight to revenue or to cash**, which is the error in Step 7.

## Step 5 — Tie payouts to bank deposits

For each payout from the processor — **[gated]**:

- **Match to the bank deposit** by date and amount — **[auto]** against **recorded** deposits;
  **`[manual]` against the bank statement**
- **Note any small timing differences** — **a 1-day lag is normal**
- **Investigate any missing deposits or unexplained deposits** — **[auto]** in the ledger

**Be precise about what was tied.** **Tying payouts to recorded deposits proves the bookkeeping; tying them
to the bank statement proves the money arrived.** They are different assurances and the workpaper should say
which was performed. See `bank-reconciliation`, where the same distinction governs.

## Step 6 — Handle multi-currency

**Many processors operate in multi-currency:**

- **Customer charged in their currency**
- **Processor converts to merchant's settlement currency at processor's rate**
- **Settlement currency might be different from the entity's functional currency**

**Capture** — **[gated]**:

- **Gross transaction currency and amount** — from the processor
- **Processor's FX rate** — **[manual]**; **the processor's rate is its own, and it is not a market rate**
- **Settlement amount in settlement currency**
- **Conversion to functional currency**, using the entity's policy — transaction date rate or settlement
  date rate

**FX gain / loss arises when:**

- **The entity's GL is in a different currency than the processor's settlement**
- **The transaction date vs. the settlement date rates differ**

**[auto]**: the entity's functional currency is known. **[manual]**: every rate — consistent with
foreign-currency translation and FX revaluation practice, where no rate is ever supplied
from memory.

## Step 7 — Tax handling

**Processor fees:**

- **In many jurisdictions, processor fees include recoverable input tax** — e.g. VAT on Stripe fees in the
  EU. **Check the processor's tax invoice**
- **In others, fees are tax-free**

**Gross customer payments:**

- **The entity is liable for output tax on the gross sale, not the net**
- **A common error is recognizing revenue net of processor fees — wrong**

**Confirm with the user's jurisdiction.**

**Mosofin test — run this every period.** **[auto]**, and it is the highest-value check in the skill:

| Signal | What it suggests |
|---|---|
| **Revenue recorded from processor deposits / sales receipts** (the clearing account's credits, or deposits from the processor payee) **≈ processor net payouts** rather than processor gross charges — compare this population, not total P&L revenue, and say which population was used | **Revenue is being recorded net** |
| **Merchant processing fee account near zero** while a processor is in use | Same |
| **No clearing account exists** | Same, and no reconciliation is possible |
| **Refunds netted against revenue** rather than shown as contra-revenue | Related presentation error |

**Report it as a presentation finding with the estimated gross-up.** **Profit is unaffected; revenue, cost
and every margin are not** — and the gross-up is computable once fees are known.

**And the output tax point follows directly**: **tax is due on the gross sale.** An entity recording net
revenue may also be **under-declaring output tax**, which is a different and more serious problem.

## Step 8 — Construct the JEs

**Hand off to `journal-entry-builder`.** `DR` is a debit, `CR` a credit. **Mosofin does not post** — these
are proposals.

**Per transaction approach (most accurate):**
```
At time of sale:
DR  Processor Clearing                           $gross customer payment
    CR  Revenue                                     $net of tax
    CR  Output Tax Payable                          $tax
Memo: Sale via [processor] — [transaction ID]

At time of fee charge:
DR  Merchant Processing Fees                     $fee
DR  Input Tax Recoverable                        $tax on fee (if applicable)
    CR  Processor Clearing                          $fee + tax
Memo: [processor] fee — [transaction ID]

At time of refund:
DR  Sales Returns & Allowances                   $net refund
DR  Output Tax Payable                           $tax refunded
    CR  Processor Clearing                          $gross refund

At time of chargeback:
DR  Chargebacks (contra-revenue or expense)      $net chargeback
DR  Output Tax Payable                           $tax (if jurisdiction allows reversal)
DR  Chargeback Fee Expense                       $processor's chargeback fee
    CR  Processor Clearing                          $gross + fee

At time of payout:
DR  Cash / Bank                                  $payout
    CR  Processor Clearing                          $payout
```

**Periodic aggregate approach (simpler, less granular):**

**Sum the components for the period and post one summary JE per processor per period. Lose
transaction-level visibility in GL but simpler reconciliation.**

```
DR  Cash / Bank                                  $net payouts
DR  Merchant Processing Fees                     $fees
DR  Sales Returns / Refunds                      $refunds (net of tax)
DR  Output Tax Payable                           $tax on refunds
DR  Chargebacks                                  $chargebacks
DR/(CR)  Processor Clearing                      increase/(decrease) in the amount owed by the
                                                 processor this period
    CR  Revenue                                     $gross sales (net of tax)
    CR  Output Tax Payable                          $tax on sales
```

**Correcting a net-revenue posting** (the Step 7 finding; per period, fees from the processor report):
```
DR  Merchant Processing Fees                     $fees
    CR  Revenue                                     $fees
If refunds were netted in revenue:
DR  Sales Returns & Allowances                   $refunds
    CR  Revenue                                     $refunds
```
**Flag the output-tax review separately; do not propose a tax entry without the filed returns.**

**Declare which approach is in use** — the original's own quality standard — **and note that `[auto]`
verification differs by approach**: the per-transaction method leaves a clearing entry per sale and is
traceable transaction by transaction; **the aggregate method leaves one journal a month**, so the
reconciliation is at the component level only. **Neither is wrong; the workpaper must say which.**

Use the **real account names from the connected chart** (*`search_accounts`*, **[auto]**).

## Step 9 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Reconciliation Summary**
- **Period, processor name**
- **Gross-to-net decomposition**
- **Clearing balance roll-forward**
- **Variance to bank deposits**
- **Variance to processor's reported balance**

Plus the Mosofin header block: workspace name; the entity by `display_name`; **whether the processor is
connected or supplied by export**; **the posting approach in use**; **which balance definition was compared**;
whether any read returned `mock` data.

**Sheet 2: Transaction Detail**

| Date | Transaction ID | Type (Charge / Refund / Chargeback / Fee / Adjustment) | Currency | Amount | FX Rate | Functional Amount | Status |

**Sheet 3: Payout Tie-Out**

| Payout Date | Processor Reference | Payout Amount | Bank Deposit Date | Bank Amount | Variance |

**Add a column: Tied to recorded deposit, or to bank statement** — the two are different assurances.

**Sheet 4: Exceptions**

| # | Issue | Action Required |

**Typical issues:**
- **Unsettled charges still in clearing past expected payout window** — **[auto]** from the ageing
- **Chargebacks without disputed status** — **[gated]**
- **Refunds with no original transaction** — **[gated]**
- **Effective fee rate by period (trend)** — **[auto]**
- **Fees vs contracted rate** — **[manual]**, only if the user supplied the contracted rate (intake F)
- **Payouts to bank with no corresponding processor record** — **[gated]**

**Sheet 5: GL Posting** — pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 6: Presentation Checks — NEW, Mosofin-specific** — the Step 7 net-revenue test, with the signals
found and the estimated gross-up; the clearing account ageing; the fee rate by period; the charge-to-payout
lag trend.

**Sheet 7: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

**The bank statement row reads `manual`.** That is the correct entry.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Processor_Recon_[ProcessorName]_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers, and which processor.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the bank statement, the processor's rates, the contract — **name the source required**
instead of estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** per processor: clearing, revenue, fees, refunds, chargebacks, chargeback fees, output
  and input tax, and **which bank account receives payouts**
- **The posting approach** — per-transaction or aggregate — since the reconciliation differs
- **The processor's payout schedule and normal lag**, so a lengthening lag is detectable
- **The contracted fee rate**, so the rate check has a benchmark. **Not the fee amounts**
- **The balance definitions** — what this processor means by available, pending and reserve, **and which one
  the GL clearing balance corresponds to**
- **The reserve or hold arrangement**, and where the reserve receivable is recorded
- **The settlement currency and the FX policy** — transaction-date or settlement-date rate
- **The tax treatment** of fees and of gross sales in this jurisdiction
- **The entity attribution rule** where one processor account serves several entities
- The replay recipe: the exact sequence of reads that produced the roll-forward and the presentation checks

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist transaction data, balances, payout amounts, customer details or card information.**
**Cardholder data must never be stored anywhere by this skill** — not a number, not a fragment, not a
token — and **customer-level transaction detail is personal data.** Persist the account map and the rates
policy; **never the transactions.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Retail — Stripe, clearing 1210, aggregate monthly posting, 2-day payout lag, 1.4% + 20p contracted, GL
clearing includes pending" — not "clearing 1210, aggregate posting". **Account maps and processor
configurations are entity-specific**, and applying one entity's clearing account to another reconciles the
wrong balance. Record the chosen **scenario** (single vs multi, and processor connectivity) as a preference
too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One clearing account per processor.

**Multi-entity.** **One processor account serving several group entities is common**, and it is the harder
case:

- **Every transaction must be attributed to the correct entity, and the clearing account is per entity** —
  the original's own edge case. **[manual]** to define the attribution rule; **[auto]** to apply it where
  the processor tags transactions by entity, product or account.
- **A single payout covering several entities' sales** must be split. **The bank deposit lands in one
  entity's account**, so **the others are owed** — creating an intercompany balance. Reconcile it
  as an intercompany balance; both sides must agree.
- **Run the clearing roll-forward per entity**, not once for the processor account. **A processor-level
  reconciliation that balances can conceal two entities' clearing accounts being wrong in opposite
  directions.**
- **The net-revenue test runs per entity** too — one entity may be posting gross correctly and another net.
- **Currency may differ by entity**, so the settlement conversion is per entity.
- **Tax registration differs by entity**, and **output tax on gross sales is owed by whichever entity made
  the supply** — not by whichever one received the payout.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
