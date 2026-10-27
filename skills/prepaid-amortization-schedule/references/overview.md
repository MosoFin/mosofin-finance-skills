<!-- prepaid-amortization-schedule · overview.md · read for: background — why the ledger holds the balance but not the schedule; read when a user asks why. Edit here, not in SKILL.md. -->

# Prepaid Amortization Schedule — Mosofin Seed

Builds and maintains schedules for expenses paid in advance (money you have already handed over for something you have not yet received), amortizes them across the period of benefit, produces the monthly entry, and reconciles the running balance to the general ledger.

This is a **seed skill**. It is built to be run against a live Mosofin workspace, and it is built to be *rewritten* the first time it is run there — because the shape of a client's prepaid account is not knowable in advance.

---

## What this skill is, and what it is not

The original version of this skill was **system-agnostic** and **chart-of-accounts-agnostic**. That claim is now only half true, and it is more honest to say so plainly than to keep the sentence.

The *accounting* is still framework-neutral: straight-line allocation over a coverage period is straight-line allocation everywhere. What is no longer neutral is the **evidence**. This version reads a specific, real, connected set of books through the Mosofin gateway. It knows which accounts exist, what the prepaid balance actually is, and what has actually been posted to it. That is a large gain in usefulness and a real loss in portability. Both are stated here rather than hidden.

### The one thing to understand before anything else

**The general ledger holds the prepaid balance. It does not hold the schedule.**

This distinction runs through the whole skill, so it is worth being slow about.

The ledger can tell you that Prepaid Expenses stands at 84,000. It cannot tell you:

- what the 84,000 is *for*
- which months of coverage it buys
- when that coverage ends
- whether any of it expired eight months ago and simply never came off
- whether it is even prepaid at all, rather than a refundable deposit somebody coded there

Those facts live on **contracts, policy schedules, and invoices** — documents outside the accounting system. A balance that agrees with itself is not evidence of anything. A prepaid account will reconcile to its own trial balance every single time, because it is the same number twice.

So: **the schedule is an input, not an output of the ledger.** The workspace supplies the balance and the movement. The user supplies the coverage dates. Neither half is a schedule on its own.

### And the inverse, which is where this skill earns its keep

The ledger cannot build the schedule. But it is unusually good at telling you the schedule is **wrong or missing**, and it can do that in a handful of queries:

- A prepaid account that only ever **increases** is one where the amortization entries were never posted.
- A twelve-month insurance premium **expensed in a single month** shows up as one large lonely debit in an expense account that is otherwise flat. That is an unrecorded prepaid, and lumpiness is its signature.
- A prepaid balance that **exceeds the last twelve months of additions**, in a book where everything is annual, is carrying residue from coverage that has already expired.
- An amortization credit that is **a different amount every month, in round numbers, posted by hand** is not a schedule being run. It is somebody guessing.

None of that requires the contracts. All of it is `[auto]`. That is the trade this skill makes: it gives up on generating the schedule and becomes very good at auditing it.

---

## Related skills

| Skill | Relationship |
|---|---|
| `month-end-close-checklist` | The parent process. Prepaid amortization is one line on it; run this skill for that line, not for the whole close. |
| `journal-entry-builder` | Formats and validates the proposed entries from Steps 6, 7 and 9. |
| `recurring-transaction-builder` | Where the monthly entry gets automated — by the user, in the accounting system. Mosofin drafts it and later verifies it ran. |
| `fixed-asset-register-and-depreciation` | Where miscoded equipment purchases belong. Step 0c flags them. |
| `bank-reconciliation` | Confirms the cash side of the original prepayment and of any refund. |
| `financial-statement-builder` | The current / non-current split for multi-year prepaids lands on the balance sheet there. |

Skills for revenue recognition (deferred revenue, the customer-side mirror of a prepaid), lease accounting, FX revaluation, intercompany reconciliation and notes to the financial statements are queued for this library and will be linked here when they ship.
