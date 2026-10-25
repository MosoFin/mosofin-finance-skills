---
name: expense-report-processor
description: "Processes employee expense reports from any T&E tool (Concur, Expensify, Brex, Ramp, Pleo, Spendesk, Soldo) or a pasted report: validates each line against the user's own policy, codes it to the real chart of accounts, flags personal and duplicate claims, calculates what each employee is owed, and prepares the GL posting inputs. Jurisdiction-agnostic: mileage rates, per-diems, receipt thresholds and deductibility rules come from the user, never from memory. Reads the books through a connected Mosofin workspace when the user agrees, so claims are checked against card charges already posted, or works from uploaded exports. Use when the user uploads an expense report, asks to review expense claims, check a report against policy, code employee expenses, or work out mileage, per-diems or T&E reimbursements. Do not use for vendor invoices (use invoice-data-extractor) or petty cash. Read-only: produces a policy-checked, coded workpaper, posting inputs and a coverage sheet, and approves, pays or posts nothing."
---

# Expense report processor

Takes an employee expense report and works out **what the employee is actually owed**: each line
checked against **your T&E policy**, coded to **the right account in your chart**, personal and
duplicate claims flagged, company-paid items taken out, and the posting inputs prepared for a
person to post.

The mistake it catches is the **double reimbursement**: an out-of-pocket claim for something the
**company card already paid**. It also catches personal spending on a claim, a Corporate Card
Clearing account that never clears, and an Employee Reimbursement Payable balance that does not
match what is genuinely owed.

**Works with or without Mosofin.** With Mosofin connected, it reads the real chart of accounts
(no placeholder coding), the employee list, the transactions already posted including card
charges, how this entity coded the same merchant before, and the clearing and payable balances;
if a T&E platform is connected, the report itself too. **It can never read your policy, the
receipt images, or mileage rates, per-diem tables, deductibility rules and gift caps** — those
always come from you. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never supplies a jurisdiction-specific number from memory.** It never defaults a mileage rate,
  a per-diem, a receipt threshold, a deductibility split, a gift cap or an FX source, and never
  invents an account number.
- **Without a policy, policy validation is reported as not performed**, never as passed; receipt
  status is reported **"per the report"**, never as verified.
- **Never persists** employee names, individual claims, amounts, card numbers, home addresses or
  travel itineraries.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–7" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *The expense report(s): which employees and which period?* | The claims themselves | **Required — `[manual]`** unless a T&E platform is connected. |
| **C** | *Your T&E policy, or its parameters: receipt thresholds, caps, class rules, alcohol, pre-approval.* | Policy validation runs only against a supplied policy | **Required for policy validation.** Without it Step 2 does not run, and the output says so; never invent limits. |
| **D** | *The receipts.* | Receipt images are not on this surface | Recommended. Without them, receipt status is reported per the report only. |
| **E** | *Tax jurisdiction, and its deductibility and recovery rules.* | Splits meals, entertainment and gifts into deductible and not | Recommended. The split is made **only if you provide the rule**. |
| **F** | *Mileage rate, per km or per mile.* | Mileage is distance × rate | **Required if mileage is claimed.** Never supplied from memory. |
| **G** | *Per-diem table.* | Claims are compared to it | **Required if per-diems are claimed.** |
| **H** | *FX rate source: central bank close, accounting system rate, or report-date rate.* | Converts foreign lines to the functional currency | **Required if multi-currency.** **Do not assume a source.** |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 for a connected **T&E or spend platform** (Concur, Expensify, Brex, Ramp, Pleo,
  Spendesk, Soldo). If one is live, the report itself is read; if not, it is supplied by hand.
- The chart of accounts, employees and functional currency are read, not asked. **If the chart
  read is disabled**, coding degrades to **PLACEHOLDER — REMAP REQUIRED**, and the output says so.
- For a group, ask **which entity employs each claimant and which bears the cost**; the duplicate
  check runs against the entity whose card paid.
- Still ask for the **policy** (C), the **receipts** (D) and any **rates** (F–H).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Expense report** — export from the T&E tool, or pasted | **Required** | CSV, XLSX or PDF, or paste it |
| **T&E policy** document or parameters | **Required for policy validation** — without it, only coding, the maths check and obvious-personal flags run | PDF or DOCX, or type the parameters |
| **Receipts** | Recommended — otherwise receipt status is per the report | PDF or images |
| **Chart of accounts** | Recommended — without it every account is labelled **PLACEHOLDER — REMAP REQUIRED** | CSV or XLSX |
| **Card charges and expenses posted** in the period | Recommended — enables the duplicate check against the books, not just within the report | CSV or XLSX |
| **GL detail** for Corporate Card Clearing and Employee Reimbursement Payable | Recommended — the clearing test and the payable reconciliation | CSV or XLSX |
| Employee list; functional currency | Recommended | CSV, or type it in the chat |
| Mileage rate, per-diem table, FX source, tax jurisdiction | **Required where they apply** | Type it in the chat, or a file |

**Read back before starting, then wait for a yes:**

> *Processing **September's expense report for the sales manager** at **Northbrook Trading**,
> 34 lines from **the Expensify export you uploaded**, against **your T&E policy (v3, January
> 2026)**, coded to the chart read from **your Mosofin connection**. Mileage at **your rate of
> 0.45 per mile**; no per-diems; FX at **the accounting system rate**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the total claimed. Flag anything unreadable, or covering the wrong period
or a different employee, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check for a T&E platform, build the capability map — a posted transaction is not a
submitted claim, and a receipt-attached flag is not a receipt — and read the company profile for
functional currency and country. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books and parse the report

Pull the chart, employees, posted expenses and card charges, the clearing and payable accounts and
the historical coding in one batch; check the `mock` flag. Parse every line — date, category,
merchant, purpose, amount with tax and tip, currency, **payment method**, receipt flag — keeping
splits, flagging low-confidence OCR, separating **company-paid from out-of-pocket**, and matching
each claimant to an employee record: [`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Validate, code and calculate

Run Step 2's checks: policy validation only if a policy was supplied, the personal-expense
patterns, and duplicates within the report and **against card transactions already posted**
(±3 days, near-amount as a review). Code each line to a real account with its historical support, then calculate the net
reimbursable per employee and reconcile it to the payable:
[`references/method.md`](references/method.md) Steps 2–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for foreign currency, conference packages,
spousal travel, gift cards, tips, a personal charge on the corporate card, prepaid items and
reverse-charge VAT.

## Stage 5 — Prepare the posting inputs and present

Assemble the posting inputs — expenses by account, recoverable tax, the reimbursable amount and
the card-paid amount — as a **proposal**, run the Corporate Card Clearing test with its oldest
item, and build the workpaper with exceptions by severity (an already-posted match is a **Reject**)
and the coverage sheet: [`references/method.md`](references/method.md) Steps 5–6. Ask before
creating the `.xlsx`. Before presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist the policy parameters with their
version, the mileage rate and per-diems with effective dates, the category-to-account map, the
clearing and payable accounts, the FX source and the match tolerances — **never employee names,
claims, amounts, card numbers, addresses or itineraries.**

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
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
