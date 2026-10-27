<!-- journal-entry-review · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Legitimate period-end entries**: **many valid entries occur at period-end — accruals, true-ups. The flag
is a screen, not a conclusion — a period-end entry with proper support and approval is fine. Avoid crying
wolf on every routine close entry.** *Mosofin note*: **the derived baseline shows which period-end entries
are routine for this entity**, which is the cheapest way to stop crying wolf.

**Round numbers can be legitimate**: **estimates and accruals are often round. Combine with other criteria
rather than flagging all round amounts.**

**Management override risk**: **senior management posting unusual entries is a classic fraud risk — they can
override controls. Entries by executives to sensitive accounts warrant particular scrutiny.**

**Topside entries**: **consolidation and topside adjustments made above the subledgers, often by senior
finance, are higher risk and less visible. Ensure they're in the population and reviewed.** *Mosofin note*:
**they may not be in any connected file at all.** Establish where they live at Gate 1.

**Missing or weak descriptions**: **a vague description isn't proof of impropriety but impedes review and is
itself a control weakness — flag for both reasons.** *Mosofin note*: **measurable**, and worth quantifying
as a control observation.

**Volume too large to review individually**: **rely on risk-based screening; review the highest-risk subset
thoroughly rather than everything superficially.** *Mosofin note*: **the screen is no longer the
constraint** — screen everything, review the top.

**System-generated entries assumed safe**: **usually lower risk, but a manipulated automated process or a
manual entry disguised as system-generated is possible. Don't ignore the system population entirely.**
*Mosofin note*: **a source label is a field, not a fact.**

**Reversing entries**: **a reversal posted but the original never re-posted — or an accrual reversed without
the cash following — can hide or shift amounts. Trace reversal pairs.** **[auto]**, and it needs the
following period in the population.

**Entries net-zero across accounts**: **an entry that nets to zero overall but moves amounts between a
sensitive pair — reduces an expense, increases a different reserve — can mask manipulation. Look at the
account-level movement, not just the net.**

**Escalation discipline**: **an anomaly is not a finding of fraud. Document objectively and escalate to
investigation rather than accusing — preserve objectivity and avoid
prejudicing any inquiry.**

**Approval-based criteria cannot run** — *Mosofin-specific, and the material gap*. **Four indicators, and
they are the segregation-of-duties ones.** Report NOT RUN; ask for the approval log.

**A user field treated as a person** — *Mosofin-specific*. Shared logins, delegated access and system
entries all break the link.

**The screen was sampled** — *Mosofin-specific*. **Screening is a query; screen the whole population** and
say so — after the Step 1 tie-out proves it is the whole population.

**"Unusual" asserted without a baseline** — *Mosofin-specific*. **Derive normal from prior periods**; it is
one more read.

**A back-dating test run without both dates** — *Mosofin-specific*. **It depends entirely on the
transaction date and a created timestamp both being returned** — two columns that both mean transaction
date prove nothing. Check the field list before claiming the test ran.

**Patterns skipped in favour of individual flags** — *Mosofin-specific*. **Patterns are the strongest
evidence here and the cheapest to compute.** Lead with them.

**One baseline applied across a group** — *Mosofin-specific*. Normal differs by entity, and a shared
baseline floods the small ones with flags.

**A company file is connected but not active** — *Mosofin-specific*. **JE testing is a required audit
procedure**; an unscreened entity must be named as unscreened.

**A result comes back with `mock: true`** — *Mosofin-specific*. **Fictional anomalies attributed to
real-sounding users.** Stop.

**Flags carried forward to the next review** — *Mosofin-specific, and prohibited*. Most flagged entries are
proper. **Persist the method; never the flags.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's sensitive-account list or thresholds to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the criterion as `[gated]` in the coverage sheet.

---
