<!-- expense-report-processor · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**International travel with multiple currencies**: **capture in original. Convert at the FX source provided
by the user (or ask). Flag rates that look off.** *Mosofin note*: the functional currency is `[auto]`; the
rate source is not.

**Conference packages with mixed components**: a single charge covering registration + meals + lodging —
**request an itemized receipt. If not available, ask the user how to allocate; do not pick an allocation
arbitrarily.**

**Spousal / accompanied travel**: **allocate the spousal portion. Mark non-reimbursable per policy, or
treat as taxable compensation if company-paid** — per the jurisdiction's payroll rules; **flag for the
user.**

**Gift cards**:
- **For clients** → reimbursable per policy; deductibility per jurisdiction
- **For employees** → **typically taxable compensation in most jurisdictions — flag for payroll handling**

**Tips**: **reimbursable per policy. Flag unusual tip percentages for review.** *Mosofin note*: a tip added
after authorization is why the card amount and the claimed amount can differ slightly — allow for it in the
duplicate tolerance rather than calling it a non-match.

**Cash transactions without receipts**: **per policy threshold. If no policy, flag every receiptless line.**

**Mileage without logged business purpose / start–end**: **insufficient documentation. Flag for additional
info.**

**Reimbursement that may be taxable pay**: if the policy's mileage rate or per-diem exceeds the rate the user
says the tax authority allows, or a line lacks business purpose or a receipt where required, flag **"excess
may be taxable pay — confirm with payroll"**. Ask for the tax-free rate; **never supply it**.

**Corp card with personal charge**: **the employee owes the company. Code as Due from Employee, not
expense.** *Mosofin note*: that balance is readable — **an ageing Due-from-Employee balance is money nobody
chased.**

**Late submissions**: **per policy.**

**Pre-paid expenses on the report** (a deposit for next quarter's conference): **code to Prepaid Expenses
(BS), not expense. Flag for amortization via `prepaid-amortization-schedule`.**

**Tax-inclusive receipts in jurisdictions that allow input-tax recovery**: **decompose the receipt total
into pre-tax + tax. If the receipt doesn't show tax explicitly, ask the user how to handle** — some
jurisdictions require an explicit tax invoice for recovery.

**Cross-border meals or services**: **may trigger reverse-charge VAT in the entity's jurisdiction. Flag —
do not silently apply.**

**A claim matches a transaction already posted** — *Mosofin-specific, and the highest-value finding*. The
company card already paid it. **Reject, do not review** — and check whether earlier periods carry the same
pattern for the same claimant.

**The Corporate Card Clearing account never clears** — *Mosofin-specific*. Report the residual **with its
oldest item**. Age distinguishes ordinary timing from a real break.

**A claimant has no employee record** — *Mosofin-specific*. A leaver, a contractor on the wrong form, or a
misspelling. Ask before coding.

**Historical coding for the same merchant is inconsistent** — *Mosofin-specific*. Say so rather than
picking the most recent. An inconsistent history usually means the category was never decided.

**The COA read is disabled** — *Mosofin-specific*. **The skill degrades to the original's placeholder
behaviour.** Label every account **PLACEHOLDER — REMAP REQUIRED** and say why, rather than inventing
numbers.

**The COA has no non-deductible accounts** — *Mosofin-specific check on an original flag*. Read the COA and
the available dimensions, then say which of sub-accounts or a class is actually available here.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded, and say that
duplicate checking against that entity's card activity did not run.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A duplicate check against fixture
transactions proves nothing.** Never report it as clean.

**A stored mileage rate or per-diem is reused without a date** — *Mosofin-specific*. These change annually.
**Store effective dates, and re-confirm at each year boundary.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's caps to another's staff.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
