<!-- credit-memo-and-refund-handler · method.md · read for: Stages 3–6 — Steps 0–7: reading the books, type, validation against the original, tax reversal, the JEs, application, the workbook, saving; and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Identify the type
- Step 2 — Validate against the original
- Step 3 — Compute the tax reversal
- Step 4 — Construct the JE (hand off to journal-entry-builder)
- Step 5 — Application
- Step 6 — Output
- Step 7 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not an
absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the credits, the
refunds, the vendor credits and the originals do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_credit_memos`* / *`get_credit_memo`* — **customer credits already recorded**, with their
  amounts and linked invoices — usually **[auto]**
- *`search_refund_receipts`* / *`get_refund_receipt`* — **refunds already paid out** — usually **[auto]**
- *`search_vendor_credits`* / *`get_vendor_credit`* — **vendor credits held**, including unapplied ones —
  usually **[auto]**
- *`search_invoices`* / *`read_invoice`* — **the original invoices**: amount, balance, date, currency and
  **tax codes** — usually **[auto]**
- *`search_bills`* / *`get-bill`* — the original bills, for vendor credits — usually **[auto]**
- *`get_customer_balance`* / *`get_aged_receivables`* — open customer positions, including credit balances
  — usually **[auto]**
- *`get_vendor_balance`* / *`get_aged_payables`* — open vendor positions — usually **[auto]**
- *`search_accounts`* — the sales returns, chargeback fee, write-off and tax accounts — usually **[auto]**
- *`search_tax_codes`* / *`search_tax_rates`* — the tax codes in use — usually **[auto]**
- *`search_items`* / *`read_item`* — item cost, for sales returns with inventory — usually **[auto]**
- *`get_company_info`* — base currency and fiscal year end — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — a refund proposed on it would send real money
against an imaginary invoice.

## Step 1 — Identify the type

| Type | What it does | Direction |
|------|--------------|-----------|
| **Customer credit memo (applied to a future invoice)** | Reduces AR; a future invoice settles partially against this credit | AR ↓ |
| **Customer refund (cash returned)** | Reduces AR and Cash | AR ↓, Cash ↓ |
| **Vendor credit note (applied to a future bill)** | Reduces AP; a future bill settles partially against this credit | AP ↓ |
| **Vendor refund (cash received from vendor)** | Reduces AP and increases Cash | AP ↓, Cash ↑ |
| **Sales return** | A specific kind of customer credit, **with inventory implications** | AR ↓, Inventory ↑ |
| **Chargeback** | Customer-initiated reversal via a payment processor | AR varies + processor fee |
| **Write-off (goodwill)** | Credit issued to maintain the relationship, no cash | AR ↓, Expense ↑ |

**[gated]**: the *document* type recorded in the books is **[auto]** and narrows this considerably — a
refund receipt is not a credit memo — but **the distinction between a sales return, a goodwill credit and
a pricing correction is the reason, not the document**, and the reason is `[manual]`. Three of these rows
can share an identical document and require three different entries.

## Step 2 — Validate against the original

If the credit references an original invoice — **[auto]** for all four checks:

- **Confirm the invoice exists in the system** (*`search_invoices`*, *`read_invoice`*)
- **Confirm the credit amount ≤ the invoice balance.** **A credit larger than the outstanding amount needs
  management approval** — and this check is exact, since the current balance is readable
- **Confirm the period** — **credits dated after the original is fully closed may need different
  treatment, especially across fiscal years.** Compare against the fiscal year end from the profile
- **Confirm the currency matches**

**If no original invoice** — rare for customer credits, common for goodwill credits — **flag and ask for
the business reason.** **[auto]** to detect: a credit with no linked invoice is directly identifiable.

Run these checks on **every** credit in the period, not only the one being processed. Credits already
recorded that fail a check are exceptions worth surfacing — particularly a credit exceeding an invoice
balance, which nobody approved.

## Step 3 — Compute the tax reversal

**Only if tax was on the original invoice.**

**Tax on a credit memo must mirror tax on the original.** If the original had 7.5% sales tax (or 5% GST,
or 20% VAT, etc.), **the credit memo reverses that same tax amount proportionally.**

- **For full credits** → reverse the full original tax
- **For partial credits** → reverse proportional tax

**Capture the tax reversal as a separate line. Do not bundle it into the net amount.**

**[auto]** and worth doing as a check rather than only a computation: read the **original invoice's tax
codes and tax amount** (*`read_invoice`*, *`search_tax_codes`*), compute the expected reversal, and
**compare it to the tax actually on the credit**. A mismatch is a real error — it either over-claims or
under-claims tax — and it is invisible without the original to hand.

## Step 4 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit. **Mosofin does not post** — these are proposals. Use the **real account
names from the connected chart of accounts** (*`search_accounts`*, **[auto]**).

#### Customer credit memo (no cash paid)
```
DR  Sales Returns & Allowances (contra-revenue)   $net
DR  Tax Payable / Output Tax Collected            $tax (if applicable)
    CR  Accounts Receivable                          $gross
Memo: Credit memo [CM #] re: invoice [Inv #] — [reason]
```

*Contra-revenue* means it sits against sales rather than in expenses — so the top line falls, which is
usually what management wants to see.

#### Customer refund (cash returned)
```
DR  Sales Returns & Allowances                     $net
DR  Tax Payable / Output Tax                       $tax
    CR  Cash / Bank                                   $gross
Memo: Refund to [Customer] re: invoice [Inv #] — [reason]
```

#### Sales return (with inventory)
```
DR  Sales Returns & Allowances                     $net
DR  Tax Payable / Output Tax                       $tax
DR  Inventory                                      $cost
    CR  Accounts Receivable (or Cash)                 $gross
    CR  Cost of Goods Sold                            $cost
Memo: Sales return [SR #] re: invoice [Inv #] — [reason]
```

**The inventory portion uses original cost** (per the inventory costing policy: FIFO, LIFO or
weighted average). **[gated]**: the item's cost is often readable
(*`read_item`*), but whether the goods came back saleable is not — see the damaged-return edge case.

#### Vendor credit note (applied to future bill)
```
DR  Accounts Payable                               $gross
    CR  Expense / Asset originally booked             $net
    CR  Input Tax Recoverable                         $tax (reverses original recovery)
Memo: Vendor credit [VC #] re: bill [Bill #] — [reason]
```

Note the credit goes back to **the account the cost was originally booked to** — **[auto]** to determine
from the original bill (*`get-bill`*). Crediting it to a generic income account instead is a common error
that leaves the original expense overstated.

#### Vendor refund (cash received)
```
DR  Cash / Bank                                    $gross
    CR  Expense / Asset originally booked             $net
    CR  Input Tax Recoverable                         $tax
Memo: Vendor refund re: bill [Bill #] — [reason]
```

#### Chargeback
```
DR  Sales Returns / Chargebacks                    $net
DR  Tax Payable / Output Tax                       $tax
DR  Chargeback Fees Expense                        $fee
    CR  Cash / Merchant Clearing                      $gross + fee
Memo: Chargeback re: invoice [Inv #] / processor ref [Ref] — [reason]
```

**If the original sale and the chargeback are in different periods, post the reversal to the period the
chargeback occurred — do not restate the prior period unless materiality and policy demand it.**
**[manual]** for the processor fee and reference unless a processor is connected.

#### Goodwill / write-off credit
```
DR  Bad Debt Expense (or Goodwill Allowance)       $net
DR  Tax Payable / Output Tax                       $tax (only if tax recoverable on write-off in jurisdiction)
    CR  Accounts Receivable                           $gross
Memo: Goodwill write-off re: invoice [Inv #] — [reason]
```

**Tax recoverability on write-offs varies by jurisdiction. Some jurisdictions require formal bad-debt
relief procedures before reclaiming output tax. Flag for the user.** **[manual]**, always — never claim
the tax back automatically.

## Step 5 — Application

For credits applied (not refunded in cash) — **[auto]** to track:

- **Customer credit applies to a specific future invoice or remains on account**
- **Vendor credit applies to a specific future bill or remains on account**
- **Track the open credit balance until fully applied**
- **When applied, no new JE — it's a sub-ledger application that closes both the credit and the invoice
  line by the applied amount**

That last point matters and is often misunderstood: applying a credit moves nothing in the general
ledger, because the credit was already recorded when it was issued. Proposing a second entry on
application double-counts it.

For partial applications:

- **Reduce the open credit by the applied amount**
- **Reduce the corresponding invoice by the same amount**
- **Both remain open for any residual**

**[auto]** and worth running every time — **the unapplied credit register, in both directions**:

- **Customer credits unapplied**, with their age. These overstate what customers owe you and eventually
  become refund requests
- **Vendor credits unapplied**, with their age. **These are money you are owed and have not taken** — a
  negotiated discount going unused. Present the total; it is frequently material and almost always a
  surprise

## Step 6 — Output

**For single credits** → markdown summary inline + JE inputs.
**For batches** → `.xlsx` with:

**Sheet 1: Credit Memos Register**

| CM # | Date | Type | Counterparty | Original Invoice | Original Amount | Credit Amount | Tax Reversed | Reason | Status (Open / Applied / Refunded) |

Add a header block: workspace name; the entity by `display_name`; each excluded company file and why;
whether any figure rests on `mock` data.

**Sheet 2: GL Posting Inputs** (per credit) — marked as **proposals**.

**Sheet 3: Application Tracking**

| CM # | Applied to Invoice # | Amount Applied | Date Applied | Remaining Balance |

**Sheet 4: Unapplied Credits — NEW, Mosofin-specific**

| Direction (customer / vendor) | Counterparty | Credit # | Date | Amount | Age | Suggested application |

**Vendor credits appear first, sorted by value.** They are money the entity is entitled to.

**Sheet 5: Validation Exceptions — NEW, Mosofin-specific**

| Credit # | Check failed | Detail | Action required |

Covering the Step 2 checks — missing original, credit exceeding invoice balance, period mismatch,
currency mismatch — and the Step 3 tax-mirroring check.

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be verified and who supplied it |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `CreditMemos_[YYYY-MM].xlsx`

In a multi-entity run: `CreditMemos_[YYYY-MM]_[EntityDisplayName].xlsx`. Every file states which
datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the reason, the jurisdiction's write-off rules — **name the source required** instead of
estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map**: sales returns & allowances, chargeback fees, goodwill / bad debt, and the tax
  accounts, by their real names
- **The reason-code set** the entity uses, and which accounting treatment each reason maps to — the thing
  that turns Step 1 from a judgment into a lookup
- **The approval threshold** above which a credit needs sign-off, and who signs
- **The jurisdiction's position on output-tax recovery for write-offs**, and the procedure required
- **The restocking-fee policy**, if any
- **The chargeback handling**: which processor, which clearing account, how fees are coded
- **The unapplied-credit review cadence**, so vendor credits get claimed rather than aged
- The replay recipe: the exact sequence of reads that produced the credit register

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Do not persist customer or vendor names with credit amounts, reasons, or dispute detail.** A stored
record that a named customer received a goodwill credit for a quality complaint is commercially sensitive
and potentially contentious. Persist the *mapping and the policy*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — returns to Sales Returns & Allowances; goodwill credits need director approval above $500;
output tax not recoverable on write-off without formal relief" — not "goodwill credits need approval
above $500". Entities operate under different tax regimes and different authority levels, and an
unlabelled threshold applied to the wrong company file authorises a credit nobody approved. Record the
chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the open credit balance is state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One credit register, one application
tracker.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every credit carrying its entity's `display_name`. Then:

- **A credit belongs to the entity that issued the original invoice.** Applying one entity's credit
  against another's invoice is an **intercompany transaction**, not an application — it moves value
  between legal entities. Flag it and route it to an intercompany reconciliation.
- **A customer trading with several entities may hold credits at one and owe another.** They will
  frequently ask to net them. That netting is a group decision with intercompany consequences, not a
  routine application — say so rather than doing it.
- **The unapplied vendor credit sweep runs per entity and is worth totalling for the group.** A shared
  supplier may hold credits at several entities, and the aggregate is what makes the claim worth making.
- **Chargebacks arrive at whichever entity holds the merchant account**, which may not be the entity that
  made the sale. Check before coding the reversal.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
