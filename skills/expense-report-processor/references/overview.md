<!-- expense-report-processor · overview.md · read for: background at any Stage, or when a user asks why. Edit here, not in SKILL.md. -->

# Expense Report Processor (Mosofin)

Reviews employee expense reports for **policy compliance**, codes them to **GL accounts**, flags exceptions,
and produces a reimbursement-ready summary plus posting instructions. Designed for AP teams processing
**T&E** (travel and entertainment) and out-of-pocket reimbursements anywhere in the world.

**In plain words:** staff spend their own money, or the company card, and want it back or accounted for.
The job is to check each line against the rules, put it in the right account, catch what should not be
claimed, and work out what the employee is actually owed.

This skill is **jurisdiction-agnostic**. **It does NOT bake in any country's mileage rate, per-diem table,
receipt thresholds, deductibility rules, or gift caps.** All such values come from the user's policy or the
user's stated jurisdiction's current rules. If the user does not provide them, **ask — never guess
jurisdiction-specific numbers.**

It is **workspace-scoped**: the chart of accounts, the employee list, the already-posted transactions and
the balances come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense.** The original had to work
without a COA and fall back to placeholders. **Here the real chart of accounts is available**, so coding is
to real accounts — and that is a change in what the skill claims, stated openly rather than left implied.

## What the workspace changes about this skill

The original is unusually honest about what it can and cannot do without each input. **Four of those inputs
stop being asks in a Mosofin workspace**, so the honesty table is rewritten rather than repeated:

| Original input | Original fallback | In a Mosofin workspace |
|---|---|---|
| **Chart of accounts** | "codes to category names only, labeled **PLACEHOLDER — REMAP REQUIRED**" | **`[auto]`.** The real COA is one read. **No placeholders.** |
| **Employee details** | Recommended; asked for | **`[auto]`.** Names, IDs, departments where set up. |
| **Functional currency** | "Default: from data" | **`[auto]`** from the company profile. |
| **Tax codes / recoverability setup** | Needed jurisdiction input | **`[gated]`.** The tax codes the entity actually uses are readable; **the rules governing them are still `[manual]`.** |

**And it adds a check the original could not perform at all:**

**The duplicate test against what is already posted.** The original's duplicate detection compares the
report against itself — same vendor, amount and date twice. **The workspace lets you compare the report
against the books.** Corporate card transactions are already in the ledger. **An out-of-pocket claim for
something the company card already paid is the classic double reimbursement**, and here it is a query rather
than a hope.

Two more that follow from the same access:

- **Historical coding.** How this entity has coded airfare, or client meals, or that specific merchant, in
  the past. **A grounded suggestion beats a generic mapping** — and it is what the reviewer would have
  checked anyway.
- **The clearing and payable balances.** Corporate Card Clearing should clear; Employee Reimbursement
  Payable should reflect what is genuinely owed. **Residual balances in either are unmatched activity**,
  and they are readable.

**What the workspace still cannot give you:**

- **The policy.** Always `[manual]`. Without it, policy validation does not run — that limit is unchanged.
- **The receipts.** Receipt *images* are not on this surface. The report's receipt-attached flag is
  evidence about the T&E tool, not about the receipt.
- **Mileage rates, per-diem tables, deductibility rules, gift caps.** All `[manual]`, all jurisdiction- and
  policy-specific.
- **The submitted report itself**, when it lives in Concur or Expensify rather than in the accounting
  system.

**Mosofin is read-only.** It cannot approve a claim, reject a line, pay a reimbursement or post an entry.
Everything below is a *proposal*.

---
