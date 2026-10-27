<!-- ar-aging-and-collections · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

*Drawn from the original's rules, guardrails and fixture conditions, plus the ones Mosofin's
workspace model introduces. The full scenario list is in Validation scenarios above.*

**Cash basis requested but the connector's aging is accrual-only** — an aging is an
accrual-basis schedule by nature (on a true cash basis there is no receivable), so only DSO and
income figures depend on basis. Do not raise it unprompted; if the user explicitly asks for a
cash-basis aging, explain the limitation and
**ask whether accrual basis is acceptable before reading data**. Do not read first and caveat
after; the user may not want the accrual view at all.

**No A/R detail capability is listed** — do **not** treat an invoice search as a complete
historical population. Its recent-date default omits exactly the old unpaid invoices
collections exists to chase. Request the smallest equivalent export and disclose the gap.

**No independent summary to tie to** — derive totals from detail and **disclose that there was
no independent tie-out**. A reconciliation against itself is not a reconciliation.

**Unresolved variance between detail and summary** — disclose it with the amount and what you
checked. **Never force a tie.**

**A customer balance report is offered as an aging** — it is not. One total per customer with
no buckets cannot answer what is overdue. Mark the task `[manual]` or reconstruct from
invoice-level data and label the reconstruction.

**Multiple currencies** — preserve each separately. Ask before presenting any consolidated
total, and never present one unlabeled.

**Fuzzy customer name** — resolve against the customer master and state the match. Two
customers with similar names are common, and chasing the wrong one is a real cost.

**Disputes, credit holds, tiers and payment history are not in the books** — *Mosofin-specific,
and the main `[manual]` cluster here*. **Never infer them.** An invoice is not disputed because
it is old, and a customer is not on hold because they stopped paying. Ask only when the
requested output needs them.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say whose receivables are therefore missing. Show the `reconnect_url`, and **do not substitute
CSVs or guessed numbers while the user is asking for live data**.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
aging's shape but must never drive a collections action against a real, named customer.

**The same customer appears in several connected company files** — *Mosofin-specific*. Report
per entity, then compare. Coordinate before sending three separate reminders, and check whether
the invoice is disputed at one entity while being chased at another.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag
it. Never apply it to a different entity; never drop it silently.

**A stored strategic tier or credit hold is stale** — *Mosofin-specific*. A hold that has been
resolved will otherwise suppress legitimate collections forever. Re-confirm standing flags on
each run.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
