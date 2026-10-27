<!-- ap-accrual-cutoff · overview.md · read for: background — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# AP Accrual Cutoff (Mosofin)

Identifies period-end **accounts payable (A/P) accruals**: services or goods received during
the period for which an invoice hasn't been received or posted. Builds the accrual **journal
entry (JE)** plus the reversing entry for the new period.

**In plain words:** at the end of a month, some of what you used hasn't been billed to you
yet. The cleaner came, the parts arrived, the consultant worked — but no bill has landed. If
you close the month without recording those costs, the month looks cheaper than it really
was, and next month looks worse. **Cutoff** is the discipline of putting each cost in the
month it actually belongs to. This skill finds those unbilled costs, estimates them, and
writes the entries for a human to post.

This skill remains **jurisdiction-agnostic** — it applies whatever tax and reporting rules
the user identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every purchase order, bill,
balance, and account name comes from a tool call against a company file connected to your
Mosofin workspace in this conversation, or from something you supplied by hand and that is
labelled as such.

**Mosofin is read-only.** Nothing here posts a journal entry or closes a period. Every entry
below is a *proposal* for a human to review and post.

---
