<!-- recurring-transaction-builder · output.md · read for: Stage 5 — the output quality standards and the coverage and provenance sheet; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All six preserved.

- **Every occurrence has a date, amount, memo and period covered.** `[auto: computed]`
- **Total amount = occurrences × amount + escalations (verified).** `[auto: computed]`
- **No silent assumption about holiday calendars, indexes or cadences.** `[manual]` inputs, asked for once and persisted. **This is the original's own version of "never hardcode," and it governs this file too.**
- **Memos are unique per occurrence**, with variables substituted. `[auto: computed]`
- **File naming consistent.** `[auto: computed]`
- **Reversal schedules included for accrual-type recurrences.** `[auto: computed]` to build; **`[auto: read]` to verify prior reversals actually posted.**

**Four Mosofin additions:**

- **Nothing is presented as posted, created or scheduled.** Every occurrence is Pending and the file says so in its header.
- **Every account, counterparty and tax code is validated against the live chart** — or the file states that it was not.
- **The duplicate check runs before the schedule is built**, not after it is loaded.
- **Computed and read are distinguished** throughout, so a reader can tell which parts of the output survived contact with the client's actual books.

---

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`) — **the chart this schedule was validated against**
- Date and time of the reads
- **Validation status**, in bold: validated, or **NOT VALIDATED**
- **Posting status**, in bold: **nothing in this file has been posted**
- **Fixture flag** — any `mock: true`? Note that validation passes by construction on fixture data.

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict. Note divergences from this file's defaults.

**Section C — Steps by verdict, with the computed/read split**
Every step, marked `[auto: computed]`, `[auto: read]`, `[gated]` or `[manual]`. **A reader should be able to see at a glance which parts of this output would have been identical with no workspace connected at all** — because that is exactly the question "was this validated?" is asking.

**Section D — What was not done, and why**
For this skill, always including:

- **Creating the recurring template in the accounting system.** **The gateway is read-only. A human does this.**
- **Posting any occurrence.**
- The holiday calendar, where not supplied — **not in the accounting system**
- The CPI index and inflation assumption — **a forecast, and jurisdiction-specific**
- Escalation terms — **in the contract, not the ledger**
- Stop and pause conditions — **in the contract**
- The pro-ration decision on partial first and last periods
- Whether an automation candidate from Step 2d *should* be automated

**Section E — Unknowns carried forward**
Validation failures not yet resolved. Possible duplicates awaiting confirmation. Automation candidates not yet reviewed. Recurring templates that did not run in a period. Accruals with no matching reversal.

**Section F — Parameters used**
Cadence, day-of-period rule, roll direction, holiday calendar, escalation rule and index, pro-ration convention, horizon for open-ended schedules. **Anyone re-running this needs every one of them to reproduce the same schedule** — and a schedule that cannot be reproduced cannot be reconciled.

---
