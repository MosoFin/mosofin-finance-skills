<!-- month-end-close-checklist · overview.md · read for: background at any Stage, or when a user asks why. Edit here, not in SKILL.md. -->

# Month-End Close Checklist (Mosofin)

Plans, orchestrates, and audits the **monthly close process**. Produces a comprehensive **task list with
owners, deadlines, dependencies, status**, and a **final tie-out** demonstrating books are ready for
reporting.

**In plain words:** closing the month means making sure everything that happened has been recorded, every
balance has been checked against something outside the ledger, the estimates have been updated, and the
numbers can be handed to someone who will make decisions with them — by a date, with names against each
piece.

This skill is **industry-aware** — it adjusts the task list to the entity's industry, size, and
complexity.

It is **workspace-scoped**: the scoping evidence, the task status and the final tie-out come from tool calls
against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## This is the orchestration hub — and three things the workspace changes

**Almost every task in this checklist hands off to another skill.** This one coordinates; the others do the
work. **Three things change when the coordinator can read the books.**

**1. The checklist scopes itself.** Step 2 asks you to customise: *"No inventory? Skip inventory steps. No
fixed assets to speak of? Streamline FA steps. Single entity, single currency? Skip consolidation and FX
revaluation."*

> **Every one of those questions is answerable from Gate 1 and the chart of accounts.** **[auto]**: no
> inventory account, no fixed asset account, one connected company file, one currency, no restricted-fund
> accounts. **A checklist that arrives already scoped to this entity is worth far more than a generic one**,
> and the scoping costs one read.

**2. Many tasks are self-verifying.** The tedious part of running a close is chasing status — *has
depreciation been posted? did the accrual go in? is the FX revaluation done?*

> **Every task that produces a journal entry leaves evidence.** **[auto]**: **pre-populate the status
> column** for depreciation, amortisation, prepaid release, accruals, FX revaluation, deferred revenue
> release and lease entries. **"Posted 2026-08-04, £14,208, JE-2608-011" is a status; "Complete" ticked by
> whoever remembered is not.**
>
> **Be precise about what this proves**: it shows **an entry exists**, not that it is **correct** or
> **complete**. The task owner still owns the task. **But knowing what has and has not been posted, at any
> moment during the close, is exactly the coordination this skill exists to provide.**

**3. The final tie-out is nearly all `[auto]`** — including **inter-period continuity**, which is the one
almost nobody checks by hand and the one that catches a reopened prior period.

**What the workspace cannot do:** **it cannot lock the books, post an entry, or mark a task complete.**
**Mosofin is read-only.** It observes evidence and reports it; **the close is run by people.**

---
