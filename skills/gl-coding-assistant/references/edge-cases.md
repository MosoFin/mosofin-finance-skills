<!-- gl-coding-assistant · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**No COA provided** → **ask. Don't invent accounts.** *Mosofin note*: normally `[auto]`; this applies when
the read is unavailable, and **the fallback in use must be stated.**

**No jurisdiction provided** → **skip tax codes or mark "TBD".** *Mosofin note*: the country is `[auto]`;
**the rules are not**, so a known country does not license a tax treatment.

**Multi-currency transactions** → **code based on nature; do not convert FX here. Flag for
FX revaluation.**

**Reimbursable vs. own-cost** → **if the entity passes through expenses to clients, ask whether there's a
separate Recoverable / Reimbursable account.** **[auto]** to check whether such an account exists.

**Credit card payments to the card** → **flag as transfer (bank → CC liability), not expense.**

**Vendor invoices with multiple line items** → **suggest per-line coding if detail exists; flag for split if
only a total is available but the invoice covers mixed categories.** **[auto]**: where the bill is already in
the system, **the line detail is readable** (*`get_bill`*).

**Refunds and chargebacks** → **contra to the original expense, not "Other Income".** **[auto]** support:
the original expense is findable by vendor and amount.

**Bulk-batched amounts** — e.g. a single PAYROLL line → **flag for `payroll-journal-entry-builder`.**

**Coding history is consistent but wrong** — *Mosofin-specific, and the central caution*. Two years of
consistent miscoding produces a confident, well-evidenced recommendation to continue. **Frequency is
practice, not correctness**, and a supplied policy overrides it.

**Coding history is inconsistent** — *Mosofin-specific*. **Report the split; do not pick.** The category was
probably never decided, and deciding it is the useful output.

**The vendor's default account differs from its actual history** — *Mosofin-specific*. Defaults are set once
and overridden thereafter. **Read the history.**

**Duplicate vendor records split the history** — *Mosofin-specific*. Neither record shows the full picture,
and both will be miscounted. Flag it.

**The uncategorized account is growing** — *Mosofin-specific, and worth surfacing unprompted*. It is the
backlog, with ages and amounts, and it is readable in one call — the posted backlog only; bank-feed items
awaiting review are not in it.

**A vendor is another group entity** — *Mosofin-specific*. An intercompany balance, not a third-party
expense. Detectable by comparing names across connected files.

**A group transfer is flagged as an inter-account transfer** — *Mosofin-specific*. The original's rule covers
the entity's **own** accounts. Money to a sibling company is intercompany in both ledgers.

**A batch spans two entities** — *Mosofin-specific*. Confirm entity before coding, not after.

**A result comes back with `mock: true`** — *Mosofin-specific*. **Fixture history is not this entity's
history.** Downgrade every history-based confidence to Low and say why.

**A stored rule conflicts with the ledger history** — *Mosofin-specific, and the rule wins*. A user
correction is a decision; history is only practice. **Say that the two disagree.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's account numbers to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
