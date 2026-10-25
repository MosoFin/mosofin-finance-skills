<!-- prepaid-amortization-schedule · method.md · read for: Stages 1 and 3–6 — the verdicts, the Inputs table, Steps 0–10, and seed to evolved. Edit here, not in SKILL.md. -->

## Contents

- How to read the verdicts
- Inputs
- Workflow
- Seed to evolved: what happens on the first real run


## How to read the verdicts

Every task below is tagged. This is the point of the conversion, so the tags are used strictly and never omitted to make a step look better than it is.

- **`[auto]`** — Mosofin can do this from live reads, unattended, with no further permission.
- **`[gated]`** — Mosofin can do this, but the gateway will ask first. Expect `approval_required`; explain, get consent, re-invoke with `approved=true` and the `data_source_id` —
  **reads only; never re-invoke a write**, see the hard stop in Gate 2.
- **`[manual]`** — Mosofin cannot do this at all. The evidence is not on this surface, or the judgment is not a machine's to make. The step is still here, still required, and the user performs it.

A step with three sub-parts may carry three different verdicts. That is normal and is shown rather than averaged into one.

**Everything this skill produces is a proposal.** Mosofin's gateway is read-only. It reads books; it does not write to them. Every entry below is drafted for a human to review and post in the accounting system themselves. Nothing in this skill posts anything. If a sentence anywhere seems to say otherwise, this sentence is the one that is right.

---

## Inputs

| Input | Format | Required | Mosofin source | Verdict |
|-------|--------|----------|----------------|---------|
| List of prepaid items | Vendor, description, amount, payment date, coverage period | **Required** | Amount, vendor and payment date are readable from the prepaid account's transaction detail and the bill/payment records. **The coverage period is not.** | `[auto]` in part, `[manual]` for coverage dates |
| Currency per item | ISO code | **Required if multi-currency** | On the transaction record | `[auto]` |
| Functional currency | ISO code | **Required** | Company/preferences record | `[auto]` |
| Chart of accounts | For prepaid asset and expense accounts | **Required** | Live read of the account list | `[auto]` |
| Tax jurisdiction | For tax handling on the original invoice | Recommended | Tax codes on the bills are readable; the *jurisdiction rules* are not | `[auto]` for the codes, `[manual]` for the treatment |
| Materiality threshold | Below which an item is expensed directly | Recommended | Not in the books. A policy decision. | `[manual]` (Gate 3) |
| Amortization frequency | Monthly (most common), quarterly | Optional | Inferable from the posting pattern; confirm rather than assume | `[auto]` to observe, `[manual]` to set |

For each prepaid item the original skill requires eight fields. They are all kept, with their source stated:

| Field | Mosofin source | Verdict |
|---|---|---|
| Vendor name | Bill / payment record | `[auto]` |
| Description / what was paid for | Memo and line description — **as good as whoever typed it** | `[auto]` to read, `[manual]` to trust |
| Invoice / contract reference | Document number on the transaction | `[auto]` |
| Original payment amount (gross if tax-inclusive, net otherwise) | Transaction amount | `[auto]` |
| Recoverable tax, kept separate from the prepaid asset | Tax lines on the bill | `[auto]` |
| Payment date (cash outflow) | Payment / bill payment date | `[auto]` |
| Coverage period start | **Not in the ledger** | `[manual]` |
| Coverage period end | **Not in the ledger** | `[manual]` |

### A near-substitute is not a substitute

Six of the eight fields come out of the books cleanly. The two that do not are the two that make it a schedule.

It is very tempting to treat the **invoice memo** as the coverage period. Resist it. "Annual policy renewal" does not say *which* twelve months. "Q3 licence" does not say whose quarter. "Insurance — 12 mo" is closer, and still does not tell you whether coverage started on the invoice date, the payment date, or the first of the following month — and the original skill is emphatic that this distinction is exactly the one that matters (Step 3).

Equally tempting: treating the **payment date plus twelve months** as the coverage period. It is right often enough to be dangerous. When it is wrong it is wrong by weeks, in the same direction, every year, and it produces a schedule that never quite ties and nobody can explain.

Where the coverage dates are unknown, say **unknown**. Put the item on the schedule with the dates blank and a flag. An honest gap is a work item. A guessed date is a silent misstatement that will be inherited by next year's schedule and the year after.

---

## Workflow

### Step 0 — Read the shape of the prepaid account before touching anything else

*(A Mosofin addition. There is no equivalent step in the original, because the original had no ledger to look at.)*

Before building or checking any schedule, pull the prepaid account's full transaction detail for at least twenty-four months, along with the account list. This is one batched read and it decides how the rest of the run goes.

**Test 0a — Does the account ever come down?** `[auto]`

Sum debits and credits to the prepaid account by month.

- Debits every month, credits never → **amortization has not been posted at all.** The balance is a growing pile of expired coverage. This is a material finding on its own and you have made it in one query.
- Debits and credits both present, but credits absent in some months → **a missed amortization run.** Name the months. The recurring entry probably stopped and nobody noticed, which is the ordinary way this fails.
- Credits present every month → good. Move to 0b.

**Test 0b — What do the credits look like?** `[auto]`

Read the amortization credits themselves.

- Identical to the cent, every month → a straight-line schedule is being run consistently. Good sign.
- Varying by a few units → daily proration, or a schedule with items starting and ending mid-stream. Normal.
- **Round numbers, differing month to month, entered by hand** → this is not a schedule being run. It is an estimate being posted. Say so. The whole point of the workpaper this skill produces is to replace that.

**Test 0c — Does anything odd live in this account?** `[auto]`

Scan the debits for entries that do not look like prepayments at all:

- Round-sum amounts to landlords or utilities → likely **refundable deposits**, which are not prepaid (see Step 1).
- Large single amounts to equipment vendors → likely **fixed assets** miscoded (see `fixed-asset-register-and-depreciation`).
- Entries with an FX or revaluation source → see the foreign-currency edge case; a prepaid asset is **non-monetary** and generally should not be revalued.
- Entries from a journal source with no vendor → these need explaining before they go on any schedule.

**Test 0d — Is the balance bigger than the last twelve months of additions?** `[auto]`

If everything in this book is annual (and Step 1's candidate list will tell you whether it is), the prepaid balance should never much exceed one year of prepayments. If it does, there is **residue from coverage that has already expired** sitting in the asset. You cannot say which items without the schedule. You can say, with confidence and with figures, that some exists.

These four tests take one round trip and, on a neglected set of books, will often be the most valuable thing this skill produces all day.

---

### Step 1 — Identify prepaid candidates

The original list is preserved in full, with the workspace read that finds each one.

**Common prepaid items** — and how they surface in a live ledger:

| Item | Signature in the books | Verdict |
|---|---|---|
| Insurance premiums paid annually | One large debit to an insurance expense account, once a year, from a broker or carrier | `[auto]` |
| SaaS / software annual contracts | Annual charge from a software vendor; frequently the same month each year | `[auto]` |
| Maintenance contracts | Annual or multi-year charge from an equipment or facilities vendor | `[auto]` |
| Rent paid in advance | Payment to a landlord dated *before* the period it covers, or a thirteenth payment in a twelve-month year | `[auto]` |
| Property tax paid in advance | Charge from a municipal authority, usually annual or semi-annual | `[auto]` |
| Annual subscriptions, memberships | Professional bodies, trade associations, licences | `[auto]` |
| Professional retainers covering future services | Payment to a law or advisory firm with no matching engagement activity | `[auto]` to find, `[manual]` to judge |
| Deposits that are expensed over time | Requires reading the agreement | `[manual]` |
| Marketing pre-buys (annual ad spend committed upfront) | One large media charge, then flat | `[auto]` |

**The general query behind all nine rows** `[auto]`: read the expense ledger for the period and rank accounts by *lumpiness* — the ratio of the largest single charge to the account's monthly average. A twelve-month premium expensed in one hit produces a ratio near twelve. A genuinely monthly expense produces a ratio near one.

**This is the highest-yield `[auto]` in the skill.** The original Step 1 is a memory exercise: the accountant tries to remember what was paid in advance. On live books it is a ranked list, and the top of that list is almost always right.

**Items that are NOT prepaid** — the original's four confusions, kept, each with the test:

| Not prepaid | Correct home | How to tell | Verdict |
|---|---|---|---|
| Refundable deposits | Asset: Deposits | The money comes back at the end; nothing is consumed. Round sums, landlords and utilities. | `[auto]` to flag, `[manual]` to confirm from the agreement |
| Equipment purchases | Fixed Asset, depreciated | A thing exists afterwards. See `fixed-asset-register-and-depreciation`. | `[auto]` to flag |
| Inventory purchases | Inventory, expensed as COGS on sale | Goods for resale, costed as inventory. | `[auto]` to flag |
| Investments in financial instruments | Separate accounting entirely | Broker or fund counterparty | `[auto]` to flag |

Flagging is automatic. **Deciding** is not — a deposit that will be applied to the final month's rent behaves like a prepaid; one that comes back in cash does not. Only the agreement says which, and the agreement is not on this surface.

---

### Step 2 — Apply materiality

`[manual]` for the threshold, `[auto]` for everything downstream of it.

The original is explicit and correct: *the threshold is the user's decision; this skill applies it.* That does not change here. Mosofin does not set materiality.

What Mosofin adds is the ability to show the user **what their threshold actually does** before they commit to it, which is not something the original could offer:

- `[auto]`: list the candidate prepaids that fall below the stated threshold, with a count and a total.
- `[auto]`: compute the aggregate P&L effect of expensing all of them directly in the month of payment, rather than spreading them.
- `[auto]`: show that effect month by month across the year, so the user can see whether the lumpiness it introduces is tolerable.

A threshold that looks harmless per item can be material in aggregate when there are forty small annual subscriptions. That is a real finding, it is arithmetic, and it is one read.

Above threshold → schedule it. Below → expense directly, if that is the policy. Either way, **record the threshold used on the coverage sheet**, so next period's run does not silently apply a different one.

---

### Step 3 — Determine the amortization period

`[manual]` at its core. This is the step the ledger cannot do, and the honest thing is to lead with that rather than bury it.

The original's rules are preserved exactly:

- **The coverage period is the basis.** A twelve-month insurance policy amortizes over twelve months.
- **Amortization is effective from the start of coverage, not the payment date**, and the two frequently differ.
- **If service starts mid-period** — payment on 15 June for service running 1 July to 30 June — **amortization starts 1 July.** Not June.
- **If service ends mid-period**, amortization ends on the end date and the final period takes a partial.
- **For irregular coverage** (an annual subscription whose use is tied to events), amortize ratably over the contract term **unless the consumption pattern materially differs.**

Each of these needs a date that exists on a contract, not in a ledger. So:

**What the workspace can contribute here** `[auto]`:

- The **payment date** exactly. This is the anchor, and it is the thing most often mistaken for the start of coverage. Show it next to the coverage start so the difference is visible rather than assumed.
- The **invoice date and document reference**, which is what the user will use to find the contract.
- **Prior-year behaviour.** If the same vendor was prepaid last year and the year before, the pattern of payment dates tells you the renewal cycle. That does not establish the coverage period — but it will often tell you when to expect it, and it will flag a renewal that has moved.
- **Whether a renewal has been missed.** A vendor prepaid every March for three years with nothing this March is either a cancelled contract or an unbooked one. Both are worth raising.

**What it cannot contribute:** the dates themselves. Ask for them, one item at a time, and leave them blank with a flag where the answer is not available. Do not derive them from the payment date. See "a near-substitute is not a substitute" above — this is the case that section was written for.

---

### Step 4 — Compute monthly amortization

`[auto]`, once Step 3 has supplied the dates. This is arithmetic and the arithmetic is not in dispute.

Default method: **straight-line over the coverage period.**

```
Monthly amortization = Total prepaid amount / Total months of coverage
```

For partial months at the start or end:

```
Partial month amortization = (Monthly amortization x Days in partial month) / Days in full month
```

Or, more simply, prorate on calendar days throughout:

```
Daily amortization = Total prepaid amount / Total days of coverage
Period amortization = Daily amortization x Days in that period
```

**Pick one method per item and apply it consistently. Document which.** The original says this and it is preserved because it is where schedules go wrong quietly: a book that whole-months some items and day-prorates others will never reconcile cleanly, and nobody will be able to say why.

`[auto]` addition: **observe which convention the existing entries already follow.** Step 0b has already told you whether the historic credits are flat or varying. If the client has been whole-monthing and the new schedule day-prorates, the change will show up as a small unexplained variance in the tie-out. Better to notice that before it appears in Sheet 3 than after.

For items with **materially uneven benefit patterns** — a marketing campaign with concentrated launch spending — amortize on benefit consumed if it is measurable; otherwise straight-line. Measuring benefit consumed is `[manual]`; the ledger records what was paid, not what was used.

---

### Step 5 — Build the schedule

`[auto]` for the construction and the checks; `[manual]` for the inputs it is built from.

For each prepaid item:

| Period | Period Start | Period End | Opening Balance | Period Amortization | Closing Balance |
|--------|--------------|------------|-----------------|---------------------|-----------------|

All three of the original's verifications are kept, and all three are `[auto]`:

- Sum of all period amortizations = total prepaid amount
- Closing balance after the last period = 0
- Opening balance minus period amortization equals closing balance, on every row

**These verify the schedule against itself.** They are worth running — they catch rounding drift and a mis-keyed month count — but be clear about what they prove. A schedule that satisfies all three is *internally consistent*. It is not thereby *correct*. If the coverage end date is wrong, every row above will still tick, and the schedule will still be wrong. Internal consistency is a floor, not a result. Step 8 is where the schedule meets something outside itself.

`[auto]` addition — **rounding**: force the final period to absorb the rounding difference rather than letting it accumulate. A twelve-way split of an amount that does not divide by twelve leaves a residue, and a residue left in the closing balance means the account never quite clears. Put it in the last month and say you have.

---

### Step 6 — Initial booking, at payment

`[auto]` to draft and to check; `[manual]` to post — as with every entry in this skill.

When the prepayment is made:

```
DR  Prepaid Expense (BS asset, per user's COA)         $net amount
DR  Input Tax Recoverable (if jurisdiction allows)     $tax
    CR  Cash / Bank or AP                                $gross
Memo: Prepayment to [vendor] for [service] covering [start - end]
```

The memo line matters more here than almost anywhere else in accounting, because it is the **only place the coverage period will ever be recorded inside the accounting system.** Everything this skill has said about coverage dates not being in the ledger is true only because people leave this memo blank. Write it properly and next year's run gets easier.

**If the entire amount was already expensed in error, reverse the expense to set up the prepaid asset.** `[auto]` to detect — this is precisely what Step 1's lumpiness scan finds — and `[auto]` to draft the correcting entry. Posting remains the user's.

**Tax, and a real finding available here** `[auto]`:

In a jurisdiction with recoverable VAT/GST, the tax should come out at payment and be recovered in full then — **not amortized over the coverage period**. The original states this in its edge cases and it is worth pulling forward, because the ledger will tell you whether it happened.

Read the prepaid debits against the gross invoice amounts on the corresponding bills. **If the prepaid additions equal the gross figures in a jurisdiction that allows recovery, recoverable tax is sitting inside the asset and is being amortized into expense.** That is a cash-flow error and a P&L error at once, it recurs every year, and it is one comparison to find. Raise it with the figures.

---

### Step 7 — The monthly amortization entry

`[auto]` to compute and draft. `[manual]` to post, and `[manual]` to automate — this second one needs stating clearly rather than glossed.

Per item:

```
DR  Expense account (per user's COA)                   $period amortization
    CR  Prepaid Expense                                    $period amortization
Memo: Amortize prepaid [vendor / description] - [period]
```

Aggregated by expense account, which is what most books actually want:

```
DR  Insurance Expense                          $sum of insurance amortizations
DR  Software Subscriptions Expense             $sum of SaaS amortizations
DR  Rent Expense                               $sum of rent amortizations
DR  ...                                        $other categories
    CR  Prepaid Expense                          $total period amortization
Memo: Monthly prepaid amortization - [period]
```

Hand the drafted entry to `journal-entry-builder` for formatting and validation.

**On the recurring entry.** The original says: *Recurring JE: hand off to `recurring-transaction-builder`.* That handoff is preserved and the cross-reference stands — but be honest about the boundary. **Mosofin cannot create a recurring transaction.** The gateway is read-only; it does not write to the accounting system, and a recurring template is a write. So:

- Drafting the entry, with the right accounts and the right amounts, from the schedule: `[auto]`
- Setting it up as a recurring template in the accounting system: `[manual]`, performed by the user
- **Checking, next period, that it actually ran:** `[auto]` — and this one is worth having. Test 0a already does it. Recurring entries stop. They stop when an account is renamed, when a template expires, when someone deactivates it during a clean-up. The failure is silent, and a monthly read catches it in the month it happens rather than at year end.

That last bullet is the genuine division of labour here: the user automates the posting, and Mosofin audits the automation.

---

### Step 8 — Roll-forward and tie-out

**This is the step where the workspace contributes most, and it is worth being precise about which legs are automatic.**

The original's roll-forward, preserved:

```
Opening prepaid balance (GL)                       $X
+ New prepayments booked during the period         $Y
- Amortization during the period                   $Z
+/- FX revaluation (multi-currency)                $A
+/- Cancellations / refunds                        $B
= Closing prepaid balance                          $X + Y - Z + A + B
```

Line by line, with verdicts:

| Line | Source | Verdict |
|---|---|---|
| Opening prepaid balance (GL) | Live read of the account at the prior period end | `[auto]` |
| New prepayments booked during the period | Debits to the prepaid account, with vendor and reference | `[auto]` |
| Amortization during the period | Credits to the prepaid account | `[auto]` |
| FX revaluation | Revaluation-source entries hitting the account — **and their presence is itself a finding**, see below | `[auto]` |
| Cancellations / refunds | Credits with a cash or AR counterparty rather than an expense one | `[auto]` |
| Closing prepaid balance | Live read at period end | `[auto]` |

**The entire roll-forward is `[auto]`.** Every component is a live read, and each line ties to identifiable transactions rather than to a summary figure. That is a substantial improvement on the original, where the roll-forward was assembled by hand from whatever the accountant could find.

The original then requires **three-way agreement**:

1. **GL closing prepaid balance** — `[auto]`, live read
2. **The roll-forward result** — `[auto]`, computed from the components above
3. **Sum of remaining prepaid balances on the schedule** — `[manual]` in origin, because the schedule came from outside

Two of the three legs are automatic. **The third is the one that matters.** Legs 1 and 2 will agree with each other whenever the arithmetic is right, because they are two views of the same ledger — that agreement proves the accounting system adds up, which was never in doubt. **Only leg 3 tests whether the balance is right**, because only the schedule carries information the ledger does not have: what the balance is for and when it ends.

This is the same trap as the balance sheet that always balances (see `financial-statement-builder`). Do not let a green variance column between legs 1 and 2 be reported as a reconciliation. Report the variance against the **schedule**, and if there is no schedule, say there is no reconciliation — only a roll-forward.

**If it does not agree, investigate.** `[auto]` for the investigation, and this is where the transaction-level detail pays off:

- Variance equal to one month's amortization → a missed run. Test 0a names the month.
- Variance equal to a whole item's remaining balance → an item on the schedule that was never booked, or booked to a different account.
- Variance equal to a gross-versus-net difference → recoverable tax in the asset. See Step 6.
- Variance that is small and stubborn → convention drift. Whole-month against day-prorated. See Step 4.
- Variance with no pattern → look for the journal-source entries Test 0c flagged.

Naming the *shape* of the variance before hunting for it turns a reconciliation from a search into a lookup.

---

### Step 9 — Cancellations and changes

`[auto]` to detect, `[auto]` to compute, `[manual]` to decide, `[manual]` to post.

If a prepaid item is cancelled mid-period — an insurance policy cancelled with a partial refund:

- Compute the unamortized balance at the cancellation date — `[auto]` from the schedule
- Compare it to the refund received — `[auto]`, the refund is in the books
- The difference is an expense (if the refund is less) or income (if it exceeds, which is rare)

```
DR  Cash / AR for refund                           $refund
DR  Expense account (if refund < unamortized)      $diff
    CR  Prepaid Expense                              $unamortized balance
    CR  Other Income (if refund > unamortized)       $diff
Memo: Cancel prepaid [item] - refund [date]
```

**The `[auto]` worth having here: cash arriving from a vendor you prepaid.** A deposit or credit memo from a vendor with an open prepaid balance is either a cancellation or a rebate, and either way it needs to hit the schedule. Read receipts and vendor credits against the vendors on the prepaid schedule. Money coming *back* from a supplier is unusual enough to be worth flagging every time, and it is one query.

**If the contract is modified — extended, for example — update the schedule with the new end date and recompute the monthly amortization from the modification date forward.** `[manual]` to learn of the modification, `[auto]` to recompute. Prospective, from the modification date. Do not restate the months already amortized; a modification is a change in the arrangement, not a correction of the past.

---

### Step 10 — Output

Deliver an `.xlsx` workpaper. The original's five sheets are kept in order, with two Mosofin additions.

**Sheet 1: Prepaid Schedule Master**
| Item ID | Vendor | Description | Payment Date | Total Amount | Currency | Coverage Start | Coverage End | Months | Monthly Amort | Expense Account |

Add a **Source** column: `ledger` for fields read live, `user` for coverage dates supplied in the interview, `unknown` for the flagged gaps from Step 3. A reader should never have to guess which figures came from the books and which came from a conversation.

**Sheet 2: Period Detail**
For each item, the monthly amortization across the coverage period.

**Sheet 3: GL Tie-Out**
| Period | Opening GL Balance | Additions | Amortizations | Cancellations | FX | Closing GL Balance | Schedule Sum | Variance |

Every column except **Schedule Sum** is `[auto]`. Mark the header so that is visible. And repeat the Step 8 caution on the sheet itself: the variance that matters is against the schedule, not between two readings of the ledger.

**Sheet 4: Monthly JE**
The current period's aggregate amortization entry, formatted for handoff to `journal-entry-builder`. Marked, unambiguously, **PROPOSED — NOT POSTED**.

**Sheet 5: Cancellations / Modifications Log**
| Item | Original Schedule | Change | New Schedule | Impact |

**Sheet 6: Ledger Findings** *(Mosofin addition)*
The output of Step 0 and the Step 1 lumpiness scan — everything the books said without being asked:

| Finding | Evidence | Amount | Periods affected | Recommended action |
|---|---|---|---|---|

Missed amortization months. Prepaid candidates never set up. Non-prepaid items sitting in the account. Recoverable tax inside the asset. FX revaluation of a non-monetary asset. Balance exceeding twelve months of additions.

On a neglected set of books this sheet is frequently the reason the engagement was worth running, and it exists only because there is a live ledger to read.

**Sheet 7: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet. Its contents are set out in full below.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

File naming: `Prepaid_Schedule_[YYYY-MM].xlsx`

Where more than one entity is in scope, the entity `display_name` goes in the file name **and** in a column on every sheet. Never one file with two companies silently interleaved. If the data is fixture data (`mock: true`), say so in the file name and on Sheet 1.

---

## Seed to evolved: what happens on the first real run

This file is a **seed**. It was written without seeing the client's books, so every verdict in it is a prediction. The first real run against a live workspace replaces predictions with observations, and the skill should be rewritten to hold them.

**What must never be frozen into a seed:** a snapshot of which tools existed, or what their policies were, on the day it was written. Capabilities change. Policies get tightened after an incident and loosened after a review. A seed that hardcodes today's capability map is wrong the first time anything changes, and worse, it is wrong *silently* — it will keep reporting `[auto]` for something that has been disabled for a month. **Gate 2 exists so that the capability map is read fresh on every run.** Do not replace it with a list.

**What is worth writing into the evolved version, after the first run:**

1. **Which accounts are the prepaid accounts in this book.** Read from the chart at Gate 3 the first time, confirmed with the user, then recorded. Saves a question every month thereafter.
2. **This client's amortization convention**, and the fact that it was agreed rather than assumed.
3. **The materiality threshold**, with the date it was set and by whom.
4. **The recurring items and their renewal months.** After a year of running this, the pattern of "insurance in March, licences in July, property tax in October" is established, and next year's Step 1 becomes a check rather than a search.
5. **The coverage dates that were established by interview.** They cost the user real effort to produce. Losing them and asking again next year is the fastest way to make this skill unwelcome.
6. **The errors found and fixed**, so the same tests run first next period. If recoverable tax was in the asset once, check it every time.
7. **Any observed policy that differed from this file's default**, so the next run's expectations are calibrated.

**Ask before saving anything.** Only after the user has **seen the results**, ask — explicitly, at that point, not earlier — whether to save these as their own customized version. A general "yes, go ahead" from earlier does not count. Decline, or no answer, and nothing is written.

Persist that through `create_skill`, scoped to the workspace it came from. **Client-specific facts belong in a client-scoped skill, never back in the seed** — the seed is what gets handed to the next engagement, and it must not arrive carrying the last client's account numbers.

**The evolved version should be shorter in its interview and longer in its findings.** That is the direction of travel: fewer questions each month, because the answers accumulate; more tests each month, because the known failure modes accumulate too.
