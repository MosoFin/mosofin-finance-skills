<!-- vendor-statement-reconciliation · method.md · read for: Stages 3–6 — how to read the verdicts, Step 0 vendor prioritisation, Inputs, Steps 1–5, seed to evolved, anti-patterns. Edit here, not in SKILL.md. -->

## Contents

- How to read the verdicts
- Step 0 — Decide which vendors to reconcile *(Mosofin addition)*
- Inputs
- Workflow
  - Step 1 — Normalise both datasets
  - Step 2 — Match statement items to the AP ledger
  - Step 3 — Explain differences
  - Step 4 — Resolution playbook
  - Step 5 — Accounting actions
- Seed to evolved: what happens on the first real run
- Anti-patterns


## How to read the verdicts

- **`[auto]`** — Mosofin can do this from live reads, unattended.
- **`[gated]`** — the gateway asks first. Explain, get consent, re-invoke with `approved=true` (**reads only — never for a write**) and the `data_source_id`.
- **`[manual]`** — not on this surface, or not a machine's judgment. **The step stays. The user performs it.**

**Everything here is a proposal.** The gateway is read-only. Mosofin posts nothing and contacts no supplier.

---

## Step 0 — Decide which vendors to reconcile *(Mosofin addition)*

**`[auto]`. One read, and it should precede any individual reconciliation.**

**Reconciling every supplier statement is not feasible and not necessary.** The question is which ones, and the answer is a ranking the workspace can produce exactly:

| Signal | Why it ranks |
|---|---|
| **Largest AP balances at the cutoff** | Where a difference is most material. |
| **Largest annual spend** | Where the volume of transactions makes error most likely. |
| **Vendors never reconciled** | **The highest risk of all** — an unrecorded liability that has never been looked for. |
| **Vendors with a credit balance in AP** | **Almost always wrong.** A debit balance on the supplier's account means either a payment misapplied, a duplicate payment made, or a credit note that should have been claimed. **Money, usually yours.** |
| **Vendors with old open items** | Invoices unpaid for months are either disputed, already paid and misapplied, or never should have been recorded. |
| **Vendors whose invoice pattern broke** | **Regular monthly billing that stopped** — either the relationship ended, or invoices are arriving and not being entered. |
| **High GRNI** | Goods received not invoiced — see `three-way-match` exception 7. The supplier's statement will show those invoices. |

**Rank by amount, and report which vendors have never been reconciled.**

**The credit-balance row deserves emphasis** because it is money and it is free to find: **a supplier account in credit means the business has paid more than it owes**, and the causes — duplicate payment, misapplied payment, unclaimed credit note — are all recoverable. **One query across the whole ledger.**

**The last row is the completeness signal**: a supplier who invoiced monthly for two years and has sent nothing for three months is either gone or **their invoices are not reaching the ledger.** The second case is exactly an unrecorded liability, and the pattern break is visible without any statement at all.

---

## Inputs

All five preserved.

| Input | Format | Required | Mosofin source | Verdict |
|---|---|---|---|---|
| **Vendor statement** | PDF / CSV | **Required** | **Not in the books. The supplier sends it.** | `[manual]` |
| **AP ageing / vendor ledger** | Export | **Required** | **`[auto]`, in full detail** — no export needed | **`[auto]`** |
| Payment register | AP payments + bank info | Recommended | **`[auto]`** | `[auto]` |
| Dispute log | Notes of disputed invoices | Recommended | **Not in the books** — disputes are correspondence | `[manual]` |
| **Cutoff date** | Month-end date | **Required** | **`[auto]` for yours; the statement carries its own** — see Step 1 | Split |

---

## Workflow

### Step 1 — Normalise both datasets

`[auto]` for the ledger side; `[manual]` extraction for the statement.

Standardise all five fields:

- **Document number**
- **Type** — invoice, credit, payment
- **Date / due date**
- **Amount / currency**
- **PO / reference**

**`[auto]` for the ledger side, completely** — every field is a database field.

**`[manual]` for the statement**, which is a PDF. Where it arrives as CSV, extraction is mechanical; where it is a scanned image, it is not. See `invoice-data-extractor` for the extraction discipline.

#### Three normalisation traps, all `[auto]` to handle and all routinely missed

**Document numbers are text.** Leading zeros, prefixes, and the supplier's internal reference versus the number printed on the invoice. **`INV-0042`, `42` and `0042` are one document**, and a match on the raw string finds none of them. Normalise both sides the same way and **record the normalisation applied** — the same discipline an AR aging applies to preserving document numbers as text.

**Cutoff dates differ.** **The supplier's statement cutoff is very often not your period end.** A statement dated the 25th against a ledger at the 30th will show five days of legitimate difference in both directions. **Establish both dates explicitly** and treat the gap as a known reconciling window rather than a set of exceptions.

**Sign conventions differ.** Suppliers present credits and payments with varying signs and column layouts. **Normalise to a consistent convention before matching**, or credits will present as invoices and the reconciliation will not converge.

---

### Step 2 — Match statement items to the AP ledger

**`[auto]` once the statement is normalised.** The four-tier matching order preserved exactly:

1. **Document number**
2. **Amount + date proximity**
3. **PO + amount**
4. **Fuzzy reference / description**

**The order is a confidence hierarchy and it should be respected as one.** Tier 1 is near-certain; tier 4 is a suggestion.

**Two Mosofin requirements**, both carried across from `three-way-match`'s line matching, because the failure mode is identical:

**Record the match tier for every matched item.** A reviewer needs to see which matches are confident and which are inferred. A reconciliation where half the matches came from tier 4 is a different document from one where they all came from tier 1.

**Never force an uncertain match.** **An unmatched item is a question; a wrongly matched item is two wrong answers** — one item is marked resolved that is not, and another is left as an exception that is not real. **Leave doubtful items unmatched and let a person look.**

**And the amount-match caution from the near-substitutes**: tier 2 exists because document numbers are often absent or mangled, and it is genuinely useful — **but with a recurring supplier billing the same amount monthly, amount plus date proximity can match the wrong month.** Where several candidates tie, **report the ambiguity rather than picking one.**

---

### Step 3 — Explain differences

**All six preserved, and the verdicts differ sharply.**

| Difference | Meaning | Verdict |
|---|---|---|
| **Missing invoice on books** | On the statement, not in your ledger | **`[auto]` to identify — and it is the finding that matters most.** See below. |
| **Missing credit memo on books** | The supplier has credited you and you have not recorded it | **`[auto]` — and this is money owed to you.** See below. |
| **Payments in transit** | Paid by you, not yet received or applied by them | **`[auto]`** — match against the payment register and the dates |
| **Misapplied payment** | Paid, but they applied it to a different invoice | **`[auto]` to detect** — the payment appears on both sides against different documents |
| **Duplicates** | The same invoice recorded twice on either side | **`[auto]`** — see `duplicate-invoice-detection` |
| **Disputes** | Withheld deliberately | **`[manual]`** — the dispute log is correspondence, not ledger data |

#### Missing invoices, and why they are the point

**This is the unrecorded liability**, and it is the reason the reconciliation is a completeness control.

An invoice on the supplier's statement and not in your ledger means one of:

- **it was never received** — and is a genuine unrecorded liability
- **it was received and not entered** — sitting in someone's inbox or a pending queue
- **it was entered under a different vendor record** — run the duplicate-vendor check first
- **it was entered to a different entity** in the group
- **it does not exist** — the supplier's error, or an invoice sent to someone else

`[auto]` can distinguish several of these: the duplicate-vendor case, the wrong-entity case where entities are connected, and the entered-late case where the invoice appears after the cutoff.

**What remains is `[manual]` and needs the invoice**, per the second near-substitute: **you cannot book from the statement line.** Request the invoice copy, and **at a period end, accrue where the liability is confirmed but the document has not arrived** — which is the same accrual as the GRNI position in `three-way-match`. See `accruals-and-deferrals` and `month-end-close-checklist`.

#### Missing credits, which nobody looks for

**The mirror case, and it is in the client's favour**, which is exactly why it goes unfound: nobody chases a supplier about money the supplier owes them.

A credit note on the statement and not in your ledger is **a reduction in what you owe that has not been taken** — and if the invoice it relates to has already been paid in full, **it is cash you are owed.**

`[auto]` finds them across the whole statement. **Report them prominently and separately from the adverse differences**, because a reconciliation presented as a list of problems buries the one item that returns money.

---

### Step 4 — Resolution playbook

`[manual]`. All three preserved:

- **Owner**
- **Next action**
- **Target close date**

**Every exception gets all three.** `[auto]` can propose the action from the difference type — request invoice copy, request credit note, investigate application, reverse duplicate — **and the owner and the date are human commitments.**

**One `[auto]` addition worth having**: **ageing of exceptions across reconciliations.** An exception raised three months running and still open is not an exception; it is a state. Where the reconciliation is a recurring process, **carry the exception list forward and age it** — the items that never close are the ones that need escalating rather than re-raising.

---

### Step 5 — Accounting actions

`[auto]` to draft; **`[manual]` to post.** All three preserved:

- **Reverse duplicates**
- **Reclass mis-postings**
- **Record confirmed missing items with support**

> **"with support"**

**The qualifier is preserved and it is the important part.** A statement line is not support. **Recording a liability needs the invoice** — for the amount, for the coding, for the tax treatment, and for input tax recovery, which generally requires a valid invoice and not a statement.

**Where the liability is confirmed and the document has not yet arrived, the answer is an accrual, not an invoice posting.** They are different entries with different consequences: an accrual reverses and is replaced when the invoice arrives; a posted invoice without the document leaves a payable nobody can support and, in a VAT jurisdiction, an input tax claim that may be disallowed.

Hand drafted entries to `journal-entry-builder`. **Marked PROPOSED — NOT POSTED.**

---

## Seed to evolved: what happens on the first real run

**What must never be frozen into a seed:** the capability map — Gate 2 reads it fresh.

**What is worth persisting into the workspace-scoped skill:**

1. **Which vendors are on the reconciliation programme**, at what frequency — the output of Step 0, turned into a policy.
2. **Each supplier's statement conventions** — cutoff date, scope, document number format, currency, sign convention. **This is what makes the second reconciliation quick and the first one slow.**
3. **The account reference per supplier per entity**, so the wrong-entity trap is closed.
4. **The normalisation rules** for each supplier's document numbers.
5. **Open exceptions, with their age and owner**, carried forward — **the single most valuable item**, because an exception list that resets each period never resolves anything.
6. **Known permanent differences** — a consignment arrangement, a self-billing agreement — so they are not re-raised.
7. **Vendors reconciled and when**, so "never reconciled" stays accurate.

Persist through `create_skill`, scoped to the workspace. **Client facts belong in a client-scoped skill, never back in the seed.**

**The evolved version opens with the exception list carried forward and the vendors due for reconciliation this period** — which turns a periodic clean-up into a running control.

---

## Anti-patterns

- **Reconciling whichever statement happened to arrive.** Step 0 says which ones matter.
- **Concluding "unrecorded liability" before checking for a duplicate vendor record.**
- **Reconciling a statement addressed to a sibling entity.**
- **Ignoring the cutoff difference.** Five days of activity is not a set of exceptions.
- **Comparing an open-item statement to a balance-forward ledger** line for line.
- **Matching on amount alone** with a recurring supplier.
- **Forcing an uncertain match.** It creates two errors, not one.
- **Reporting matches without their tier.**
- **Burying missing credits in a list of problems.** They are money owed to the client.
- **Posting an invoice from a statement line.** Accrue; post when the document arrives.
- **Assuming the statement is right.** It is the vendor's view and it can be wrong.
- **Converting foreign currency before matching.** Match on document and currency amount.
- **Letting exceptions reset each period.** Age them; the ones that never close are the finding.
- **Treating this as housekeeping.** It is the primary completeness control over payables.
- **Saying "posted".** The gateway reads.

---
