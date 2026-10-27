---
name: three-way-match
description: "Matches a vendor invoice to its purchase order and goods receipt before payment: header checks, then every line for quantity, price and item, your tolerance applied, fifteen exception tests from price creep to an unapproved order, and a Pay, Hold or Reject recommendation with the matched and disputed amounts. Counts the legs it actually has and says plainly whether it ran a three-way or a two-way match. Reads bills and purchase orders through a connected Mosofin workspace when the user agrees, or works from uploaded POs, delivery records and invoices. Use when the user asks whether an invoice should be paid, wants to match invoices to purchase orders or receipts, mentions overbilling, short shipments or goods received not invoiced (GRNI), or uploads a PO, receipt or invoice. Do not use for finding duplicate payments alone (use duplicate-invoice-detection) or for reconciling a vendor statement (use vendor-statement-reconciliation). Read-only: recommends, posts nothing, pays nothing."
---

# Three-way match: order, receipt, invoice

Checks that three documents agree before money goes out: the **purchase order** (PO — what you agreed
to buy), the **goods receipt** (GRN — what arrived, and in what condition) and the **vendor invoice**
(what the supplier wants paid). It compares them header first, then line by line, applies your
tolerance, runs fifteen exception tests, and recommends **Pay, Hold or Reject** with the matched
and disputed amounts. A person acts on the recommendation.

**Works with or without Mosofin.** With Mosofin connected it reads the bills, and the purchase
orders where the system holds them. **No accounting system reliably holds the goods receipt**, so
it checks at Gate 2 (its check of which data the connection exposes) which legs exist and asks
for the rest. **If it has invoices and orders but no receipts, it runs a two-way match and says so** in the summary and the file name; the tests that
need the receipt are listed as not run, never as passed, while billed quantity is still checked
against the order.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never pays, holds or releases money, and never changes data in any system.** Every
  recommendation is for a person to act on.
- **Never invents a tolerance.** With none given, it expects an exact match and flags every
  variance; how much overbilling is acceptable is the business's decision.
- **Never lets an absent test read as a pass, and never concludes fraud.** It names which match it
  ran and which tests did not; patterns are reported with counts and amounts, people conclude.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 1–6" always mean the steps in `references/method.md`.*

Before reading any data, collect what the books cannot tell you, in **one short batch**, not one
question at a time. Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the documents yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *What tolerance applies: price %, quantity %, and a total-amount limit?* | Decides what is a match and what is an exception | **Default to exact match and flag every variance.** Say that you did. |
| **C** | *Who may approve a purchase order, and up to what amount?* | Exceptions 11 and 12 (unapproved, or approved beyond authority) cannot run without it | Run the other thirteen tests and list 11 and 12 as not run. **Persist the matrix** once given; it changes rarely. |
| **D** | *Are services purchase orders in scope, and what stands in for a goods receipt on them?* | A services PO with no receipt is a two-way match **by design**; a goods PO with no receipt is two-way **by omission**. They look the same in the output and are not | Treat as goods unless told otherwise, and say so. |
| **E** | *Any orders or invoices in a foreign currency, and what rate policy applies?* | A price variance that is really an FX movement is the classic false exception | Flag every cross-currency pair and separate the FX movement before raising exception 1. |
| **F** | *Who owns exception resolution?* | Every exception row needs an owner | Leave the owner column open and say so in the summary. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- At Gate 2, answer the **three capability questions** from the live tool catalogue: does it
  expose purchase orders, with line detail? item receipts, with quantities? approval status and
  the approver? **Then say which match this will be** — three-way, two-way by design, or two-way
  by omission — before promising anything.
- Ask for whatever leg the system does not hold, usually the goods receipts.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Purchase order(s)** | Required | PDF, XLSX, CSV, or pasted |
| **Goods receipt, proof of delivery, or signed service confirmation** | **Required for goods.** Without it the match is two-way and the output says so | PDF, XLSX, CSV, or pasted |
| **Vendor invoice(s)** | Required | PDF, XLSX, CSV, or pasted |
| **Prior bills and payments against these POs** (AP transactions or a bills-by-vendor export for the PO's life) | **Required for progress or partial billing** and the duplicate test; without it those tests are listed as not run | CSV, XLSX or PDF |
| Tolerance policy (B) and approval matrix (C) | Recommended | Type it in the chat |
| Vendor master, for payment-terms checks | Optional | CSV or pasted |

**Read back before starting, then wait for a yes:**

> *Matching **September's open invoices** for **Northbrook Trading** against purchase orders and
> goods receipts, with the invoices and orders from **your Mosofin connection** and the receipts
> **you uploaded**. **2% price tolerance, exact on quantity**, approval matrix as supplied. This
> will be a **three-way match**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — document count,
line count, totals, period. Flag anything unreadable, or any trio whose headers already disagree
(different vendor, currency or entity), straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, answer the three capability questions, read the company profile, and interview only
for what Stage 1 did not cover. On the upload path, go straight to Stage 3.

## Stage 3 — Extract, then match headers and lines

Pull the whole open population in one batch, extract the fields from each document, confirm the
four header checks, then match every invoice line to its PO line and receipt lines by line number,
then SKU, then description, recording the basis per line:
[`references/method.md`](references/method.md) Steps 1–2. An unmatched line is a status, never
forced.

## Stage 4 — Apply tolerances and run the fifteen tests

Tolerance per line, then the exception tests the available legs allow, with severities, and the
population patterns that only a full run shows (variances always just inside tolerance, bulk
receipts, one name across several stages, received-not-billed as an accrual):
[`references/method.md`](references/method.md) Steps 3–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for progress billings, blanket POs,
substitutions, price clauses, FX, tax, and receipts dated before their PO.

## Stage 5 — Propose a resolution and present the result

Pay, Hold, Reject, request a credit, override with a documented reason and authority, or pay the
matched portion and dispute the rest — proposed, never decided. Then the six sheets:
[`references/method.md`](references/method.md) Steps 5–6. Before presenting, check the coverage
and provenance sheet in [`references/output.md`](references/output.md): which legs were available,
which tests ran, which did not and why. Ask whether the user wants the workpaper as an Excel file
before creating one.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md), *Seed to evolved*. Persist which legs the system
holds, the tolerance, the approval matrix, known price clauses, resolved exceptions and the
override log — never the capability map itself, which Gate 2 reads fresh each run.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stage 4, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
