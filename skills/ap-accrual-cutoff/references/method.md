<!-- ap-accrual-cutoff · method.md · read for: Stages 3–6 — Steps 0–8 (evidence, GRNI, recurring vendors, post-period invoices, amount and tax, proposed and reversing JEs, materiality, output, saving) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Identify accrual candidates from open POs (GRNI)
- Step 2 — Identify recurring-vendor accruals
- Step 3 — Identify post-period invoices for in-period services
- Step 4 — Calculate the accrual amount
- Step 5 — Build the accrual JE (hand off to journal-entry-builder)
- Step 6 — Materiality screen
- Step 7 — Output
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical
evidence tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named
gap*, not an absence.

Tool names in *italics* are typical. Resolve the real names and policies from your Gate 2
catalog — the italic name is a pointer, not a promise.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — open
purchase orders, in-period bills, post-period bills, and vendor spend history do not depend
on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_purchase_orders`* — commitments made, the GRNI starting population — usually
  **[auto]**
- *`get_purchase_order`* — one PO's line detail: quantity and unit price — usually **[auto]**
- *`search_bills`* for the period — what has already been billed — usually **[auto]**
- *`search_bills`* for the **subsequent window** (period end + 1 through the close date) —
  the late invoices of Step 3 — usually **[auto]**
- *`get-bill`* — one bill's line detail and its service dates — usually **[auto]**
- *`get_vendor_expenses`* — spend per vendor over several prior periods, to establish the
  recurring pattern and the expected amount — usually **[auto]**
- *`search_accounts`* — the chart of accounts, to find the accrued-liability account —
  usually **[auto]**
- *`get_trial_balance`* / *`get_balance_sheet`* — the accrued-liability balance carried in —
  usually **[auto]**
- *`search_journal_entries`* — last period's accruals and whether their reversals posted —
  usually **[auto]**
- *`get_company_info`* — fiscal calendar and base currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → ask the user in chat, then re-invoke the same tool with
  `approved=true` (**reads only — never for a write**).
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can show the shape of a schedule
but **cannot support a posted entry**. Say so at the top if any proposed accrual rests on it.

## Step 1 — Identify accrual candidates from open POs (GRNI)

**GRNI — "goods received, not invoiced"** — means the stuff turned up but the bill hasn't.
You owe for it, so it belongs in this period even though nothing has been billed.

A **purchase order (PO)** is the order you placed. A **goods receipt (GRN)** is the record
that it arrived.

Process:

- **Pull every PO still open at period end, whatever its PO date** (search from the oldest
  open PO, not from the period start), **and the receipts dated on or before period end** —
  goods received in an earlier month and still unbilled are GRNI too; receipts dated after
  period end are excluded — **[auto]** for the POs themselves
  (*`search_purchase_orders`*, *`get_purchase_order`*); **[gated/manual] for the receipts**.
  This is the honest split, and it is the single most important capability judgment in this
  skill: most accounting connectors expose **orders and bills, but no separate
  goods-receipt object**. Where no receipt record exists in the connected books, ask the
  user where receipts are logged (a warehouse system, a signed delivery note, an inventory
  module) and treat the receipt quantity as **[manual]** input.
- **For each line: GRN qty × PO unit price = expected accrual value** — **[auto]**
  arithmetic; **[auto]** for the unit price from the PO line; receipt quantity per the
  verdict above.
- **Subtract any invoices already matched against that PO line** — **[auto]** where bills
  reference their PO (*`search_bills`*, *`get-bill`*). Where the connector does not carry
  the PO link on the bill, match by vendor, date, amount and description and **say the match
  was inferred, not linked** — an inferred match is a judgment, and a wrong one causes the
  double-count Step 7's quality standard forbids. Net only bills **dated on or before period
  end**; a bill dated after period end for these goods leaves the line as GRNI here and is
  excluded from Step 3.
- **Net = GRNI to accrue** — **[auto]**.

**For services with completed service confirmations: same logic** — confirmed delivery
without an invoice is an accrual. Service confirmations are almost always **[manual]**;
where the workspace tracks time, *`search_time_activities`* (**[auto]**) can evidence that
work was performed even when no confirmation document exists.

## Step 2 — Identify recurring-vendor accruals

Some bills arrive every month like clockwork. If this month's hasn't landed yet, it still
needs to be in this month's numbers.

For each recurring vendor (rent, utilities, subscriptions, maintenance contracts, **staff
augmentation** — contract staff working alongside your own — etc.):

- **Confirm a bill covering this period's service has been received and posted** — **[auto]**
  (*`search_bills`* for the period, by vendor; read the service period, not the bill date).
- **If not, accrue at the expected amount** based on — **[auto]** for the most recent invoice
  and the recurring schedule; **[manual]** for the contract amount unless a recurring
  template exists:
  - **The most recent invoice for the same service** (*`search_bills`*, *`get-bill`*)
  - **The contract / agreement amount** — **[manual]** where the contract is not in the
    books; **[auto]** where a recurring template or standing order exists
  - **The recurring schedule** (`recurring-transaction-builder`)
- **Flag any variance from prior periods** — **[auto]** by comparing the expected amount
  against several prior months (*`get_vendor_expenses`* with a monthly breakdown). E.g. this
  month's expected utility bill is unusually high or low.

Identifying the recurring population itself is **[auto]** and worth doing properly: a vendor
billed in each of the last several periods but not this one is exactly the accrual candidate
that gets missed by hand.

## Step 3 — Identify post-period invoices for in-period services

Look at what arrived *after* you closed the gate, and ask whether it really belongs inside.

**Subsequent-events review**: look at invoices received after period end — posted, or
unposted ones the user sent from the inbox or approval queue — dated
after period end, but **for services delivered before period end**. **[auto]** to find them
(*`search_bills`* with `start_date` = period end + 1 through the close date confirmed at
Gate 3); **[manual] (judgment)** to judge each one, because the service period is often in
the description rather than a structured field.

**The service period is the test** — not the invoice date:

- **Service date / period entirely in the period being closed → accrue**
- **Service date / period entirely in the new period → don't accrue**
- **Service period straddles the cutoff → accrue the in-period portion (pro rata)** —
  *pro rata* meaning split in proportion to the days on each side

Where the bill does not state its service period, that judgment is **[manual]** — record it
in the exceptions sheet rather than guessing a split.

## Step 4 — Calculate the accrual amount

**Each cost lands in exactly one population.** Order: GRNI, then subsequent invoice, then
recurring. A recurring vendor whose bill for this service period is found in the subsequent
window is priced from that bill under Step 3 and dropped from Step 2.

For each candidate:

- **Estimate the expense amount, net of recoverable tax** — **[auto]** from the evidence
  gathered above. If the source figure includes tax, take the tax out.
- **Tax handling** depends on whether the entity's jurisdiction allows accrual of **input
  tax** (the recoverable sales tax / VAT / GST on what you buy) on services without an
  invoice — **[manual]**, always, because this is a rule, not a number in the ledger:
  - **Most jurisdictions**: tax recovery requires a **valid tax invoice** — so accrue the
    expense net of recoverable tax, book no input-tax line, and recognise the tax when the
    invoice arrives
  - **Some jurisdictions**: tax can be accrued — book input-tax recoverable alongside the
    expense
  - **Confirm with the user — do not assume**, and do not carry a rule over from a stored
    preference without re-confirming it

**The conservative default**: accrue the expense **net of recoverable tax** (the amount
excluding tax), with no input-tax line, and let the tax come through when the actual tax
invoice posts. Where tax is **not** recoverable, the tax is part of the cost and is accrued
with it.

The tax accounts and codes in use are **[auto]** to discover (*`search_tax_codes`*,
*`search_tax_rates`*, *`search_accounts`*), which helps you name the right account — but the
recoverability rule stays the user's to confirm.

## Step 5 — Build the accrual JE (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. `BS` means the balance sheet.
**Mosofin does not post these** — it drafts them.

For each accrual:

```
DR  Account the PO line / bill will post to         $accrual amount
    CR  Accrued Liabilities (BS, per user's COA)      $accrual amount
Memo: Accrue [service] from [vendor] for [period] — invoice expected [date]
```

Mark each JE as **reversing on the first day of the new period**:

```
DR  Accrued Liabilities                            $accrual amount
    CR  Same account the accrual debited               $accrual amount
Memo: Reversal of accrual [original JE #] — original [vendor] [service]
```

**The debit goes to the account the real bill will post to** — for a GRNI line, read the PO
line's item or account (*`get_purchase_order`*): the **inventory asset** account for stock
items, the **fixed-asset** account for capital items, otherwise the expense account. Goods
received and held at period end are stock or equipment, not this month's expense.

**The reversal cancels the accrual; when the real invoice posts, it hits the same account the
accrual debited, netting clean.**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which account you chose.
**[auto]** to check whether last period's reversals actually posted
(*`search_journal_entries`* over the first days of the current period) — an unreversed
accrual is the most common cause of a creeping accrued-liabilities balance.

## Step 6 — Materiality screen

**Materiality** is the size below which a difference isn't worth chasing.

If the user provided a materiality threshold:

- Accruals **below** the threshold can be skipped, **with disclosure**
- Accruals **above** the threshold are required
- **The sum of skipped items must remain immaterial in aggregate** — flag if the cumulative
  immaterial items add up to a material amount. Individually trivial, collectively they can
  change the picture, and the aggregate is what an auditor asks for.

**If no threshold was provided, accrue everything identified** — and say that is what you
did, rather than quietly applying a figure of your own.

## Step 7 — Output

Offer an `.xlsx` workpaper: ask the user whether they want it as an Excel file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Sheet 1: Accrual Summary**

- Period closed
- Total accruals by category (GRNI / recurring / subsequent invoices)
- Total accrual amount (functional currency)
- Materiality threshold applied
- Count of items above / below threshold
- **Added:** workspace name; each in-scope company file by `display_name`; each excluded
  company file and why; whether any figure rests on `mock` data
- **Accrued-liability roll-forward:** opening balance per trial balance (agreed to last
  period's closing schedule) − reversals posted + proposed accruals ± other postings =
  proposed closing. List every residual item older than one period with owner and action, and
  separate AP-accrual items from other accruals (payroll and the like) held in the same account
- Prepared by / date — Reviewed by / date (left blank for the reviewer)

**Sheet 2: GRNI Accruals**

| Vendor | PO # | PO Line | GRN # | Cumulative Qty Received to Period End | Unit Price | Cumulative Amount Invoiced to Period End | Match (linked / inferred) | GRNI Amount | Currency | Functional Amount | Debit Account | Debit account type (inventory / asset / expense) | Memo |

GRNI Amount = received × unit price − invoiced, readable off each row. Add a column
recording, per line, whether the receipt quantity came from a tool or from the
user — the GRN column is frequently the manual one.

**Sheet 3: Recurring Accruals**

| Vendor | Service | Expected Amount | Source (prior invoice / contract) | Variance vs Prior % | Expense Account | Memo |

**Sheet 4: Subsequent Invoices**

| Vendor | Invoice # | Invoice Date | Service Period Start | Service Period End | Accrual Period Portion | Amount Accrued | Expense Account | Memo |

**Sheet 5: Proposed JEs**

Pass-through to `journal-entry-builder`, including both the period-end accruals and the
first-day-of-next-period reversals. Marked clearly as **proposals**.

**Sheet 6: Exceptions / Open Items** — each with Owner | Action needed | Due by | Effect if
unresolved

- Receipts on POs with no unit price (estimate needed)
- Services with a completion confirmation but no contract value
- Subsequent invoices with an unclear service period
- Variances vs. prior period flagged for review
- **Added:** PO-to-bill matches that were **inferred** rather than linked

**Sheet 7: Coverage — NEW, Mosofin-specific**

The auditable record of what was verified versus estimated. One row per accrual candidate:

| Item | Category (GRNI / recurring / subsequent) | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

In a multi-entity run this sheet is **per entity**: a tool enabled for one company file may
be disabled for its sibling, so the same task can be `[auto]` for one and `[manual]` for
another.

**File naming:** `AP_Accruals_[YYYY-MM]_Cutoff.xlsx`

In a multi-entity run: `AP_Accruals_[YYYY-MM]_[EntityDisplayName]_Cutoff.xlsx`, plus one
combined file named for the set. Every file states which datasource and `display_name` it
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

- The Gate 3 answers: materiality threshold, tax jurisdiction and the input-tax accrual rule
  confirmed, subsequent-event window, functional currency
- The **recurring vendor list** with each one's expected amount, basis, and expense account —
  the single highest-value thing to carry forward, since it turns Step 2 from discovery into
  confirmation
- The account mapping: which accrued-liability account, and which expense account per vendor
  or category, by their real names in the chart of accounts
- Standing exclusions and why
- How receipts are evidenced when the books hold no goods-receipt record
- The replay recipe: the exact sequence of reads that produced this period's schedule

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — rent accrual $8,400/mo to Occupancy Costs, materiality $500" — not "rent
$8,400". One entity's landlord is not another's, and an unlabelled recurring-vendor list
applied to the wrong company file books a cost that does not exist there. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong
to the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's;
state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One accrual schedule, one
JE set, one workpaper.

**Multi-entity.** Steps 0–7 run **once per entity**, each call targeting exactly one
`data_source_id`, every accrual line carrying that entity's `display_name`. Then one
cross-entity step:

- **A roll-up** of total accruals by category and entity — accruals do aggregate meaningfully,
  but only once each entity is shown on its own line first.
- Watch for the **shared vendor**: one supplier billing several entities is normal, but the
  same invoice accrued at two entities is a double-count. Compare vendor and amount across
  entities before combining.
- Watch for the **intercompany accrual**: an accrual at one entity may be an unbilled
  receivable at another. Flag the pair rather than netting silently; clearing the pair is an
  intercompany reconciliation.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict
per company file.

---
