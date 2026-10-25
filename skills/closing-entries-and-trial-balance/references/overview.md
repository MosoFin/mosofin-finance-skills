<!-- closing-entries-and-trial-balance · overview.md · read for: background — what closing does, and why the double-close test exists; read when a user asks why. Edit here, not in SKILL.md. -->

# Closing Entries and Trial Balance (Mosofin)

Prepares the formal **closing entries** at fiscal year-end — closing revenue, expense, and dividend
/ distribution accounts to **retained earnings** — and produces or audits the **trial balance**.

**In plain words:** at the end of a financial year the profit and loss accounts have to be emptied
back to zero so next year starts fresh, and the year's profit gets rolled into the owners' stake in
the business. The balance sheet accounts carry on as they are. This skill works out those entries,
proves the books still balance afterwards, and checks the new year opens correctly.

This skill is **chart-of-accounts-agnostic**. It applies the standard closing procedure for
accrual-basis entities.

It is **not** system-agnostic. It is **workspace-scoped**: the trial balance, the account types, the
prior-year equity and the year's activity all come from tool calls against a company file connected
to your Mosofin workspace in this conversation, or from something you supplied by hand and that is
labelled as such.

**Two things a connected workspace changes here.**

1. **Nearly the whole procedure is `[auto]`.** The trial balance, every account's *type* (which is
   what decides temporary versus permanent), net income, opening retained earnings, dividends
   declared, and whether the adjusting entries have actually posted — all readable. This is one of
   the most fully automatable skills in the pack.
2. **The "don't double-close" hazard becomes testable.** The original's most practically damaging
   edge case is that *"some systems automatically close P&L to RE when the fiscal year is advanced;
   the closing entry may not need explicit posting."* Post an explicit closing entry on top of an
   automatic one and retained earnings is wrong by the whole year's profit. **In a connected
   workspace you can check**: read the trial balance at the first day of the new fiscal year and see
   whether the P&L accounts are already zero, and search for an explicit closing journal. Do this
   **before** proposing anything.

**Mosofin is read-only.** It cannot post a closing entry, and — importantly for Step 9 — **it cannot
lock a period**. Every entry below is a *proposal*, and locking is a human action in the accounting
system.

---
