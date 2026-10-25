<!-- payroll-clearing-reconciliation · overview.md · read for: background — what the skill reconciles and why, the personal-data rule, and why the register is the missing half; read when a user asks why. Edit here, not in SKILL.md. -->

# Payroll Clearing Reconciliation (Mosofin)

Reconciles **payroll clearing / suspense / liability accounts** to ensure all payroll obligations have been
properly remitted and the control accounts close to expected balances. Designed for **periodic review of
payroll-related GL accounts**.

**In plain words:** when payroll runs, the business owes several different people money at once — the staff,
the tax authority, the pension provider, sometimes a court. Each of those obligations sits in its own
account until it is paid. This checks that every one of them was paid, and finds the ones that have been
sitting there since nobody quite knows when.

This skill is **jurisdiction-agnostic**.

It is **workspace-scoped**: the payroll account balances, their movements and their ageing come from tool
calls against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## Payroll data is personal — handle it accordingly

**Payroll records concern identifiable people and are among the most sensitive data an employer holds.**
**Garnishments and wage attachments are more sensitive still** — they reveal court judgments, child support
obligations and personal debts.

**Rules for this skill:**

- **Work at account level.** Every step below is an account-level question. **Reconcile the balance, not the
  people.**
- **Never itemise individual garnishments, individual pay, or individual deductions** in a workpaper, a
  summary or a message. **Report counts and totals.**
- **Never persist any individual's payroll detail.** See Step 10.
- **Where a reconciling item genuinely concerns one employee** — an unclaimed final payment, a returned
  deposit — **refer to it by reference number, not by name.**

## The shape: the register is the missing half — and the ageing is the finding

**The general ledger holds every payroll control account and every movement through it.** **The payroll
register does not live here** — the by-employee, by-component detail is in the payroll system, and **the
`accrued during the period` half of Step 2's formula comes from there.**

**So check at Gate 1 whether a payroll platform is connected.** If one is, both halves are readable and this
becomes a genuine two-sided reconciliation. **If not, the GL side is still fully readable — and three things
follow that are worth having on their own:**

1. **The stale-balance test is entirely `[auto]`, and it is where the real findings are.** ⭐ **Step 7's
   sixty-day threshold is ledger arithmetic.** **A payroll clearing account that never clears is the single
   most common finding in this area**, and it hides genuine obligations: **unclaimed pay, garnishments
   awaiting direction, disputed final settlements.** **Some of it is escheatable** — a legal obligation with
   penalties, not a housekeeping matter.
2. **The behaviour test.** **[auto]**: Step 2 says the expected balance follows the remittance cadence —
   **a monthly-remitted withholding account should carry roughly one month's withholdings and drop to near
   nil after each remittance.** **You can test whether the balance behaves that way without the register at
   all.** A withholding account that never drops, or that drops to a residual that grows, is a finding.
3. **Remittances are readable.** **[auto]**: payments out of the bank account, by payee and date, **give the
   remittance side of every roll-forward** even where the register is absent.

**What stays outside:** the payroll register, benefit provider statements, court orders behind garnishments,
the bank statement itself, and every remittance schedule set by a tax authority.

**Mosofin is read-only.** It cannot post a clearing entry, remit anything or write off a balance. Every
entry below is a *proposal*.

---
