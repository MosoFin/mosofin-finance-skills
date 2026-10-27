<!-- cash-flow-forecast-13-week · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Turnaround / distressed situation**: this forecast becomes **the central management tool**. Higher
rigor, daily or weekly updates, **conservative collection assumptions**, and explicit
creditor-payment prioritization. Often required by lenders or restructuring advisors. *Mosofin note*:
here the derived days-to-pay matters most — under stress, customers of a distressed supplier often
pay *slower*, so use the recent window rather than a long average, and say which you used.

**Customer concentration**: if one large customer's payment timing dominates the forecast, **model it
explicitly and stress-test a delay.** *Mosofin note*: concentration is directly measurable
(*`get_customer_sales`*, *`get_aged_receivables`*) — quantify it rather than asserting it.

**Seasonal cash cycles**: a 13-week window may sit entirely within a high or low season — **extend
the horizon if the window misses a critical inflection** (e.g. a large seasonal collection just past
week 13). *Mosofin note*: last year's monthly cash movement shows where those inflections fall.

**Multi-currency cash**: forecast each currency separately if the entity holds and spends in
multiple currencies; consolidate at forecast FX. **FX timing on conversions matters.**

**Lumpy large payments** (tax, debt maturity, earn-out): **a single large outflow can breach the
floor in one week even if the trend is healthy. Highlight these explicitly.** They are also the most
common omission — check last year's cash for anniversaries falling inside the horizon.

**Revolver mechanics**: model the **borrowing-base availability**, draw / repay timing, and interest.
**Some facilities have weekly clean-down requirements.** Undrawn capacity is not the same as
available capacity.

**Disputed / at-risk receivables**: **don't forecast collection of disputed invoices at full
confidence**; probability-weight or exclude. *Mosofin note*: dispute status is `[manual]` — the books
do not flag it, and an old invoice is not evidence of a dispute.

**Payment float / clearing time**: a cheque or ACH takes days to clear. **Place the cash impact in
the week it actually clears, not the week it's initiated.**

**Payroll is sacrosanct**: in a tight forecast, **payroll and statutory remittances are typically
non-deferrable. Model other payments as the flex.** Never present a lever list that includes payroll.

**Forecast feeding a covenant certificate**: if a minimum-liquidity covenant is tested, **ensure the
forecast aligns with the covenant's exact definition of cash / liquidity** — which may exclude
restricted cash, may include undrawn facility, or may be measured on a different day.

**Collection timing was assumed rather than derived** — *Mosofin-specific, and the biggest quality
lever here*. If payment history is readable, derive days-to-pay per customer and show the sample
size. Forecasting collection on the due date is the optimism the final quality standard forbids.

**A days-to-pay derived from too few invoices** — *Mosofin-specific*. Two invoices is not a pattern.
State the sample size, and fall back to a segment average or a stated assumption where it is thin.

**Restricted cash included in opening balance** — *Mosofin-specific*. A cash account in the chart of
accounts is not necessarily available cash. Confirm which accounts count.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose payroll and bills are therefore missing. In this skill that omission flatters the forecast.
Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A forecast on fixture data can look
healthy while a real business misses payroll. Never let it drive a liquidity decision.

**Cash is not actually pooled across entities** — *Mosofin-specific*. Do not net one entity's surplus
against another's shortfall without confirming funds can move, and model any transfer explicitly.

**A stored recurring item has ended or changed** — *Mosofin-specific*. A lease that expired will
otherwise be forecast forever. Re-check each stored recurring item against recent actuals every run.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
