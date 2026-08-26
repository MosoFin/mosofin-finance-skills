---
name: three-way-match
description: "Use this skill whenever the user wants to perform a three-way match between purchase orders, goods receipts and vendor invoices against a connected Mosofin workspace. Triggers include: 'three-way match these documents', 'verify the invoice against the PO and receipt', 'match PO to receipt to invoice', 'PO matching', 'GRN matching', 'run the match across all open invoices', uploading a PO + receipt + invoice trio, or any AP control task involving PO-to-invoice verification. Do NOT use for invoice extraction alone — use invoice-data-extractor. Do NOT use for duplicate detection — use duplicate-invoice-detection. Where the workspace holds purchase orders and item receipts, this runs across the full population every period rather than document by document. Outputs a match result with line-by-line comparison and exception list. Proposes only — Mosofin pays nothing and releases nothing."
---

## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** — but every step becomes manual.

### First-run onboarding

Work through these once per workspace. **The skill does not read any data until you
have explicitly confirmed step 3.**

| # | Step | What happens |
|---|---|---|
| 1 | **Have an active subscription** | The Mosofin gateway returns data only for an authenticated, subscribed account. Unauthenticated calls are rejected. |
| 2 | **Connect the gateway** | Add the Mosofin MCP server — `https://mcp.mosofin.com/mcp`. Follow [**Connect MosoFin to Claude**](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) for the exact steps in your destination. Authentication is **OAuth** — no credentials are stored locally, and **this skill never asks you for a password, token or account number.** |
| 3 | **Confirm your workspace** | Gate 0 below. The skill reads your workspaces back **by name** and waits for an explicit yes. Silence is not a yes. |
| 4 | **Confirm the company file** | Gate 1. Which set of books, by name — never by internal id. |
| 5 | **Capability check** | Gate 2. The skill reads what your subscription and connection actually permit **today** and annotates every task accordingly. |
| 6 | **Profile** | Gate 3. On the first run this is a short interview. On later runs the skill reads what was already learned and asks only what is still open. |

### Where the setup instructions live — [docs.mosofin.com](https://docs.mosofin.com)

Mosofin connects a **source** (your books) to a **destination** (where you are reading
this skill). Both sides have to be set up once. If any step above is unclear, or a gate
below reports that it cannot reach your data, start here:

| If you need to… | Read |
|---|---|
| Do the whole setup start to finish | [Quickstart](https://docs.mosofin.com/start-here/quickstart) |
| Create an account or sign in | [Sign in and account basics](https://docs.mosofin.com/start-here/register-a-mosofin-account) |
| Create the workspace this skill will read | [Set up your first workspace](https://docs.mosofin.com/start-here/create-your-first-data-flow) |
| **Connect Mosofin to your destination** | [Destinations overview](https://docs.mosofin.com/source-and-destination/destinations) → [Claude](https://docs.mosofin.com/source-and-destination/destinations/claude) → [Connect MosoFin to Claude](https://docs.mosofin.com/source-and-destination/destinations/claude/connect-claude) |
| Connect the books themselves | [Sources overview](https://docs.mosofin.com/source-and-destination/sources) → [Connect QuickBooks](https://docs.mosofin.com/source-and-destination/sources/quickbooks/connect-quickbooks) |
| See which data and tools are exposed | [Available financial data](https://docs.mosofin.com/source-and-destination/sources/quickbooks/data-overview) · [API tools reference](https://docs.mosofin.com/source-and-destination/sources/quickbooks/api-tools) |
| Fix a connection that will not authenticate | [Common issues](https://docs.mosofin.com/source-and-destination/destinations/claude/common-issues) · [Claude FAQ](https://docs.mosofin.com/source-and-destination/destinations/claude/faq) |
| Check your subscription, seats or limits | [Billing](https://docs.mosofin.com/account/billing) · [Usage and plan limits](https://docs.mosofin.com/account/plan-limits) |
| Get a person involved | [Contact support](https://docs.mosofin.com/troubleshooting/contact-support) |

### What the subscription requirement means in practice

- **The gateway is read-only.** Nothing in this skill posts an entry, files a return,
  sends a message, or moves money. **Every output is a proposal for a person to act on.**
- **Access is workspace-scoped.** The skill sees only the workspaces and company files
  your subscription grants, and only the tools enabled for them.
- **Permissions are read fresh on every run.** If your plan, connection or tool
  permissions change, the skill's behaviour changes with them. It never assumes
  yesterday's access.
- **You are told what was actually available.** Every run produces a coverage sheet
  recording which capabilities were live, which were gated, and which were unavailable.

### Running without a connection

The skill **degrades rather than failing**. Every step that would have been automatic
becomes `[manual]`, and you supply the data by export instead. The output says so
explicitly — you will always be able to tell which figures came from your books and
which you provided by hand.

---

# Three-Way Match — Mosofin Seed

Performs a three-way match between a purchase order (PO), a goods receipt note (GRN) or proof of delivery, and a vendor invoice. Identifies pricing, quantity and authorisation exceptions **before payment.**

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## Everything depends on which legs the system actually holds

The match has three legs, and a connected accounting system holds them to very different degrees:

| Leg | Typically in the accounting system? | Verdict |
|---|---|---|
| **Vendor invoice** | **Almost always** — it is a bill in the AP ledger | **`[auto]`** |
| **Purchase order** | **Often, but not universally.** Many systems support POs; many businesses do not use them. | **`[auto]` if present** — check |
| **Goods receipt** | **Frequently not.** Receiving is a warehouse function, and the GRN commonly lives in an inventory or WMS system, on paper, or nowhere. | **Often `[manual]`** |

**So the first question is not how to match. It is how many legs exist.**

> **If the workspace holds only invoices, this is not a three-way match. It is an invoice review.**
>
> **If it holds invoices and POs but no receipts, it is a two-way match.**

**Say which one is being performed**, in the output and in the file name. Presenting a two-leg exercise as a three-way match misrepresents the control that was operated — and the missing leg is usually the receipt, which is the leg that proves the goods actually arrived. **The strongest exceptions in Step 4 — *item billed not received*, *quantity overbilling*, *short-shipment billed in full* — all require it.** Without receipts, those tests do not run, and their absence from the exception list must not read as their having passed.

**Check at Gate 2**, and check what the PO and receipt records actually carry — a system may hold POs with no line detail, or receipts with no quantities, either of which limits the match to header level.

### The change of shape where the legs do exist

The original is written **document by document**: *"uploading a PO + receipt + invoice trio."* That is how manual three-way matching works, because a person can only look at one trio at a time.

**A connected workspace changes the unit of work.** Every open invoice, every PO, every receipt is readable together, so the match runs across **the whole population, every period**, unattended.

That converts a per-invoice clerical check into **a standing control** — and it is precisely one of the ledger-evidenced controls that `sox-controls-design-and-testing` identifies as testable at full population rather than by sample. **The exceptions found are the same; the coverage is not.**

### Three near-substitutes

**1. A PO number written on an invoice is not a match.** Vendors put PO references on their invoices as a courtesy, and AP staff frequently treat the presence of one as evidence the invoice is authorised. **It is a reference, not a verification** — the whole point of the match is to check that what the reference points to actually agrees.

**2. An item receipt posted in the accounting system is not a goods receipt.** Where someone posts a receipt to close out a PO — often at month end, often in bulk, often to make the PO stop appearing on a report — **the record is a bookkeeping action, not evidence that anybody inspected anything.** `[auto]` can spot the signature: receipts posted in batches, all on one date, all exactly matching the PO quantity, frequently by the same user who entered the invoice. That last combination is a segregation-of-duties finding as well as a match one.

**3. Matched is not approved.** A perfectly matching invoice from an unapproved PO is still unauthorised spending. Exceptions 11 and 12 in Step 4 are about authority, not arithmetic, and they are the ones a clean match will not surface.

---

## Gate 0 — Confirm the workspace before anything else

1. Call `list_workspaces` with no arguments.
2. If the status is `confirmed`, there is one workspace. **Read its name back and wait for an explicit yes.**
3. If the status is `selection_required`, ask: **"Is this a single-workspace task or a multi-workspace one?"**
   - Single: ask which one by name, then `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. Never print the internal numeric id, never ask for it, and if it appears in an error, name the workspace instead.

**Why this gate matters here.** The output of this skill is **a recommendation to pay, hold or reject** — it gates money leaving the business. It also names vendors and, where approval data exists, individuals.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The document-by-document match still works exactly as the original describes, on uploaded files. **The population-wide match does not.** Say so. |
| **Exactly one company file** | Confirm the `display_name`. **Entity matching (Step 2) is against this entity.** |
| **Several company files** | **The buyer entity is one of the header checks.** An invoice billed to the wrong group company is exception 13's cousin and is common in groups sharing suppliers. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. Stop — **a partial population produces "no exceptions" for invoices that were simply not read.** |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

---

## Gate 2 — Map what you can actually do

### Write tools are out of scope — always

`get_datasource_tools` describes what the connection *could* do. This skill uses only
the reads.

**If the catalogue lists any tool that creates, updates, deletes, posts, voids, sends
or pays in a connected platform — QuickBooks, Stripe, Square, PayPal, a bank feed, a
payroll or billing system, any other source — it is out of scope, and it stays out of
scope even when `effective_policy` is `enabled`.** A permission to write is not an
instruction to write. Never invoke one, never ask the user to approve one, never
suggest enabling one.

This holds for **every connected platform, not only the books.** Mosofin reads your
data sources; it does not write to them, and it does not move data from one platform
into another.

If a step appears to need a write, that step is **`[manual]`**. Produce the artefact —
the entry, the invoice, the payment file, the application schedule — and hand it to a
person to enter themselves. Say so plainly in the output, so nobody assumes it was
done.

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each tool.

| `effective_policy` | Verdict | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch with other independent reads. |
| `permission` | `[gated]` | Expect `approval_required`. Explain what and why, get a yes, re-invoke with `approved=true`. |
| `disabled` | `[manual]` | Not available. The step remains; the user performs it. |

Every verdict below is a **default written before the gateway was consulted.** Where Gate 2 disagrees, **Gate 2 wins** for this run. Do not carry a capability map between runs.

**Three capability questions decide this skill, and they must be answered before anything is promised:**

1. **Does the surface expose purchase orders?** With line detail, or header only?
2. **Does it expose item receipts?** With quantities, or only as a status flag?
3. **Does it expose approval status and the approver's identity?** Exceptions 11 and 12 depend on it, and so does the SoD observation above.

**Read the returned schemas and answer all three.** Do not assume in either direction.

**A scope note**: if a tool that pays a bill or releases a payment appears in the listing, it is **out of scope regardless of `effective_policy`.** This skill produces a recommendation; a person pays.

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** Open bills, purchase orders, item receipts, the vendor master and payment history are independent. **Read the whole open population**, not a sample — that is the point.

### The `mock: true` flag

Fixture data has **POs, receipts and invoices that agree**, because they were generated together from the same source. **Every one of the fifteen exception tests passes.**

**And the output of this skill is a payment recommendation.** Label it in the file name, on the match summary, and beside every Pay recommendation.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Interview for:

1. **The tolerance policy** — price %, quantity %, total amount. `[manual]`. **If none is provided, default to exact match and flag every variance** — the original's rule, preserved.
2. **The approval matrix** — who may approve at what amount. `[manual]`, **and persist it**; it changes rarely and exception 12 cannot run without it.
3. **Whether services POs are in scope**, and what substitutes for a GRN.
4. **The FX policy** for multi-currency POs. `[manual]`.
5. **Who owns exception resolution.** `[manual]` — Sheet 3 needs an owner per row.

**Decisions are the user's; state is the workspace's.**

---

## How to read the verdicts

- **`[auto]`** — Mosofin can do this from live reads, unattended.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` and the `data_source_id`.
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

**One `[auto]` observation worth reporting**, and it is only visible across a population: **variances that sit consistently just inside tolerance.** A vendor whose prices are always 1.8% above PO, against a 2% tolerance, is not producing random variances — and each instance passes, which is precisely why nobody notices. **Report the pattern with its count and its total value**, exactly as `petty-cash-management` reports a persistent within-tolerance shortage. **As a pattern, with figures, never as an allegation.**

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

**So exception 7 is Information to AP and a close item to the accountant**, and it should be flagged as both. `[auto]` to quantify the whole GRNI population at any date, which is exactly what the accrual needs and is a query nobody usually runs. See `month-end-close-checklist` and `accruals-and-prepayments`.

#### Exception 8, and where it leads

**"Item billed not received — possible fraud or vendor error."** Preserved with its severity.

`[auto]` to detect, **`[manual]` to conclude.** The overwhelming majority are timing — the receipt was not posted, or was posted late, or the goods arrived at a different site. **A minority are not**, and this exception is the reason the receipt leg exists at all.

**Report the population with amounts and ages. Never as an allegation.** Where a pattern emerges — one vendor, repeatedly, with no receipts ever — that is a finding for `fraud-detection-and-forensics`, and it should go there rather than being resolved in an AP queue.

#### Exceptions 11 and 12, and the segregation-of-duties link

These two are **authority** exceptions, not arithmetic ones, and they are the ones a clean match will not surface — per the third near-substitute.

`[auto]` where approval data is exposed. **And read them alongside the SoD tests in `sox-controls-design-and-testing`:** the same user creating the PO, approving it, receiving against it and entering the invoice is a structural finding that no individual exception captures. **`[auto]` across the population**, and far more informative than any single trio.

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

If creating xlsx, read first: `/mnt/skills/public/xlsx/SKILL.md`

File naming: `3WayMatch_PO[PONumber]_[YYYY-MM-DD].xlsx` for a single trio; **`Match_Population_[YYYY-MM]_[EntityName].xlsx`** for a population run — **and the name should not say "3Way" when only two legs were matched.**

Entity `display_name` on every sheet.

---

## Edge Cases

All eleven preserved, in order.

**Multiple invoices against one PO** — progress billings: **each invoice matched against the PO; cumulative billed cannot exceed the PO total. Track a running balance.** **`[auto]`, and materially easier at population level** — the cumulative test requires seeing every invoice against that PO at once, which is exactly what a document-by-document match cannot do. **This is a case where the manual method structurally cannot perform the test properly.**

**Multiple POs combined on one invoice**: **split the invoice virtually and match per PO. Each invoice line maps to one PO.** `[auto]`.

**Service POs with no GRN**: **substitute a service-completion confirmation, signed by the service receiver. Treat the confirmation as the GRN equivalent.** `[manual]` — a signed confirmation is not usually in the accounting system. **And this is two-way by design**, per the Inputs note.

**Blanket POs with releases**: **match against the release, not the blanket. Roll up to the blanket for commitment tracking.** `[auto]` where releases are recorded; **matching an invoice to a blanket PO's total will pass almost anything**, which is why the release is the right unit.

**Partial deliveries / partial billing**: **match the delivered or billed portion. Carry forward the open balance. Multi-period matching tracked.** **`[auto]`, and again easier at population level**, since the open balance persists across periods and a per-trio match loses it.

**Substitutions** — vendor delivers a similar but different SKU: **if authorised, match by authorisation reference. Otherwise flag.** `[manual]` for the authorisation; `[auto]` to flag the SKU mismatch.

**Price changes mid-PO** — long-running POs where market price moved: **if the PO has a price-adjustment clause, the invoice price may legitimately differ. Confirm against the contract or clause reference.** `[manual]` — **the clause is in the contract, not the PO record**, and this is a common source of exceptions that are not errors.

**Multi-currency POs and invoices**: **convert at the PO's stated rate or the invoice date's rate per policy. Flag the FX treatment.** `[manual]` for the policy; `[auto]` for the conversion. **A price variance that is really an FX movement is the classic false positive here** — see `multicurrency-fx-revaluation`, and separate the two before raising exception 1.

**Tax discrepancies** — PO had estimated tax, invoice has actual: **flag for total reconciliation; the tax line itself may not need a match if pricing aligns.** `[auto]`. See `sales-tax-us-multistate` and `vat-gst-international` — **and note the use-tax angle: an invoice with no tax charged may create a self-assessment obligation**, which is a finding this population read can supply for free.

**Goods received before the PO was issued** — rush orders: **require retroactive PO approval. Flag as a process exception even if the amounts match.** **`[auto]` — compare the receipt date to the PO date**, which is a trivially cheap test and catches a real control breakdown that a value-based match never sees. **The amounts agreeing is precisely what makes it invisible otherwise.**

**Open POs received and billed but not yet matched in the system** — **backlog cleanup mode: match historic transactions and update commitment balances.** **`[auto]`, and this is where a population run earns its keep on the first engagement.** A business that has never run the match has a backlog; **clearing it is one query rather than months of clerical work**, and the GRNI figure that falls out of it is usually the most valuable single number produced.

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

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`)
- **Which legs were available**: invoices / POs / receipts, and at what level of detail
- **Which of the fifteen exception tests ran, and which did not, with reasons**
- Population and period covered, or the specific trio
- Tolerance policy applied; approval matrix used
- **Fixture flag** — any `mock: true`? In bold: **generated documents agree, so every test passes — and this skill recommends payments.**

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict. **Including the three Gate 2 questions and their answers.**

**Section C — Steps by verdict**
Every step, and **every exception type**, with whether it ran.

**Section D — What was not done, and why**
- **Goods receipts**, where the system does not hold them — **and therefore exceptions 3, 4, 7, 8 and 15**
- **Condition data** (damaged / rejected), which is rarely digitised
- **Approval status or approver identity**, where not exposed — **and therefore exceptions 11 and 12**
- **The approval matrix**, where not supplied
- **Contract price-adjustment clauses** — in the contract, not the PO
- **Service completion confirmations**
- **Authorisation for substitutions**
- **Any conclusion of fraud** — the data shows the pattern; people conclude
- **Payment.** The gateway is read-only

**Section E — Unknowns carried forward**
Unmatched lines. Exceptions unresolved by age. Unreceipted invoices outstanding. Undocumented overrides. GRNI not yet accrued. Vendors showing within-tolerance drift.

**Section F — Parameters used**
Tolerances. Matching precedence. Population and dates. Approval matrix version. **A control test that cannot be reproduced is not evidence** — and this one is a SOX control, so it will be re-performed.

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

## Related skills

| Skill | Relationship |
|---|---|
| `invoice-data-extractor` | Extraction of uploaded invoices, explicitly out of scope for the match itself. |
| `duplicate-invoice-detection` | Exception 9, in depth. |
| `sox-controls-design-and-testing` | Three-way match as a ledger-evidenced control tested at full population — and the SoD reading of exceptions 11 and 12. |
| `fraud-detection-and-forensics` | Where a recurring unreceipted-invoice pattern belongs. |
| `vendor-onboarding-and-w9-tin` | The vendor master, and master-data change control. |
| `vendor-statement-reconciliation` | The other direction: what the vendor thinks is owed. |
| `month-end-close-checklist` / `accruals-and-prepayments` | The GRNI accrual falling out of exception 7. |
| `multicurrency-fx-revaluation` | Separating an FX movement from a price variance. |
| `sales-tax-us-multistate` / `vat-gst-international` | Tax mismatches, and the use-tax exposure on untaxed invoices. |
| `inventory-to-gl-reconciliation` | Where received-not-billed goods sit in stock. |
| `standard-costing-and-variance-analysis` | Where the actual purchase price enters, and becomes PPV. |
