<!-- journal-entry-review · overview.md · read for: background — what the skill does, why it screens the whole population, and what it cannot test; read when a user asks why. Edit here, not in SKILL.md. -->

# Journal Entry Review (Mosofin)

Reviews a population of journal entries through a **control and audit lens** — screening for **unusual,
high-risk, or potentially improper entries** using risk characteristics, and producing a **prioritized list
for investigation**. **A core audit procedure — journal entry testing is required in financial statement
audits — and a useful internal control.**

**In plain words:** most accounting entries come from an invoice, a payment, a payroll run. A few are typed
in by hand, and those are the ones that bypass the normal checks. This looks through them for the patterns
that tend to accompany mistakes or manipulation, and puts the ones worth a closer look at the top.

It is **workspace-scoped**: the journal entry population, the account types and the pattern evidence come
from tool calls against a company file connected to your Mosofin workspace in this conversation, or from
something you supplied by hand and that is labelled as such.

**This skill identifies risk indicators and anomalies; it does not conclude fraud occurred** — that requires
a fraud investigation, which is outside this skill.

## What changes: screen everything, and name what cannot be screened

**The original says: *"Don't try to review every entry — screening focuses attention on the ones that
matter."* That is right about review and no longer right about screening.**

> **Screening every entry is a query.** The population is readable, the criteria are computable, and the
> cost of applying them to 8,000 entries is the same as applying them to 80. **So screen 100% and review the
> top** — the same reasoning as an internal audit workpaper, where a readable population removes sampling
> risk.
>
> **Report the population size and, once the extract agrees to the ledger's movement, state that the
> screen was complete.** "All 4,812 entries screened; 63
> flagged; 12 high-risk reviewed" is a materially stronger sentence than any sample-based version, and it is
> what an auditor wants to hear about JE testing.

**The strongest `[auto]` area is Step 5 — patterns.** Individual flagged entries are noisy; **clusters,
recurring period-end adjustments, and reserves that move with earnings are the ones that actually mean
something**, and they need the whole population to see. **The original says patterns are often more telling
than single entries. Here they are also cheaper.**

**And the gap, stated plainly:**

> **Approval data is generally not on this surface.** **Four of the People-and-process indicators depend on
> it** — entries lacking approval, self-approved entries, one person posting and approving, and the
> segregation-of-duties failure that follows. **Where approval status is not exposed, these cannot be
> tested. Report them as NOT RUN**, name what they would have shown, and ask for the approval log from the
> system that holds it.
>
> **And where a user field does exist, a user name is not a person.** Shared logins, delegated access and
> system-generated entries all break that link — the same caveat that applies in
> fraud investigation, internal audit and IPO-readiness work.

**One more inherited discipline:** **this skill escalates to the fraud skill and inherits its rules.** **An
anomaly is not a finding.** Entries are posted by identifiable people; **a flagged list is a list of
questions, not of suspects**, and **nothing from it is persisted.**

**Mosofin is read-only.** It cannot correct, reverse or reclassify anything it flags.

---
