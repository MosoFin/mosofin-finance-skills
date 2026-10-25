---
name: balance-sheet-reconciliations
description: "Reconciles balance sheet accounts to their support — subledgers, schedules and external documents — and builds a monthly or quarterly workpaper per account: GL balance, supporting balance, reconciling items typed as timing, permanent or investigating, roll-forward, aging against materiality and proposed correcting entries. Every account gets a two-sided verdict: one whose support was never supplied, or is another view of the same ledger, is not reconciled. Reads the GL side, and the A/R, A/P and clearing support, through Mosofin when the user agrees, or works from an uploaded trial balance and schedules. Use when the user asks to reconcile balance sheet accounts, tie A/R, A/P, prepaid, accrued or intercompany balances to the GL, prepare a monthly BS rec workpaper, or find unreconciled differences. Do not use for bank accounts (use bank-reconciliation) or the full period close (use month-end-close-checklist). Read-only: produces a workpaper, proposed entries and a coverage sheet, and posts nothing."
---

# Balance sheet reconciliations

The balance sheet shows one number per account. Behind most of those numbers there should be a
detailed list that adds up to exactly that number — the customers who owe you, the bills you
haven't paid, the assets you own. This skill proves the **GL balance** and its **support** agree
for each account, explains every difference as **timing**, **permanent** or **investigating**,
rolls activity forward, ages the open items against materiality, and proposes the corrections.

The mistake it exists to stop is a **tie-out that never happened**: an account whose support was
never supplied, or whose "support" was just another view of the same ledger, presented as
reconciled. Every account gets a **two-sided verdict** — GL side and support side — so a total
agreeing with itself is never passed off as assurance.

**Works with or without Mosofin.** With Mosofin connected, the **GL side is almost always read
directly** — the trial balance, the balance and the transactions behind it — and so is the
support for **A/R, A/P and suspense / clearing accounts**, where the subledger lives in the same
books. Where both entities are connected company files, the **intercompany mirror balance** is
readable too, and a connected payroll, inventory or payments platform can change other rows.
**It cannot read** support that lives outside the connected books — prepaid schedules, fixed asset
registers, lease and loan schedules, tax filings, bank statements — so it asks for each. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never calls an account reconciled without independent support.** A support side never
  supplied is reported as **not reconciled**, and no account is reconciled to another view of
  itself.
- **Never plugs a difference**, and **never adjusts a timing difference** — it is documented and
  monitored. Every investigating item has an owner and a target date.
- **Never defaults the period, the materiality threshold or the entity**, and never signs off a
  reconciliation on `mock` data.

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
| **B** | *Which company — or, for a group, which entities?* | Each entity is reconciled on its own; one entity's GL is never tied to another's subledger, except in the deliberate intercompany mirror check | **Never default the entity.** On the Mosofin path, list the connected company files **by name** and ask. |
| **C** | *Which accounts — named accounts, or all balance sheet accounts?* | Sets the workpaper's tabs and the source each account reconciles to | **Required.** On the Mosofin path the chart of accounts is read; ask **which** are in scope. |
| **D** | *Which period? The period-end date.* | Sets every balance and every cut-off | **Never default the period.** |
| **E** | *For each account whose support is outside the books — prepaid, fixed assets, leases, payroll, debt, tax, bank — where does the schedule live, and can you supply it?* | Without it that account cannot be reconciled | **Required.** An account whose support is not supplied stays in the workpaper as **not reconciled**, with a named gap and owner. |
| **F** | *What materiality threshold applies to unreconciled differences?* | Items above it need immediate resolution | **Never silently assume it.** Suggest a basis — e.g. overall materiality divided across the accounts — and ask. |
| **G** | *Do you have last period's reconciliation?* | Needed for the prior-period carry-forward check | Recommended. Without it, say the carry-forward could not be performed. |
| **H** | *Who prepares and who reviews?* | The workpaper header needs both | Recommended. They should not be the same person. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether **both sides of any intercompany balance** are connected, and whether a
  **payroll, inventory or payments platform** is — each changes an account's support verdict.
- Confirm the **cleanup / suspense account** for proposed entries by its real name in the chart.
- A **vendor or customer balance** report is not an aging: it can confirm a total, not which items
  make it up.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Trial balance** at period end — the GL balance of every account in scope | **Required** | CSV or XLSX |
| **Support for each account in scope** — A/R and A/P agings or open-item lists, the prepaid, fixed asset, lease, loan, accrual and payroll schedules, tax filings, bank statements | **Required** per account — an account without it is reported as not reconciled | CSV, XLSX or PDF |
| **Chart of accounts** — for proposing correcting entries | **Required** | CSV or XLSX |
| Accounts in scope, period end, entity name, base currency | **Required** | Type it in the chat |
| **GL detail** for the accounts in scope | Recommended — roll-forwards and investigating differences | CSV or XLSX |
| **Prior period reconciliation** | Recommended — the carry-forward check | XLSX or PDF |
| Materiality threshold; preparer and reviewer | Recommended — never assumed | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Reconciling **all balance sheet accounts** of **Northbrook Trading** at **30 September**, with
> the GL read from **your Mosofin connection**. A/R, A/P and the clearing account will be supported
> from the books; the **prepaid schedule** and **loan amortization schedule** you uploaded support those
> two; the **fixed asset register** is still outstanding, so fixed assets will show as **not
> reconciled**. Materiality **$500**; prepared by the bookkeeper, reviewed by the controller.
> Shall I go ahead?*

On the upload path, name each file you received and what was read from it — the date, the row
count and the total. Flag anything unreadable, at the wrong date, or for a different account, at
once.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files, check which read tools are enabled — resolving **each account's GL side and support
side separately**, since the A/R and A/P agings often carry different policies — and read the
company profile for the period-end and base currency, so Stage 1's answers are not asked twice. On
the upload path, go straight to Stage 3.

## Stage 3 — Map each account and read both sides

Pull the trial balance, balance sheet, chart of accounts, GL detail, agings and journal entries in
one batch, and check the `mock` flag. Assign every account its reconciliation source from the
method table — **if an account type isn't listed, ask what its support is; never guess** — then
capture the GL balance and the supporting balance, **each with its source and date**:
[`references/method.md`](references/method.md) Steps 0–2. Run suspense and clearing accounts
first: both sides come from the GL, and any non-zero balance is investigated at once.

## Stage 4 — Find and investigate the differences

Bridge GL to support with the reconciling-items formula and type every item as timing, permanent
or investigating. Investigate every unreconciled difference — prior-period rec, posting cutoffs,
mispostings, FX revaluation, rounding — and **document the checks that found nothing**:
[`references/method.md`](references/method.md) Steps 3–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for a subledger that does not tie to its own
control, multi-currency, intercompany mismatches, recurring timing items, merged or split
accounts, informal support, and both sides from the same source.

## Stage 5 — Propose corrections, roll forward, age, and present

Propose a correcting entry for each **permanent** difference — reclass, small residual write-off,
or reverse and rebook — in the real account names; document timing items without adjusting them;
log investigating items with an owner and a target date. Roll forward the activity-based accounts
and tie the movements to the activity; age every item against materiality, escalating anything
over three months: [`references/method.md`](references/method.md) Steps 5–8. One tab per account,
with the two-sided coverage sheet. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the account-to-source map with
owners, the materiality threshold and escalation ages, preparer and reviewer, known recurring
timing items, the cleanup account and its limit, and the always-zero accounts, keyed by datasource
and entity — never balances, reconciling-item detail or the workpaper itself.

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
