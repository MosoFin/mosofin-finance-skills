<!-- payroll-reconciliation · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Pre-tax deductions changing the wage base**: **retirement and certain benefit deductions reduce some
taxable bases but not others. Reconcile each tax's base separately; a single "gross" comparison will
mismatch.**

**Wage base caps / ceilings**: **some contributions stop once an employee hits an annual ceiling. Mid-year
and year-end, employees who crossed the cap break a naive rate × gross check. Reconcile to the capped
base.** *Mosofin note*: **caps apply per employee**, so **no aggregate figure in the GL can reproduce
them.**

**Timing across period boundaries**: **a pay date or remittance date straddling the period end creates
expected differences between accrual, GL, and bank. Identify and carry them.**

**Multiple pay runs and off-cycle payments**: **bonuses, corrections, and final pays may be separate runs.
Include all runs in the register total.** *Mosofin note*: **a payroll journal outside the usual cadence is
readable**, and it is the prompt to ask whether a run was missed from the register total.

**Third-party payroll provider**: **the provider's reports are the register; reconcile the provider's
lump-sum bank debits to net pay + taxes + fees, and confirm the provider actually remitted the taxes — the
entity remains liable even if the provider fails to remit.** **The most important sentence in this list**:
**a provider's failure to remit is the employer's problem**, and the accounts will look perfectly settled
while the liability is unpaid. **Confirming remittance is `[manual]`, from the authority.**

**Year-end wage statement reconciliation**: **the sum of employee wage statements must equal the filed totals,
and agree to GL wages through a bridge** — accrual movement, capitalised labour, pre-tax deductions, imputed
income. Differences must be resolved before statements are issued to employees.**

**Capitalized labor**: **legitimately not in wage expense; ensure the register-to-GL bridge accounts for it
rather than flagging it as an error.** **[auto]** to detect — a payroll-dated debit to an asset account.

**Garnishments and third-party payables**: **confirm these were remitted to the correct third party and
cleared; stale balances indicate missed remittances.** **Report at account level.**

**Manual adjustments / journal corrections**: **prior manual entries to payroll accounts can break the
register-to-GL tie. Identify and explain them.** **[auto]**, and **usually the answer.**

**Negative or unusual liability balances**: **usually a posting error or over-remittance; investigate rather
than ignore.** **[auto]**, one query.

**Step 5 attempted without a register** — *Mosofin-specific*. **A gross-based check mismatches for every
affected employee**, and the mismatch looks like an error. **Report NOT PERFORMED.**

**"Taxable wages per the GL"** — *Mosofin-specific*. **The GL holds gross, not taxable.** Step 4's first
comparison needs the register.

**A nil difference where both sides came from the same postings** — *Mosofin-specific*. It proves arithmetic,
not agreement. **State the basis.**

**Recorded disbursements presented as bank-verified** — *Mosofin-specific*. Different assurances.

**Exceptions ordered by amount** — *Mosofin-specific*. **An overdue remittance is more urgent than a larger
timing difference.** Order by consequence.

**A group-level reconciliation** — *Mosofin-specific*. **Negative balances in one entity and positive in
another net away.** Run per entity.

**An employee who moved between group entities mid-year** — *Mosofin-specific*. **Caps may restart**, which
changes the wage base in both entities.

**A result comes back with `mock: true`** — *Mosofin-specific*. This reconciliation feeds filings and
employee wage statements.

**A stored wage base rule reused across a statutory year** — *Mosofin-specific*. **Caps and thresholds
change annually.** Store them with effective dates and re-confirm.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's due dates or wage bases to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the reconciliation as `[gated]` in the coverage sheet.

---
