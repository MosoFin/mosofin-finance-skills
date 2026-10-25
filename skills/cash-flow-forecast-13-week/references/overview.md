<!-- cash-flow-forecast-13-week · overview.md · read for: background — what the forecast is for, what the books supply and what they cannot; read when a user asks why. Edit here, not in SKILL.md. -->

# 13-Week Cash Flow Forecast (Mosofin)

Builds a short-term, **direct-method** cash forecast (classically 13 weeks) for liquidity
management. Projects cash **receipts** and **disbursements** week by week, computes the running cash
balance, and flags liquidity risks. Essential for treasury, turnaround situations, and any
cash-constrained entity.

**In plain words:** profit is an opinion; cash is a fact. This forecast ignores accounting niceties
and asks one question, week by week: how much money will actually be in the bank? It is the tool
that tells you whether you can make payroll in seven weeks' time, and it is the first thing a lender
or a restructuring adviser asks for.

This skill is **direct method** — actual cash in and out, not accrual.

It is **not** system-agnostic. It is **workspace-scoped**: every opening balance, open invoice and
open bill comes from a tool call against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## Why this skill fits a connected workspace particularly well

Most of the inputs are readable, and one of them matters more than all the rest.

**`[auto]` and strong:**

- **Opening cash by account** — the starting point of the whole chain
- **Open A/R with due dates** and **open A/P with due dates** — the bulk of both columns
- **Recurring receipts and disbursements** — derivable as a pattern from several months of history
  rather than typed from memory
- **Actual cash movement by week**, which makes the Step 7 forecast-versus-actual tracker automatic
  instead of a manual chore

**And the one that changes the forecast's quality most:**

> **Each customer's actual historical days-to-pay is derivable.** Invoice dates and the dates their
> payments were received are both in the books, so "this customer pays on average 15 days late" is a
> **measurement**, not an assumption. The original's own final quality standard is *"No optimistic
> collection assumptions that ignore payment behavior"* — in a connected workspace you can satisfy
> that with evidence rather than caution.

**`[manual]`:** the payroll schedule (unless payroll is connected), the debt service schedule, tax
payment due dates, the minimum cash threshold or covenant, the credit facility's terms, FX rates,
and every judgment about which payments could slip.

**Mosofin is read-only.** It cannot draw on a facility, schedule a payment, or defer anything. Every
lever below is a *proposal* for a human.

---
