---
name: duplicate-invoice-detection
description: "Scans the accounts payable register for likely duplicate invoices and payments — the same invoice resubmitted, the same amount paid through two channels, altered invoice numbers, vendor-name variants, and vendor credits never applied — rates each cluster's confidence, quantifies exposure, puts unpaid duplicates first and proposes recovery. In a group, also finds one invoice paid by two entities. Reads bills, payments and the vendor master through a connected Mosofin workspace when the user agrees, or works from an uploaded AP register and payment history. States that the same-bank-account rule cannot run without vendor bank details. Use when the user asks to check for duplicate invoices or payments, scan AP for duplicates, detect invoice fraud or 'have we paid this twice', or uploads a payment history or AP register. Do not use for general fraud detection across all transaction types. Read-only: produces a duplicate-suspect workpaper with evidence, a rules-run sheet and coverage sheet, and posts nothing."
---

# Duplicate invoice detection

Scans **your accounts payable** for bills entered or paid twice: the same invoice resubmitted, the
same amount paid by cheque and again by wire, an invoice number altered by a character, a supplier
set up twice under slightly different names. It groups suspects into **clusters**, shows the
records side by side so a reviewer can agree or dismiss in seconds, quantifies the exposure, and
lists **unpaid duplicates first — a duplicate caught before payment costs nothing to fix.**

It runs **ten rules**, from an exact invoice number for the same vendor down to round-number
clusters and **vendor credits never applied** — money the business is owed and has not taken. The
mistake it refuses to make is a **false "clean"**: a scan of part of the population, or a rule that
did not run, never reads as "no duplicates found".

**Works with or without Mosofin.** With Mosofin connected, it reads the whole bill population, the
payments with their method and date, direct purchases that bypassed the bill process, the vendor
master **including inactive records**, vendor credits, open payables and PO references — nine of
the ten rules run as queries. **It can never read vendor bank details**, so **Rule 7 — same bank
account, different vendors — cannot run from the Mosofin connection**; it runs from an uploaded payee
list, or in the AP or banking system itself.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never lets a rule that did not run look clean.** Rule 7 is reported **as not run, with a named
  owner**, and the output says a clean scan does not mean the fraud test passed. If the bill-level
  search is unavailable, the skill cannot run, and says so.
- **Scans the whole population.** It paginates to completion and states **records scanned against
  records available**; a truncated scan is not a scan. It **never defaults the period or the
  entity**, and states the sensitivity setting on every output.
- **Treats a duplicate as usually error rather than misconduct**, and never persists vendor bank
  details, invoice-level data or any suspicion attached to a named person.

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
| **B** | *Which entity, or entities? In a group, should I also scan across them?* | One scan per entity; the same invoice paid by two group entities is invisible to each entity's own scan | **Never default the entity.** On the Mosofin path, confirm by `display_name`. |
| **C** | *Which period should I scan, and how far back before it?* | Sets every read | **Never default it.** Scan wider than the period under review — duplicates straddle boundaries — and state the window actually read. |
| **D** | *Which suppliers legitimately bill the same amount repeatedly — rent, subscriptions, retainers?* | Naming them up front removes most false positives | Recommended. Otherwise their repeat invoices are filtered by date pattern at Rule 8, not by name. |
| **E** | *Sensitivity — Strict, Standard or Permissive — and the Rule 3 date window?* | Decides which confidence levels count in the headline exposure; every match is still listed | Optional: state the defaults, **Standard** and **7 days**, rather than asking. |
| **F** | *Any prior duplicate-scan results?* | So clusters already cleared are not raised again | Optional. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- **Do not ask for an AP export — read it.** Confirm the population and its record count. The
  vendor master is read too, including inactive records.
- Say **before reporting results** that Rule 7 is `[manual]` and who should run it.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **AP register and payment history** for the period and beyond — vendor, vendor ID, invoice number, invoice date, amount, PO reference, payment date, payment method, status, incl. voided records | **Required** | CSV or XLSX |
| **Vendor master**, including inactive records — names, IDs, tax IDs, remit-to addresses | Recommended — needed for the alias rules | CSV or XLSX |
| **Cheques, expenses and card charges by vendor** for the same window (e.g. a transaction list by vendor) | **Required** — payments made outside the bill process, for Rule 9 | CSV or XLSX |
| Open vendor credits; open payables (aged payables) | Recommended — Rule 10, and paid versus unpaid | CSV or XLSX |
| Vendor payee bank details (last 4 digits + routing or sort code) | Optional — enables Rule 7 on this path; masked, never stored | CSV or XLSX |
| Known legitimate recurring suppliers | Recommended | Type it in the chat |
| Prior duplicate-scan results; sensitivity and Rule 3 window | Optional — default Standard, 7 days | XLSX, or type it in the chat |

**Read back before starting, then wait for a yes:**

> *Scanning **every bill and payment** at **Northbrook Trading** from **1 January to 30 September**,
> read from **your Mosofin connection**, at **Standard** sensitivity with a **7-day** Rule 3 window.
> Landlord, insurer and three SaaS suppliers treated as legitimate recurring billers. **Rule 7 cannot
> run here** — it needs your AP or banking system. Shall I go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers and the row count. Flag anything unreadable, or covering the wrong period, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
company files — in a group, whether the cross-entity scan applies — check which read tools are
enabled, and read the company profile — **base currency**, which decides whether the
multi-currency caution applies, and **fiscal year-end**, for the cross-period pattern. A vendor
spend summary is not a substitute for the bill-level search. On the upload path, go straight to
Stage 3.

## Stage 3 — Read the whole population and normalize it

Pull bills, payments, direct purchases, vendors including inactive, vendor credits, open payables,
payment methods, PO references and the company profile in one batch, **paginated to completion**;
check the `mock` flag — no recovery request rests on fixture data. Normalize vendor names and
invoice numbers, group by vendor ID with fuzzy links for aliases, convert currencies for comparison
with FX matches flagged, and read voided and reversed records to report separately:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Run the ten rules, tune sensitivity, find aliases

Run Rules 1–10 with their confidence levels — Rule 7 recorded as not run unless payee bank details were uploaded, Rule 9 degrading to
Rule 2 where payment method is not recorded, fuzzy matches shown with their similarity score —
list every match and apply the sensitivity setting to the headline, and check each suspect for vendor records that should be merged:
[`references/method.md`](references/method.md) Steps 2–4. In a group, run the cross-entity scan
with group entities excluded from the counterparty population. Check
[`references/edge-cases.md`](references/edge-cases.md) for recurring invoices, cross-period
duplicates, reissued invoices, partial payments, different currencies and different POs.

## Stage 5 — Assess recovery and present the workpaper

For paid duplicates, propose a vendor credit, a refund or a set-off where an open balance exists,
with the draft entry; for unpaid ones, propose voiding before payment (a current-period vendor
credit if the period is closed), listed first. Quantify exposure by confidence level, excluding the
record treated as valid. Then the workpaper — Summary with population scanned against available, Flagged Pairs,
Detail, Vendor Aliases to Merge, Recovery Plan, **Rules Run** and Coverage:
[`references/method.md`](references/method.md) Steps 5–6. Before presenting, check it against
[`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 7. Persist cleared clusters with reason and
date, recurring suppliers, confirmed aliases, the sensitivity and Rule 3 window, the recovery
playbook and who runs Rule 7 — never vendor bank details, invoice-level data or a suspicion
attached to a named person.

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
