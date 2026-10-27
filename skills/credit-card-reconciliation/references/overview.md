<!-- credit-card-reconciliation · overview.md · read for: background — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# Credit Card Reconciliation (Mosofin)

Reconciles **credit card statements to the general ledger**, matches **receipts** to transactions, and
produces the posting **journal entry**. Designed for monthly corporate-card processing.

**In plain words:** a company card gets used dozens or hundreds of times a month by people who are not
the bookkeeper. At month end somebody has to check that every charge on the card statement is in the
books, coded to the right account, backed by a receipt, and actually for the business. This skill does
that check and writes the entry.

This skill is **jurisdiction-agnostic** — it applies whatever tax rules the user identifies.

It is **not** system-agnostic. It is **workspace-scoped**: card charges, the card liability balance, and
the chart of accounts come from tool calls against a company file connected to your Mosofin workspace in
this conversation, or from something you supplied by hand and that is labelled as such.

## What a connected workspace gives you here — and what it does not

**The same structural limit as `bank-reconciliation`:** Mosofin connects the **accounting system**, not
the card issuer. **The statement is `[manual]`, and so are the receipts.** Without a statement there is
no reconciliation — only a review of what was posted.

**But the book side is richer than in a bank reconciliation**, and that matters. Card charges are
normally posted **individually** in the accounting system — each with its merchant, date, amount and
account code — rather than as a single monthly total. So a great deal is `[auto]`:

- **Every card charge posted in the period**, with its merchant, amount, date and GL coding
- **The card liability balance** and its movement, including payments made to the card
- **Three tests worth running every month**, each of which the original raises and none of which needs a
  statement:
  - **Duplicate charges** — same merchant, same amount, within a few days (same day is the strongest
    signal)
  - **Recurring subscriptions** — same merchant, same amount, month after month. The original notes that
    these "accumulate; periodically review for unused subscriptions". **Here that review is a query**,
    and it routinely finds software nobody has opened in a year
  - **Capitalization-threshold breaches** — charges above the entity's capitalisation limit sitting in an
    expense account rather than fixed assets

**Say which you did.** A "review of posted card charges" and a "reconciliation to the card statement" are
different pieces of work with different assurance, and only the second is a reconciliation.

**Mosofin is read-only.** Every entry below is a *proposal* for a human.

---
