<!-- financial-statement-builder · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Mid-year statements with no closing entries**: **P&L accounts hold YTD balances directly. Don't post
closing entries to build the IS — just use the YTD balances.**

**Post-closing TB with all P&L accounts at zero**: **cannot build an IS from this alone. Need the period's
activity** — general ledger transactions or a pre-closing snapshot. *Mosofin note*: *`get_profit_and_loss`*
for the period supplies it directly, which is easier than the original assumes.

**Multi-entity consolidated statements**: **each entity's TB consolidated first,
then statements built from the consolidated TB. The consolidation
eliminates intercompany items.**

**Multi-currency**: **each entity in its functional currency; group reporting currency requires translation
per ASC 830 / IAS 21. CTA flows to OCI.**

**Discontinued operations** (US GAAP — ASC 205-20; IFRS 5): **presented separately on the IS, net of tax, on
a single line. Assets and liabilities of a disposal group held for sale separately on the BS. Prior periods
restated to reflect.** *Mosofin note*: **nothing in the ledger flags a disposal group** — `[manual]`, always.

**Investment company / specialized industry presentation**: **certain industries have specific statement
formats** — banks, insurance, REITs, registered investment companies. **Apply industry guidance.**

**Going-concern doubt**: **doesn't change the statements themselves but requires disclosure** in the notes
to the financial statements.

**Restated comparatives**: **if the prior period was restated** (correction of a prior-period
error), **present restated comparatives with disclosure.**

**Materially different from the auditor's expected statements**: **if the auditor's adjustments materially
change the statements, ensure those adjustments are in the TB before building.** *Mosofin note*: **this is
the single most important check in the skill, and it is `[manual]`.** The ledger will happily give you a
prior year that no longer matches what was filed.

**Reverse-stock-split or other capital restructurings**: **retrospective adjustment to all per-share data in
comparatives** — typically presented in the EPS section and notes.

**EPS (Earnings Per Share)**:
- **Required under US GAAP for public entities and IFRS for entities with listed equity**
- **Basic EPS = (Net income − preferred dividends) / weighted average common shares outstanding**
- **Diluted EPS = same numerator with dilutive securities effect; same denominator with dilutive securities
  added**
- **Hand off detail to a separate computation; result shown on the IS face**
- *Mosofin note*: **weighted average shares are not in the ledger** — `[manual]`, from the share register.

**Single-entity vs. consolidated presentation**: **parent-only statements may be required in some
jurisdictions in addition to consolidated. Use the same procedure on the parent-only TB.**

**The platform's balance sheet is presented as the finished statement** — *Mosofin-specific, and the
commonest shortcut*. It is a report in the platform's groupings, not framework presentation. **Reclassify,
then re-prove the balance on what you built.**

**Tie-out 1 is reported as a pass without reclassification** — *Mosofin-specific*. A system-sourced balance
sheet balances by construction. **The test only means something on your own statements.**

**The two periods were pulled on different accounting methods** — *Mosofin-specific, and invisible
downstream*. Pass the same `accounting_method` for both, and record it on the TB sheet.

**An account in the TB maps to no statement line** — *Mosofin-specific*. The commonest cause of a package
that stops footing. Check mapping completeness explicitly rather than trusting the totals.

**A by-function P&L is requested but the entity never tracked function** — *Mosofin-specific*. Say that it
is a reallocation, not a read, and ask for the basis.

**An AOCI balance exists with no supporting analysis** — *Mosofin-specific*. Report the balance and name
the analysis required; never present an unexplained movement.

**A company file is connected but not active** — *Mosofin-specific*. For a consolidated package this is a
**stop condition**, not a footnote: the statements would not cover the reporting entity.

**A result comes back with `mock: true`** — *Mosofin-specific*. **These statements go to banks, investors
and auditors.** Say so on the face of every statement, not in a footnote.

**A stored trial balance or statement figure is reused** — *Mosofin-specific*. All of it is state. Persist
the mapping and the presentation decisions; rebuild the numbers.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it, and stop
if the package is consolidated.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
