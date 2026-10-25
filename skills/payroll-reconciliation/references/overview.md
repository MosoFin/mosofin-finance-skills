<!-- payroll-reconciliation · overview.md · read for: background — what the skill reconciles and why, the personal-data rule, the four sources and the wage-base limit; read when a user asks why. Edit here, not in SKILL.md. -->

# Payroll Reconciliation (Mosofin)

Reconciles payroll across its **sources of truth** — the **payroll register**, the **general ledger**, the
**bank**, and the **tax and benefit remittances** — to confirm payroll is **recorded completely and
accurately and that all liabilities are settled**. **Catches mispostings, unremitted liabilities, and
register-to-GL gaps before they become filing or audit problems.**

**In plain words:** four systems should agree about what payroll cost and where the money went — the payroll
software, the accounts, the bank, and whatever was filed with the tax authority. When they do not, someone
has been paid the wrong amount, a liability has not been settled, or a filing will be wrong.

This skill is **jurisdiction-agnostic** — it reconciles whatever withholding and contribution types the
register contains.

It is **workspace-scoped**: the GL side of every tie-out, the liability movements and the recorded
disbursements come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**This is the umbrella payroll reconciliation.** `payroll-clearing-reconciliation` covers the clearing and
liability accounts in depth; **this one spans register ↔ GL ↔ bank ↔ filings.** Where they overlap, they
agree, and the detail belongs there.

## Payroll data is personal

**The rule from the other payroll skills applies in full**: **reconcile at account and total level, never
employee by employee.** **Individual pay, deductions and garnishments do not appear in this workpaper**;
where a reconciling item concerns one person, **refer to it by reference number.** **Never persist any
individual's payroll data.**

## Four sources, and the workspace owns one of them

| Source | Verdict |
|---|---|
| **The general ledger** — every payroll account and movement | **`[auto]`**, entirely |
| **The payroll register** — gross, withholdings, employer costs, net, **and the taxable wage bases** | **`[auto]` if a payroll platform is connected; `[manual]` otherwise** |
| **The bank** — what actually left the account | **`[manual]`** for the statement; **`[auto]`** for the recorded disbursement |
| **The filings** — what was reported to the authority | **`[manual]`** — the filings themselves are payroll tax filing work |

**So this is a four-way reconciliation in which the workspace owns one corner exactly and contributes to
two others.** That is worth stating, because **a "reconciliation" performed against only the corner you can
read is not one.**

**Three things the GL side contributes that are worth having on their own:**

1. **Manual adjustments to payroll accounts.** **[auto]**, and the edge cases name them as a cause of the
   register-to-GL break. **A journal entry to a payroll account with no payroll run behind it** is readable,
   and it is usually the explanation.
2. **Negative and anomalous liability balances.** **[auto]**, trivially. **A negative payroll liability is
   always wrong** — over-remittance or a posting error — and it is one query.
3. **The liability roll-forward's GL anchors.** **[auto]** at both ends, so **the roll-forward has to
   land**, and any difference is real.

**And the honest limit, which is the most important sentence in this file:**

> **The general ledger does not hold taxable wage bases.** **Step 5 reconciles each tax to its own base —
> gross, less pre-tax deductions, subject to caps — and none of that structure exists in the accounts.**
> The GL has one gross figure and one tax figure per liability.
>
> **So Step 5 is `[manual]` and cannot be approximated.** **A naive gross × rate check will mismatch for
> every employee who crossed a ceiling or made a pre-tax contribution** — which is exactly the error the
> original warns against. **Where the register is unavailable, report Step 5 as not performed** rather than
> substituting the gross comparison.

**Mosofin is read-only.** It cannot post a correction, remit a liability or amend a filing. Every correction
below is a *proposal*.

---
