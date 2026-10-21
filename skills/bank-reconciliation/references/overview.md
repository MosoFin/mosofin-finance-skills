<!-- bank-reconciliation · overview.md · read for: background — what the skill does and the defining limitation; read when a user asks why. Edit here, not in SKILL.md. -->

# Bank Reconciliation (Mosofin)

Reconciles the cash balance per the **general ledger (GL)** to the **bank statement** balance for
a specified period, explains timing differences, and identifies errors requiring correction.

**In plain words:** your books say you have one amount of cash; the bank says another. Usually
both are right — cheques you wrote haven't been cashed yet, money you banked hasn't landed yet,
and the bank has charged fees you didn't know about. **Reconciling** is proving that the two
figures differ *only* for reasons you can name. Anything left over is an error, and finding it is
the point.

This skill supports single or multiple bank accounts.

It is **workspace-scoped**: every ledger balance, payment and deposit comes from a tool call
against a company file connected to your Mosofin workspace in this conversation, or from
something you supplied by hand and that is labelled as such.

## The defining limitation — read this before promising a reconciliation

A bank reconciliation has two sides. **Mosofin can read one of them.**

Mosofin connects the **accounting system**. It reads the GL cash balance, every payment, every
deposit and every transfer recorded in the books. It **cannot read a bank statement, a bank feed,
or a downloaded transaction file**, and no accounting datasource exposes one.

> **Without a bank statement, a bank reconciliation cannot be performed.** Not partially, not
> approximately. Comparing the books to the books is not a reconciliation — it is a total
> agreeing with itself. Never label such an output a bank reconciliation, and never report a
> cash balance as "reconciled" on that basis.

**What this skill genuinely does from a connected workspace, and it is worth doing:**

- Builds **the entire book side** of the bridge from live data — the GL ending balance and every
  transaction behind it.
- Produces the **candidate lists**: payments recorded but plausibly not yet cleared (potential
  outstanding cheques), deposits recorded near period end (potential deposits in transit).
- **Detects book-side errors without the statement** — duplicate entries, wrong-account postings,
  wrong dates, and transactions after the cutoff.
- **Flags stale items** against the escalation rules in Quality checks.
- Prepares a **reconciliation template with the book side complete**, so that when the statement
  arrives the remaining work is matching, not rebuilding.

Then it **asks for the statement** and says exactly what it could not conclude without it.

If a **banking or payments platform is a connected datasource** in this workspace, that changes
everything — check at Gate 1 before assuming the statement is unavailable.

**Mosofin is read-only.** It cannot post an adjusting entry, mark an item cleared, or sign off a
reconciliation. Every entry below is a *proposal* for a human.

---
