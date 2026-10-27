<!-- ap-aging-and-payment-runs · overview.md · read for: background — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# AP Aging and Payment Runs (Mosofin)

Produces **accounts payable (A/P) aging** analysis and proposes prioritized **payment runs**
based on due dates, early-pay discounts, cash availability, and vendor importance. Designed
for A/P teams running weekly or bi-weekly pay cycles.

**In plain words:** this answers two questions — *who do we owe, and how late are we?* and
*given the cash we actually have this week, who should we pay first?* An **aging** sorts
every unpaid bill by how overdue it is. A **payment run** is the batch of payments you send
out in one go.

This skill is **jurisdiction-agnostic** — it applies whatever terms and rules the user
identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every bill, balance, term, and
vendor name comes from a tool call against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled
as such.

**Mosofin is read-only.** It cannot send a payment, release a payment run, change a vendor's
bank details, or put a vendor on hold. Every payment run below is a *proposal* for a human to
review, approve, and execute in the banking or accounting system.

---
