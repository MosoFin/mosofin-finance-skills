<!-- payroll-clearing-reconciliation · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-state / multi-province payroll**: **each jurisdiction has its own withholding remittances. Reconcile
by jurisdiction, then aggregate.**

**Multi-currency payroll**: **reconcile in functional currency; track FX gain / loss on the period's payroll
cycle.** The translation itself is an FX revaluation task.

**Stock-based compensation accruals**: an equity compensation accounting matter. **The reconciliation for
SBC-related accounts is separate from cash payroll.**

**Severance and termination payments**: **often paid through separate channels; ensure they're in the
payroll register and on the reconciliation.** *Mosofin note*: **a payment to a former employee outside the
normal cycle is readable**, and it is a common omission.

**Year-end accruals** — vacation, sick leave: **non-cash but liability-impacting. The vacation accrual
account ties to the entity's vacation policy and employee balance reports.** **The balance report is
`[manual]`.**

**Loans to employees**: **tracked as Due from Employee, not as a payroll item, but often coordinated with
payroll for repayment.** See `expense-report-processor`, where the same account appears.

**Garnishments**: **third-party recipient; reconcile to court orders / wage attachment notices.**
**Sensitive — report totals and counts, never individual detail.**

**Withholding tax remittance frequency varies by jurisdiction**: **monthly, semi-weekly, weekly, or
quarterly. The expected balance pattern follows the remittance cadence.** *Mosofin note*: **which is why the
cadence is a required input** — without it the behaviour test has no benchmark.

**Mid-year payroll-system change**: **YTD figures must transfer correctly. Reconcile pre- and
post-transition balances.** *Mosofin note*: **a discontinuity in the account's movement pattern is readable**
and marks the transition date.

**Reversed bonus accrual**: **a year-end bonus accrual later cancelled or modified — track the reversal.**

**Health insurance / benefit invoices in arrears**: **provider may invoice for the prior month's coverage.
Accrue the current month's expense and reconcile against the invoice when received.** *Mosofin note*: **the
saw-tooth pattern this creates is readable**, and it should not be mistaken for a break.

**Direct deposit reversals**: **an employee account closed, deposit returns. Track the return and the
re-issuance.** **The returned amount is owed to the employee** — see escheatment.

**A clearing account that never reaches nil** — *Mosofin-specific, and the headline finding*. **The minimum
balance over twelve periods is a permanent residual** wearing a payroll liability's name.

**A withholding account that only grows** — *Mosofin-specific*. Remittances are not happening, or not all of
them. **A serious finding**, since the money belongs to a tax authority.

**Unclaimed pay written off to income** — *Mosofin-specific compliance point*. **Frequently not permitted.**
It belongs to the employee, then to the state.

**The same small write-off proposed every period** — *Mosofin-specific*. **A process fault, not an immaterial
residual.** Writing it off again treats the symptom.

**The expected balance derived from the same postings as the actual** — *Mosofin-specific*. **A nil
difference then proves only that arithmetic works.** State the basis used.

**Recorded disbursements presented as bank-verified** — *Mosofin-specific*. Different assurances.

**A group clearing balance netting to nil** — *Mosofin-specific*. One entity owing and another over-remitted
cancel out. **Reconcile per entity.**

**A payment by one entity for another's payroll** — *Mosofin-specific*. An intercompany balance, not a
payroll reconciling item.

**A result comes back with `mock: true`** — *Mosofin-specific*. **These are amounts owed to people and to tax
authorities.**

**A stored balance or reconciling item is reused** — *Mosofin-specific*. All state. Persist the account map
and the cadences.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's cadence or escheatment position to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
