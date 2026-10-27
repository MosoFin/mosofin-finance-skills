<!-- balance-sheet-reconciliations · overview.md · read for: background — what a reconciliation proves, and why the support side is often manual; read when a user asks why. Edit here, not in SKILL.md. -->

# Balance Sheet Reconciliations (Mosofin)

Reconciles **general ledger (GL)** balance sheet account balances to supporting **subledgers**,
schedules, or external documents. Designed for the controllership function — the standard
monthly / quarterly procedure to support the trial balance.

**In plain words:** the balance sheet shows one number per account. Behind most of those numbers
there should be a detailed list that adds up to exactly that number — the customers who owe you,
the bills you haven't paid, the assets you own. **Reconciling** is proving the two agree, and
explaining every difference when they don't. It is the routine that catches errors before they
become audit findings.

This skill is **chart-of-accounts-agnostic** — it builds the same disciplined reconciliation
format for any account type.

It is **not** system-agnostic. It is **workspace-scoped**: every balance and account name comes
from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**The structural shape of this skill in a Mosofin workspace, stated up front.** A reconciliation
has two sides, and they behave very differently here:

- **The GL side is almost always `[auto]`.** The trial balance, the account balance, and the
  transactions behind it are all readable.
- **The supporting side is `[auto]` only where the subledger itself lives in the connected
  system.** In practice that means **accounts receivable, accounts payable, and any
  suspense / clearing account** — where the "subledger" is just a different view of the same
  books. An integrated subledger tie is reported as **"agrees to subledger (same system)"** and is
  not counted as independent support: A/R or A/P is **reconciled** only with the aging review plus
  at least one independent test (subsequent receipts or payments, vendor statements, customer
  confirmations). A suspense / clearing account is tested differently — its balance should be zero
  and every line explained. For prepaid schedules, fixed asset registers, lease schedules, payroll
  registers, loan amortization schedules, tax filings and bank statements, **the supporting side is outside the
  connected books and is `[manual]`**.

So expect a workpaper where the GL column is complete and the support column is mixed. Say which
is which per account. **A reconciliation where both sides came from the same source is not a
reconciliation** — it is a total agreeing with itself, and presenting it as a tie-out asserts
assurance that was never obtained.

**One genuine multi-entity advantage:** where **both** sides of an intercompany balance are
connected company files in the same workspace, the counterparty's mirror balance *is* readable.
That reconciliation becomes `[auto]` on both sides — one of the few where it does.

**Mosofin is read-only.** It cannot post a correcting entry, clear a suspense account, or sign
off a reconciliation. Every correction below is a *proposal* for a human.

---
