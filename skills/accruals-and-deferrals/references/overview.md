<!-- accruals-and-deferrals · overview.md · read for: background — what accruals and deferrals are, and what this skill covers beyond AP cutoff; read when a user asks why. Edit here, not in SKILL.md. -->

# Accruals and Deferrals (Mosofin)

Identifies and books period-end **accruals** (expenses incurred but not invoiced, revenue
earned but not invoiced) and **deferrals** (revenue received but not earned, expenses paid
but not consumed), so the financials line up with the **accrual basis of accounting**.

**In plain words:** your books should show costs and income in the month they actually
*happened*, not the month the paperwork or the money showed up. An **accrual** records
something that already happened but hasn't been billed yet — you used electricity in March,
the bill comes in April, but March should carry the cost. A **deferral** does the opposite —
a customer paid you in January for a whole year of service, so you can't call it all January
income; you spread it out. This skill finds those items, works out the amounts, and writes
the entries for a human to post.

This skill covers categories beyond AP-specific cutoff (which is handled by
`ap-accrual-cutoff`). Examples: bonus accruals, commission accruals, interest accruals,
vacation accruals, utility / service period-end accruals, revenue accruals, and deferrals.

This skill remains **chart-of-accounts-agnostic** and **jurisdiction-agnostic** — it uses
whatever account structure and rules the workspace and the user present.

It is **not** system-agnostic. It is **workspace-scoped**: every balance, transaction, and
account name comes from a tool call against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled
as such.

**Mosofin is read-only.** Nothing here posts a journal entry. Every entry below is a
*proposal* — a human reviews it and posts it in the accounting system.

---
