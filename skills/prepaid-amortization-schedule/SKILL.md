---
name: prepaid-amortization-schedule
description: "Builds, maintains and audits a prepaid expense amortization schedule — insurance, SaaS, rent and other costs paid in advance: finds prepaid candidates, applies the user's materiality threshold, amortizes each item over its coverage period, drafts the entries, and ties the schedule to the GL prepaid balance. Audits the account from the ledger alone: missed amortization runs, prepaids expensed in one month, expired residue, deposits or fixed assets coded to prepaid, recoverable tax inside the asset. Reads the books through Mosofin when the user agrees, or works from uploaded GL detail, and always asks for the coverage dates, which no ledger holds. Use when the user asks to set up or reconcile a prepaid schedule, amortize a prepaid, prepare the monthly prepaid entry, or find prepaids never set up. Do not use for deferred revenue (use accruals-and-deferrals) or the whole close (use month-end-close-checklist). Read-only: produces a schedule workpaper, proposed entries and a coverage sheet, and posts nothing."
---

# Prepaid amortization schedule

Builds and maintains the schedule for expenses paid in advance — money already handed over for
something not yet received — spreads each one across its **coverage period**, drafts the monthly
entry, and ties the running balance to the **general ledger**.

**The ledger holds the prepaid balance. It does not hold the schedule.** What the balance is for,
which months it buys and when they end live on contracts and policy schedules. So this skill never
treats a balance agreeing with itself as a reconciliation — and it is unusually good at showing the
schedule is **wrong or missing**: a prepaid account that only ever increases, a year's premium
expensed in one month, a balance bigger than a year of additions, amortization posted by hand in
round numbers.

**Works with or without Mosofin.** With Mosofin connected, it reads the prepaid account's full
transaction detail, the expense ledger, the bills and payments behind each item — vendor, amount,
payment date, reference, tax lines — and the chart of accounts. **It can never read the coverage
start and end dates** — they are on contracts, not in the ledger — so it always asks you for them.
The materiality threshold and the judgment on deposits and related-party advances are yours too.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never derives coverage dates from the payment date or the invoice memo.** An unknown date
  stays blank and flagged as **unknown**.
- **Never reports a roll-forward as a reconciliation.** GL balance and roll-forward are the same
  ledger read twice; only the schedule tests the balance. No schedule, no reconciliation.
- **Never sets the materiality threshold** — it applies yours — and never presents a tie-out on
  `mock` data as a clean result.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–10" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which company — or, for a group, which entities?* | Several company files means several schedules, each labelled, never merged | On the Mosofin path, ask **by name**. Never auto-pick. |
| **C** | *Which account, or accounts, are prepaid?* | Many books have several — and an "Other Current Assets" that has become a drawer | On the Mosofin path, read the chart first, then **confirm**. |
| **D** | *The coverage start and end date for each open item.* | The one thing the ledger cannot supply, and what makes it a schedule | **Required.** Ask item by item; where unknown, the item goes on the schedule with dates **blank and flagged**. Never inferred. |
| **E** | *Your materiality threshold — below which an item is expensed, not scheduled.* | Decides what is scheduled | **Your call; never set by the skill.** It can show what a proposed threshold does in aggregate. If unstated, the coverage sheet says so. |
| **F** | *Whole-month or daily proration?* | Both are defensible; mixing them in one schedule is not | Observe which convention the existing entries follow, then **confirm rather than assume**. |
| **G** | *Is recoverable tax (VAT/GST) split out at payment, and in which jurisdiction?* | Where recoverable, the tax comes out at payment and is not amortized | The policy is yours to state; the ledger test for tax inside the asset still runs. |
| **H** | *Functional currency, and the policy on revaluing foreign-currency prepaids.* | A prepaid is non-monetary and is generally not revalued | Currency: **required**, read from the company record on the Mosofin path. FX policy: **confirm it**. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Read any saved client profile first (Gate 3) — threshold, convention, prepaid accounts, tax
  split — **use it and say you are using it**; ask only what is still open.
- Still ask for the **coverage dates** (D). Neither the payment date nor "annual renewal" in a
  memo is a coverage period.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Prepaid account transaction detail** — at least 24 months, for the ledger tests — with vendor, description, reference, amount and payment date per item | **Required** | CSV or XLSX |
| **Coverage start and end dates** per item — from the contracts, policy schedules or invoices | **Required** — unknown dates stay blank and flagged | PDF, CSV, XLSX, or typed in the chat |
| **Chart of accounts** — prepaid asset and expense accounts | **Required** | CSV or XLSX |
| Functional currency; currency per item if multi-currency | **Required** (per item: if multi-currency) | Type it in the chat |
| **The existing prepaid schedule**, if there is one | Needed for a reconciliation — without it the tie-out is a roll-forward only, and says so | XLSX or PDF |
| **Expense ledger** for the period | Recommended — the scan for prepaids expensed in one hit | CSV or XLSX |
| Materiality threshold; tax jurisdiction; amortization frequency | Recommended (frequency optional) | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Building the **September** prepaid schedule for **Northbrook Trading**, account **Prepaid
> Expenses**, from **your Mosofin connection**. Materiality **$1,000**, **whole-month**
> amortization, VAT recovered at payment. You gave coverage dates for **9 of 11** items; the
> other two go on the schedule **blank and flagged**. Shall I go ahead?*

On the upload path, name each file you received and what was read from it — the period covered,
the row count, opening and closing balances. Flag anything unreadable or for the wrong period at
once.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, read each tool's `effective_policy` — **Gate 2 wins** over any default verdict —
explain why a clean tie-out on `mock` data proves nothing, and read the saved profile before
interviewing. On the upload path, go straight to Stage 3.

## Stage 3 — Read the shape of the account, and find the candidates

Before building anything, read at least 24 months of the prepaid account and run the four ledger tests:
does it ever come down, what the credits look like, what odd items live there, and whether the
balance exceeds twelve months of additions. Then rank expense accounts by **lumpiness** to find
prepaids expensed in one hit, and flag what is **not** prepaid — deposits, equipment, inventory,
investments: [`references/method.md`](references/method.md) Steps 0–1. The Inputs table and
the verdict tags are at the top of the same file.

## Stage 4 — Build the schedule

Apply the threshold, showing its aggregate effect; set each item's amortization period from its
**coverage start**, not the payment date; compute straight-line or day-prorated amortization, one
method per item; build the per-item schedule, run its three internal checks and put rounding in
the last period: [`references/method.md`](references/method.md) Steps 2–5. Internal consistency is
a floor, not a result. Check [`references/edge-cases.md`](references/edge-cases.md) for monthly
billing, variable amounts, multi-year current / non-current splits, price increases,
installments, foreign currency, tax-inclusive amounts, related parties, impairment, lease costs
and auto-renewals.

## Stage 5 — Propose the entries, tie out, and present

Draft the initial booking with the coverage period in the memo, any reversal of a prepaid expensed
in error, and the monthly amortization entry — **setting it up as a recurring entry is yours**;
the skill checks next period that it ran. Roll forward the GL and tie it **three ways**, naming the
shape of any variance, settle cancellations against the refund, and apply modifications prospectively:
[`references/method.md`](references/method.md) Steps 6–10. Every entry is marked **PROPOSED — NOT
POSTED**. Before presenting, check it against [`references/output.md`](references/output.md),
including the mandatory coverage and provenance sheet and the anti-patterns.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md), "Seed to evolved". Persist the prepaid accounts,
the convention, the threshold (with who set it and when), the recurring items and renewal months,
the coverage dates established by interview, the errors found, and any policy that differed from
the default — in a client-scoped skill, never the seed. Never freeze the capability map.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6, and the Inputs table for Stage 1 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stage 4, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
