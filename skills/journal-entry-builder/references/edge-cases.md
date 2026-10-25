<!-- journal-entry-builder · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-currency entries**: **each line must be in the same currency, or include explicit FX rate columns.
For cross-currency entries, post in functional currency with an FX gain / loss plug. Flag for
FX revaluation.**

**Penny imbalances from rounding allocations**: **do not pad with a "Rounding" plug. Allocate the rounding
to the largest line and note in the memo.**

**Entries crossing fiscal years**: **warn. Year-end accruals should reverse in Period 1 of the new year, not
in adjustment periods.**

**Entries to Suspense / Clearing accounts**: **always temporary. Flag any open clearing-account balance.**
*Mosofin note*: **the balance and its age are readable** — report them with the entry.

**Cash basis entities**: **accruals and deferrals are inappropriate on a pure cash basis. Confirm basis and
flag if mismatch.** *Mosofin note*: **the accounting method used by the books is readable**, so the mismatch
is detectable rather than assumed.

**Large or unusual JEs**: **if a single entry exceeds the entity's materiality threshold — ask the user; do
not assume — flag for review per `journal-entry-review`.**

**Manual JEs to revenue, cash, AR, or AP control accounts**: **these are red flags for auditors. Flag and ask
the user to confirm the business reason; recommend a subledger transaction where possible.** *Mosofin note*:
**whether an account is a control account is readable**, so this flag raises itself.

**An account in the proposed entry does not exist in the chart** — *Mosofin-specific*. **A hard stop, not a
warning.** The import would fail or, worse, create the account.

**The period is open in the software but already reported** — *Mosofin-specific*. **Two different
questions.** Warn on both.

**A payment entry where an accrual is already open** — *Mosofin-specific, and the highest-value check*.
**The classic double-count.** Read the accrual account first.

**A receipt booked to revenue where an invoice is open** — *Mosofin-specific*. It should clear AR.

**A loan payment booked entirely to expense** — *Mosofin-specific*. **Only interest is expense.** The
liability movement shows the split.

**A closing entry proposed where the platform closes automatically** — *Mosofin-specific*. **Double-closes
retained earnings.** See `closing-entries-and-trial-balance`.

**An entry built against the wrong entity's chart** — *Mosofin-specific*. The most common cross-entity
failure. **Confirm the entity before building.**

**An elimination entry imported into a subsidiary** — *Mosofin-specific*. **Consolidation-only entries belong
to neither entity's books.** Label them.

**The chart read is unavailable** — *Mosofin-specific*. Placeholder coding applies, **and the output must say
so**. Never invent numbers.

**A result comes back with `mock: true`** — *Mosofin-specific*. **An entry validated against fixture accounts
may reference accounts that do not exist**, and it would be imported.

**The entry is described as posted** — *Mosofin-specific, and prohibited*. **Mosofin posts nothing.** Every
output says proposal.

**A stored template applied to a different entity** — *Mosofin-specific*. Account numbers are chart-specific.
Key templates by entity.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the validation as `[gated]` in the coverage sheet.

---
