<!-- budget-vs-actual-analysis · overview.md · read for: background — what the analysis does, why both sides can sit in the books, and what stays manual; read when a user asks why. Edit here, not in SKILL.md. -->

# Budget vs. Actual Analysis (Mosofin)

Compares actual financial results to budget (or forecast), classifies variances as
**favorable / unfavorable**, decomposes them into drivers, and drafts explanatory commentary. The
core monthly **FP&A** (financial planning and analysis) deliverable.

**In plain words:** you said the month would look one way; it looked another. This skill measures
the gap on every line, works out *why* — was it volume, or price, or timing, or a one-off? — and
writes the explanation someone can take to a management meeting. The hard part is never the
subtraction; it is saying what caused it.

This skill is **chart-of-accounts-agnostic** — it works on whatever line structure the entity uses.

It is **not** system-agnostic. It is **workspace-scoped**: every actual and every budget figure
comes from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**A note on how well this particular skill fits a connected workspace.** Most skills in this pack
have one side of a comparison living outside the accounting system — a bank statement, a goods
receipt, an actuarial report. **This one has both sides inside it.** Actuals are readable by month
and by line; and where the accounting platform holds the budget, that is readable too, by account
and by period. So a budget-versus-actual analysis is one of the few workflows here that can run
**almost entirely `[auto]`**, end to end, with the entity's own numbers on both sides.

What stays `[manual]`: the materiality thresholds, the *explanation* of a driver where it depends
on business events the ledger cannot see, and the judgment of timing versus permanent. Those are
where the human value is, and pushing everything else to `[auto]` is precisely what frees time for
them.

**Mosofin is read-only.** It cannot revise a budget, post a reclassification, or update a forecast.
Every recommendation below is a *proposal* for a human.

---
