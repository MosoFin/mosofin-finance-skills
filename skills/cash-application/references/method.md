<!-- cash-application · method.md · read for: Stages 3–6 — Steps 0–8 (evidence, parsing, the match hierarchy, short pays, overpayments, multi-currency, the proposed JE, output, saving) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Parse payments and invoices
- Step 2 — Match payments to invoices
- Step 3 — Short pay handling
- Step 4 — Overpayment handling
- Step 5 — Multi-currency
- Step 6 — Construct the JE (hand off to journal-entry-builder)
- Step 7 — Output
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the open
invoices, the customer master, the recorded payments and the credit memos do not depend on each
other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_aged_receivables`* — the **complete** open invoice population, including old items — usually
  **[auto]**
- *`search_invoices`* / *`read_invoice`* — invoice detail: number, dates, original amount,
  paid-to-date, open balance, currency, customer PO reference — usually **[auto]**
- *`search_customers`* / *`get_customer`* — the customer master, for fuzzy payer matching — usually
  **[auto]**
- *`search_payments`* / *`get_payment`* — payments already recorded and what they were applied to —
  usually **[auto]**
- *`search_deposits`* / *`get_deposit`* — how receipts were banked, and the netted-fee check —
  usually **[auto]**
- *`search_sales_receipts`* — receipts with no invoice behind them — usually **[auto]**
- *`search_credit_memos`* — credits that may explain a short pay — usually **[auto]**
- *`search_terms`* / *`get_term`* — payment terms, to identify a legitimate early-pay discount —
  usually **[auto]**
- *`search_accounts`* — the unapplied cash, customer credit, discount, bank fee, WHT and FX accounts
  — usually **[auto]**
- *`search_payment_methods`* — how methods are labelled here — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the matching logic but
**must never drive a real application or write-off**, which would show a real customer as paid when
they have not paid.

## Step 1 — Parse payments and invoices

For each payment — **[auto]** where recorded, **[manual]** from a file:

- **Date received** — use the entity's time zone for receipts near midnight
- **Amount**
- **Currency**
- **Payer name** — *often differs from the customer's legal name — it is a bank string*, truncated
  and upper-cased. This mismatch is the main cause of unmatched cash
- **Payment method** (wire, ACH, card, cheque, processor)
- **Reference field** (invoice #, statement #, PO #)

For each open invoice — **[auto]**:

- **Customer, invoice #, date, due date, original amount, paid-to-date, open balance, currency**

**Use the open balance, not the original amount**, for matching. An invoice part-paid last month
will never match on its original figure.

## Step 2 — Match payments to invoices

**Match hierarchy (stop at the highest-confidence match).** Record which level produced each match —
a level-1 and a level-5 match are not the same claim.

**1. Reference field cites the invoice number** → **exact match, apply.** **[auto]**
(*`search_invoices`* by document number). Always the best answer when available.

**2. Payer name + amount matches a single open invoice** → **high confidence.** **[auto]**. Check
first whether two open invoices share that amount; if so this is not unambiguous.

**3. Payer name + amount matches the sum of multiple open invoices** → **lump payment, apply to
those invoices (oldest first by default unless the customer specified).** **[auto]** to find
combinations; **[gated]** to choose, because several combinations can sum to the same total. Report
the combination selected and whether another existed.

**4. Payer name only matches; amount differs** — **[gated]**:

- **Amount > total open** → **overpayment**; apply to all open, leftover = customer credit
- **Amount < total open** → **partial**; apply to oldest (**FIFO**) unless specified
- **Amount = a subset of invoices** → apply to those

**5. Amount matches multiple customers' invoices** → **ambiguous; request remittance advice from the
customer or use bank string clues.** **[manual]** to resolve. Never pick one.

**6. No match** → **unidentified deposit. Park in a "Customer Deposits — Unidentified" account, hold
for research.** **[auto]** to identify what already sits there and how long it has been there
(*`search_accounts`*, *`get_general_ledger`*).

**Apply fuzzy matching for payer names (string similarity ≥ 0.85).** **[auto]** against the customer
master (*`search_customers`*). Common variants:

- **"ABC Corporation" vs "ABC CORP"** → match
- **"John Smith" paying for "Smith Consulting LLC"** → **flag** — a person paying for a company is a
  real relationship but not a name match, and it needs confirming once, then storing as an alias
- **Bank truncation ("ACME C")** → match against customers starting with "ACME C"

Present every fuzzy match with its similarity score and the alternatives considered. **Never
auto-accept below the threshold**, and store confirmed aliases at Step 8 so the same puzzle is not
re-solved every month.

## Step 3 — Short pay handling

When a customer pays less than the invoice total, the reason determines the accounting. Guessing
wrong either hides a dispute or writes off money you were entitled to.

| Reason | Treatment |
|--------|-----------|
| **Customer-claimed deduction** (damage, shortage) | Apply payment, leave residual open as **"Disputed"** pending investigation |
| **Early-pay discount taken** | Apply payment + book **Sales Discount** for the difference **if terms allowed it** |
| **Bank fee deducted** (cross-border wires often deduct) | Apply payment + book **Bank Fee** for the difference |
| **Withholding tax deducted** (cross-border) | Apply payment + book **Withholding Tax Receivable** for the difference, **pending tax certificate** |
| **Rounding / FX difference** | Apply payment + book **FX Gain/Loss** for the difference |
| **Unknown reason** | Apply payment, leave residual open, **flag for collections follow-up** |

**Distinguish carefully — short pays without explanation are different from short pays with a
documented reason.**

**[auto]** contributions that materially narrow the guesswork:

- **Check for an outstanding credit memo** first (*`search_credit_memos`*) — a short pay matching a
  credit is not a deduction at all
- **Check the invoice's terms** (*`get_term`*, *`read_invoice`*) — a discount taken **within** the
  discount window on terms that offer one is evidenced, not assumed; a "discount" taken outside the
  window is an unauthorised deduction and belongs in the last row, not the second
- **Check the deposit against its receipts** (*`get_deposit`*) — a shortfall at deposit level rather
  than payment level points to a bank or processor fee

The reason itself, where none of those apply, is **[manual]**.

## Step 4 — Overpayment handling

When a customer pays more than the open invoices:

- **Apply to all open invoices**
- **Park the excess in "Customer Credit" or "Unapplied Cash"**
- **Don't book the excess as revenue** — it isn't yours yet; it is money you owe back or owe goods
  for
- **Flag for application against future invoices or refund**

**[auto]** to check first for a **duplicate payment** — a customer paying the same invoice twice
looks identical to one overpaying once (*`search_payments`* for a matching earlier receipt). The
remedies differ: a duplicate is usually refunded, an overpayment usually held.

## Step 5 — Multi-currency

If the payment currency ≠ the invoice currency — **[gated]**:

- **Use the receipt date's FX rate to convert** — **[manual]**; no accounting connector supplies a
  rate. Record the rate and its source
- **Book FX gain/loss** for any difference between (invoice converted at the invoice rate) and (cash
  converted at the receipt rate)
- **Apply the payment to the invoice in the invoice currency at the converted equivalent**

**[auto]** to detect that the step applies at all: compare the currencies on the payment and the
invoice.

## Step 6 — Construct the JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — this is a proposal.

Per payment:

```
DR  Cash / Bank                             $payment amount
    CR  Accounts Receivable                    $applied to invoices
    CR  Customer Credit / Unapplied (if overpay) $overpay
    DR  Sales Discount (if discount taken)
    DR  Bank Fee (if fee withheld)
    DR  Withholding Tax Receivable (if WHT)
    DR/CR  FX Gain/Loss (if multi-currency)
Memo: Cash application — [Customer] — [Reference]
```

**Every sub-component appears on its own line.** Netting a bank fee into the cash line hides a real
cost; netting a discount into A/R hides a real margin reduction. Use the **real account names from
the connected chart of accounts** (*`search_accounts`*, **[auto]**), and say which you chose.

## Step 7 — Output

Offer an `.xlsx` workpaper: ask the user whether they want it as an Excel file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Sheet 1: Application Summary**

- Total payments processed
- Total applied to invoices
- Total parked as customer credit / unapplied
- Total in unidentified deposits
- Short-pay residuals open

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one
and why; **which population was processed — recorded payments or a supplied file**; whether any
figure rests on `mock` data.

**Sheet 2: Payment-to-Invoice Mapping**

| Payment ID | Date | Payer | Amount | Currency | Invoice # | Applied Amount | Residual | Match Type | Confidence |

**Match Type** is the hierarchy level (1–6); **Confidence** carries the fuzzy-match score where one
was used.

**Sheet 3: Exceptions**

| Payment ID | Issue | Recommended Action |

Issues:
- **Unidentified** — needs research
- **Short pay** — needs collection follow-up
- **Overpay** — needs credit / refund decision
- **Multi-customer ambiguous**

**Sheet 4: GL Posting**

Pass-through to `journal-entry-builder`, marked clearly as **proposals**.

**Sheet 5: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

Rows for remittance advices, FX rates and withholding tax certificates will read `manual` with their
gaps named. That is the correct, expected result.

In a multi-entity run this sheet is **per entity**.

**File naming:** `Cash_Application_[YYYY-MM-DD].xlsx`

In a multi-entity run: `Cash_Application_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus one combined
file. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The payer-alias map** — every confirmed bank string, truncation and third-party payer against
  its customer. The highest-value artefact here by a wide margin: it is pure accumulated knowledge,
  never in the ledger, and it directly reduces unidentified cash on every future run
- **Tolerances** for short and over pay, and the application order (FIFO or otherwise)
- **The account mapping**: unapplied cash, customer credit, sales discount, bank fee, withholding
  tax receivable and FX accounts, by their real names
- **Customers who habitually withhold tax at source**, and the jurisdiction and rate
- **Customers who pay by statement or by PO** rather than invoice number
- Standing disputes and their owners
- The replay recipe: the exact sequence of reads that produced this run

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist bank account numbers, payment-level data, customer balances, or remittance
contents.** Those are transaction records; persist the *aliases and the rules*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — payer 'NRTHWD TRDG LTD' = Northwood Trading; tolerance $5; FIFO" — not "payer
alias". The same bank string can belong to different customers at different entities, and a
misapplied alias credits the wrong company. Record the chosen **scenario** (single vs multi, and
which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that
is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One application schedule, one JE
set.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every payment and match carrying that entity's `display_name`. Then one
cross-entity step:

- **The lump payment covering several entities' invoices** is the genuine cross-entity case, and it
  is common where a group bills one customer from more than one company. **Split it explicitly by
  entity**, show the split and its basis, and never let one entity's books absorb the whole receipt.
  Each entity's portion is applied against that entity's own open invoices only.
- **A parent paying on behalf of subsidiaries** is the same shape — apply to the subsidiary's
  invoices, capture the parent as payer-of-record, and record the alias per entity.
- **A shared bank account across entities** makes attribution ambiguous by design. Say so rather
  than allocating silently.
- **Compare unidentified-cash levels across entities** — one entity with far more than its siblings
  usually has a payer-naming or remittance problem rather than a customer problem.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
company file.

---
