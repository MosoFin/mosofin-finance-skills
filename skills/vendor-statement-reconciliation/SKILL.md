---
name: vendor-statement-reconciliation
description: "Reconciles a supplier's statement to the AP subledger and general ledger: matches by document number, then amount and date, then PO, then description, recording the tier, and explains every difference: missing invoices (candidate unrecorded liabilities), missing credits owed back, payments in transit, misapplied payments, duplicates and disputes, each with an owner, next action and target date. Ranks which vendors most need reconciling, including any never reconciled or overpaid. Reads the AP ledger and payment register through a connected Mosofin workspace when the user agrees, or works from uploaded exports; always asks for the statement, which no accounting system holds. Use for a vendor statement recon, AP statement tie-out, supplier statement mismatch, cleaning up AP, unrecorded liabilities or unclaimed credits. Do not use for bank accounts (use bank-reconciliation) or matching invoices to POs (use three-way-match). Read-only: produces a reconciliation, exceptions and proposed entries, and posts nothing."
---

# Vendor statement reconciliation

Compares what a **supplier says you owe** — their statement, prepared from their own records —
with what **your AP ledger** says, item by item, and explains every difference. Because the
other side was produced by somebody with no access to your books, it is a genuine external
reconciliation, like a bank reconciliation: **the primary control over the completeness of
payables.**

The mistake it catches is the **unrecorded liability** — an invoice on the supplier's list and
not on yours, understating both payables and expense — and its mirror, the **credit note the
supplier issued and you never took**, which is money back. It also catches the false alarms: a
statement addressed to a sibling entity, a supplier set up twice in the vendor master, or two
different cutoff dates, any of which make recorded invoices look missing.

**Works with or without Mosofin.** With Mosofin connected, it reads one side in full: every
invoice, credit and payment in the AP subledger and vendor ledger, the payment register, the
vendor master and spend by vendor — and uses them to rank which suppliers most need reconciling.
**It can never read the vendor statement** — a document the supplier sends, not in any
accounting system — **or the dispute log**, which is correspondence; it always asks for both.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post, and it contacts no supplier.
- **Never books a liability from a statement line.** A statement is not an invoice: a confirmed
  missing item whose document has not arrived is accrued, not posted as an invoice.
- **Never concludes "missing invoice" before the duplicate-vendor check**, and never reconciles
  a statement whose entity and account reference do not match the ledger.
- **Never forces an uncertain match.** Every match shows its tier; an amount match with a
  recurring supplier can be the wrong month, so ties are reported as ambiguity, not picked.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–5" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *The vendor statement for each supplier to reconcile — PDF or CSV.* | The one side Mosofin cannot see | **Required, always.** On the Mosofin path, Step 0 can still rank which suppliers need a statement requested. |
| **C** | *Which entity is the statement addressed to, and what account reference does it carry?* | A statement for a sibling entity, reconciled against the wrong ledger, shows every invoice as missing | **Never assume.** Check the account reference against the entity being reconciled before matching. |
| **D** | *Your cutoff date — and the date on the statement, if different.* | A statement at the 25th against a ledger at the 30th shows five days of legitimate difference both ways | **Required.** Establish both dates; the gap is a known reconciling window, not exceptions. |
| **E** | *Is the statement a full open-item list, overdue items only, or balance-forward?* | An overdue-only statement makes every current invoice look unmatched; open-item and balance-forward cannot be compared line for line | Confirm before matching. |
| **F** | *The dispute log — any invoices deliberately withheld?* | Disputes are correspondence, not ledger data | Recommended. Without it, the coverage sheet lists it as not done. |
| **G** | *Which vendors are on the reconciliation programme, how often, and who owns the exceptions?* | Every exception needs an owner and a target date | Step 0 informs the vendor list. The next action is proposed per exception; **the owner and the date are human commitments** — leave them to a person. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)), and confirm it is **the entity
  the statement addresses**. A combined statement covering several group entities is matched
  across all the connected ones, then split by entity. A connection needing reconnection stops
  the run — a partial ledger makes recorded invoices look missing.
- Run **Step 0** before any single reconciliation: rank suppliers by balance, spend, never
  reconciled, overpaid, old open items, a broken invoice pattern and high GRNI, and report which
  have never been reconciled.
- Read **beyond the cutoff date**, so payments in transit and post-cutoff activity can explain
  differences.
- Still ask for the **statement** (B) and the **dispute log** (F).

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Vendor statement** | **Required** | PDF or CSV |
| **AP ageing or vendor ledger** for that supplier | **Required** | CSV or XLSX export |
| Cutoff date, the entity the statement addresses and its account reference | **Required** | Type it in the chat |
| **Payment register** — AP payments with bank detail | Recommended — explains payments in transit and misapplied payments | CSV or XLSX export |
| **Dispute log** — notes of disputed invoices | Recommended | Any format, or type it in the chat |

Without a connection, Step 0's prioritisation does not run; the reconciliation itself is the same.

**Read back before starting, then wait for a yes:**

> *Reconciling **Harbor Supply's** statement to **Northbrook Trading**'s AP ledger, account
> reference **NT-4471**, with the ledger and payments read from **your Mosofin connection** and
> the **open-item statement you uploaded**. Ledger cutoff **30 September**, statement dated
> **25 September** — the five days between are a known window. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the cutoff it
covers, the item count, the closing balance. Flag anything unreadable, or a statement for a
different entity or account, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace, the
company file and the entity the statement addresses, map the read tools, and read any saved
version of this skill before interviewing. On the upload path, go straight to Stage 3.

## Stage 3 — Choose the vendors, then normalise both sides

On the Mosofin path, rank the supplier population first: [`references/method.md`](references/method.md)
Step 0. Then standardise document number, type, date, amount and currency, and PO reference on
both sides, handling the three traps — document numbers as text, different cutoff dates,
different sign conventions — and recording the normalisation applied: Step 1.

## Stage 4 — Match, then explain every difference

Match in the four-tier order — document number, amount and date proximity, PO and amount, fuzzy
reference — recording the tier and leaving doubtful items unmatched; then classify each
difference: missing invoice (by likely cause), missing credit, payment in transit, misapplied
payment, duplicate or dispute: [`references/method.md`](references/method.md) Steps 2–3. Check
[`references/edge-cases.md`](references/edge-cases.md) for a statement for the wrong entity, a
duplicate vendor record, foreign-currency statements (match on the currency amount, not the
converted one), payments to an old bank account, rebates, and a supplier never reconciled before.

## Stage 5 — Resolve, propose the entries and present

Give every exception an owner, a next action and a target date, and age exceptions carried
from earlier reconciliations; then draft the entries — reverse duplicates, reclass mis-postings,
record confirmed missing items **with support**, accruals kept distinct from invoice postings,
marked PROPOSED — NOT POSTED: [`references/method.md`](references/method.md) Steps 4–5. Report
missing credits **separately and prominently**. Before presenting, check the six sheets, the
quality standards and the coverage sheet in [`references/output.md`](references/output.md). Ask
whether the user wants the workpaper as an Excel file before creating one.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md), *Seed to evolved*. Persist the vendors on the
programme and their frequency, each supplier's statement conventions and account reference per
entity, the normalisation rules, open exceptions with their age and owner, known permanent
differences, and which vendors were reconciled when — never the capability map, which Gate 2
reads fresh each run.

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
