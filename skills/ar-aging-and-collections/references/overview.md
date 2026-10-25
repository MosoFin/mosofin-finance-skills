<!-- ar-aging-and-collections · overview.md · read for: background at any Stage, or when a user asks why. Edit here, not in SKILL.md. -->

# A/R Aging and Collections (Mosofin)

Builds an **accounts receivable (A/R) aging**, reconciles it, prioritizes collections, computes
receivables metrics, and drafts review-only reminders.

**In plain words:** this answers *who owes us money, how late are they, and who should we
chase first?* An **aging** sorts every unpaid customer invoice by how overdue it is.
**Collections** is the work of getting that money in.

Use this skill only after the Mosofin workspace and the company file are confirmed. Pull live
data through the Mosofin datasource gateway, then ask once for material fields the connector
cannot supply. **Never write to the accounting system and never contact customers.**

**Mosofin is read-only.** It cannot create an invoice, apply a payment, write off a balance,
place a credit hold, or send a reminder. Every draft below is text for a human to review and
send themselves.

---
