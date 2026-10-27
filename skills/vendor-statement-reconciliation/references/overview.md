<!-- vendor-statement-reconciliation · overview.md · read for: background — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# Vendor Statement Reconciliation — Mosofin Seed

Reconciles vendor statements — the supplier's own open balance or ageing — to the AP subledger and the general ledger, identifies missing and duplicate items, and drives resolution.

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## This is a genuine external reconciliation

Worth saying plainly, because it is unusual in this pack.

Most reconciliations here tie one part of a ledger to another part of the same ledger, and I have had to say repeatedly that they **agree by construction** — the balancing balance sheet in `financial-statement-builder`, a segment reconciliation, the detail-to-summary tie of an AR aging, an equity roll-forward.

**This one is different.**

> **A vendor statement is independent evidence, prepared by a third party from their own records.**

That makes it the same kind of thing as a bank statement — and **it is the same kind of control**. `bank-reconciliation` and this skill are the two genuine external reconciliations on the cash-and-payables side, and they earn their place for the same reason: **the other side of the comparison was produced by somebody with no access to your books.**

### Which makes it the primary control over completeness of AP

**Completeness is the hardest assertion to test.** Internal audit makes the point and SOX controls testing repeats it: a full-population test of what is in the ledger still cannot prove that nothing is missing, because absence leaves no trace.

**A vendor statement is one of the few things that can.** The supplier lists what they believe you owe them. **Anything on their list and not on yours is a candidate unrecorded liability** — and unrecorded liabilities are the classic AP misstatement, understating both payables and expense.

**So the accounting significance of this skill is larger than "tidying up AP suggests."** At a period end it is the substantive completeness procedure over payables.

### The clean split

| Side | Where it lives | Verdict |
|---|---|---|
| **AP subledger and vendor ledger** | **The workspace** — every invoice, credit, payment, in full detail | **`[auto]`** |
| **Payment register** | **The workspace** | **`[auto]`** |
| **The vendor statement** | **A PDF the supplier emailed.** Not in any accounting system. | **`[manual]`** |
| **The dispute log** | Notes, emails, someone's spreadsheet | **`[manual]`** |

**One side is exact and complete; the other has to be obtained.** Which is exactly what makes the reconciliation worth doing.

### And a contribution the original does not have

The source assumes **a statement in hand** and reconciles it. It says nothing about **which vendors ought to be reconciled at all** — which, in practice, is the decision that determines whether the control works.

**`[auto]` answers it**: rank the whole vendor population by balance, by spend, by activity, and by whether a statement has ever been reconciled. **A large supplier whose statement has never been reconciled is precisely where an unrecorded liability sits undisturbed.** See Step 0.

### Three near-substitutes

**1. The AP balance is not what you owe.** It is what you have **recorded**. The gap between the two is the entire subject of this skill, and treating the ledger balance as the liability assumes away the question.

**2. A statement is not an invoice.** Step 5 is careful about this — *record confirmed missing items **with support*** — and the qualifier is load-bearing. **You cannot book a liability from a statement line alone**: you need the invoice, both for the accounting and for input tax recovery. A statement tells you an invoice may exist; it is not the invoice.

**3. Matching on amount is not matching.** Recurring suppliers issue identical amounts month after month. **An amount match without a document number or a date is a coincidence dressed as a match**, and it produces two errors at once — see Step 2.

**And a fourth, which cuts the other way: the statement can be wrong too.** It is the vendor's view of the relationship, produced from their system, subject to their errors. An item on the statement and not on your books may be an invoice they never sent, one they sent to the wrong entity, or one already settled and not applied on their side. **The reconciliation is two-way.**

---

## Related skills

| Skill | Relationship |
|---|---|
| `bank-reconciliation` | The other genuine external reconciliation on this side of the ledger. |
| `three-way-match` | GRNI — goods received not invoiced — which the supplier's statement will show as invoices. |
| `duplicate-invoice-detection` | Duplicates on either side. |
| `invoice-data-extractor` | Extracting the statement where it arrives as a document. |
| `accruals-and-deferrals` | Accruing confirmed liabilities where the invoice has not arrived. |
| `month-end-close-checklist` | Where the reconciliation belongs as a recurring close task. |
| `journal-entry-builder` | Formats the proposed entries. |

Skills for vendor onboarding, VAT and GST, FX revaluation, internal audit and SOX controls testing, and AP invoice processing are queued for this library and will be linked here when they ship.
