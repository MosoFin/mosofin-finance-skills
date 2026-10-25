<!-- month-end-close-checklist · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Soft close vs. hard close**: **monthly closes are typically "soft" — books locked for reporting but
adjustments can still be made before audit. Quarter-end and year-end are "hard". Different rigor levels.**

**Three-day close** (high-performance close): **everything in parallel, automation heavy, real-time data.
Requires the entity's systems and processes to support it.** *Mosofin note*: **status pre-population helps
most here**, because chasing status is what a compressed close cannot afford.

**Late information** — a vendor statement arriving Day 7 with a material correction: **policy decision —
adjust the closed period (re-open) or true up in the next period. Materiality and audit considerations
matter.**

**Multi-time-zone teams**: **clarify whether deadlines are in entity HQ time or local time.**

**Year-end close vs. monthly**: **year-end adds audit prep, tax provision, 1099/T4A, and other tasks. The
full year-end procedure is a close of its own.**

**Close while implementing a system change**: **doubles the work. Plan for parallel running of old + new
system data. Flag and resource appropriately.**

**Auditor presence during close**: **certain procedures may need to align with audit timing.**

**Close failures / re-opens**: **if a material error is discovered after books locked, document the re-open
with management approval. Don't quietly tweak.** *Mosofin note*: **the inter-period continuity check finds
an undocumented re-open in the following month**, which is precisely why it belongs in the tie-out.

**Materiality in a startup with small revenue**: **even small amounts may be material. Don't apply
enterprise materiality to a startup.**

**Process documentation for SOX-eligible companies**: **each close task
is potentially a control. Ensure documentation, evidence, and review/approval trails.** *Mosofin note*: **the
Evidence column is the beginning of that trail**, though **an observed entry is not an approval**.

**Holidays / weekends within the close window**: **extend the calendar.**

**A task marked Complete with no entry posted** — *Mosofin-specific, and the most useful line on the board*.
Status and evidence disagree. **Ask before the books lock.**

**An entry posted read as a task complete** — *Mosofin-specific, and the inverse error*. **It proves
something was posted, not that it was right or complete.** The owner still owns the task.

**A reconciliation reported as verified from the ledger** — *Mosofin-specific*. **Reconciliation compares to
something outside.** Bank, statement, count, subledger. **The books cannot confirm it.**

**A balanced trial balance presented as a closed month** — *Mosofin-specific*. **True by construction.**

**Inter-period continuity broken** — *Mosofin-specific*. A prior period was reopened and changed after
reporting. **Run it per account, not only in total.**

**A task removed by scoping that the entity actually needs** — *Mosofin-specific risk*. **Report the scoping
evidence** so a wrong removal is visible.

**External dependencies buried among self-completing tasks** — *Mosofin-specific*. **They are usually the
critical path**, and nobody here can advance them. Group them separately.

**One entity's scoped checklist applied across a group** — *Mosofin-specific*. Scoping is per entity.

**A group close tracked without per-entity status** — *Mosofin-specific*. **The group is as fast as its
slowest entity**, and the board should show which.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A status board built on fixtures shows a
month closing that is not.**

**A stored status is reused** — *Mosofin-specific*. Statuses are state and describe one period only.
**Re-observe.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; its tasks
still exist and simply cannot be verified.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
