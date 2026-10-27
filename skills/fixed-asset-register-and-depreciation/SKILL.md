---
name: fixed-asset-register-and-depreciation
description: "Maintains the fixed asset (PP&E) register and computes depreciation under US GAAP, IFRS or local GAAP: derives additions and disposals from the ledger movements, scans repairs and maintenance for capital items at or above the threshold, computes period depreciation by the policy method, compares the implied rate with policy lives, proposes depreciation, capitalization and disposal entries, and reconciles the register to the GL in both directions. Reads the books through a connected Mosofin workspace when the user agrees, or works from uploaded trial balances, GL detail and an asset listing. Always asks for useful lives, the capitalization threshold and the convention, which the books do not hold. Use when the user asks to add or dispose of an asset, capitalize a purchase, compute depreciation, build a depreciation schedule, reconcile fixed assets or review for impairment. Do not use for intangibles or leases. Read-only: produces a register workpaper and proposed entries, and posts nothing."
---

# Fixed asset register and depreciation

Keeps the list of every long-lived asset the business owns — what it cost, when it went into use, how
fast it is being written down — computes the period's depreciation, handles capitalizations and
disposals, and ties the register to the general ledger. It catches the errors that sit quietly for
years: **a capitalization that never made it into the register and so is never depreciated**, a
register asset that was disposed of long ago, **a capital item hiding in repairs and maintenance**, a
disposal that removed the cost but left the accumulated depreciation behind. **The ledger holds the
balances, not the register** — but its movements let it derive additions and disposals independently
and reconcile **in both directions**.

**Works with or without Mosofin.** With Mosofin connected, it reads gross cost, accumulated
depreciation and depreciation expense by account, every debit and credit to the asset accounts, the
purchase documents behind them, and the expense accounts where capital items hide. **It cannot read the
register itself** (unless a fixed-asset module is connected), **useful lives, methods, salvage values,
the capitalization policy, impairment forecasts and fair values, tax depreciation, or the physical
count** — so it always asks for them. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never defaults a useful life, a salvage value, a capitalization threshold, or a convention.** The
  class table in Step 1 is a range, not a policy.
- **Reports candidates, not conclusions** — a large repair is not asserted to be a capital item, and
  impairment is **never concluded from ledger data**. The policy call is yours.
- **Never lets a clean GL tie-out imply the assets exist.** The physical count is `[manual]`, with an
  owner and its last-performed date; and the register, asset-level costs, net book values, locations
  and serial numbers are never persisted.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–13" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which period?* | Sets the movements, the charge and the roll-forward | **Required.** |
| **C** | *Your existing fixed asset register — asset, class, cost, in-service date, life, salvage, method, location.* | **The core gap.** Asset-level depreciation needs it | Recommended. Without it, offer a **draft register derived from the GL**, to be confirmed (Step 5). |
| **D** | *Useful life, method and salvage policy for each asset class (salvage nil is a valid answer, but it is yours).* | Drives every depreciation figure | **Required. Never assume a life or salvage.** |
| **D2** | *Do you book depreciation per your own policy, or post the figure from your tax return / accountant?* | If the latter, the accountant's schedule is the register source and no separate charge is computed | **Required.** |
| **E** | *What is the capitalization threshold?* | Step 2b's expense scan depends on it | **Required, and never defaulted.** Ask early. |
| **F** | *Which first / last period convention — half-month, full month or pro-rata?* | Changes every number | **Required, and never defaulted.** |
| **G** | *Which reporting framework — US GAAP, IFRS or local GAAP?* | Decides componentization, revaluation and impairment reversal | **Required.** |
| **H** | *Which tax jurisdiction?* | Tax-book differences | Recommended. Tax depreciation is `[manual]`, always. |
| **I** | *Any impairment triggering events? And when were the assets last physically counted, and by whom?* | Nothing in the ledger signals a trigger; only a count proves the assets exist | Impairment indicators if applicable. The count is recorded as `[manual]` with its owner and date — **if never, that is the finding.** |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 for a connected **fixed-asset module or asset-management platform**. If one is live,
  the register becomes `[auto]`; most accounting connections have none — say which case you are in.
- Do not ask for acquisitions or disposals: they are **derived from the debits and credits to the
  asset accounts** and the gain-or-loss accounts. Confirm them, and ask for the disposal reason and
  proceeds.
- Do not ask for the chart or the functional currency; read whether accumulated depreciation is per
  class or consolidated.
- Still ask for the **register** (C), the **class policies** (D), the **threshold** (E), the
  **convention** (F) and the **framework** (G). None is in the books.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Trial balance or balance sheet** — gross cost and accumulated depreciation by account, opening and closing | **Required** | CSV or XLSX |
| **GL detail** for the asset, accumulated depreciation, depreciation expense and gain / loss on disposal accounts | **Required** — the additions and disposals population | CSV or XLSX |
| **Fixed asset register** (or the accountant's depreciation schedule) | Recommended — without it, a draft register is derived from the GL, to be confirmed | CSV or XLSX |
| **GL detail for repairs, maintenance, small tools, equipment and computer expense** | Recommended — the capitalization threshold scan | CSV or XLSX |
| **Purchase invoices** behind the period's additions | Recommended — the cost build-up, freight and installation | PDF or image |
| Period, entity name, functional currency, year-end; framework; class lives and methods; threshold; convention | **Required** | Type it in the chat |
| Tax jurisdiction; disposal reasons and proceeds; impairment indicators; last count date and owner | Recommended | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Running the fixed asset register for **Northbrook Trading** for **September**, with the ledger read
> from **your Mosofin connection** and the register from **the spreadsheet you uploaded (412 assets)**.
> **US GAAP**; machinery **10 years** and vehicles **5 years**, straight-line; capitalization threshold
> **$2,500**; **full-month** convention. Last physical count **December 2023, by the operations
> manager**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period or date it
covers, the row count, the totals. Flag anything unreadable, covering the wrong period, or missing a
life or in-service date, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, check for a fixed-asset module, check which read tools are enabled, and read the company
profile — functional currency, fiscal calendar and year-end — so Stage 1's answers do not need asking
twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read the ledger and map the classes

Pull the asset, accumulated depreciation, depreciation expense, disposal and repairs accounts, the
balances, every movement on the asset accounts, the purchase documents and the expense accounts in one
batch; **if a read returns `mock: true`, stop** — nothing computed from it is proposed for posting. Then
map each class to the accounts that exist, report a class with no account or an account with no policy,
and **check that land carries no accumulated depreciation**:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Capitalize, depreciate and check disposals

Test acquisitions against the policy and the cost build-up, flag freight or installation expensed on a
capitalized invoice, and run the **threshold scan both ways** (Step 2b). Apply the method and convention,
compute the period's charge — never past cost less salvage — and compare the **implied rate** with the
policy life; say whether depreciation was posted at all. Draft the depreciation entry for
`journal-entry-builder`, a reclassification (crediting the expense, not Cash / AP) only for items the scan found wrongly expensed, and
disposal entries — all **proposals** — and check every disposal for the **half-entry** error: [`references/method.md`](references/method.md) Steps 2–8. Check
[`references/edge-cases.md`](references/edge-cases.md) for land, CIP, composite assets, leasehold
improvements, foreign currency, held for sale, trade-ins and software.

## Stage 5 — Tie out both ways, flag impairment and the count, and present

Roll forward cost and accumulated depreciation by class and tie to the GL; then reconcile **register →
GL** (phantoms) and **GL → register** (assets never depreciated) as **separate lists**. Raise impairment
**candidates** only, and record the physical count with its owner and date. Then the workpaper — register,
schedule, acquisitions, disposals, roll-forward, tie-out, impairment, postings, tax-book differences,
**threshold scan** and coverage: [`references/method.md`](references/method.md) Steps 9–12. Ask before
creating the `.xlsx`; otherwise give the sheets as tables. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 13. Persist the class policies, the threshold with
its effective date, the convention, the account and class maps, the framework and its elections, the
salvage **policy**, the allocation basis and the count cadence and owner — never the register,
asset-level costs, net book values, locations or serial numbers.

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
