<!-- recurring-transaction-builder · overview.md · read for: background — why a read-only surface designs, validates and audits but never creates the template, the near-substitutes, the double-load risk, and related skills; read when a user asks why. Edit here, not in SKILL.md. -->

# Recurring Transaction Builder — Mosofin Seed

Builds recurring transaction schedules — journal entries, bills or invoices that repeat on a defined cadence — and generates the full set of future-dated occurrences.

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## Read this before anything else

The original describes its output as occurrences "**ready to post**", to be "**batch-loaded, reviewed, or auto-posted by the accounting system.**"

**Mosofin cannot do the last part of that sentence. The gateway is read-only.** It cannot create a recurring template, cannot post an entry, cannot schedule anything, and cannot cause a payment or an invoice to happen at a future date. There is no write path and there is not going to be one in this skill.

That is a blunt statement and it needs to come first, because this is the one skill in the pack whose *stated purpose* is to make something happen inside an accounting system. Every other skill produces analysis, and analysis is what a read-only surface is for. This one produces automation, and automation is a write.

So the honest position is:

> **Mosofin designs and validates the schedule. A human creates the template in the accounting system. Mosofin then audits whether it actually ran.**

That division is not a consolation prize. Each of the three parts is real work, and the third one — auditing whether the automation ran — is a job nobody currently does, and it is the reason recurring entries fail silently for months. `prepaid-amortization-schedule` already relies on this skill for exactly that, and the two are consistent: Mosofin drafts the entry, the user automates it, Mosofin checks it every period thereafter.

### The three things this skill actually does

**1. Computation, which never needed the accounting system.**

Generating occurrence dates, rolling a 31st into a 30-day month, applying an escalation at an anniversary, substituting `{month}` into a memo — **none of this touches a ledger.** It is arithmetic and calendar logic. It was always automatable and the gateway is irrelevant to it.

This gives the skill an unusual verdict profile. In most skills, `[auto]` means "readable from the ledger." Here, a large block of `[auto]` means "computable from what the user told us." Both are genuinely automatic; they just have different failure modes, and the coverage sheet distinguishes them.

**2. Validation against the live ledger, which is new.**

The original builds a schedule against accounts, vendors and tax codes that the user names. **It has no way to check that any of them exist.** A connected workspace does, and this turns out to matter more than it sounds — see Step 2b. A recurring template pointed at an account that was renamed last quarter will fail, or post to suspense, **every month, forever, quietly.**

**3. Discovery and audit, which are the inverse of the original's job.**

The original waits to be told what to automate. A live ledger can be asked **what is already being done by hand every month that should not be** — and separately, **whether the templates that do exist are still running.** Both are one query. Neither was available before.

### A near-substitute is not a substitute

**A schedule is not a template.** A spreadsheet of twenty-four future-dated rows is a *plan*. The thing that makes a payment happen is an object inside the accounting system with a next-run date on it. Handing someone a well-formatted schedule and letting them come away believing automation now exists is this skill's characteristic failure — and it is a quiet one, discovered in month two when nothing happened.

**"Ready to post" is not "posted."** Every occurrence carries a status, and the status starts at Pending.

**The ledger's history of a charge is not the contract behind it.** Fourteen months of identical rent tells you what was paid. It does not tell you the lease has a step-up in month fifteen. Extrapolating a schedule from posting history is a hypothesis about the future, and it must be checked against the agreement. For rent, that agreement is the lease.

### And one risk that is specific to producing a loadable file

Because Mosofin cannot load the occurrences, the user does — and a file containing twenty-four future-dated rent bills is a file that can be loaded **twice**. Duplicate-posting a year of rent is an expensive, embarrassing, and entirely preventable error.

So the Status column the original already includes is not decorative. It is the control. Every occurrence starts **Pending**, the file states in its header that nothing in it has been posted, and the schedule is designed to be reconciled back to the ledger after loading rather than trusted. Step 6 sets this out.

---

## Related skills

| Skill | Relationship |
|---|---|
| `journal-entry-builder` | Formats and validates the JE template that every recurring JE occurrence instantiates. |
| `prepaid-amortization-schedule` | Generates exactly this shape of recurring entry — and relies on Step 5b to confirm it kept running. |
| `fixed-asset-register-and-depreciation` | The other large source of recurring journal entries. |
| `journal-entry-review` | The reversal check in Sheet 4, and unreversed accruals generally. |
| `month-end-close-checklist` | Where a recurring entry that failed to run shows up as a missing close task. |
| `vendor-statement-reconciliation` | What happens when a near-miss name creates a second vendor record. |

Skills for revenue recognition, FX revaluation, consolidation and eliminations, related-party disclosures, lease accounting and real estate accounting are queued for this library and will be linked here when they ship.
