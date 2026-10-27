<!-- vendor-statement-reconciliation · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

*(A Mosofin addition — the original has no Edge Cases section.)*

**The statement is for a different entity in the group.** Every invoice presents as missing. **Check the account reference before reconciling** — the commonest cause of a reconciliation that will not converge.

**The supplier exists twice in the vendor master.** Half the invoices sit under the other record. **Run the duplicate-vendor check first.**

**Different cutoff dates.** A window of legitimate difference in both directions. Establish both dates and treat the gap as known, not as exceptions — **but list each ledger item inside the window individually**, per Step 1; a lump hides a missing invoice.

**The statement is an open-item list; your ledger is a balance-forward.** Or the reverse. **The two cannot be compared line for line** until one is converted. Establish which each is before matching; for a balance-forward statement, use the opening-balance roll-forward in Step 2.

**A statement showing only overdue items.** Some suppliers issue chasing statements rather than full ones. **Reconciling to it will show every current invoice as unmatched** — which is meaningless. Confirm the statement's scope.

**The supplier's error.** An invoice on the statement that was genuinely never issued to you, or was settled and not applied on their side. **The reconciliation is two-way**, and pushing back is legitimate — `[manual]`.

**Payments made to an old bank account.** A payment you made and they did not receive. **Serious**, and it connects to vendor bank-change detection: if the details were changed fraudulently, the supplier's statement is the thing that reveals it — **which is another reason the reconciliation matters.**

**Foreign currency statements.** The supplier states in their currency; your ledger may hold both. **Match on document and quantity of currency, not on the converted amount** — the converted figures will differ by the rate used and by revaluation; the revaluation itself is an FX revaluation task.

**Rebates and volume credits.** Frequently agreed commercially and not invoiced or credited for months. **They may appear on neither side** and are a completeness question of their own. `[manual]` — ask.

**Consignment or self-billed arrangements.** Where you raise the document rather than the supplier, the statement may be blank or structured differently. **Confirm the arrangement** before treating the absence of invoices as a finding.

**A statement that has never been requested.** The most consequential edge case, and the reason Step 0 exists: **for a supplier whose statement has never been reconciled, the reconciliation is not routine maintenance — it is a first-time substantive test**, and the exceptions may be years old.

---
