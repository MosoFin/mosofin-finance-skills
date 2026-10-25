<!-- prepaid-amortization-schedule · output.md · read for: Stage 5 — the quality standards, the coverage sheet and the anti-patterns; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

The original's nine standards are preserved, each with the verdict that says who is responsible for meeting it.

- **Every prepaid item has full coverage dates, amount, and expense account.** `[auto]` for amount and account; `[manual]` for coverage dates. Where a date is unknown, it is **flagged as unknown, never inferred from the payment date.**
- **Monthly amortization x months = total prepaid (verified).** `[auto]`
- **Schedule sum reconciles to the GL balance every period.** `[auto]` for the GL side; `[manual]` for the schedule side. **Both legs must be present for this standard to be met** — a roll-forward that ties to itself does not satisfy it.
- **Cancellations and modifications logged with impact.** `[auto]` to detect and compute; `[manual]` to approve.
- **FX handling per policy.** `[auto]` to test that practice matches the stated policy; `[manual]` to state the policy.
- **Materiality threshold applied.** `[manual]` to set, `[auto]` to apply, and **recorded on the coverage sheet** so the next run uses the same one.
- **File naming consistent.** `[auto]`
- **Recurring JE handled via `recurring-transaction-builder` when appropriate.** `[manual]` to create — Mosofin cannot write. `[auto]` to verify it ran.
- **No unallocated prepaid at the end of the schedule's last period.** `[auto]` against the schedule; and `[auto]` against the ledger too, which is the stronger test — Step 0d asks whether the account is carrying expired coverage, and that question does not need the schedule to be asked.

**Two Mosofin additions:**

- **Every figure is attributed.** Ledger-read, user-supplied, or unknown. No mixing without labels.
- **Nothing is presented as posted.** Every entry in the pack is a proposal for a human to review and post. The gateway is read-only and the workpaper says so on the sheet that carries the entries.

---

## Coverage and Provenance sheet (mandatory)

Sheet 7 of every output. Not optional, not abbreviated when the run went well.

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`)
- Date and time of the reads
- Period covered by the schedule
- **Fixture flag** — was any response `mock: true`? If yes, in bold, with the caution from Gate 2 restated: a clean tie-out on fixture data proves the arithmetic and nothing else.

**Section B — Capability map as observed today**
For each tool this run needed: its name as returned by `get_datasource_tools`, its `effective_policy`, and the resulting verdict. Where an observed policy differed from the default in this file, note it — that difference is exactly what the evolved version of the skill should absorb.

**Section C — Steps by verdict**
Every step above, with its verdict **as it actually applied in this workspace**, not as defaulted here. Count them. A reader should be able to see at a glance how much of this run was automatic.

**Section D — What was not done, and why**
The `[manual]` list, with reasons. For this skill it will typically include:

- Coverage start and end dates for the items where they were unavailable — **not in the accounting system; from contracts and policy schedules**
- The materiality threshold, if the user did not state one
- The substance judgment on any deposit or related-party advance
- Impairment assessment for any vendor in difficulty
- Creation of the recurring template — **read-only gateway; the user posts and automates**
- Posting of every proposed entry

**Section E — Unknowns carried forward**
Items on the schedule with blank coverage dates. Prepaid candidates identified in Step 1 but not yet confirmed. Variances in Step 8 that were quantified but not explained. These are the opening work list for next period, and writing them down is the difference between a schedule that improves each month and one that is rebuilt from nothing each year.

**Section F — Parameters used**
Materiality threshold. Amortization convention (whole-month or daily). Prepaid accounts in scope. Tax treatment applied. Rounding convention. Anyone re-running this next period needs these to get the same answer, and "the same answer" is most of what a schedule is for.

---

## Anti-patterns

Specific to this skill, and each one has been seen.

- **Reporting the roll-forward as a reconciliation.** Legs 1 and 2 of Step 8 agree because they are the same ledger read twice. Only the schedule tests the balance. A tie-out with no schedule column is a roll-forward with a green cell.
- **Deriving coverage dates from the payment date.** Right often enough to be dangerous, wrong by weeks when it is wrong, and wrong in the same direction every year.
- **Reading the coverage period out of the invoice memo.** "Annual renewal" is not twelve identified months.
- **Mixing whole-month and day-prorated items in one schedule** and then hunting for the small variance it creates.
- **Amortizing recoverable tax.** It comes out at payment. Step 6 tests for it; run the test.
- **Letting an FX process revalue the prepaid asset.** It is non-monetary. If revaluation entries are hitting the account, that is a finding, not a rounding difference.
- **Treating the prepaid account as a drawer.** Deposits, fixed assets and inventory get coded there. Step 0c looks; look.
- **Presenting a fixture tie-out as a clean result.** `mock: true` data reconciles perfectly and means nothing.
- **Assuming the recurring entry ran.** It stops silently. Test 0a is one query and finds the month it stopped.
- **Merging two entities' prepaids into one schedule** because the same broker wrote both policies.
- **Claiming this skill is still system-agnostic.** It reads a specific connected ledger. The accounting is portable; the evidence is not. Say which is which.
- **Saying "posted" anywhere.** Nothing here is posted. The gateway reads.

---
