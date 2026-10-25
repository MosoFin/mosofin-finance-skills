<!-- balance-sheet-reconciliations · method.md · read for: Stages 3–6 — Steps 0–9, the reconciliation itself, and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Identify the right reconciliation method per account type
- Step 2 — Pull the GL balance and the supporting balance
- Step 3 — Identify reconciling items
- Step 4 — Investigate unreconciled differences
- Step 5 — Propose corrections
- Step 6 — Roll-forward (for activity-based accounts)
- Step 7 — Materiality and aging
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop an account because no tool covers its supporting side.** An account whose support is
`[manual]` is an account with a *named gap and a named owner*, not an account that reconciled.
Omitting it from the workpaper implies a tie-out that never happened.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the trial
balance, the agings, and the general ledger extracts do not depend on each other. Never
serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* — every account's GL balance at period end — usually **[auto]**
- *`get_balance_sheet`* — the same balances as presented, including current / non-current split —
  usually **[auto]**
- *`search_accounts`* — the chart of accounts, to identify account types and find suspense /
  clearing accounts — usually **[auto]**
- *`get_general_ledger`* — transaction detail behind any account, and the raw material for every
  roll-forward — usually **[auto]**
- *`get_aged_receivables`* / *`get_customer_balance`* — the A/R supporting side — usually **[auto]**
- *`get_aged_payables`* / *`get_vendor_balance`* — the A/P supporting side — policies often differ
  from the receivables one
- *`search_journal_entries`* — manual entries, a frequent source of reconciling items — usually
  **[auto]**
- *`get_company_info`* — period-end and base currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that side of the reconciliation to **[manual]** and record the
  gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the workpaper's
format but **cannot support a signed reconciliation**. A reconciliation is a control; performing
it on fixture data records a control as operating when it did not.

## Step 1 — Identify the right reconciliation method per account type

Different balance sheet accounts reconcile to different sources. The verdict column below is the
**typical** case — confirm each against your Gate 2 capability map, since a connected payroll or
inventory platform changes several rows at once.

| GL Account | Reconcile to | Typical GL side | Typical support side |
|---|---|---|---|
| Cash / Bank | Bank statement (use `bank-reconciliation` skill) | **[auto]** | **[manual]** — the statement is outside the books |
| Accounts Receivable | A/R sub-ledger / open invoice listing | **[auto]** | **[auto]** — *`get_aged_receivables`*, *`search_invoices`* |
| Allowance for Doubtful Accounts | Allowance calculation | **[auto]** | **[manual]** — the calculation is a schedule |
| Inventory | Inventory subledger / physical count (see `inventory-to-gl-reconciliation`) | **[auto]** | **[gated]** — *`search_items`* gives the master; counts and valuation usually **[manual]** |
| Prepaid Expenses | Prepaid amortization schedule (see `prepaid-amortization-schedule`) | **[auto]** | **[manual]** |
| Input Tax / VAT Receivable | Tax filing detail | **[auto]** | **[manual]** — *`search_tax_codes`* / *`search_tax_rates`* help identify, not evidence |
| Fixed Assets (gross) | Fixed Asset Register (see `fixed-asset-register-and-depreciation`) | **[auto]** | **[manual]** |
| Accumulated Depreciation | Fixed Asset Register depreciation summary | **[auto]** | **[manual]** |
| Intangible Assets | Intangibles register | **[auto]** | **[manual]** |
| Right-of-Use Assets | Lease schedules | **[auto]** | **[manual]** |
| Goodwill | Acquisition history + impairment tests | **[auto]** | **[manual]** |
| Accounts Payable | A/P sub-ledger / open bill listing | **[auto]** | **[auto]** — *`get_aged_payables`*, *`search_bills`* |
| Accrued Expenses | Accruals schedule (see `ap-accrual-cutoff`, `accruals-and-deferrals`) | **[auto]** | **[gated]** — booked entries **[auto]**, the calculations behind them **[manual]** |
| Customer Deposits / Deferred Revenue | Contract / customer schedule | **[auto]** | **[gated]** — receipts **[auto]**, the service periods **[manual]** |
| Sales Tax / VAT / GST Payable | Tax filing return + post-period activity | **[auto]** | **[manual]** for the return; post-period activity **[auto]** |
| Payroll Liabilities | Payroll register + remittances (see `payroll-clearing-reconciliation`) | **[auto]** | **[manual]** unless a payroll platform is connected |
| Income Tax Payable | Tax provision workpaper | **[auto]** | **[manual]** |
| Lease Liability | Lease schedule | **[auto]** | **[manual]** |
| Long-Term Debt | Loan amortization schedule + lender confirmation | **[auto]** | **[manual]** |
| Intercompany Accounts | Counterparty entity's mirror balance | **[auto]** | **[auto] if the counterparty is a connected company file**, otherwise **[manual]** |
| Equity Accounts | Stock register / capital movements log | **[auto]** | **[manual]** |
| Suspense / Clearing | Should be zero or near-zero; investigate every line | **[auto]** | **[auto]** — *`get_general_ledger`*; fully supported, and the highest-value quick win here |

**If the user's account type isn't listed, ask what the supporting source is.** Do not guess a
source — a reconciliation to the wrong support is worse than none, because it looks complete.

## Step 2 — Pull the GL balance and the supporting balance

Capture:

- **GL balance** at period end (from the trial balance) — **[auto]**
  (*`get_trial_balance`*, *`get_balance_sheet`*)
- **Supporting balance** (sum of subledger detail, schedule total, external statement balance) —
  per the verdict in Step 1's table

**State each clearly with source and date.** In a Mosofin run that means: the tool name, the
parameters, the as-of timestamp, and the `mock` status for anything `[auto]`; the document name,
its date and who supplied it for anything `[manual]`. A balance without a source cannot be
reviewed.

## Step 3 — Identify reconciling items

The standard rec formula:

```
GL balance                                              $X
Plus/Less: reconciling items
  - Item 1 (e.g., timing differences, GL not yet in subledger, subledger not yet in GL)
  - Item 2
  - Item 3
Equals: Adjusted GL balance                             $Y

Supporting balance                                      $Z
Plus/Less: reconciling items on the subledger side (rare)
Equals: Adjusted supporting balance                     $W

Reconciled?  Y = W ?
  Yes  → tied
  No   → unreconciled difference of $(Y − W)
```

**Categorize each reconciling item by type:**

- **Timing** — legitimate timing differences that will clear next period (e.g. a bank deposit in
  transit, an invoice posted after the subledger cut). These are *expected* and need no
  correction, only monitoring
- **Permanent** — differences that should be corrected via a JE (e.g. a misposting). These need
  fixing
- **Investigating** — not yet identified; requires research. Honest and normal, provided it has
  an owner and a date

## Step 4 — Investigate unreconciled differences

For any difference — each of these is **[auto]** or **[gated]** where the GL side is readable:

- **Compare the prior-period rec — was the difference already there?** **[manual]** unless the
  prior rec was supplied; **[auto]** as a proxy by checking whether the same balance persisted
  (*`get_general_ledger`* across periods)
- **Cross-check posting cutoffs — did the GL and subledger close at the same time?** **[auto]**:
  look for transactions dated in the period but entered after it
- **Cross-check for misposted entries** (right account but wrong subledger / dimension) —
  **[auto]** (*`get_general_ledger`*, *`search_journal_entries`*, *`search_classes`*,
  *`search_departments`*)
- **Cross-check for FX revaluation differences** (the subledger may not have been revalued) —
  **[gated]**: multi-currency activity is visible, the revaluation policy is not
- **Cross-check rounding** (sum of many sub-items vs the GL total) — **[auto]**

**Document the investigation steps and results** — including the checks that found nothing. A
reconciliation that lists only what was found does not show what was looked for.

## Step 5 — Propose corrections

For **permanent** differences, propose a JE to clear (hand off to `journal-entry-builder`).
Examples:

- **Reclass between accounts** if posted incorrectly
- **Write off small immaterial residuals** to a cleanup account
- **Reverse and rebook** if a prior JE is wrong

For **timing** differences, **document but do not adjust** — they'll clear naturally. Adjusting a
timing difference creates a second error next period when the original clears.

For **investigating** items, log them with an **owner and target resolution date**. An
investigating item with no owner is an item nobody is investigating.

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**). **Mosofin proposes; a human posts.**

## Step 6 — Roll-forward (for activity-based accounts)

For accounts with significant activity (A/R, A/P, Inventory, Fixed Assets, Accruals), show a
roll-forward — **[auto]** wherever the GL side is readable (*`get_general_ledger`*):

```
Opening balance
+ Additions (purchases, billings, accruals booked)
- Reductions (payments, releases, write-offs)
+/- Other adjustments
= Closing balance
```

**The closing balance should tie to the GL. Movements should tie to the relevant activity**
(sales register, payment register, etc.) — **[auto]** for the comparison where the activity lives
in the connected books (*`search_invoices`*, *`search_payments`*, *`search_bills`*,
*`search_bill_payments`*), which makes this one of the strongest automated checks available.

## Step 7 — Materiality and aging

For each reconciling item:

- **Amount** — against the entity's materiality
- **Age** — how long has this item been open? **[auto]** where the item is a GL transaction:
  its posting date is readable

**Items aged > 3 months should escalate. Items above the materiality threshold require immediate
resolution.**

Age matters independently of size: a small item open for a year usually indicates that nobody
owns the account, which is a bigger problem than the amount.

## Step 8 — Output

Deliver an `.xlsx` workpaper, ideally **one tab per account** being reconciled.

**Standard tab structure per account:**

**Section 1: Header**
- Account number and name
- Period
- GL balance (and source)
- Supporting balance (and source)
- Difference
- Preparer / Reviewer
- Materiality threshold
- **Added:** entity `display_name`; the tool and timestamp behind each `[auto]` balance; the
  document and supplier behind each `[manual]` one; `mock` status

**Section 2: Reconciliation**

| Type | Description | Amount | Direction (Add / Less) |

Sub-totaled to the adjusted balance, ending in:

| Reconciled difference | $X | Status (Tied / Within tolerance / Investigating) |

**Section 3: Reconciling Items Detail**

| # | Description | Type (Timing / Permanent / Investigating) | Amount | Age | Owner | Target Resolution | Status |

**Section 4: Roll-Forward** (if activity-based)

Opening + activity = closing.

**Section 5: Proposed JEs**

Pass-through to `journal-entry-builder` for any permanent corrections, marked as **proposals**.

**Section 6: Prior Period Carry-Forward Check**

| Item from Prior Rec | Status This Period | If Still Open: New Target Date |

**Section 7: Coverage — NEW, Mosofin-specific**

| Account | Entity (`display_name`) | GL side (auto / gated / manual) | Support side (auto / gated / manual) | Tool used per side | Policy | `mock` | Gap — what could not be evidenced and who owns it |

**The two-sided verdict is the point.** An account with an `[auto]` GL side and a `[manual]`
support side that was never supplied is **not reconciled**, and this sheet is what makes that
visible.

Optionally, a **master workbook** listing all account reconciliations with:

- Account, GL balance, status (tied / within tolerance / unreconciled), materiality breach Y/N
- **Added:** support-side coverage, so the controller can see at a glance how much of the balance
  sheet is genuinely evidenced

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `BS_Recs_[YYYY-MM]_[EntityName].xlsx`

In a multi-entity run, `[EntityName]` is the company file's `display_name`, one per entity plus a
combined view. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This skill runs every month, so the evolution step pays for itself faster here than almost
anywhere.

On an explicit yes, persist the **decisions**:

- **The account-to-source map** — for every balance sheet account in this entity's chart: what it
  reconciles to, where that support lives, and who owns it. This is the single highest-value
  artefact, and it is exactly what makes month two faster than month one
- **The materiality threshold** and the escalation ages
- **Preparer and reviewer** per account, or per account group
- **Known recurring timing items** and the window in which each normally clears — so a familiar
  deposit-in-transit is recognised rather than re-investigated every month
- The cleanup / suspense account to use for immaterial residuals, and the limit above which
  nothing may be written off
- Accounts that must always be zero, so a non-zero balance is escalated immediately
- The replay recipe: the exact sequence of reads that produced this period's workpaper

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Do not persist balances, reconciling item detail, or the workpaper itself.** Those are the
period's evidence and belong in the close file, which is a controlled record. Persist the *map,
the thresholds, and the owners*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Prepaid Expenses reconciles to the prepaid schedule held by the financial
controller; materiality $500" — not "Prepaid reconciles to the schedule". Different entities keep
different schedules in different places, and an unlabelled map sends someone to the wrong file.
Record the chosen **scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to
the workspace and are re-discovered by Gates 1–2 every run — which matters here, because a tool
that was enabled last month may be disabled this month, flipping an account from `[auto]` to
`[manual]` without warning. **Decisions are the user's; state is the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One workpaper, one master
summary.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one
`data_source_id`, every account and reconciling item carrying that entity's `display_name`. Then
one cross-entity step:

- **The intercompany mirror check**, which is the genuine cross-entity reconciliation and the one
  worth doing deliberately: entity A's receivable from entity B against entity B's payable to
  entity A. Where both are connected company files, **both sides are `[auto]`** — pull each
  entity's balance separately, compare, and report the mismatch. Clearing the
  mismatch is a separate intercompany reconciliation.
- **A group master summary** showing, per entity, how many accounts tied, how many are
  unreconciled, and **how much of the balance sheet has an evidenced supporting side**. The last
  column is the one that reveals a weak component.
- **Never merge two entities' subledger detail** into one reconciliation. Reconcile per entity,
  then compare.

Capability is checked **per entity** at Gate 2: the same account can be `[auto]` on both sides at
one company file and `[manual]` on support at another.

---
