---
name: closing-entries-and-trial-balance
description: "Prepares the year-end closing entries that empty revenue, expense, gain and loss accounts and dividends, distributions or draws into retained earnings (or owner or member capital), and produces or audits the pre-closing and post-closing trial balance with retained-earnings tie-outs. Before proposing any entry it tests whether the platform has already closed the year, so retained earnings is never closed twice. Reads the trial balance, account types and equity through a connected Mosofin workspace when the user agrees, or works from an uploaded trial balance and chart of accounts. Use when the user asks to close the books for the year, prepare closing entries, roll income to retained earnings, produce a final or post-closing trial balance, check why a TB does not balance, or uploads a TB to review. Do not use for monthly close orchestration (use month-end-close-checklist). Read-only: produces proposed closing entries, trial balances, a tie-out workpaper and a coverage sheet, posts nothing and locks no period."
---

# Closing entries and trial balance

At year end the profit and loss accounts are emptied to zero and the year's profit is rolled into
**retained earnings** (or owner or member capital). This skill checks the **pre-closing trial
balance** balances, works out the **closing entries** account by account, proves the
**post-closing trial balance** balances, and ties retained earnings to the balance sheet.

The mistake it exists to stop is the **double close**: some systems close the P&L to retained
earnings automatically when the fiscal year is advanced, and posting an explicit closing entry on
top misstates retained earnings by the whole year's result. It tests for that **before proposing
anything**. It also catches an **OCI item swept into net income**, and an account whose **type and
name disagree** — a revenue-typed "Deferred Revenue" would close a liability into retained earnings.

**Works with or without Mosofin.** With Mosofin connected, nearly everything reads from your books:
the trial balance, every account's **type** (which decides temporary versus permanent), net income,
opening retained earnings, dividends, whether adjustments posted, and the new year's opening TB. **It can never post
a closing entry or lock a period**, and it cannot read your **entity's legal form**, your
**reporting framework**, or whether reconciliations and management approval are done — it asks.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never proposes a closing entry before the closed-state test.** If the year is already closed —
  by the platform or by an explicit entry — it verifies, it does not close again.
- **Classifies temporary versus permanent on account type, never on name**, and lists every
  name / type mismatch as an exception for you to confirm. Draws and distributions, equity-typed on
  most platforms, are the one exception: identified from the equity GL and confirmed with you.
- **Never reports the period as locked.** Locking is a human action in the accounting system; the
  output names who will do it. **Never defaults the fiscal year end, the entity type or the
  framework**, and never builds a closing entry on `mock` data.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–11" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which company — or, for a group, which entities?* | **Each entity closes its own books**; there is no group closing entry, and trial balances are never combined before closing | On the Mosofin path, list the connected company files **by name** and ask. Never auto-pick. |
| **C** | *What is the fiscal year end?* | Defines the closing date and the first day of the new year; the wrong year-end closes the wrong twelve months | **Never default it.** On the Mosofin path read it from the profile, then **read it back and confirm** — a changed year-end is common. |
| **D** | *What is the entity type — corporation, partnership, LLC, sole proprietor or nonprofit?* | The dividends / distributions entry (Step 5) differs entirely by type | **Never default it.** Propose what the equity account names suggest, then **have the user confirm**. |
| **D2** | *If a partnership or LLC: how is profit shared between members (percentages, or per the operating agreement), and is capital kept per member?* | The year's income is allocated to each member's capital account (Step 5) | **Required for those types.** Never assume equal shares. |
| **E** | *Which reporting framework — US GAAP, IFRS, local GAAP or other?* | Affects OCI treatment | **Never default it.** Ask. |
| **F** | *Is this the final trial balance — are all adjusting entries posted?* | Closing runs on the final TB, after depreciation, accruals, deferrals, prepaid amortization and the tax provision | **Required.** A missing expected entry is flagged as a signal, but the full list is the user's to confirm. |
| **G** | *Does your accounting system close the year automatically when you advance it?* | Prevents the double close | **Required.** On the Mosofin path it is **tested, then confirmed** with the user (Step 0b). |
| **H** | *Is the audit complete?* | Decides preliminary versus final close | Recommended. A preliminary close that is later adjusted needs the tie-outs re-run. |
| **I** | *Do you close two-step (straight to retained earnings) or four-step (through Income Summary)?* | Both reach the same end state; consistency year to year matters more than the choice | Check which was used historically and propose it. |
| **J** | *Do you report on a cash or accrual basis?* | Net income and retained earnings differ by basis; the closing entries must tie to the statements and the return | **Required.** Passed on every read and stated in the workpaper header. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Derive the fiscal year end and functional currency from the company profile, and **read the year
  end back** for confirmation.
- Read the account **types** from the chart of accounts. If the account tool is disabled,
  classification becomes manual and is confirmed **account by account**.
- A balance sheet plus a P&L is **not** a trial balance. If the trial balance tool is disabled, say
  the balance check could not be performed.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Pre-closing trial balance** at the fiscal year end — the **final** TB, after adjusting entries | **Required** | CSV or XLSX |
| **Chart of accounts with account types** — this drives the temporary / permanent split | **Required** | CSV or XLSX |
| **Prior year's closing retained earnings** — RE + Net Income lines at the prior year end, or RE on the first day of this year | **Required for continuity** | CSV, XLSX or PDF |
| **Trial balance (or balance sheet) dated the first day of the new fiscal year**, and the **retained earnings / equity GL** for the year and the first month after | **Required for the closed-state test** — without them the state is user-asserted, not tested | CSV or XLSX |
| **Last year's final statements or tax return** — to agree opening retained earnings or capital | Recommended | PDF, CSV or XLSX |
| Fiscal year end, entity type, functional currency; whether the system auto-closes the year | **Required** | Type it in the chat |
| **Dividends / distributions declared** during the year — GL detail for the dividend, draw and equity accounts | If applicable | CSV or XLSX |
| Reporting framework; any **OCI** items; whether the audit is complete | Recommended | Type it in the chat |
| P&L for the year; balance sheet at the current year end | Recommended — the net-income cross-check and the equity tie-out | CSV, XLSX or PDF |

**Read back before starting, then wait for a yes:**

> *Closing **FY2026** (year ended **31 December 2026**) for **Northbrook Trading**, an **LLC** with
> capital kept **per member**, using the **two-step** method, with the books read from **your
> Mosofin connection**. The audit is **not yet complete**, so this is a **preliminary close**. I
> will first test whether the system has already closed the year. Shall I go ahead?*

On the upload path, name each file you received and what was read from it — the date, row count,
total debits and credits. Flag anything unreadable, at the wrong date, or not final, at once.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, check which read tools are enabled — the account tool carrying **account types**
matters most — and read the profile for the fiscal year end and functional currency, so Stage 1's
answers are not asked twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books, test the closed state, verify the trial balance

Pull the trial balance, the accounts with their types, the P&L, both balance sheets, the equity GL
and the year-end journal entries in one batch, and check the `mock` flag. Then **test whether the
year is already closed** — the trial balance on the first day of the new year, any explicit closing
journal, the movement in retained earnings — and report one of three states: **not closed**,
**auto-closed by the platform**, or **already closed by an explicit entry**. Then verify the
pre-closing TB: debits equal credits, adjusting entries posted, reconciliations tied out, material
variances reviewed, management approval: [`references/method.md`](references/method.md) Steps 0–1.
If the TB does not balance, investigate before closing — see
[`references/edge-cases.md`](references/edge-cases.md).

## Stage 4 — Classify the accounts and build the closing entries

Only if Stage 3 found the year **not closed** — or auto-closed, for the draws / distributions entry
and the member allocation only. Classify every account as temporary or permanent on
its type, listing name / type mismatches; settle the two-step or four-step method; compute the
category totals and **cross-check net income against the P&L**; construct the closing entries for
the entity type, **every account listed individually** in the real chart names; and close OCI to
AOCI, not retained earnings: [`references/method.md`](references/method.md) Steps 2–6. Check
[`references/edge-cases.md`](references/edge-cases.md) for owner-capital and nonprofit equity,
multi-currency, treasury stock, stock-based compensation, OCI never recycled, and audit adjustments
after a preliminary close. If the year was already closed by an explicit entry, propose no entries
and verify it; if auto-closed, document the system's roll and propose only what it leaves (Step 0b).

## Stage 5 — Prove the result and present it

Build the post-closing trial balance and run the tie-outs — only temporary accounts moved, net
income and dividends equal the movement in retained earnings, permanent accounts unchanged,
closing retained earnings reconciled to the balance sheet equity — and record the **lock as a
manual step with a named owner**: [`references/method.md`](references/method.md) Steps 7–10. One
workpaper per entity, never combined, with the Step 0b closed-state finding in its header. Before
presenting, check it against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 11. Persist the entity type, the closing
method, whether the platform auto-closes, the classification exceptions, the OCI list, the equity
account map and who locks the period, keyed by datasource and entity — never balances, net income,
retained earnings or the trial balances. Whether this year is closed is state, re-tested every run.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 3–4, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
| [`references/tools-and-glossary.md`](references/tools-and-glossary.md) | When you need a tool name or a term |
