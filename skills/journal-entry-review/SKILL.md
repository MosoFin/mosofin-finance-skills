---
name: journal-entry-review
description: "Reviews a population of journal entries for risk, propriety and anomalies through a control and audit lens: screens every entry against timing, account-combination, amount and people-and-process indicators measured against the entity's history, risk-scores the flags and leads with patterns such as recurring period-end adjustments and reserves that move with earnings. Reads the entries through a connected Mosofin workspace when the user agrees, or works from uploaded journal or GL exports. Reports the approval-based indicators as not run where approval data is not available, and treats every flag as a question, never a finding of fraud. Use when the user asks to review journal entries, run JE testing, find unusual journal entries, test JEs for fraud indicators or assess journal entry controls. Do not use for building entries (use journal-entry-builder) or for a full forensic investigation. Read-only: produces a risk-scored review workpaper, follow-up items and a coverage sheet, and posts nothing."
---

# Journal entry review

Screens **every journal entry in the period** for the signs that tend to accompany error or
manipulation — period-end and back-dated postings, entries straight to revenue, reserves, equity or
suspense, round amounts and amounts just below an approval limit, vague descriptions, users who do
not normally post — then scores them and puts the few worth a closer look at the top. Most entries
come from an invoice, a payment or a payroll run; the ones typed in by hand bypass the normal checks,
and those are the focus.

The patterns matter more than any single flag: **a user with a cluster of high-risk entries, the
same account adjusted by hand every quarter-end, reserves that move with earnings.** It identifies
risk indicators; **it never concludes that fraud occurred.**

**Works with or without Mosofin.** With Mosofin connected, it reads the full entry population for the
period and several prior periods, the chart with account types, the general ledger and the period
P&L and balance sheet — so it screens 100% and derives "normal" from the entity's own history.
**Approval data is generally not readable**, and supporting documents and anyone's explanation never
are, so the four approval-based indicators are reported as **NOT RUN** unless you supply the approval
log; and topside entries made in a consolidation system that is not connected are not in the
population at all. Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **An anomaly is not a finding.** A flagged list is a list of questions, not of suspects; a user
  name is not a person; escalation is not an accusation.
- **Screens the whole population and says so**, and reports every criterion it could not run — above
  all the four approval-based ones — as **NOT RUN**, never omits it.
- **Never defaults an authorization threshold, a materiality level, or a conclusion about an entry**,
  and **never persists flagged entries, risk scores, user names, explanations or any anomaly.**

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
| **B** | *Which period is under review?* | Sets the population and the timing criteria, which depend on the period ends | **Required.** Nothing is screened without it. |
| **C** | *What are the authorization thresholds?* | The just-below-threshold test | **Required for that test, and never defaulted.** Without them the test is meaningless; name it as not run. |
| **D** | *What materiality threshold should apply?* | Magnitude screening and the below-threshold test | **Never default it.** Recommended; ask. |
| **E** | *Do topside or consolidation entries exist, and where are they made?* | They are the higher-risk population and may not be in this one at all | **Required.** The output must state whether they are in the population. |
| **F** | *Who may see the output?* | It names people | **Required.** |
| **G** | *Can you supply the approval log — who approved, approval status?* | Four People-and-process indicators depend on it | Recommended, usually `[manual]`. Without it those four are **NOT RUN**, with what they would have shown. |
| **H** | *Which accounts are sensitive here, and any known risk areas?* | Focuses the account-combination criteria and the review | Recommended. Revenue, reserves, equity and suspense are readable by account type; the rest is `[manual]`. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- Check at Gate 1 whether a **consolidation or reporting platform** is connected. If it is not,
  topside entries are not in the population — a material limit, said plainly.
- Do not ask for the population or for expected posting patterns: the population is read in full and
  "normal" is **derived from prior periods** (Step 1), which beats a stated expectation.
- **Establish the field list the entry read returns** — posting versus effective date, user,
  description, source — before designing the screen, and record each criterion lost to a missing field.
- Still ask for the **approval log** (G) and the **thresholds** (C, D). Neither is on this surface.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Journal entries for the period** — every entry, with posting date, effective date, user, description, source, accounts and amount | **Required** — this is the population; the criteria you can test depend on the fields present | CSV or XLSX |
| **Journal entries for several prior periods** | Recommended — the baseline for "normal", and Step 5's patterns need several periods | CSV or XLSX |
| **Chart of accounts** with account types, sensitive accounts noted | Recommended — drives the account-combination criteria | CSV or XLSX |
| **Approval log** — who approved each entry, approval status | Recommended — without it the four approval-based indicators are NOT RUN | CSV or XLSX export |
| **P&L and balance sheet by period** | Recommended — for the reserves-move-with-earnings test | CSV, XLSX or PDF |
| Period, entity name, base currency, fiscal calendar and period ends; where topside entries live; who may see the output | Required | Type it in the chat |
| Authorization thresholds; materiality threshold; known risk areas | Authorization thresholds **required for the just-below test**; the rest recommended | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Reviewing **every journal entry** posted by **Northbrook Trading** for **1 July–30 September**,
> against a baseline from **the six prior quarters**, read from **your Mosofin connection**.
> Authorization threshold **$10,000**, materiality **$25,000**. Topside entries are made in **the
> consolidation workbook**, which is not connected, so they are **not in this population**. No approval
> log, so the four approval-based tests will be reported as not run. Output for **the CFO and the audit
> committee**. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the fields present. Flag anything unreadable, covering the wrong period, or
missing a field a criterion needs, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file — an excluded entity is **named as unscreened**, since JE testing is a required audit
procedure — check which read tools are enabled and which fields the entry read returns, and read the
company profile, deriving **fiscal calendar and period ends** silently so Stage 1's answers do not
need asking twice. On the upload path, go straight to Stage 3.

## Stage 3 — Read the population and derive the baseline

Pull the period's full entry population, the chart with account types, the general ledger, prior
periods and the P&L and balance sheet in one batch; **if a read returns `mock: true`, stop.** Then
profile the population — number and value, manual versus system, by account, user and period — and
compute "normal" from the prior periods: [`references/method.md`](references/method.md) Steps 0–1.
Report the profile before the flags.

## Stage 4 — Screen, score and find the patterns

Screen every entry against the nineteen indicators — fifteen run as queries; the four approval-based
ones are **NOT RUN** without approval data. Score with **weighted combinations, not single criteria**,
and state the weights. Analyse the high-priority flags (three of five checks need a person), then run
the pattern tests across the population and several periods, including reserves against earnings:
[`references/method.md`](references/method.md) Steps 2–5. Check
[`references/edge-cases.md`](references/edge-cases.md) for routine period-end entries, legitimate round
numbers, management override, topside entries, system labels, reversals and net-zero entries.

## Stage 5 — Follow up, assess controls and present

Classify each follow-up item as **legitimate, error or escalate**; from the moment an item is
escalated, the fraud-investigation rules apply — objectivity, no accusation, no approval prompt to
anyone in scope. Quantify the measurable control observations, then build the workpaper: population
profile, criteria and screening, risk-scored flags, detailed review, **patterns first**, follow-up,
controls, **criteria not run**, and coverage: [`references/method.md`](references/method.md)
Steps 6–8. Ask before creating the `.xlsx`; otherwise give the sheets as tables. Before presenting,
check it against [`references/output.md`](references/output.md). The header states the population
size, that the screen was complete, and whether topside entries are in it.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 9. Persist the method — the criteria set and
which cannot run here, scoring weights, sensitive accounts, thresholds with effective dates, the
baseline definition, cleared-pattern **rules**, the escalation path by role, where topside entries
live — never flagged entries, risk scores, user names, explanations or anomalies.

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
