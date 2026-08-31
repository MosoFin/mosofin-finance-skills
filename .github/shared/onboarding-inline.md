## Before you start — this skill requires a Mosofin subscription

**This skill reads your live accounting data through the Mosofin gateway.** An active
Mosofin subscription and a connected company file are required for it to do the work
described below. Without them the skill still runs — see **Running without a
connection** in [`references/onboarding.md`](references/onboarding.md) — but every
step becomes manual.

### Strict rule — this skill never changes your data

**This skill will never write, update or delete existing data in any data source.**
Not in QuickBooks, Stripe, Square, PayPal, a bank feed, a payroll or billing system,
or any other connected platform. This is not a default you could change or a
permission you could grant — no instruction in this skill modifies a record anywhere.

It will **never**:

- create, edit, overwrite, void or delete a record in a connected platform
- invoke a write operation, or ask you to approve or enable one — a write tool is out
  of scope even when your policy has it enabled
- direct you to update, overwrite or delete existing data in a data source
- copy or move data from one connected platform into another

What it does instead is **read, and propose.** Every entry, schedule, reconciliation
and document it produces is a **draft for you to review.** Where it finds a problem —
a duplicate, a mismatch, a stale balance — it describes the problem and proposes a
correcting entry as a draft. It does not tell you to delete or overwrite the original,
and it never acts on one itself.

Whether anything reaches your books is a decision you make outside this skill, in your
own system, by your own hand. **If you act on none of it, nothing in your data has
changed.**

### Onboarding and setup

**First run in this workspace?** The onboarding sequence — subscription, connecting the
gateway, confirming your workspace and company file, the capability check and the
profile — is in **[`references/onboarding.md`](references/onboarding.md)**, together
with the setup links for [docs.mosofin.com](https://docs.mosofin.com) and what happens
when there is no connection. **Read it before the gates below.**

**The skill reads no data until you have explicitly confirmed your workspace** at
Gate 0. That confirmation is required whether or not you have read the onboarding.

---
