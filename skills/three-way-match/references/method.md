<!-- three-way-match · method.md · read for: Stages 3–6 — the match itself: verdicts, inputs, Steps 1–6, output quality, what to persist, anti-patterns. Edit here, not in SKILL.md. -->

## Contents

- How to read the verdicts
- Inputs
- Workflow
- Step 1 — Extract structured data from each document
- Step 2 — Match the three documents
- Step 3 — Apply tolerances
- Step 4 — Identify exception types
- One correction to exception 7's severity
- Exception 8, and where it leads
- Exceptions 11 and 12, and the segregation-of-duties link
- Step 5 — Resolution suggestions
- Step 6 — Output
- Output Quality Standards
- Seed to evolved: what happens on the first real run
- Anti-patterns


## How to read the verdicts

- **`[auto]`** — Mosofin can do this from live reads, unattended.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` (**reads only — never for a write**) and the `data_source_id`.
- **`[manual]`** — not on this surface, or not a machine's judgment. **The step stays. The user performs it.**

**Everything here is a recommendation.** The gateway is read-only. **Mosofin pays nothing, holds nothing and releases nothing** — a human acts on the Pay / Hold / Reject conclusion.

---

## Inputs

All six preserved.

| Input | Format | Required | Mosofin source | Verdict |
|-------|--------|----------|----------------|---------|
| **Purchase order(s)** | PDF, XLSX, CSV, or pasted | **Required** | **`[auto]` where the system holds POs**; otherwise the original's upload path | Conditional |
| **Goods receipt / proof of delivery / service confirmation** | PDF, XLSX, CSV, or pasted | **Required for goods** | **`[auto]` where item receipts exist — frequently they do not** | Conditional |
| **Vendor invoice(s)** | PDF, XLSX, CSV, or pasted | **Required** | **`[auto]`, always** — bills in the AP ledger | `[auto]` |
| Tolerance policy | Price %, quantity %, total amount | Recommended | Not in the books; **persist it** | `[manual]` |
| Vendor master | For payment terms verification | Optional | **`[auto]`** | `[auto]` |
| Approval matrix | Who can approve a PO at what amount | Optional | **Not in the books.** Persist it. | `[manual]` |

> **If a goods receipt is not applicable — a services-only PO — the match becomes effectively a two-way match (PO ↔ invoice) plus a service-completion confirmation. Confirm with the user.**

**Preserved, and note it is the deliberate version of the situation described at the top of this file.** A services PO with no GRN is a two-way match **by design**; a goods PO with no GRN is a two-way match **by omission.** They look identical in the output and they are not the same thing. **Distinguish them.**

---

## Workflow

### Step 1 — Extract structured data from each document

`[auto]` where the system holds the record; `[manual]` extraction from uploads otherwise. Use `invoice-data-extractor` for uploaded invoices.

All three field sets preserved in full.

**Purchase Order fields** — PO number; PO date; vendor; buyer (entity); PO total; currency; payment terms; delivery terms (Incoterms, address); **approval signatures / approval status; approval timestamp**; and line items: line #, description, SKU/code, quantity ordered, unit price, line total, expected delivery date.

`[auto]` for most where POs are held. **Approval status and timestamp depend on Gate 2's third question** — and they are what exceptions 11 and 12 run on.

**Goods Receipt / Service Confirmation fields** — GRN number; receipt date; PO reference; vendor; receiving entity; **receiver name**; and line items: line #, description, SKU, quantity received, **condition (accepted / damaged / rejected)**. For services: confirmation of completion, hours or units delivered, service period.

**Two fields here are rarely in an accounting system even where receipts are**: the **receiver's name** and the **condition**. Condition is what exception 15 needs, and its absence means that test does not run. Say so rather than reporting no damaged-goods exceptions.

**Invoice fields** — invoice number; invoice date; vendor; bill-to entity; PO reference; invoice total, tax, shipping; currency; payment terms; and line items: line #, description, SKU, quantity billed, unit price, line total.

`[auto]`, with the caveat that **line-level detail varies** — some bills are entered as a single line with no item detail, which limits the match to header level. Check, and report which invoices could only be matched at header level.

---

### Step 2 — Match the three documents

`[auto]` where the legs exist.

**First confirm at header level** — all four preserved:

- **PO references match across all three documents**
- **Vendor name matches across all three** — **allow for legal name versus DBA differences; flag**
- **Currency matches**
- **Entity (buyer / receiver / bill-to) matches**

**Then match at line-item level.** For each invoice line:

1. **Find the corresponding PO line** — by line #, SKU, or description match
2. **Find the corresponding GRN line(s)** — **a PO line may have multiple partial receipts**
3. **Compare the three values:**
   - **Quantity**: PO ordered vs. GRN received vs. invoice billed
   - **Price**: PO unit price vs. invoice unit price
   - **Description / SKU**: should match across all three

**On line matching by description** `[auto]` with a caution: description matching is fuzzy by nature, and a wrong line match produces a **false variance** on two lines at once — one appears overbilled and another underbilled. **Prefer line number, then SKU, then description**, and **report the matching basis used per line** so a reviewer can see which matches are confident. Where a line cannot be matched confidently, **flag it as unmatched rather than forcing it** — an unmatched line is a question; a wrongly matched line is two wrong answers.

---

### Step 3 — Apply tolerances

`[auto]` given the policy. All three tolerance types preserved.

- **Price variance tolerance** — e.g. ±2% or a fixed amount per line
- **Quantity variance tolerance** — e.g. ±5%, allowing for a short shipment that is accepted
- **Total invoice variance tolerance** — e.g. a fixed amount

> **If no tolerance is provided, default to exact match (zero tolerance) and flag every variance.**

**Preserved exactly. The default is strict, and that is right** — a tool inventing a tolerance is a tool deciding how much overbilling is acceptable, which is a policy decision belonging to the business.

**Variance classifications**, both preserved:

- **Within tolerance** → auto-match, no exception
- **Outside tolerance** → exception, requires resolution before pay

**One `[auto]` observation worth reporting**, and it is only visible across a population: **variances that sit consistently just inside tolerance.** A vendor whose prices are always 1.8% above PO, against a 2% tolerance, is not producing random variances — and each instance passes, which is precisely why nobody notices. **Report the pattern with its count and its total value**, exactly as a petty-cash review reports a persistent within-tolerance shortage. **As a pattern, with figures, never as an allegation.**

---

### Step 4 — Identify exception types

**All fifteen preserved, with severities — and with one severity corrected.**

| # | Exception | Description | Severity | Verdict |
|---|---|---|---|---|
| 1 | **Price overbilling** | Invoice price > PO price | High | `[auto]` |
| 2 | **Price underbilling** | Invoice price < PO price | Low (favourable, but flag) | `[auto]` |
| 3 | **Quantity overbilling** | Invoice qty > GRN qty | High | **`[auto]` — needs the receipt leg** |
| 4 | **Short-shipment billed in full** | Invoice qty > GRN qty | High | **`[auto]` — needs the receipt leg** |
| 5 | **Item not on PO** | Invoice line has no matching PO line | High | `[auto]` — needs the PO leg |
| 6 | **Item on PO not invoiced** | PO line has no matching invoice line | Low (open commitment) | `[auto]` |
| 7 | **Item received not billed** | GRN line has no matching invoice line | **Information → see below** | **`[auto]` — needs the receipt leg** |
| 8 | **Item billed not received** | Invoice + PO line but no GRN | **High — possible fraud or vendor error** | **`[auto]` — needs the receipt leg** |
| 9 | **Duplicate against prior invoice** | Same vendor + PO line + amount paid already | **Critical** | `[auto]` — see `duplicate-invoice-detection` |
| 10 | **Currency mismatch** | Different currency on any document | High | `[auto]` |
| 11 | **PO not approved** | PO lacks approval signature / status | **Critical** | **`[auto]` if approval status is exposed** |
| 12 | **Approved by wrong authority** | PO total exceeds approver's limit per the matrix | **Critical** | `[auto]` **given the matrix and the approver identity** |
| 13 | **Vendor mismatch** | Different vendor on PO vs. invoice | **Critical** | `[auto]` |
| 14 | **Tax mismatch** | Tax on invoice doesn't reconcile to expected | Medium | `[auto]` |
| 15 | **Damaged goods on GRN but full billing** | GRN flagged damage or rejection, invoice billed full | High | **`[manual]` — condition is rarely digitised** |

#### One correction to exception 7's severity

The original marks **"item received not billed"** as **Information**, on the reasoning that the vendor may simply be late invoicing. **From an AP-control standpoint that is right.**

**From an accounting standpoint it is a liability.** Goods received and not yet invoiced is **goods received not invoiced (GRNI)** — **the business owes for them, and the obligation must be accrued at period end** whether or not the invoice has arrived. An unrecorded GRNI at a year end understates both liabilities and, depending on what was received, either inventory or expense.

**So exception 7 is Information to AP and a close item to the accountant**, and it should be flagged as both. `[auto]` to quantify the whole GRNI population at any date, which is exactly what the accrual needs and is a query nobody usually runs. See `month-end-close-checklist` and `accruals-and-deferrals`.

#### Exception 8, and where it leads

**"Item billed not received — possible fraud or vendor error."** Preserved with its severity.

`[auto]` to detect, **`[manual]` to conclude.** The overwhelming majority are timing — the receipt was not posted, or was posted late, or the goods arrived at a different site. **A minority are not**, and this exception is the reason the receipt leg exists at all.

**Report the population with amounts and ages. Never as an allegation.** Where a pattern emerges — one vendor, repeatedly, with no receipts ever — that is a fraud-investigation finding, and it belongs with whoever owns those rather than being resolved in an AP queue.

#### Exceptions 11 and 12, and the segregation-of-duties link

These two are **authority** exceptions, not arithmetic ones, and they are the ones a clean match will not surface — per the third near-substitute.

`[auto]` where approval data is exposed. **And read them alongside the segregation-of-duties tests of a SOX controls review:** the same user creating the PO, approving it, receiving against it and entering the invoice is a structural finding that no individual exception captures. **`[auto]` across the population**, and far more informative than any single trio.

---

### Step 5 — Resolution suggestions

`[auto]` to propose; **`[manual]` to decide and to act.** All five preserved.

- **Hold for AP investigation**
- **Reject the invoice**
- **Request vendor credit memo**
- **Approve override** — **with documented reason and authority**
- **Partial payment** — pay the matched portion, dispute the remainder

**The override deserves its qualifier preserved.** An override without a documented reason and a named authority is not a resolution; **it is the control being switched off for one invoice**, and a population of undocumented overrides is the finding that matters more than any of them individually. `[auto]` to count them.

---

### Step 6 — Output

An `.xlsx` workpaper. All four of the original's sheets, plus two additions.

**Sheet 1: Match Summary**
- PO #, GRN #, Invoice #
- Header-level match status
- Line-level match counts — matched / exception
- **Overall recommendation: Pay / Hold / Reject**

**Header carries, in bold: which match was actually performed** — three-way, two-way by design, or two-way by omission — **and which of the fifteen tests could not run**, with the reason. Plus the fixture flag.

**Sheet 2: Line-by-Line Match**
| Inv Line | Description | PO Qty | GRN Qty | Inv Qty | PO Price | Inv Price | PO Total | Inv Total | Variance | Tolerance Applied | Status |

**Add a Match Basis column** — line #, SKU, description, or unmatched — per the Step 2 caution.

**Sheet 3: Exceptions**
| # | Exception Type | Severity | Description | Recommended Action | Resolution Owner |

**Every row has an owner.** Exception 7 flagged as both Information and a close item.

**Sheet 4: Document References**
Source PO, GRN and invoice references with key fields, for the audit trail. **`[auto]` — and this is where the connected version is materially better than the manual one**: every reference is a live record with its own transaction detail, rather than a filename.

**Sheet 5: Population Findings** *(Mosofin addition)*
What only a population view shows:

| Finding | Vendor / scope | Count | Value | Period | Action |
|---|---|---|---|---|---|

Variances consistently just inside tolerance. Receipts posted in bulk on one date. Same user across multiple stages. Vendors with recurring unreceipted invoices. Undocumented overrides. **Total GRNI at the period end.**

**Sheet 6: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet, **including which legs were available.**

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

File naming: `3WayMatch_PO[PONumber]_[YYYY-MM-DD].xlsx` for a single trio; **`Match_Population_[YYYY-MM]_[EntityName].xlsx`** for a population run — **and the name should not say "3Way" when only two legs were matched.**

Entity `display_name` on every sheet.

---

## Output Quality Standards

All seven preserved.

- **Every invoice line has a match status.** `[auto]` — **including "unmatched", which is a status, not a gap.**
- **Every exception has type, severity and recommended action.** `[auto]`, **with an owner.**
- **Tolerance application is documented per line.** `[auto]`
- **Cumulative match across multiple invoices per PO tracks correctly.** **`[auto]`, and only reliably possible at population level.**
- **No silent auto-resolution of exceptions outside tolerance.** `[auto]` to enforce — **and overrides are counted, not just recorded.**
- **File naming consistent.** `[auto]`
- **Pay / Hold / Reject recommendation is explicit.** `[auto]` to recommend; **`[manual]` to act.**

**Five Mosofin additions:**

- **Which match was performed is stated** — three-way, two-way by design, or two-way by omission.
- **Tests that could not run are listed**, so their absence from the exception list is not read as a pass.
- **The match basis is recorded per line**, since a wrong line match produces two false variances.
- **Population patterns are reported**, not just individual exceptions.
- **GRNI is quantified at the period end**, because it is an accrual and not merely information.

---

## Seed to evolved: what happens on the first real run

**What must never be frozen into a seed:** the capability map — Gate 2 reads it fresh, and **which legs exist is exactly the thing that changes when a client adopts POs or receipting.**

**What is worth persisting into the workspace-scoped skill:**

1. **Which legs the system holds**, and at what detail — the answer to the three Gate 2 questions.
2. **The tolerance policy**, and the date it was set.
3. **The approval matrix**, without which exception 12 cannot run.
4. **The matching precedence** and any client-specific SKU or description conventions.
5. **Vendors with known legitimate price-adjustment clauses**, so recurring exceptions that are not errors stop being raised.
6. **Exceptions previously resolved with their reasons**, so the same invoice is not re-flagged monthly.
7. **The override log**, cumulatively — **the pattern is the finding.**
8. **The GRNI baseline**, so the accrual is a movement rather than a discovery each period.

Persist through `create_skill`, scoped to the workspace. **Client facts belong in a client-scoped skill, never back in the seed** — this analysis names vendors, approvers and disputed amounts.

**The evolved version runs the whole population every period** and reports what changed: new exceptions, ageing unresolved ones, the GRNI movement, and any drift in the patterns. That is a standing control rather than a clerical task.

---

## Anti-patterns

- **Calling a two-leg exercise a three-way match.** The missing leg is usually the one that proves the goods arrived.
- **Letting absent tests read as passed tests.** List what did not run.
- **Treating a PO number on an invoice as a match.** It is a reference.
- **Treating a posted item receipt as evidence of receipt.** Bulk receipts posted on one date are a bookkeeping action.
- **Forcing an uncertain line match.** It produces two false variances, not one.
- **Inventing a tolerance.** Exact match is the default; the policy belongs to the business.
- **Ignoring variances that sit just inside tolerance.** Each passes; the pattern is the finding.
- **Raising a price exception that is an FX movement.**
- **Matching against a blanket PO's total** instead of the release.
- **Treating GRNI as information only.** It is an accrual.
- **Resolving a repeated unreceipted-invoice pattern in the AP queue.** That belongs with fraud detection.
- **Recording overrides without counting them.**
- **Missing a receipt dated before its PO.** The amounts agreeing is what hides it.
- **Running the match on a sample when the population is available.**
- **Saying "paid" or "released".** The gateway reads; a person pays.

---
