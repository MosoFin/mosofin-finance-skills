---
name: journal-entry-builder
description: "Builds balanced, import-ready journal entries for any accounting event — standard, accrual, deferral, adjusting, correcting, reclass, reversing, intercompany or closing — against the entity's real chart of accounts, and validates each one: debits equal credits, every account exists, signs match account types, the period is open, and no open accrual, open invoice or control account makes the entry wrong. Reads the books through a connected Mosofin workspace when the user agrees, or works from an uploaded chart of accounts, trial balance or GL export. Use when the user says 'book a JE for…', 'create a journal entry to record…', 'how do I record this transaction', 'make me an accrual JE', 'reclass these entries' or 'reverse this entry', or asks for an import-ready JE file. Do not use for GL coding decisions only (use gl-coding-assistant) or a full period close (use month-end-close-checklist). Read-only: produces proposed entries with narration, validation results and a coverage sheet, and posts nothing."
---

# Journal entry builder

Turns an accounting event into a **proposed journal entry** that balances to the penny, names
real accounts from **your chart of accounts**, carries a memo someone can follow a year later and
comes in the **import format of your accounting system**. Every entry arrives with its
**validation result**, check by check, so a reviewer can post it quickly.

The mistake it catches most is the **double-count**: booking a payment or an invoice for an item
an **accrual already covers**. It also catches a receipt sent to revenue when an invoice is open,
a loan payment booked entirely as expense, a manual entry to a control account, an account that
does not exist in the chart, and a closing entry where the platform already closes the year.

**Works with or without Mosofin.** With Mosofin connected, it reads the chart with account numbers,
names and types, the balances on the accounts being touched, the accrual, prepaid, deferred and
clearing accounts, open invoices and bills, and past journal entries for the numbering convention
and any original being reversed or reclassed. **It can never read the transaction or event being
recorded, the materiality threshold, the tax rules, or a source document not held in the system**,
so it asks you for those. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Says "proposed entry" on every output** — the header reads **PROPOSED ENTRY — NOT POSTED** —
  and never implies anything has been recorded.
- **Never invents an account number.** An account that does not exist in the chart is a **hard
  stop**, not a warning; with no chart at all, it uses descriptive names labelled
  **"PLACEHOLDER — REMAP REQUIRED"** and says so.
- **Never defaults an account, a tax treatment or a materiality threshold**, never pads with a
  "Rounding" plug, and never deletes or alters a posted original — a correction reverses and
  rebooks, or nets the difference, and references the original entry.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–8" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *What transaction or event are we recording?* With the amounts and any supporting document | It is the user's, and no connection can supply it | **Required.** Nothing is built without it. |
| **C** | *What is the posting date?* | Sets the period, the reversal date and the open-period check | **Required.** Ask; the period check cannot run without it. |
| **D** | *Which entity does this entry belong to?* For an intercompany entry, both | Account numbers differ by entity; building against the wrong chart is the most common cross-entity failure | On the Mosofin path, confirm by `display_name`. In a manual run, ask by name and record it as user-asserted. |
| **E** | *Does it have a tax effect, and in which jurisdiction?* | Decides whether tax lines appear, and which side they sit on | **Required if there are tax effects.** No tax lines without a jurisdiction; if the rules are unclear, ask — never assume the treatment. |
| **F** | *What is the materiality threshold for a review flag?* | Drives the large-entry flag | **Never default it.** If unanswered, that check is named as not run. |
| **G** | *Source document reference, and should the entry reverse?* | Goes in the header; an accrual usually reverses on the first day of the next period | Recommended / optional. Where the document is in the system it can be found. |
| **H** | *What date are the books closed (or locked) through, and has any period after that already been reported?* | The open-period check; a journal search cannot show a lock date | **Required.** Recorded as user-asserted unless the platform's own setting is readable. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- The **chart of accounts, entity, functional currency and accounting system** come from the
  books — don't ask for them. The import format follows the connected platform; ask only when its
  import template is itself the uncertainty. For a loan payment, ask for the lender statement or
  amortization schedule — the split is not in the books.
- **Invoked as a handoff from another skill?** The gates have usually run in this conversation:
  confirm the entity in one line rather than repeating them — never build against an unconfirmed
  entity.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| The **transaction or event** — what happened, the amounts, the date | **Required** | Type it in the chat, or the source document as PDF or image |
| **Chart of accounts** — account numbers, names and types | **Required** — without it, only descriptive placeholders labelled "PLACEHOLDER — REMAP REQUIRED" | CSV or XLSX, or the account names and numbers typed in |
| Entity name, functional currency, **fiscal year-end** and **accounting basis** (cash or accrual) | Required | Type it in the chat |
| Accounting system, or its import template | Recommended — without it, generic columns for you to remap | Type it in the chat; the template as CSV or XLSX |
| **Tax jurisdiction** and rules | Required if the transaction has tax effects | Type it in the chat |
| **Trial balance** or **GL detail** for the accounts touched, incl. accrual, prepaid, deferred and clearing accounts | Recommended — needed for the accrual double-count, clearing-balance and other ledger checks | CSV or XLSX |
| **Materiality threshold**; the original entry for a reversal, reclass or correction | Recommended | Type it in the chat; the original as CSV, XLSX or PDF |
| **Open invoices / open bills** (AR or AP aging detail) for a receipt or payment; the **loan statement or amortization schedule** for a loan payment | Recommended — the open-invoice check and the interest/principal split depend on them | CSV or XLSX; the statement as PDF |

**Read back before starting, then wait for a yes:**

> *Building a **proposed accrual** at **Northbrook Trading** for **September consulting fees of
> $8,400**, invoice expected in October, dated **30 September** and reversing on **1 October**,
> against the chart read from **your Mosofin connection**, in **QuickBooks Online** import format.
> No tax effect; materiality threshold **$25,000**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the accounts found. Flag anything unreadable or covering the wrong entity
straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
entity — for an intercompany entry, both entities — check which read tools are enabled, and read
the company profile — legal name, **functional currency**, fiscal calendar and year-end — so
Stage 1's answers do not need asking twice. If the chart read is disabled, the placeholder
fallback applies and the output says why. On the upload path, go straight to Stage 3.

## Stage 3 — Read the chart and the books

Pull everything in one batch — the chart with numbers, names and types, balances on the accounts
being touched, the accrual, prepaid, deferred and clearing accounts, any existing invoice or bill
for the item, past journal entries for the numbering convention and period status, and the
company profile: [`references/method.md`](references/method.md) Step 0. Check the `mock` flag:
fixture accounts may not exist in the real chart.

## Stage 4 — Classify and construct the entry

Name the JE type and state it in the header; check before any closing entry whether the platform
closes the year automatically. Apply the normal-balance rules, construct the entry from the live
chart exactly as accounts appear there, use the common patterns — reversals dated the **first day
of the next period**, intercompany mirrored in both entities against their own charts — and add tax
lines only with a jurisdiction: [`references/method.md`](references/method.md) Steps 1–5. Check
[`references/edge-cases.md`](references/edge-cases.md) for multi-currency entries, penny rounding,
entries crossing fiscal years, suspense and clearing accounts, cash-basis entities and large or
unusual entries.

## Stage 5 — Validate and present the proposed entry

Run the nine original checks and the Mosofin additions — no open accrual covers the item, no open
invoice for a receipt booked to revenue, a loan payment split between interest and principal, no
control account, the materiality flag, and the age of any clearing balance — and report the result
**with the entry**, each check with its evidence; a check that could not run is **named as not
run**. Then the entry inline, or as an import-ready file in the platform's format with Validation
Results and Coverage sheets: [`references/method.md`](references/method.md) Steps 6–7, and the
pitfalls at the end of that file. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 8. Persist the account map, entry templates,
import format, numbering and memo conventions, materiality threshold, reversal policy,
intercompany account pairs and tax code mapping, keyed by datasource and `display_name` — never
amounts, balances, entry contents or transaction details.

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
