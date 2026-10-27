<!-- budget-vs-actual-analysis · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Zero or near-zero budget line with actual spend**: the % variance is undefined or huge. **Show the
dollar variance and flag "no budget"** rather than a meaningless %. *Mosofin note*: an account
present in the actuals but absent from the budget is directly detectable at Step 1 — list them
before computing anything.

**Reclassification between actual and budget**: if a cost was budgeted in one line but booked in
another, the variance is misleading — one line is over and another under by the same amount.
**Reclassify to compare like with like, and note it.** *Mosofin note*: paired equal-and-opposite
variances are a strong signal of exactly this; test for them.

**Budget not phased monthly (annual / 12)**: if the budget was crudely spread evenly but the
business is seasonal, monthly variances will be noise. **Flag the phasing issue; compare YTD which
is more meaningful.** *Mosofin note*: detectable — a budget with identical monthly values is
evenly spread by construction. Say so rather than explaining twelve months of seasonal noise.

**Mid-year budget revision**: clarify whether comparing to the original budget, a revised budget, or
the latest forecast. **Each tells a different story; label clearly.** *Mosofin note*: where the
system holds several budgets, **list them and ask which one** — never pick the most recent by
default, and always name the chosen one on the face of the report.

**FX-driven variances**: separate operational performance from currency translation.
**Constant-currency variance isolates the real performance.**

**One-time items in actuals**: large one-offs (legal settlement, asset sale gain, restructuring)
distort the variance. **Call them out separately so the underlying run-rate is visible.**

**Accrual catch-ups**: a true-up of a prior accrual hits one month, distorting that month's
variance. Note it. *Mosofin note*: journal entries around period end are directly readable and are
where these live.

**New initiatives not in the original budget**: if the board approved spend after the budget was
set, the variance to the original budget is **"expected."** Compare to the revised plan and say so.

**Cumulative immaterial variances adding up**: several small unfavorable variances can aggregate to
a material full-year miss. **Watch the YTD trend, not just the month.**

**Revenue timing vs. permanent**: a deal slipping from this month to next is timing; **a lost deal
is permanent.** Treat them differently — and note that the ledger cannot tell them apart, so this
one always needs the business.

**No budget is available in the system** — *Mosofin-specific*. Ask for it. **Do not substitute
prior-year actuals and call the result a variance report** — that measures change, not performance
against plan.

**A cause was written that the ledger does not evidence** — *Mosofin-specific, and the most
important discipline in this skill*. Commentary goes to management verbatim. Name the transactions,
mark unknown causes as **to be confirmed** with an owner, and never narrate a business event nobody
mentioned.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded. Its
absence will read as a favourable cost variance if not stated. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data cannot support
commentary that management will act on.

**A stored threshold no longer suits the entity's scale** — *Mosofin-specific*. A business that has
doubled needs a bigger threshold, or the report becomes unreadable. Revisit thresholds when the
count of commentary-required lines jumps.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
