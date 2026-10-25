<!-- duplicate-invoice-detection · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Legitimate identical recurring invoices** (rent, monthly subscriptions): vendors do issue identical
amounts repeatedly. **Check invoice dates spread across months — if they're 30-ish days apart, that's a
pattern, not a duplicate. Filter these out at Rule 8 unless the dates overlap.** *Mosofin note*: store the
recurring suppliers at Step 7 so they stop recurring as false positives.

**Cross-period duplicates** (one invoice paid in December, another in January with the same number):
**flag — fiscal-year-boundary fraud is a known pattern.** *Mosofin note*: this is why the scan window
should extend beyond the period being reviewed.

**Vendor reissues an invoice** (original lost or corrected): both versions may exist in the register but
**only one paid. Verify against the payment ledger, not just the invoice register.** **[auto]** — and this
check is why the payment search matters as much as the bill search.

**Vendor merger / acquisition**: two vendor records may legitimately have shared a bank account during a
transition. **Flag and confirm.**

**Partial payments**: a vendor's invoice paid in two tranches **isn't a duplicate. Distinguish by checking
total paid against invoice total.** **[auto]**.

**Different currencies, same vendor**: amounts may "match" only after FX conversion. **Be cautious —
FX-converted matches are not high confidence. Flag for human review.**

**Voided / reversed entries**: **ignore voided records in the live duplicate scan, but include them in a
separate sheet to confirm voids were processed correctly.**

**Internal credit memo applied as a payment**: **not a duplicate payment, but may look like one in the
register if not coded properly.**

**Same vendor, same amount, different POs**: **legitimate if each PO references a different deliverable.
Check the PO reference field.** **[auto]** where bills carry PO references.

**Rule 7 could not be run** — *the central Mosofin-specific gap*. Vendor bank details are not on this
surface. **Report the rule as not run with a named owner**; a clean scan does not mean the fraud test
passed.

**A truncated population scanned** — *Mosofin-specific and a silent failure mode*. Duplicate detection
compares every record against every other; a partial population produces **false negatives that look
exactly like a clean result**. Paginate to completion and state the record count.

**Inactive vendor records excluded** — *Mosofin-specific*. A duplicate routed through a deactivated vendor
record is precisely what Rule 6 hunts. Search including inactive records.

**A duplicate paid by two group entities** — *Mosofin-specific*, and invisible to any single-entity scan.
Run the cross-entity match.

**Intercompany invoices flagged as duplicates** — *Mosofin-specific*. In a cross-entity scan, group
entities appear on both sides by construction. Exclude them from the counterparty population first.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say that its
payments were not scanned. In this skill an unscanned entity is an unchecked payment population.

**A result comes back with `mock: true`** — *Mosofin-specific*. A duplicate finding implies an error or
worse, and a recovery request to a real supplier on fixture evidence is worse than no scan.

**A previously cleared cluster reappears** — *Mosofin-specific*. Without the cleared list, the same false
positives return monthly and the report stops being read. Persist them and suppress them with their
reason visible.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the rule as `[gated]` in the coverage sheet.

---
