---
name: inventory-to-gl-reconciliation
description: "Reconciles the inventory subledger and physical count to the general ledger inventory accounts: first establishes whether the subledger and the GL are two systems or one (which agree by construction), then compares GL, subledger and count, classifies variances as shrinkage, overage, cut-off, wrong location or damage, lists every negative quantity, tests cut-off, ties the reserve roll-forward and trends shrinkage. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded GL balances, item listings and count sheets. Always asks for the physical count, the only test that the goods exist, which no ledger read can supply. Use when the user asks to reconcile inventory to the GL, explain a physical or cycle count variance, investigate shrinkage or tie inventory to the balance sheet. Do not use for choosing or applying a costing method (FIFO, LIFO, weighted average). Read-only: produces a reconciliation workpaper and proposed cleanup entries, and posts nothing."
---

# Inventory ↔ GL reconciliation

Checks that the **value of stock in the books**, the **quantity in the stock system** and **what is
actually on the shelves** agree — and where they do not, finds out why: shrinkage, a count error, a
receipt or shipment in the wrong period, stock moved but not transferred, damaged goods still carried
at cost. It then proposes the cleanup entries.

It starts with the question that decides what the reconciliation is worth: **are the subledger and the
GL two systems, or one?** In many small and mid-market platforms the item module *is* the subledger,
so GL and subledger **agree by construction** — proving that proves the software works, not that the
stock is right. **Only a physical count tests whether the goods exist.**

**Works with or without Mosofin.** With Mosofin connected, it reads the GL inventory, reserve,
shrinkage and variance accounts, item quantities, unit costs and locations, and the transactions
around the period boundary — enough to list every negative quantity, test cut-off, tie the reserve
roll-forward and trend shrinkage. **It can never read the physical count, a 3PL statement, Incoterms
or title terms, or the warehouse team's explanation**, so it always asks for them. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never presents a same-system agreement as a reconciliation.** Where subledger and GL are one, that
  leg is reported as **nil by construction**.
- **Never presents ledger evidence as proof the goods exist**, and calls a difference **shrinkage only
  where a count supports it**.
- **Never defaults a count result, a title determination or a variance explanation**, and never
  persists quantities, balances, variances, shrinkage figures, count results or item costs.

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
| **B** | *Which period are we reconciling?* | Sets every balance and the cut-off window | **Required.** |
| **C** | *Is the inventory subledger a separate system — a WMS, manufacturing ERP or 3PL platform — or the accounting platform's own item module?* | **Decides what this reconciliation proves.** One system agrees by construction | **Required.** Corroborate it at Gate 1 and Step 0b, but the user confirms it. |
| **D** | *The physical count results — counted SKUs, quantity, location.* | **The only leg that tests existence** | **Required for the count comparison, and always `[manual]`.** Never default a count result. Without it, no difference is called shrinkage. |
| **E** | *When was the last physical count, and what is the cadence — full annual, cycle counting, or none?* | A clean GL-to-subledger result with no recent count is weak | **Required.** If never, that is the headline finding. |
| **F** | *Any stock in transit or on consignment, in or out — quantity, value and the title terms?* | Ownership turns on the contract, not the location field | Recommended. **Never default a title determination.** |
| **G** | *Is any stock held by a 3PL? If so, its statement for the period.* | The 3PL's stock is reconciled to its statement | Ask whenever a 3PL holds stock; the statement is `[manual]`. |
| **H** | *The reserve / write-down policy, and the standard cost variance absorption policy if you use standard cost.* | Write-downs need a policy basis; variance balances are readable, the policy is not | Recommended, `[manual]`. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether an **inventory, WMS, manufacturing or 3PL platform** is connected. If one is,
  both sides are readable and the reconciliation is genuine; if only the accounting platform is, the
  item module is almost certainly the same database as the GL — say so.
- Do not ask for the GL balances, the chart or the item listing: they are read. Check that the chart
  actually separates raw materials, WIP and finished goods.
- Still ask for the **count** (D, E), the **3PL statement** (G) and the **title terms** (F). None is on
  this surface.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **GL inventory balances** at period end, by account — a trial balance works | **Required** | CSV or XLSX |
| **Inventory subledger / item listing** — SKU, quantity on hand, unit cost, extended value, location | **Required** for the GL-to-subledger leg | CSV or XLSX |
| **Physical count results** — counted SKUs, quantity, location, count date | **Required for the count comparison** — the only test of existence | CSV, XLSX or count sheets (PDF / image) |
| **GL detail** for the inventory, reserve, shrinkage and variance accounts | Recommended — movements, the reserve roll-forward, the shrinkage trend | CSV or XLSX |
| **Sales, purchases and bills around the period boundary**, plus anything posted after period end | Recommended — the cut-off test | CSV or XLSX |
| **3PL statement**; in-transit and consignment details with their title terms | Where they apply | PDF or CSV |
| **Chart of accounts** | Recommended — which account is which inventory category | CSV or XLSX |
| Period, entity name, base currency; whether the subledger is a separate system; last count date and cadence; reserve and variance policies | Required (policies recommended) | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Reconciling **Northbrook Trading**'s inventory at **30 September**, with the GL and item listing read
> from **your Mosofin connection**. The item listing is the **same platform's items module**, so the
> GL-to-subledger leg will be reported **nil by construction**, not as a reconciliation. Count: **the A-item
> cycle count of 26 September you uploaded**; last full count **31 December**. Stock at **the Midlands
> 3PL** checked against **its September statement**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period or count
date it covers, the row count, the totals. Flag anything unreadable, covering the wrong period or a
different location, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, answer the one-system-or-two question from what is connected, check which read tools are
enabled, and read the company profile — base currency, fiscal calendar and year-end — so Stage 1's
answers do not need asking twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books, and settle what this can prove

Pull the inventory, reserve, shrinkage and variance accounts, the balances, the items and the cut-off
population — transactions dated near the boundary **and anything posted after period end** — in one
batch; **if a read returns `mock: true`, stop.** Then establish the systems and the count status and put
them in the header, and capture balances by category, checking for consignment-in on the balance sheet:
[`references/method.md`](references/method.md) Steps 0–1, including Step 0b.

## Stage 4 — Reconcile the three legs and investigate

Compare GL, subledger and count; reconcile GL to subledger — **"nil by construction"** where the systems
are one — and subledger to count, classifying each variance and saying whether it was **corroborated
from data or needs fieldwork**. Work through the common reconciling items, investigate material
variances (the last two checks need people, and are where causes come from), and compute shrinkage only
on a count: [`references/method.md`](references/method.md) Steps 2–7. Check
[`references/edge-cases.md`](references/edge-cases.md) for negative quantities, consignment, 3PL stock,
returns, aged and damaged stock, multi-currency, WIP and the reserve roll-forward.

## Stage 5 — Propose the cleanup entries and present the result

Construct shrinkage, overage, NRV write-down and cut-off entries as **proposals** for
`journal-entry-builder`, the count entries' memos citing the count date; then the workpaper — summary, GL-to-subledger detail, count variances, cut-off items,
write-downs and reserves, the posting, **ledger checks** and coverage, with the physical count recorded
as `[manual]` with its owner and last date: [`references/method.md`](references/method.md) Steps 8–9.
Ask before creating the `.xlsx`; otherwise give the sheets as tables. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 10. Persist the decisions — whether the subledger
is separate, the account map, locations, count cadence and owner, recurring reconciling items as rules,
consignment arrangements, the variance absorption policy, the cut-off window and materiality threshold — never quantities,
balances, variances, shrinkage figures, count results, item costs or supplier pricing.

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
