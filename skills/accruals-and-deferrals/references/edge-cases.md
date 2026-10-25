<!-- accruals-and-deferrals · edge-cases.md · read for: Stages 4–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Bonus accrual where payout is uncertain**: use management's best estimate of the probable
payout. Adjust as the year progresses. This is a judgment the ledger cannot supply — record
it as **[manual]** with the estimate's owner named.

**Vacation accrual policy variations**: some entities use "use it or lose it" (lower accrual);
others allow carry-forward. The vacation liability reflects the actual unused balance × pay
rate — so the policy has to be confirmed before the number means anything.

**Multi-currency accruals**: accrue in the functional currency at the period-end FX rate. The
reversal uses the same rate, or the current rate, per policy; the revaluation
itself is an FX revaluation task. If the connected books hold only one currency but the
underlying obligation is in another, that conversion is **[manual]**; say so.

**Bonus / commission with deferral or clawback features**: only the **vested** portion is a
current accrual; deferred portions accrue gradually as conditions are met. Clawback
contingencies are disclosed but typically do not reduce the accrual unless the clawback is
probable.

**Interest accrual on variable-rate debt**: use the rate in effect for the accrual period; if
the rate changed mid-period, weight it by days. The rate history is **[manual]** — the ledger
shows what was paid, not what the rate was.

**Tax on accruals**: payroll-related accruals (bonus, commission, vacation) typically include
the employer-side payroll tax accrual. Add a separate line to the JE rather than burying it
in the gross figure.

**Catch-up / true-up of prior period accruals**: when the actual amount comes in differently
from what was accrued, true it up in the current period. If the variance is material and
relates to a prior period, consider whether a **restatement** is needed.

**Reclass of deferred revenue between current and non-current**: at each period end, the
portion expected to be earned within twelve months is current; beyond that is non-current.

**Accruals that may turn out not to be owed**: e.g. an expected vendor service that never
happens. Reverse it without an expense — do not leave it sitting on the balance sheet.

**Stock-based comp expense**: accrued via the entity's vesting schedule — separate from this
skill; it is an equity compensation accounting task.

**Pension / OPEB accruals**: actuarially determined. This skill summarises the result but does
not compute the actuarial liability.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say which accruals are therefore unsupported. Surface any `reconnect_url`. Do not present a
schedule that looks complete.

**The transaction-level ledger tool is `disabled` in this workspace** — *Mosofin-specific*.
Do not substitute a summary balance: it gives the accrual account's total but not the items
inside it, and a roll-forward you cannot itemise is not a roll-forward. Mark those tasks
`[manual]`, name the tool, and ask for a ledger export.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate
the schedule's shape but cannot support a posted entry. Flag it at the top of the deliverable.

**The books are kept on a cash basis** — *Mosofin-specific and common in small workspaces*.
Accruals and deferrals are precisely the entries a cash-basis ledger does not carry, so the
opening balances may legitimately be zero. Say that explicitly rather than reporting "no
accruals found", and confirm with the user whether they are converting to accrual basis.

**The accrued-liability account cannot be identified in the chart of accounts** —
*Mosofin-specific*. Do not guess from an account name that merely looks plausible. Ask the
user to name the account, and record the answer as a preference in Step 9.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity, never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke the same
tool with `approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` rather than
`[auto]` in the coverage sheet.

---
