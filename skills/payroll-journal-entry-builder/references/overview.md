<!-- payroll-journal-entry-builder · overview.md · read for: background — what the skill builds and why, the personal-data rule and why Mosofin only proposes; read when a user asks why. Edit here, not in SKILL.md. -->

# Payroll Journal Entry Builder (Mosofin)

Converts a **payroll register or report** into the general ledger journal entries that correctly record
**gross pay, withholdings, employer costs, net pay, and related accruals**. Ensures the entries **balance,
hit the right accounts, and split appropriately across departments and cost centers.**

**In plain words:** payroll costs the business more than the staff receive and more than it pays out on
payday. Gross pay is the cost; part of it goes to the employee and part to other people on their behalf; and
the employer owes more again on top. Recording it properly means keeping those three things apart.

This skill is **jurisdiction-agnostic** — **withholding and contribution types depend on the jurisdiction;
the skill maps whatever the payroll register contains.**

It is **workspace-scoped**: the chart of accounts, the department structure, the prior runs and the
validation evidence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart rather than accepting any mapping. That is a narrowing, stated rather than implied.

## Payroll data is personal

**Everything in a payroll register concerns identifiable people.** The rule from
`payroll-clearing-reconciliation` applies here in full:

- **Build and present entries at account and department level**, not by employee. **The journal is a total;
  the register is the detail, and the detail stays in the payroll system.**
- **Never itemise individual pay, deductions or garnishments** in a workpaper or a message.
- **Never persist any individual's payroll data.** See Step 9.

## Mosofin proposes; it never posts

**Like `journal-entry-builder`, this skill produces a proposal.** **Mosofin is read-only and cannot post a
payroll journal.** What it can do is make the proposal correct before a person posts it:

1. **Build against the real chart.** **[auto]**: the accounts exist, the names match, **no invented account
   numbers** — the original's own standard, now enforceable rather than aspirational.
2. **Validate the identities.** **[auto]**: Step 7's checks are arithmetic, and **two of them catch the
   error the edge cases call "the single most common"** — see below.
3. **Compare the run to prior runs.** **[auto]**, and this is an addition the original does not have.
   **Payroll is the most stable recurring cost most businesses have**, so **a run that differs materially
   from the last one without a headcount change is worth a question before it posts**, not after.
4. **Check the accrual actually reversed.** **[auto]** in the following period — the edge case the original
   flags as causing double-counting.

**The register itself is `[manual]`** unless a payroll platform is connected — the same position as
`payroll-clearing-reconciliation`. **Check at Gate 1.**

**This skill feeds two others**: the entries built here are what `payroll-clearing-reconciliation`
subsequently reconciles, and the liabilities created are what the payroll tax filings remit. **Build them so
those skills can use them** — which mostly means using the account map consistently.

---
