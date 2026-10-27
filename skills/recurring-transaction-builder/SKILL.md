---
name: recurring-transaction-builder
description: "Designs and validates recurring journal entries, bills, invoices and subscription schedules: computes every future occurrence (calendar rolls, escalations, memo variables), checks each account, counterparty and tax code against the live chart, checks whether the recurrence already exists, finds manually repeated transactions worth automating, and audits whether existing recurring entries actually ran. Reads the chart, counterparties, tax codes and posting history through a connected Mosofin workspace when the user agrees, or works from details the user supplies. Use when the user asks to set up a recurring entry or bill, generate the next 12 months of entries, automate a monthly entry, build a subscription invoice template, check whether a recurring entry ran, or asks what to automate. Do not use for one-off entries (use journal-entry-builder) or prepaid amortization (use prepaid-amortization-schedule). Read-only: produces a schedule specification for a person to load, and creates, posts or schedules nothing."
---

# Recurring transaction builder

Builds the schedule for a journal entry, bill or invoice that repeats on a defined cadence, and
computes **every future occurrence**: dates with month-end and business-day rolls, escalations at the
right anniversary, memos with `{month}` and `{year}` resolved. With the books connected, it also
**validates the template against the live chart**, **checks whether the recurrence already exists**,
lists **what is being keyed by hand every month** that could be automated, and **audits whether the
recurring entries that do exist actually ran**.

The mistake it catches: a schedule is not a template. A spreadsheet of future-dated rows is a plan;
handing it over and letting someone believe automation now exists is this skill's characteristic
failure, discovered in month two when nothing happened. So is a template pointed at a renamed account,
which fails **every month, forever, quietly**, and a file of twenty-four rent bills loaded **twice**.

**Works with or without Mosofin.** The computation needs no ledger and works in full without a
connection. With Mosofin connected it reads the chart of accounts, the vendor and customer lists, the
tax codes and the posting history, which is what the validation, the duplicate check, the discovery
and the run audit need. **It can never create the recurring template, post an occurrence or schedule
anything**, and it can never read what lives outside the books: the contract's escalation and stop
terms, the holiday calendar, the inflation assumption, or the pro-ration decision. Background:
[`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never says "posted", "created" or "scheduled".** The output is a specification; every occurrence
  starts **Pending**, and the file's header says **NOT POSTED**.
- **Never assumes a rate or defaults a holiday calendar.** No inflation assumption or tax rate is
  supplied by the skill or by a saved version; the index source may be saved, never the rate.
- **Never builds a schedule without checking whether the recurrence already exists**, and never lets
  an unvalidated schedule look validated: the validation status goes in the header of Sheet 1.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 1–6" always mean the steps in `references/method.md`, including
Steps 2b–2d and 5b.*

Before reading any data, collect the schedule's parameters (the Inputs table in
[`references/method.md`](references/method.md)) in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *What type: recurring JE, bill, invoice or subscription? With which vendor or customer?* | The template and the duplicate risk differ by type | **Required.** The counterparty is required for AP and AR, and verified against the vendor or customer list. |
| **C** | *Amount and currency per occurrence.* | Occurrences stay in the contract currency | **Required.** |
| **D** | *Start date, and an end date or number of occurrences.* | An open-ended recurrence needs management approval | **Required.** For "until cancelled", build a finite horizon of 12 or 24 months and flag it for renewal review. |
| **E** | *Cadence and day-of-period rule: "1st of month" or "last business day", not "monthly".* | The rule must be unambiguous | **Required.** |
| **F** | *Coding: GL accounts for a JE; account or item for a bill; product / service item for an invoice; tax code if tax applies.* | Each is validated against the live chart and item list at Step 2b | **Required**; tax code required if tax applies. |
| **F2** | *Payment terms (e.g. Net 30), for bills and invoices.* | Sets each occurrence's due date | **Required for bills and invoices.** |
| **G** | *Holiday calendar and roll policy, forward or backward.* | Business-day rolls depend on both, applied one direction throughout | **Do not pick a default.** Ask once and persist; read a saved version first. |
| **H** | *Escalation rule (fixed, annual %, CPI-linked, step-up) and any stop or pause conditions.* | They live in the contract, not the ledger | Optional. For CPI, **ask for the index source and the inflation assumption; never assume a rate.** |
| **I** | *A partial first or last period: pro-rate on days, or per the contract?* | The two differ by real money on the first invoice | **Do not default.** Ask which. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)). The schedule is validated against one
  chart and is not portable to another.
- If no datasource is connected, or the connection is broken, the computation still runs; **say it is
  unvalidated**, because an unvalidated schedule looks identical to a validated one.
- At Gate 3, read the saved skill for the holiday calendar and roll policy before asking for them.
- Still ask for the escalation and stop terms (H) and the pro-ration choice (I). None is in the books.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| Type, counterparty, amount and currency, start, end or count, cadence, day-of-period rule | **Required** | Type it in the chat |
| Coding (accounts or items) and posting template; payment terms for bills and invoices | **Required** | Type it in the chat, or CSV/XLSX |
| **Chart of accounts** (and item list for invoices) | **Required for validation** (Step 2b) | CSV or XLSX export |
| **Vendor or customer list**; **tax code list** if tax applies | Recommended — counterparty and tax-code checks | CSV or XLSX export |
| **Recurring / repeating template list** | Recommended — the duplicate check (Step 2c) | CSV or XLSX export |
| **Transactions with this counterparty, last 12–24 months** | Recommended — the duplicate check and run audit (Steps 2c, 5b) | CSV or XLSX export |
| Tax code | Required if tax applies | Type it in the chat |
| Holiday calendar and roll policy, for business-day rules | Required when the rule is business-day-aware | Type it in the chat |
| Memo template with `{month}`, `{year}` | Recommended | Type it in the chat |
| The contract: escalation rule, stop and pause conditions | Optional | PDF, or type the terms |
| A list of recurring items to build templates for | When there are several | CSV or XLSX |

Steps 2b–2d and 5b run on the uploaded files and are labelled user-supplied. Only a check whose
file was not supplied is **NOT VALIDATED**, and the header says which.

**Read back before starting, then wait for a yes:**

> *Building a **recurring bill** for **Northbrook Trading**: **office rent** to **the landlord you
> named**, **$8,500 a month** in **USD**, on the **1st**, **24 occurrences** from **1 January**, rolled
> **forward** on the **US federal holiday calendar**, coded to **Rent Expense**, a **3% annual
> increase at the lease anniversary**, validated against **your Mosofin connection**. Nothing will be posted.
> Shall I go ahead?*

On the upload path, name each file you received and say what was read from it. Flag anything
unreadable, or terms that disagree with what was typed, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company file, map which read tools are enabled (a tool that creates or posts is out of scope whatever
its policy), note that `mock: true` data validates cleanly by construction, and read any saved
version for the standing facts. On the upload path, go straight to Stage 3.

## Stage 3 — Identify the type, validate the schedule, check the books

Identify the type; confirm the four schedule checks (start, end or count, cadence, day rule); then,
with the books, one batched read to validate every account, counterparty and tax code against the live
chart, check the trailing twelve to twenty-four months for an existing recurrence, and scan for
manually repeated transactions, presented as candidates, not a plan:
[`references/method.md`](references/method.md) Steps 1–2, with Steps 2b–2d.

## Stage 4 — Generate the occurrences and apply escalation

One row per occurrence: number, date, amount, period covered, resolved memo. Roll the 31st to the last
day of short months, never skip them; apply the roll policy one way throughout; compare the dates with
where the charge has actually landed; apply the escalation and document it in each row's memo:
[`references/method.md`](references/method.md) Steps 3–4. Check
[`references/edge-cases.md`](references/edge-cases.md) for partial periods, cadence changes, currency,
related parties, fixed-plus-variable charges, escalating leases, upgrades, tax rate changes and open-ended subscriptions.

## Stage 5 — Build the specification, audit past runs, present the result

Construct the template per occurrence (service-period dates on subscriptions) as a **specification
for a person to enter or load**; audit whether existing recurring entries posted in each expected
period, at the expected amount and accounts, and whether accrual reversals posted; then the six
sheets: [`references/method.md`](references/method.md) Steps 5–6, with Step 5b. Ask whether the user
wants the workpaper as an Excel file before creating one. Before presenting, check it against
[`references/output.md`](references/output.md), including the coverage sheet's computed-versus-read
split.

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md), *Seed to evolved*. Persist the holiday calendar and
roll policy, the CPI index source, the validated chart mapping, the register of recurring
arrangements, the pro-ration convention and horizon, declined automation candidates and escalation
terms — never a rate of any kind, and never the capability map.

---

## Files

| File | Read when |
|---|---|
| [`references/mosofin-protocol.md`](references/mosofin-protocol.md) | Before the first tool call |
| [`references/gates.md`](references/gates.md) | Stage 2, Mosofin path |
| [`references/method.md`](references/method.md) | Stage 1 (Inputs), Stages 3–6 |
| [`references/edge-cases.md`](references/edge-cases.md) | Stages 4–5, and whenever something looks unusual |
| [`references/output.md`](references/output.md) | Before presenting |
| [`references/overview.md`](references/overview.md) | Background, or when a user asks why |
