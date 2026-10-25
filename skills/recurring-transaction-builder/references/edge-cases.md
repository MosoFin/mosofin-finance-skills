<!-- recurring-transaction-builder · edge-cases.md · read for: Stages 4–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All ten preserved, in order.

**Mid-period start**: the first occurrence may be a partial period — a monthly subscription starting on the 10th. **Pro-rate on days, or per the contract terms — ask the user which.** `[auto: computed]` once told; `[manual]` to decide. Do not default: day-prorating and charging a full first period are both common, and they differ by real money on the first invoice a customer ever sees.

**Mid-period termination**: the final occurrence may be partial. Pro-rate similarly. `[auto: computed]`, `[manual]` to decide.

**Cadence change mid-schedule**: **build as two sub-schedules.** `[auto: computed]`. Two clean schedules are auditable; one schedule with a hidden rule change is not.

**Currency change or revaluation**: each occurrence is in the contract currency; FX is handled separately at posting time, as an FX revaluation task. `[auto: computed]` to hold the currency; `[manual]` for the FX treatment. **Do not convert occurrences into the functional currency in this schedule** — that bakes in a rate that will be wrong by the time the transaction posts.

**Vendor or customer is also a related party**: flag for elimination consideration on consolidation. **`[auto: read]` to detect** where the counterparty's name matches another connected company file's `display_name`, or appears in both the customer and vendor lists. `[manual]` to conclude. Intercompany reconciliation and related-party disclosure follow from the same detection.

**Schedule with both a fixed and a variable component** — base rent plus CAM (common area maintenance) service charges that vary: **build the fixed schedule and flag the variable as requiring per-period actual amounts.** `[auto: computed]` for the fixed part. **Do not average the variable part into the fixed schedule.** An averaged estimate posted automatically every month is an accrual nobody decided to make, and it will drift.

**Customer subscription with a mid-term upgrade or downgrade**: **treat as a new schedule from the change date; the old schedule terminates.** `[auto: computed]`. Same reasoning as the cadence change — two schedules, not one with an invisible seam.

**Tax rate change during the schedule period**: if the user knows about it, build with the new rate from its effective date. If not, **flag for review at each rate change.** `[manual]` — and this is a third instance of the same rule: **rates change, so nothing here supplies one.** `[auto: read]` for the supporting fact: which tax codes the book currently has configured.

**Holidays and weekend rolls**: if the cadence falls on a non-business day and the policy is to roll, **apply it consistently — always forward or always backward, per policy.** `[auto: computed]` given the calendar; `[manual]` for the calendar itself, which is not in the accounting system.

**Open-ended ("until cancelled") subscriptions**: **build for a finite horizon — 12 or 24 months — and flag for renewal review at the end.** `[auto: computed]`. This is the right answer and worth defending: a finite horizon with a review date is a control. An indefinite schedule is a standing instruction that nobody will ever revisit, and Step 2's flag exists for the same reason.

---
