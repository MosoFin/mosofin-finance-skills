---
name: ar-aging-and-collections
description: "Builds an accounts receivable aging as of a date, one row per open invoice on its open balance, ties the invoice detail to the aging summary, ranks overdue customers for collection, calculates receivables metrics such as overdue percentage, concentration and DSO, and drafts review-only reminders. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded aging exports. Asks for disputes, credit holds, customer tiers, credit sales and collection policy only when the requested output needs them, and never infers them from the ledger. Use when the user asks to run an AR aging, who owes us money, to prioritise collections, to calculate DSO, or to draft overdue-invoice reminders. Do not use for applying customer payments (use cash-application), creating invoices (use customer-invoicing), bad-debt write-offs or sending reminders. Read-only: produces an aging, a collection plan, unsent reminder drafts and a coverage sheet, and posts or sends nothing."
---

# A/R aging and collections

Answers **who owes us money, how late are they, and who should we chase first.** It sorts every
unpaid customer invoice into lateness buckets on its **open balance**, ties the invoice detail
back to the aging summary, ranks overdue customers, works out the receivables metrics, and drafts
reminders that a person reviews and sends.

The mistakes it catches are an aging that **silently leaves out the oldest unpaid invoices**
(an invoice search that defaults to recent dates is not the population), a **customer balance
report passed off as an aging**, a **DSO that flatters itself** by dividing by total income, and
a **disputed invoice chased as though it were simply late**.

**Works with or without Mosofin.** With Mosofin connected, it reads the aging summary, the aging
detail where that capability is listed, invoices, payments, credit memos, the customer master and
the A/R control balance. **It can never read disputes, credit holds, strategic tiers, payment
history or your collection policy** — the books do not reliably hold them — so it asks for them
when the output needs them. It cannot apply a payment, write off a balance, place a hold or send a
reminder. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never contacts a customer.** Every draft is marked `REVIEW REQUIRED - NOT SENT` and invents
  no dispute, credit hold, payment promise, late fee, suspension or legal action.
- **Never forces a tie, and never passes off a partial population.** An invoice search is not a
  complete aging and a customer balance report is not an aging; unresolved variance is disclosed.
- **Never infers** disputes, holds, tiers or payment history from the ledger, never presents a
  proxy DSO unlabeled, and never folds currencies into an unlabeled total.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 1–7" always mean the numbered sections in
`references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *As of which date?* | Every bucket is counted from it: days past due = as-of date − due date | Ask only if ambiguous, and pass a concrete date. **Never silently default it.** |
| **C** | *What do you need: the aging alone, a collection plan, DSO, reminder drafts? All customers, or one?* | Decides which inputs are material. Core aging needs no dispute flags, payment history, DSO or policy | For one customer, resolve the name against the customer master and **state the match**. |
| **D** | *State, don't ask:* an aging lists unpaid invoices, so it is always on invoices issued (accrual), even if you file on a cash basis; only DSO and any income figure depend on basis | Avoids promising a "cash" aging that does not exist | If the user explicitly asks for a cash-basis aging, explain and **ask whether accrual is acceptable before reading data**. |
| **E** | *For DSO: the measurement period (and, on the upload path, credit sales).* | The correct DSO denominator; total income includes cash sales | Only if DSO is wanted. On the Mosofin path credit sales are derived from invoices less credit memos (Step 5); otherwise **require credit sales**; offer `Approximate DSO (total-income proxy)` only with approval. |
| **F** | *Any disputes, credit holds, strategic tiers or payment history?* | They change ranking and tone, and route disputes away from collection pressure | Only when the prioritisation needs them. **Never infer**; omit and disclose. |
| **G** | *Your collection policy: approved wording, payment contact, escalation ladder.* | Drafts apply only supplied terms | Only if drafts are wanted. Use neutral language with no fees or threats. |

Whatever is still missing and material after the pull is asked **once, as one consolidated
question** (Step 4).

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)); confirm the company from its
  profile before reporting.
- If the datasource is disconnected or not active, **stop**: show the `reconnect_url` and wait.
  Do not substitute CSVs or guessed numbers while the user is asking for live data.
- Check at Gate 2 whether an **A/R aging detail** capability is listed. If not, ask for an A/R
  Aging Detail export — an invoice search is enrichment, never the population.
- Name any company file that is excluded, and say whose receivables are therefore missing.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **A/R Aging Detail** as of the date — one row per open invoice, with due date and open balance, exported with **Aging method: Report date** and the as-of date set | **Required** — the invoice population | CSV or XLSX |
| **A/R Aging Summary** for the same date | Recommended — the independent tie-out; without it, totals come from the detail and the output says there was no independent tie-out | CSV, XLSX or PDF |
| **A/R control balance** (balance sheet or trial balance) | Recommended — needed before the tie-out may be called a GL reconciliation | CSV, XLSX or PDF |
| **Unapplied credits and payments**, or a full detail export | Only if detail and summary do not reconcile | CSV or XLSX |
| **Credit sales** for the period | Only for exact DSO | Type it in the chat, or CSV/XLSX |
| Disputes, credit holds, tiers, payment history; collection policy and payment contact | Only when the plan or drafts need them | Type it in the chat |
| Company name, as-of date, base currency | Required | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Building the A/R aging for **Northbrook Trading** as of **30 September 2026**, accrual basis,
> from **your Mosofin connection**: invoice detail tied to the aging summary, then a collection
> plan and reminder drafts in **your approved wording**, every draft marked not sent. No DSO this
> time. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the as-of date,
the row count, the total open balance. Flag anything unreadable, or covering the wrong date or a
different company, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, settle single or multi-entity, build the capability map — aging summary and aging
detail are different capabilities — and read the company profile for base currency and fiscal
calendar. The guardrails at the end of gates.md hold for the whole run. On the upload path, go
straight to Stage 3.

## Stage 3 — Pull the aging and normalise it

Pull the aging detail and the unfiltered summary for the same date in one batch, using invoice
search only for selected enrichment; check each result's `mock` flag. Normalise to one row per
invoice, aged on the **open balance**, IDs kept as text, absent fields left blank, into Current,
1-30, 31-60, 61-90, 91-120 and Over 120: [`references/method.md`](references/method.md) Steps 1–2.

## Stage 4 — Reconcile, fill the gaps, analyse

Tie detail to summary by customer and in total at a 0.01 tolerance, re-pulling unfiltered to find
reconciling credits and payments; **disclose any unresolved variance**, and call it a
summary-to-detail reconciliation unless the GL control balance was tested. Ask the one
consolidated gap question, then compute the metrics, rank overdue customers by age and open
balance, and assign action bands: [`references/method.md`](references/method.md) Steps 3–5.
Bankruptcy or insolvency stops ordinary dunning. Check
[`references/edge-cases.md`](references/edge-cases.md) and the validation scenarios in method.md
for credits, payments in flight, missing due dates, foreign currency and shared customers.

## Stage 5 — Deliver the aging, plan and drafts

Build the run context, aging summary and detail, collection plan, drafts, exceptions and coverage
sheet: [`references/method.md`](references/method.md) Step 6. Ask before creating the `.xlsx`.
Before presenting, check it against [`references/output.md`](references/output.md). End with one
**Data sources** line.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist strategic tiers, standing credit
holds and disputes, the collection policy and brand voice, any overridden action bands or buckets
and the DSO basis, keyed to the entity — **never customer contact details, balances or draft
correspondence.**

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
