<!-- closing-entries-and-trial-balance · edge-cases.md · read for: Stages 3–4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**TB doesn't balance (debits ≠ credits)**: investigate before closing. Common causes:
- **Compute the imbalance amount**
- **Search for an entry of that exact amount** (often a one-sided posting)
- **Search for an entry of half that amount** (sign error: posted as DR instead of CR)
- **Check sub-ledger postings to the GL**
- **Check whether OCI items are appearing as net income items**
- **Check for a missing roll-forward of opening retained earnings**

*Mosofin note*: in a live double-entry system a genuine one-sided entry is usually impossible, so a
persistent imbalance more often means the report was requested with a different accounting method or
date range than expected. Check the request parameters before hunting a phantom transaction.

**Multiple ledgers / multi-entity**: **each entity closes its own books.** Consolidation is a separate
procedure. The closing entries are at the entity level.

**Closing in a multi-currency environment**: closing entries are **in functional currency. CTA flows
to AOCI, not RE.** Re-translation for consolidated reporting is separate.

**Sole proprietor / partnership / LLC**: **no Retained Earnings account.** Income closes to Owner
Capital or Members' Capital (per allocation). Distributions / draws close to the same. *Mosofin note*:
the equity account names in the chart make the entity type strongly inferable — propose, then confirm.

**Nonprofit**: typically uses **Net Assets** rather than RE, often split between **Without Donor
Restrictions** and **With Donor Restrictions**. Closing rolls the change-in-net-assets into the
appropriate net asset class. Fund-level detail is a nonprofit fund-accounting task.

**Prior period adjustment discovered after closing**: requires re-opening the prior year or restating
the prior period.

**Stock-based compensation expense closed to RE**: routine. **The accumulated SBC sits in APIC, not
closed. The expense is closed.**

**Treasury stock**: a **contra-equity account. Permanent, not closed.**

**OCI never recycled** (e.g. revaluation surplus under IFRS): stays in AOCI / Revaluation Surplus
indefinitely unless the asset is sold, when it may transfer directly to RE under IFRS.

**Discontinued operations / extraordinary items**: typically combined with continuing operations in
the closing entries unless presented separately on the P&L per the framework.

**Software / system behavior at year-end**: **some systems automatically close P&L to RE when the
fiscal year is advanced; the closing entry may not need explicit posting. Verify and document the
system's behavior so the entity doesn't double-close.** *Mosofin note*: **this is now a test, not an
assumption** — see Step 0b. Run it before proposing anything.

**Audit adjustments posted after preliminary close**: **re-run the closing entries with audit
adjustments included, or post a final-close adjustment. Document.** *Mosofin note*: ask at Gate 3
whether the audit is complete; a preliminary close that is then adjusted needs the tie-outs re-run.

**Late entries after close**: in soft-closed periods, may post with senior approval. In hard-closed
(year-end), typically requires re-opening and proper authorization. **Document everything.**
*Mosofin note*: detectable — entries dated within a closed year but created after it are visible in
the journal history.

**An account's type and name disagree** — *Mosofin-specific*. A liability-sounding account typed as
revenue will be closed to retained earnings and misstate it. Classify on **type**, and list every
name / type mismatch as an exception before closing.

**Mosofin cannot lock the period** — *Mosofin-specific*. Step 9's lock is the control that makes the
close real, and it is `[manual]`. Never report the period as locked; name the person who will do it.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose books are therefore unclosed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A closing entry misstates retained
earnings permanently; fixture data cannot support one.

**The profile's fiscal year end has changed** — *Mosofin-specific*. A changed year-end means a short
or long period. Read it back and confirm before closing anything.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply one entity's closing method or entity type to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
