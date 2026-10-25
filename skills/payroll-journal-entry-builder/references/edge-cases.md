<!-- payroll-journal-entry-builder · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multiple pay frequencies**: **weekly, bi-weekly, monthly runs each need entries; period-end accruals
differ by frequency. Handle each run.** *Mosofin note*: **the accrual requirement per period end is date
arithmetic** and can be scheduled once the calendar is stored.

**Bonus / commission runs**: **often have different, sometimes higher, withholding rates and may be separate
runs. Book per the register.** *Mosofin note*: **these will flag in the run comparison** — correctly, and
they should be explained rather than suppressed.

**Benefits-in-kind / non-cash compensation**: **taxable non-cash benefits increase the expense and the
taxable / withholding base without a cash net-pay effect. Record per the register.**

**Employer vs. employee split**: **the single most common error is mixing employer and employee
contributions. Employee contributions reduce net pay — already in gross; employer contributions are
additional expense. Keep them separate.** *Mosofin note*: **the gross = net + withholdings identity catches
it**, and keeping the two entries separate makes it visible.

**Garnishments and third-party deductions**: **create a payable to the third party — court, agency; clear
when remitted. Don't net into tax accounts.** **Sensitive; report at account level.**

**Capitalized labor**: **labor on self-constructed assets or qualifying software development is capitalized,
not expensed. Route to the asset account; flag for the FA register**
(`fixed-asset-register-and-depreciation`) **or intangibles** (an intangibles amortization review).

**Payroll clearing account**: **when used, the JE credits clearing and a separate bank entry clears it. The
clearing account should reconcile to zero** (`payroll-clearing-reconciliation`).

**Accrual reversal**: **a period-end accrual must reverse next period to avoid double-counting when the
actual payroll is booked. Use reversing entries.** *Mosofin note*: **whether the last one reversed is
`[auto]` to check** — and it is the check that prevents the double-count.

**Multi-currency / multi-entity payroll**: **book each in the right entity and currency; intercompany
recharges of shared employees follow an intercompany reconciliation.**

**Corrections / retro pay**: **prior-period adjustments and retroactive pay create catch-up entries; book in
the current period with a clear memo.**

**Third-party payroll provider lump-sum debit**: **reconcile the single bank debit to the sum of net pay +
taxes + provider fee; book the components, not just the lump sum.** *Mosofin note*: **the lump sum is
`[auto]`; its composition is `[manual]`** — and booking the lump sum as one expense loses every liability
this skill exists to create.

**An account in the entry does not exist in the chart** — *Mosofin-specific*. **A hard stop.** The import
would fail, or create the account.

**Employer and employee liabilities share one account** — *Mosofin-specific*. **State the limitation**;
`payroll-clearing-reconciliation` will not be able to separate them either.

**A register component with no mapped account** — *Mosofin-specific*. Resolve before building; it is usually
a new deduction type or a new jurisdiction.

**A payroll account receiving nothing this run** — *Mosofin-specific*. Dormant, or a liability the entity
has started incurring and not mapped.

**This run differs materially from the last** — *Mosofin-specific, and the point of the comparison*. A bonus
run, a headcount change, a rate change, or an error. **Ask before posting**, not after.

**The prior accrual never reversed** — *Mosofin-specific*. **This run will double-count.** Check first.

**An accrual covering gross only** — *Mosofin-specific*. **Understates the liability by the employer's
contributions**, which can be a fifth again.

**A department's share moves sharply** — *Mosofin-specific*. A real change, or an allocation error.

**A group payroll booked as one journal** — *Mosofin-specific*. **The liabilities are owed by different
legal entities.** One journal per entity.

**A result comes back with `mock: true`** — *Mosofin-specific*. An entry validated against fixture accounts
would be imported and posted.

**A stored template applied to another entity** — *Mosofin-specific*. Account numbers are chart-specific and
jurisdiction-specific.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
