---
name: gl-coding-assistant
description: "Suggests the general ledger account, expense category and tax code for each transaction from its vendor, description and amount, against the entity's real chart of accounts, and grounds each suggestion in how this entity has actually coded the same vendor before — with the count and recency. Rates confidence, separates clear items from ones to review, and flags possible capex, personal use, splits, transfers, related-party and cross-border items and inconsistent history. Reads the books through a connected Mosofin workspace when the user agrees, or works from an uploaded bank or card export plus a chart of accounts. Use when the user asks 'what account should this go to', 'code these expenses', 'categorize these transactions' or 'suggest a GL account for…', or has uncoded transactions. Do not use to design the chart of accounts itself, or to post entries (use journal-entry-builder). Read-only: produces a coded transaction list with confidence, reasoning, evidence and a coverage sheet, and posts nothing."
---

# GL coding assistant

Works out which **account** each payment or receipt belongs in — and the expense category and tax
code — from the vendor, the description, the amount and the context. It says how sure it is, gives
one sentence of reasoning, and **separates the easy ones from the ones a person should look at.**

Its strongest evidence is **your own coding history**: not "Amazon usually goes to Office
Supplies" as a guess, but "coded to 6120 Office Supplies in 43 of 45 prior transactions, most
recently last month." The mistake it guards against is treating that history as proof — **two
years of consistent miscoding still recommends itself confidently** — so it reports consistency,
not correctness, and reports a split history as undecided rather than picking a winner.

**Works with or without Mosofin.** With Mosofin connected, it reads the chart of accounts, the
vendor master, the coding history with counts, the transactions sitting in **uncategorized and
suspense accounts** — often the real work list — the tax codes configured in the books, the bank
and card accounts for transfer detection, and the employee list for related-party comparison.
**There is no tax rule engine, no capitalization policy and no receipt image on this surface**, so
the tax rules, your capitalization threshold and any house coding policy always come from you.
Background: [`references/overview.md`](references/overview.md).

## Rules that never bend

- **Asks before using Mosofin.** A connected account is not permission to read it.
- **Reads nothing until Stage 1 is answered** and you have confirmed the read-back.
- **Never writes, updates or deletes anything, in any system.** Every entry it produces is a
  proposal for a person to post.
- **Never invents an account.** It codes only to accounts in the entity's chart; with no chart it
  stops and asks, then codes to your category names or — only if you explicitly authorize it — to
  a placeholder labelled **"PLACEHOLDER — REMAP REQUIRED BEFORE POSTING"**, and says which.
- **Frequency is not correctness.** History is reported with its count; an inconsistent history is
  reported as a split, never resolved by picking the commonest or most recent; a supplied policy
  or a stored correction wins over history, and the conflict is reported.
- **Never defaults a capitalization threshold or a tax treatment** — tax codes only with a
  jurisdiction and a tax code list — and **surfaces a possible personal or related-party item,
  never concludes it**, and never stores that flag against a named individual.

Full wording: [`references/mosofin-protocol.md`](references/mosofin-protocol.md). **Read it before
the first tool call.**

---

## Stage 1 — Intake: ask these first, in one message

*Stages 1–6 are this card's. "Steps 0–6" always mean the steps in `references/method.md`.*

Before reading any data, collect the basics in **one short batch**, not one question at a time.
Ask only what you cannot already see.

| # | Ask | Why it matters | If unanswered |
|---|---|---|---|
| **A** | *Use Mosofin as the data source for this run, or upload the data yourself?* | Decides the path. Mosofin is the connection to the user's books and other linked platforms; with it the skill reads from there, without it the user uploads and the checks are the same | **Never assume.** Ask only if the Mosofin tools are present. If they are absent, skip this and say once that the run is manual. |
| **B** | *Which transactions should I code?* A pasted list or a bank or card export — or shall I find them? | The work itself | **Required.** On the Mosofin path, **offer to find them**: uncategorized and suspense accounts are readable. |
| **C** | *Which entity are they for?* In a group, which entity each batch belongs to | Coding is entity-specific: the same vendor maps to different accounts in different charts | Confirm **before coding any of them**. On the Mosofin path, by `display_name`. |
| **D** | *Do you want tax codes? If so, which jurisdiction, and which tax codes are set up?* | Tax codes are only suggested with both | **Required for tax codes.** Without them, output "Tax code: TBD — confirm with tax setup"; never assume a treatment. |
| **E** | *What is your capitalization threshold?* Ask if equipment, computers, furniture or vehicles are in the batch | Drives the possible-capex flag | **Never pick one.** The flag reads "unknown — please confirm". |
| **F** | *Any house coding rules that override past practice?* | A policy wins over history | Optional. History is used, labelled as practice. |

**Then, depending on the answer to A:**

**Mosofin path — confirm, don't ask.**
- Read back the workspace and the company file **by name** and wait for an explicit yes
  (Gates 0–1 in [`references/gates.md`](references/gates.md)).
- The **chart of accounts, jurisdiction (country), industry and prior vendor-to-account mappings**
  come from the books — don't ask for them. The country does not license a tax treatment: **the
  rules stay yours.**
- Ask to confirm any **profile contradiction** — for example transactions in a currency the entity
  does not use.

**Upload path — hand over one checklist.**

| Upload | Needed? | Format |
|---|---|---|
| **Transactions to code** — date, vendor or payee, description, signed amount, source account if known | **Required** | CSV or XLSX bank or card export, or a pasted table |
| **Chart of accounts** — numbers and names | **Required** — without it, stop and ask; coding falls to category names, or an authorized placeholder | CSV or XLSX |
| Entity name; jurisdiction; industry | Entity: Required. Jurisdiction: Required for tax codes. Industry: if known | Type it in the chat |
| **Tax code list** | Required for tax codes | CSV or XLSX, or typed in |
| **Prior vendor-to-account mappings**, or a coded GL export | Optional — improves accuracy; enables Tier 1, the strongest evidence | CSV or XLSX |
| **Capitalization threshold**; house coding policy | Optional — ask if relevant | Type it in the chat |

**Read back before starting, then wait for a yes:**

> *Coding the **38 transactions in Uncategorized Expense** at **Northbrook Trading**, read from
> **your Mosofin connection**, against its chart and coding history. Tax codes from the configured
> list, **which code applies to be confirmed by you**; capitalization threshold **$2,500**. Shall I
> go ahead?*

On the upload path, name each file you received and say what was read from it — the period it
covers, the row count, the accounts in the chart. Flag anything unreadable, or a column you cannot
identify, straight away.

---

## Stage 2 — Confirm scope and capabilities *(Mosofin path only)*

Run Gates 0–3 in [`references/gates.md`](references/gates.md). They confirm the workspace and the
entity — in a group, which entity each batch belongs to — check which read tools are enabled, and
read the company profile — legal name, base currency, **country** and **industry** — so Stage 1's
answers do not need asking twice. If the chart read is disabled, the fallbacks apply and the output
says which is in use and why. On the upload path, go straight to Stage 3.

## Stage 3 — Read the books, then parse and normalize

Pull everything in one batch — the chart including uncategorized and suspense accounts, the vendor
master, the coding history, prior transactions by vendor, configured tax codes, bank and card
accounts, employees, the company profile — and check the `mock` flag: fixture history downgrades
every history-based confidence to Low. Then normalize each vendor name — suffixes, trailing IDs,
processor prefixes — and match it to the vendor master: known, new, or a duplicate vendor record:
[`references/method.md`](references/method.md) Steps 0–1.

## Stage 4 — Classify, assign tax codes, and flag special cases

Apply the five tiers **in order and stop at the first confident match**: exact vendor match from
the history (consistent, inconsistent or changed), vendor-type pattern, keyword inference, amount
heuristics, and "Needs Review" with a reason. Suggest tax codes only with a jurisdiction and code
list, flagging cross-border items for review. Then the special cases — capitalization threshold,
personal use, splits, transfers with both legs named, owner and related-party items, loan payments
split between interest and principal: [`references/method.md`](references/method.md) Steps 2–4.
Check [`references/edge-cases.md`](references/edge-cases.md) for refunds, card payments,
multi-currency, reimbursables, payroll lines and group entities.

## Stage 5 — Present the coded list

The coded table with Evidence and Verdict columns, confidence bands and flags, a summary — total
coded, % by confidence band, flagged count — the header block saying whether the chart was read or
a fallback is in use, and for an `.xlsx` the Uncoded Population and Coverage sheets:
[`references/method.md`](references/method.md) Step 5. If the user recodes something, apply the
same logic to similar transactions this session (the Learning Loop). Before presenting, check it
against [`references/output.md`](references/output.md).

## Stage 6 — Offer to save *(optional)*

Only after the results have been shown, and only on an explicit yes:
[`references/method.md`](references/method.md) Step 6 and the Learning Loop. Persist the
confirmed or corrected vendor-to-account rules, the house policy, the threshold, the tax code
mapping, the account map and normalization rules, keyed by datasource and `display_name` — never
transaction lists, amounts or the coding history itself.

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
