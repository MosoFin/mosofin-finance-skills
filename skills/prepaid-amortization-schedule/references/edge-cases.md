<!-- prepaid-amortization-schedule · edge-cases.md · read for: Stages 3–4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All thirteen of the original's edge cases are preserved, in order, each with the workspace read that bears on it.

**Annual contracts with monthly billing** (NOT a prepaid): if the vendor invoices monthly, it is an ordinary expense each month and no prepaid setup is needed. The distinction: prepaid means paid **more than one period in advance**. `[auto]` — the billing frequency is directly visible in the vendor's transaction history, and this is the cheapest false positive to eliminate from Step 1's candidate list. A vendor with twelve invoices a year is not a prepaid, whatever the contract says.

**Prepayment for a variable amount** (a minimum commitment with usage-based overages): amortize the fixed portion; expense the overages when incurred. `[auto]` to see the pattern — a fixed annual charge with irregular top-ups is a recognisable shape in the ledger. `[manual]` to split it, because only the contract says which part is the commitment.

**Multi-year prepayments**: amortize over the full term even if it spans years. **Split between the current portion (next twelve months) and the non-current portion (beyond twelve months) on the balance sheet.** `[auto]` for the split once coverage dates exist — it is arithmetic. `[auto]` for a related check: if the chart has no non-current prepaid account at all, and multi-year items exist, the classification is wrong on the face of the balance sheet. Say so.

**Mid-contract price increase**: typically the original amount continues amortizing on its existing schedule; the increase is a **new prepaid item from its effective date**. `[auto]` to detect — a second charge from a vendor already on the schedule, mid-term, is exactly this. Do not blend it into the original item; a blended schedule cannot be unwound later.

**Item paid in installments rather than fully upfront**: each installment is its own prepaid with its own coverage period, if applicable. Or the entire contract value is set up as prepaid with an offsetting payable for the unpaid installments. `[auto]` to detect the installment pattern; `[manual]` to choose between the two treatments, and **apply the choice consistently** — a book that does both will not reconcile.

**Foreign-currency prepaid items**: a prepaid asset is **non-monetary** — typically **not revalued for FX after initial recognition**. Some entities elect otherwise; confirm the policy. `[auto]` and important: **look for revaluation-source entries hitting the prepaid account.** If they are there and the policy is non-revaluation, an FX process is reaching an account it should not touch, and it will do so again next month. This is a one-query finding of a recurring error. Correcting the FX process itself is an FX revaluation task.

**Tax-inclusive prepayments** (VAT/GST jurisdictions): set up the prepaid **net** of recoverable tax; recover the tax **in full at payment**, not amortized across the coverage period. `[auto]` to test, as set out in Step 6 — compare the prepaid debits to the gross bill amounts. This is one of the most reliably detectable errors in the whole skill.

**Prepayments to related parties**: check substance. If it is effectively a loan, it does not belong in prepaid. If it is a genuine advance for services, it does. `[auto]` to flag — a prepayment to a name that also appears in the customer list, or to a connected entity's `display_name`, is worth a second look. `[manual]` to judge, because substance is not a field. The wider review is an intercompany reconciliation or a related-party review.

**Prepaid items that become impaired** (the vendor fails, the service will not be delivered): write down the unamortized balance. `[manual]` to learn of it — vendor insolvency is not in the ledger. `[auto]` for one weak signal: a vendor with an open prepaid balance and no transaction activity for an unusually long stretch is worth asking about. Weak, but free.

**Initial direct costs of obtaining a lease**: formerly parked in prepaid; under ASC 842 / IFRS 16 they are **included in the ROU asset**. `[auto]` to flag lease-related items sitting in prepaid; `[manual]` to reclassify. The reclassification itself is lease-accounting work.

**Subscriptions that auto-renew without an explicit invoice**: the schedule rolls into the new period automatically; make sure the new period's invoice is captured. `[auto]` and genuinely useful — **compare the vendors on the schedule to the vendors with recent charges.** A schedule item whose coverage has ended with no renewal charge in the books is either a cancelled service or an uncaptured invoice, and both need an answer.

**Prepayment paid by a related entity on behalf of this entity**: due-from / intercompany handling. The prepaid is real, offset by an intercompany payable. `[auto]` where both entities are connected to the workspace — read both sides in one batch and check they agree. **If only one side is connected, this cannot be reconciled**, and a single-sided figure should be labelled as such rather than presented as agreed. Matching the two sides is an intercompany reconciliation.

**Mid-year change in policy or amortization method**: a change in **estimate**, applied **prospectively**. Document it. `[auto]` to detect — Step 0b's convention read will show the point where the credit pattern changed. `[manual]` to document the reason, because the reason is not in the books.

---
