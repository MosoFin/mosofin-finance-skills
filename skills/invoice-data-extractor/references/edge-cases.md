<!-- invoice-data-extractor · edge-cases.md · read for: Stages 3–4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Poor-quality scans / handwriting**: **Mark Confidence: Low. Output what's legible; mark unreadable fields
as `null`. Do not guess.**

**Multiple invoices in one PDF**: **detect page breaks — header repetition, new "Invoice #". Treat each as
separate. Confirm count with user.**

**Statement vs invoice**: **a statement summarizes multiple invoices — Beginning Balance, Charges, Payments,
Ending Balance. Detect and ask — statements are usually not posted; their underlying invoices are.**
*Mosofin note*: **a statement is genuinely useful for a different purpose** — reconciling the vendor's view
to the entity's payable balance, which is `[auto]` (*`get_aged_payables`*). **Offer that instead of
posting it.**

**Credit memos**: **negative amounts, "Credit Memo", "Refund", or parenthesized amounts. Tag as Credit Memo.
Output amounts negative for downstream processing.** Run the duplicate check against posted vendor
credits, not bills, and report whether the credit is already applied (Step 0).

**Foreign language**: **identify language, translate field labels, preserve original amounts and currency.
Note translation in output.**

**Embedded purchase orders**: **sometimes a PO is attached. Extract separately and link via PO #.**

**Recurring service invoices**: **service periods — e.g. "Service from Jan 1 – Jan 31" — matter for prepaid
amortization. Capture them.**

**Tax-inclusive vs exclusive prices**: **always identify which. Misreading inclusive as exclusive overstates
expense and understates tax.**

**Ambiguous date format**: **"03/04/2025" — use vendor country, language, or other date cues. Flag if
unresolved.** *Mosofin note*: **prior invoices from the same vendor show that vendor's convention.**

**Ambiguous currency symbol**: **"$" alone — never default to USD. Use vendor country, ISO code if shown, or
ask user.** *Mosofin note*: **the vendor's billing history is a strong cue** — and still a cue.

**Vendor / DBA / payee name mismatch**: **a vendor may operate under a different trade or payment name.
Capture all; flag the mismatch.**

**Math discrepancies on the invoice**: **if line items don't sum to subtotal, or subtotal + tax ≠ total,
capture as-is and flag. The invoice is the legal document; do not silently fix.** *Mosofin note*: **a failed
cross-check usually indicates a misread figure** — re-check the extraction before concluding the invoice is
wrong.

**"PAID" stamp or paid date shown**: **capture and flag. AP entry may not be needed, or only the unpaid
portion is.** *Mosofin note*: **whether it is paid in the books is `[auto]`**, and the two can disagree —
paid per the stamp but open in the ledger, or the reverse.

**Pro Forma invoices**: **not legal invoices — they're quotes. Flag and exclude from AP unless the user
explicitly wants to record them as a commitment.**

**The invoice number is already posted for this vendor** — *Mosofin-specific, and the highest-value
finding*. **A double payment about to happen.** Status: **Stop.**

**The vendor is not in the master** — *Mosofin-specific*. Not wrong in itself, but **a new vendor with an
immediate invoice is the shape of a fictitious-vendor scheme.** Flag for setup and review; do not accuse.

**Duplicate vendor records split the history** — *Mosofin-specific*. **The duplicate check is weakened**
because prior invoices are spread across records.

**The Bill-To is a different group entity** — *Mosofin-specific*. Route it, do not post it here.

**The Bill-To matches no connected entity** — *Mosofin-specific*. **Stop and ask.** Never route to the
nearest match.

**The bank-detail fraud check cannot run** — *Mosofin-specific, and it must be stated*. **Vendor bank details
are not on this surface.** Report NOT RUN; compare remit-to instead, and require out-of-band verification
for any change.

**A remit-to differs from the vendor master** — *Mosofin-specific*. Worth a question. **Not proof of
anything**, and not a substitute for the bank check.

**The extracted currency is one this vendor has never billed in** — *Mosofin-specific*. A cue worth
resolving before posting.

**A result comes back with `mock: true`** — *Mosofin-specific*. **A duplicate check against fixture bills
proves nothing**, and reporting "not previously seen" on that basis is worse than not checking.

**A stored invoice or amount is reused** — *Mosofin-specific*. Invoice contents are sensitive and are never
persisted. **Persist the conventions; never the documents.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
validate against the wrong entity's Bill-To list.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the validation as `[gated]` in the coverage sheet.

---
