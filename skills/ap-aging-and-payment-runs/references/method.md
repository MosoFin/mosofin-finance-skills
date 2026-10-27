<!-- ap-aging-and-payment-runs · method.md · read for: Stages 3–6 — Steps 0–8 (evidence, normalising bills, aging buckets, discounts, penalties, prioritising the run, multi-currency, output, saving) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Parse and normalize
- Step 2 — Build the aging buckets
- Step 3 — Identify early-pay discounts
- Step 4 — Identify late-pay penalties
- Step 5 — Prioritize the payment run (if cash is constrained)
- Step 6 — Multi-currency handling
- Step 7 — Output
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical
evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the aging
report, the bill list, the payment history, the credit list and the terms catalogue do not
depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_aged_payables`* — the A/P aging, if its policy allows — **[auto]** or **[gated]**, or
  **[manual]** if disabled (then reconstruct, per Gate 2)
- *`search_bills`* — open bills, and the raw material for a reconstruction — usually **[auto]**
- *`get-bill`* — one bill's lines, terms and due date — usually **[auto]**
- *`search_bill_payments`* — what has already been paid against those bills — usually **[auto]**
- *`search_vendor_credits`* — credits available to net off — usually **[auto]**
- *`get_vendor_balance`* — total owed per vendor, for the tie-out — usually **[auto]**
- *`search_vendors`* / *`get-vendor`* — vendor master, terms, remit-to details — usually
  **[auto]**
- *`search_terms`* / *`get_term`* — the payment-terms catalogue, including discount terms —
  usually **[auto]**
- *`get_balance_sheet`* — the A/P control balance and the bank balances — usually **[auto]**
- *`search_payment_methods`* — the payment methods in use — usually **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true` (**reads only — never for a write**).
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → reconstruct if bill-level data is available (labelled as such),
  otherwise convert to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the aging's shape
but **must never drive a real payment run**. A payment proposed from fixture data would be a
real transfer of real money against an imaginary bill. If any figure is mock, say so at the
top and mark the payment run as illustrative only.

## Step 1 — Parse and normalize

Get every bill into a consistent shape before you sort anything.

For each open item — **[auto]**:

- **Keep every open item with a non-zero open amount.** Bills are positive. Unapplied vendor
  credits and unapplied payments are negative and appear in the vendor's row (bucketed by
  their own date). Drop only items with an open amount of exactly zero
- **Compute days past due = (As-of date) − (Due date)**
  - **Negative or zero (due today) = not yet due**
  - **Positive = overdue**
- **Normalize currency labels**

Where the connector returns a bill without a due date, derive it from the terms record
(*`get_term`*, **[auto]**) and **say it was derived**, since a derived due date drives every
bucket downstream.

**Flag suspicious entries** — **[auto]**, all four are computable from the pulled data:

- **Open amount > original amount** (a data error)
- **Bill date after due date** (likely a terms entry error)
- **Bill dated in the future** (capture but flag)
- **Possible duplicates** — same vendor and same bill number (ignoring punctuation and
  leading zeros); or same vendor and same amount on dates close together that do not fit the
  vendor's normal billing cycle. Flag both; never pay a flagged pair until the user confirms
  (see `duplicate-invoice-detection`)

## Step 2 — Build the aging buckets

An **aging bucket** is a band of lateness. Sorting bills into bands is what turns a list of
debts into a picture of a problem.

Default buckets (override if the user specifies different ones):

- **Not yet due**
- **1 – 30 days overdue**
- **31 – 60 days overdue**
- **61 – 90 days overdue**
- **91 – 120 days overdue**
- **Over 120 days overdue**

Output by vendor and by bucket. **Totals per vendor and per bucket.**

**[auto]** whether the buckets come from the aging report directly or are computed from bill
dates. If they were computed, say so — a report-native aging and a reconstructed one can
differ where the report applies its own aging method (aging from the due date versus from the
report date), and that difference is worth naming rather than hiding.

## Step 3 — Identify early-pay discounts

Some suppliers knock a percentage off if you pay quickly. The return on doing so is usually
enormous, so this step often pays for the whole exercise.

For each bill, check the payment terms for an early-pay discount — **[auto]** where terms are
on the bill or the terms record (*`get-bill`*, *`get_term`*, *`search_terms`*).

**"2/10 Net 30" means: 2% discount if paid within 10 days, otherwise the full amount is due
in 30 days.**

For each bill with a discount opportunity — **[auto]** arithmetic:

- **Compute the last day to take the discount**
- **Compute the discount amount**
- **Compute the implied annualized return** on taking the discount versus waiting

Implied return formula:

```
Discount % / (1 − Discount %) × (365 / (Net days − Discount days))
```

Example: 2/10 Net 30 → 2% / 98% × (365 / 20) = ~37.2% annualized (the simpler
2% × 365 / 20 = 36.5% is an approximation). **This is essentially always
worth taking if cash allows** — few uses of cash return 36% a year.

**Where a discount is taken**, the payment line shows Bill open amount, Discount and Cash
paid. The discount is recorded with the payment — a discount line or vendor credit to the
entity's purchase-discount account, named from the chart of accounts — so the bill closes in
full and does not come back in the next run.

**Flag any discount where the deadline is within the payment-run horizon.** Use the entity's
time zone from the profile when a deadline falls on the run date itself.

## Step 4 — Identify late-pay penalties

**[manual] (judgment)**: if the terms specify a late fee or interest, compute the accruing penalty for
overdue bills. Terms text is usually readable (*`get_term`*, **[auto]**), but penalty clauses
often live in the contract rather than the terms record — where that is so, the penalty is
**[manual]**.

**Flag bills accruing a penalty so the user can prioritize** — a bill quietly accruing
interest can outrank a larger one that is not.

## Step 5 — Prioritize the payment run (if cash is constrained)

When there isn't enough cash for everything, the order matters more than the total.

Rank in this default order (override if the user specifies) — **[manual] (judgment)**, since the ranking
mixes ledger facts with business judgment:

1. **Vendors marked critical** — services that stop without payment: utilities, the payroll
   provider, key SaaS, a key supplier. **[manual]** input, from the tiers confirmed at Gate 3
2. **Bills past due where the vendor is threatening collection / late penalties are accruing**
   — **[auto]** for past-due status, **[manual]** for the threat
3. **Early-pay discount opportunities expiring within the run window** — **[auto]**, because
   the discount return is usually huge
4. **Bills due this week** — **[auto]**
5. **Bills due next week** — **[auto]**
6. **Already paid / not yet due / discretionary — defer** — **[auto]** for paid and not-due,
   **[manual]** for discretionary

**Net each vendor's credits.** A vendor's proposed payment is its selected bills less its
open credits. If the credits exceed the bills, propose no payment and flag the debit balance.

**Constraint check: sum of cash paid ≤ cash available. Stop adding payments when cash
runs out. Show what's left unpaid.** The unpaid remainder is not a footnote — it is the part
the user has to make a decision about, and it belongs on the face of the output.

Because Mosofin cannot execute anything, the run is a **proposal**. Say so on the sheet, and
never phrase a line as though a payment has been made or scheduled.

## Step 6 — Multi-currency handling

If bills are in multiple currencies and the entity pays from a single-currency bank —
**[manual] (judgment)**:

- **Convert to the functional currency** at a user-provided FX rate or a stated source
  (e.g. the bank's wire rate today). **[manual]**: no accounting connector supplies a live
  wire rate, so the rate is the user's to give
- **Flag the rate source and the date used** — a converted figure without its rate and date
  cannot be checked later
- **Each payment will have an FX gain / loss at settlement** — the difference between the
  rate when the bill was booked and the rate when it is paid. Note it; recognising it is an
  FX revaluation task

## Step 7 — Output

Offer an `.xlsx` workpaper: ask the user whether they want it as an Excel file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Sheet 1: Aging Summary**

By vendor, columns = aging buckets, rows = vendors. Totals row at bottom.

Add a header block: workspace name; each in-scope company file by `display_name`; each
excluded company file and why; the as-of date; **whether the aging was report-native or
reconstructed**; whether any figure rests on `mock` data.

**Sheet 2: Aging Detail**

| Vendor | Bill # | Bill Date | Due Date | Days Past Due | Bucket | Original Amount | Open Amount | Currency | Payment Terms | Discount Eligible? | Discount Deadline | Discount Amount | Late Penalty Accruing? | Vendor Tier | Payment Method | Status |

**Sheet 3: Proposed Payment Run**

| Vendor | Bill # | Bill Open Amount | Payment Method | Reason in Run | Discount Captured | Cash Paid | Bank-detail change? |

With:
- Total proposed payment (sum of **Cash paid** — this is what counts against cash available)
- Cash available (input)
- Remaining cash after run
- Bills deferred to next run

Headed clearly: **proposal — no payment has been made or scheduled.** Ends with "Prepared by /
date — Approved by / date" (left blank for the approver).

**Sheet 3b: Held and Disputed**

| Vendor | Bill # | Amount Held | Reason | Date Opened | Owner |

**Sheet 4: Discount Opportunities**

All discount-eligible bills with deadlines, amounts, and implied annualized returns. Sorted
by return descending.

**Sheet 5: Exceptions**

Bills with data issues — flagged for cleanup before payment. Include bills missing any of the
minimum fields, and any due date that was **derived** rather than read.

**Sheet 6: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus supplied. One row per task in Steps 1–6:

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: the aging report may be enabled for one
company file and disabled for its sibling, so the same task can be `[auto]` for one and
reconstructed or `[manual]` for another.

**File naming:** `AP_Aging_and_PaymentRun_[YYYY-MM-DD].xlsx`

In a multi-entity run: `AP_Aging_and_PaymentRun_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus
one combined file named for the set. Every file states which datasource and `display_name` it
covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead
of estimating.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved
them, ask — explicitly, at that point, not earlier — whether to save this as their own
customized version. A general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- The Gate 3 answers: aging buckets if non-default, functional currency, the run cadence
- **The vendor priority tiers** — critical / standard / discretionary, per vendor. This is the
  highest-value thing to carry forward, since it is pure judgment that the books never hold
  and it would otherwise be re-asked every single week
- **Payment method per vendor**, and any remit-to grouping for vendors that bill from several
  entities
- Standing holds and disputes, with the reason and the date opened — so a held vendor is not
  quietly paid next week by a fresh run
- The prioritization order, if the user overrode the default
- The replay recipe: the exact sequence of reads that produced this run

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Do not persist vendor bank account details.** Bank details are the top payment-fraud target
(see the edge case below); they belong in the accounting or banking system with its own
controls, never in a skill bundle.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Power Co: critical, ACH" — not "Power Co: critical". The same supplier
can be critical to one entity and discretionary to another, and an unlabelled tier applied to
the wrong company file reorders a real payment run. Record the chosen **scenario** (single vs
multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's;
state is the workspace's.** Cash available is *also* state, not a decision — it changes daily
and must be asked for every run, never recalled.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One aging, one payment
run, one workpaper.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every aging line and proposed payment carrying that entity's
`display_name`. Then one cross-entity step:

- **A side-by-side comparison plus a group total.** Total A/P does aggregate meaningfully —
  but **the payment runs do not**. Each entity pays from its own bank, so each run is
  constrained by that entity's own cash. Never propose paying one entity's bill from
  another's balance unless the user explicitly confirms a shared treasury arrangement, and
  even then label it as an intercompany funding decision, not a payment run line.
- **Shared vendors** are the point of the comparison: the same supplier owed by three
  entities may be a concentration risk, may be eligible for one negotiated discount, and may
  have three different tiers assigned. Show the vendor once per entity, labelled, plus the
  group total.
- **Intercompany payables** — where one entity owes another — should be flagged and settled
  through an intercompany reconciliation, not paid through a normal run.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict
per company file.

---
