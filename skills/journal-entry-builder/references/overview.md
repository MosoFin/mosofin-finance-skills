<!-- journal-entry-builder · overview.md · read for: background for the card and Stage 1 — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# Journal Entry Builder (Mosofin)

Constructs **properly balanced journal entries** for any accounting scenario — **standard, adjusting,
accrual, deferral, reclass, reversing, intercompany, or closing**. Outputs entries that **balance to the
penny**, with complete narration and **import-ready format** for the user's accounting system.

**In plain words:** every accounting event gets recorded as at least two lines that cancel out — something
gained against something given up. Getting the two sides right, against the right accounts, on the right
date, with an explanation someone can follow a year later, is the whole job.

This skill is **system-agnostic**. **It does not invent account numbers or assume any jurisdiction's tax
rules.**

It is **workspace-scoped**: the chart of accounts, the account types, the existing balances and the
validation evidence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart rather than accepting any list. That is a narrowing, stated rather than implied.

## Mosofin never posts — and this is the skill where that matters most

**Dozens of skills in this pack end by handing off here.** Depreciation, accruals, impairments, releases
from restriction, elimination entries, shrinkage, deferred tax — **all of them arrive at this skill to
become an entry.**

> **Mosofin is read-only. It cannot post a journal entry, and it will not.** **Everything this skill
> produces is a proposal** — a fully constructed, validated, import-ready entry **for a person to review and
> post.**
>
> **That is not a limitation to apologise for; it is the correct division.** Posting is an authorised act
> with a preparer and a reviewer behind it, and an entry arriving pre-validated with its support attached is
> what makes that review fast. **Say "proposed entry" on every output**, and never imply anything has been
> recorded.

## What the workspace changes: validation stops being aspirational

The original's Step 6 asks you to *verify* nine things. **In a Mosofin workspace, six of them become
queries** rather than intentions:

| Validation | Original | Here |
|---|---|---|
| **Debits = Credits** | arithmetic | arithmetic — **[auto]** |
| **All accounts exist in the COA** | verify against a supplied list | **[auto]** against the live chart |
| **Date is within an open accounting period** | "warn if not" | **[gated]** — the closed-through date is asked at intake; a lock or closing date is used only where the platform exposes it |
| **Sign conventions match account types** | judgment | **[auto]** — **account types are readable** |
| **Memo explains the business purpose** | judgment | judgment |
| **References to source documents** | judgment | **[gated]** — the document may be in the system |
| **Reversing flag set correctly** | judgment | judgment |
| **No P&L accounts in a pure BS reclass** | verify | **[auto]** — account types again |
| **Tax lines present where warranted** | jurisdiction | **[gated]** — codes readable, rules not |

**And it adds the check the Pitfalls section names first, which is the most valuable one here:**

> **Pitfall 1 — "Recording a payment when an accrual already exists → double-counts."** **[auto]**: **the
> accrual balance is readable.** Before proposing a payment or invoice entry, **check whether an accrual for
> the same item is sitting open.** This is the classic double-count, it is invisible at the moment of
> posting, and it is one query.

Three more from the same section:

- **Pitfall 2 — a receipt where an invoice exists** should be applied to the open invoice as a customer
  payment, not go to revenue. **[auto]**: the open invoice is findable.
- **Pitfall 5 — a loan payment booked entirely as expense.** **[manual]**: the split comes from the lender
  statement or amortization schedule; the loan liability balance is read only to confirm the post-payment
  balance agrees to the lender's stated principal.
- **Manual JEs to revenue, cash, AR or AP control accounts** — the original flags these as auditor red
  flags. **[auto]**: whether the target is a control account is readable from the chart, so the flag raises
  itself.

**What stays outside:** the transaction or event being recorded — that is the user's — the materiality
threshold, the tax rules, and any source document not held in the system.

---
