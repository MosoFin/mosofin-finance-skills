---
name: cash-flow-forecast-13-week
description: "Builds a short-term direct-method cash forecast, classically 13 weeks: opening cash by account, receipts and disbursements placed in the week they hit the bank, the weekly closing-cash chain, minimum-balance and covenant alerts, the lowest cash point, runway, sensitivities and a rolling forecast-versus-actual tracker. Times collections from each customer's actual historical days-to-pay, not the due date. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded balances, AR and AP agings and schedules. Always asks for debt service and tax dates, the cash floor and facility terms, and for payroll unless it is connected. Use when the user asks for a 13-week cash forecast, a weekly cash projection, liquidity forecast, cash runway, a TWCF or whether they will run out of cash. Do not use for the GAAP statement of cash flows or for annual forecasting. Read-only: produces a forecast workbook and a coverage sheet, proposes any draw, deferral or transfer, and posts nothing."
---

# 13-week cash flow forecast

Projects, week by week, **how much money will actually be in the bank**: opening cash, the receipts
and disbursements expected to clear each week, and the closing balance that becomes next week's
opening. It flags the weeks that fall below the floor or go negative, names **the lowest cash point
and the week it falls in**, works out the runway, and shows what happens if collections slip. It is
the tool that tells you whether you can make payroll in seven weeks' time.

The mistake it is built to avoid is **optimism about collections**. Customers pay late, so forecasting
each receipt on its due date flatters the forecast. Where payment history is readable, it **measures**
each customer's days-to-pay instead of assuming it.

**Works with or without Mosofin.** With Mosofin connected, it reads opening cash by account, open
invoices and bills with their due dates, when past invoices were actually paid, the recurring
payment pattern, and the actual weekly cash movement for the forecast-versus-actual tracker.
**It cannot read** the forward payroll schedule (unless payroll is connected), the debt service
schedule, tax due dates, the minimum cash threshold or covenant, the credit facility's terms, FX rates,
or any judgment about which payments could slip — so it always asks for them. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never drops an outflow because no tool covers it.** Payroll, debt service, taxes, the floor and the
  facility are `[manual]` lines with named gaps, shown prominently — and **no lever list includes
  payroll or statutory remittances.**
- **Never defaults the opening balance, the floor, the payroll amounts, or the entity**, and excludes
  restricted cash from opening cash.
- **Never nets one entity's surplus against another's shortfall** unless cash is confirmed pooled; any
  transfer is modelled explicitly.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–9" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *What horizon, from which start date — 13 weeks, or 6, 8, 17, 26?* | Sets the grid; a 13-week window can miss a seasonal inflection | **Required.** Propose 13, but check the seasonality edge case first. |
| **C** | *Which cash accounts count as available cash, and which are restricted?* | Opening cash for Week 1 | **Required. Never default the opening balance**; restricted cash is excluded. |
| **D** | *The payroll schedule — pay dates and amounts, payroll tax remittance dates, benefit dates.* | Usually the most certain and critical outflow | **Required, and `[manual]`** unless payroll is connected. **Never default the payroll amounts.** |
| **E** | *The debt service schedule and tax payment due dates — and any other lumpy payments: annual or quarterly, capex, distributions.* | The lumpy items are the ones that breach a floor | Debt service and tax dates are **required, and `[manual]`.** Record what was not supplied. |
| **F** | *Which open bills do you intend to pay, and when?* | Due dates are data; the payment plan is a decision | **Required.** The bills are read; the plan is `[manual]`. |
| **G** | *The minimum cash threshold — a covenant or a management floor — and, for a covenant, its exact definition of cash.* | The floor every week is tested against | **Never default the floor.** Without it, the below-floor alerts cannot be computed. |
| **H** | *Any credit facility — undrawn amount, borrowing base, clean-down requirement?* | The draw needed to stay above the floor | Recommended, `[manual]`. Undrawn is not the same as available. |
| **I** | *More than one entity? Is cash actually pooled between them?* | A group total is a fiction if cash cannot move | **Required when several entities are in scope.** Forecast per entity; consolidate only on an explicit yes. |
| **J** | *Expected new sales and their cash timing; FX rates if you hold several currencies.* | Receipts the books cannot see yet; conversion | Recommended, `[manual]`. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). An excluded entity's payroll and bills
  are real outflows: name it, and say the omission flatters the forecast.
- Do not ask for opening cash, open invoices or open bills — they are read; **confirm which accounts
  count** (C).
- Check at Gate 2 that the agings carry **due dates** and that **payment history is readable**. Without
  history, collections fall back to due dates plus a **stated** assumption, and the forecast is
  materially weaker — say so.
- Derive the recurring pattern and the payroll rhythm from history, then confirm; still ask for D–H.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Cash balances by account** at the start date, restricted accounts marked | **Required** | CSV, XLSX or bank statements (PDF) |
| **Open receivables** — invoice, customer, amount, due date | **Required** | CSV or XLSX (an aged receivables report works) |
| **Open payables** — bill, vendor, amount, due date | **Required** | CSV or XLSX (an aged payables report works) |
| **Payroll schedule; debt service schedule; tax due dates** | **Required** | XLSX, PDF, or type it in the chat |
| **Payment history** — past invoices and the dates they were paid, several months | Recommended — derives each customer's days-to-pay; without it collections are due-date-based and weaker | CSV or XLSX |
| **Cash account transactions** for the prior twelve months | Recommended — recurring pattern, payroll rhythm, annual one-offs, forecast-vs-actual | CSV or XLSX |
| Facility terms; covenant definition | Recommended | PDF, or type it in the chat |
| Entity name, base currency, time zone; horizon and start date; the floor; whether cash is pooled | Required (floor never defaulted) | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Forecasting **13 weeks from Monday 2 November** for **Northbrook Trading**, with opening cash, open
> invoices and open bills read from **your Mosofin connection** — the operating and payroll accounts,
> **excluding the restricted deposit account**. Collections timed from **each customer's days-to-pay over
> the trailing six months**. Payroll on **the 15th and the last day**, from **the schedule you uploaded**.
> Floor **$250,000 — a covenant**, cash net of restricted, tested weekly. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the date or period it
covers, the row count, the totals. Flag anything unreadable, missing due dates, or covering the wrong
date, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file — and, for several entities, **whether cash is pooled** — check which read tools are
enabled, and read the company profile, deriving base currency, fiscal calendar and **time zone**, which
decides the week a receipt near a boundary falls into. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books and set up the grid

Pull cash accounts and opening balances, both agings, invoice and payment history, bill payments,
recurring spend and the cash-account ledger in one batch; **if a read returns `mock: true`, stop** — it
must never drive a liquidity decision. Then set the weekly grid with dates and Week 1's opening cash,
excluding restricted cash: [`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Forecast receipts and disbursements, and run the chain

Place each receipt in the week it will hit the bank, using **derived days-to-pay with its sample size**,
probability-weighting uncertain ones. Place payroll, payroll taxes, the AP plan, recurring and lumpy
disbursements in the week they clear, and scan last year's cash for **annual one-offs falling inside
the horizon**. Then run the chain — closing cash is next week's opening:
[`references/method.md`](references/method.md) Steps 2–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for distress, customer concentration, seasonality,
multi-currency, lumpy payments, revolver mechanics, disputed receivables and clearing time.

## Stage 5 — Flag risks, test sensitivities and present

Flag weeks below the floor (red) and below zero (critical), the **lowest cash point**, the runway and
any facility draw needed; say whether the floor is a covenant or a preference. Test collections
slipping by the observed spread, the single receipt that matters most, and the levers — never payroll.
On a rolling run, compare last week's forecast to actuals and roll forward:
[`references/method.md`](references/method.md) Steps 5–8. Build the workbook with **live formulas**;
ask before creating the `.xlsx`, otherwise give the sheets as tables. Before presenting, check it
against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the recurring schedule, the payroll
calendar, the floor and its definition, facility terms, which accounts count as cash, the deferrable
lever list, the days-to-pay **method** (not the values) and the horizon — never cash balances, the
forecast, customer-level collection data or facility utilisation.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 3–5, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
