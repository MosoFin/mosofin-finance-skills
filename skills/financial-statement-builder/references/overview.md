<!-- financial-statement-builder · overview.md · read for: background at any Stage, or when a user asks why. Edit here, not in SKILL.md. -->

# Financial Statement Builder (Mosofin)

Assembles a complete set of financial statements from a **trial balance** — **Balance Sheet**, **Income
Statement**, **Comprehensive Income** (where OCI exists), **Statement of Cash Flows** and **Changes in
Equity**. Adds comparatives, applies proper classification, and ties
everything together.

**In plain words:** the accounting system holds a long list of account balances. This turns that list into
the five statements a bank, an investor or an auditor expects to see — in the order, the groupings and the
wording their framework requires — and then proves the statements agree with each other.

This skill is **framework-aware** (US GAAP, IFRS, local GAAP). **The TB drives the content; the framework
drives the presentation.**

It is **workspace-scoped**: the trial balance, the comparative period, the account types and the entity
details come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's actual
chart of accounts and account types rather than accepting any TB shape. That is a narrowing, and it is
stated rather than left implied.

## What this skill is actually for, given the platform already prints statements

**The connected accounting platform will hand you a balance sheet and a profit and loss on request.** So it
is worth being precise about what this skill adds, because "fetch the numbers" is not it:

1. **Classification.** The platform groups by its own account types. **A framework requires current versus
   non-current**, in a specific order, under specific headings. Nothing in the ledger knows which portion of
   a loan falls due within twelve months.
2. **Framework presentation.** US GAAP leads with current; IFRS commonly leads with non-current. IFRS says
   "trade and other receivables". By-function versus by-nature. **None of this is a data question.**
3. **The comparative basis.** Pulling last year is one call. **Confirming that last year, as it now sits in
   the ledger, is what was actually published is not** — see the warning below.
4. **The seven cross-statement tie-outs.** The real deliverable. They are what turns three reports into a
   statement package.
5. **Everything the ledger has no field for**: discontinued operations, OCI, EPS, restated comparatives.

**And one warning that shapes the whole skill:**

> **The system-generated balance sheet always balances.** Double-entry software enforces it. So **tie-out 1
> proves the software works — it does not prove your statements are right.** The moment you reclassify a
> current portion of debt, split a deferred tax balance, or reclassify a comparative, **you are looking at
> statements the system did not produce, and the balance must be re-proved on those.** Run tie-out 1 against
> your own presentation, never against the platform's report.

> **The ledger's prior year is not necessarily the published prior year.** If audit adjustments were agreed
> but never posted, or were posted to a later period, **the comparative you read will differ from the
> comparative that was filed.** Compare against the prior-year financials as issued — that comparison is
> `[manual]`, and it is one of the most valuable checks in this skill.

**Mosofin is read-only.** It cannot post a reclassification, an adjustment or a closing entry. Every
proposed change below is a *proposal*.

---
