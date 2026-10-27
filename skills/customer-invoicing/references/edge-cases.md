<!-- customer-invoicing · edge-cases.md · read for: Stages 4–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multi-currency**: the invoice currency may differ from the functional currency. **The customer pays in
the invoice currency; the entity books in functional. Use the invoice date's FX rate for the AR booking.
FX gain / loss at receipt time.** The rate itself is **[manual]** — no rate source here.

**Customer PO required**: **some customers won't pay an invoice without their PO number on it. Validate
before sending.** *Mosofin note*: **detectable** — check whether prior invoices to this customer carried a
PO reference, and flag its absence before the invoice goes out rather than thirty days later.

**Progress billings** (construction, long projects): **bill against completed milestones. Each invoice
references the contract and the milestone(s) billed.** May trigger percentage-of-completion (POC)
accounting.

**Retainage**: **invoice the gross but expect partial payment, with the rest held until project
completion. Track the retainage receivable separately** — otherwise the aging shows a permanently overdue
balance that is not actually late.

**Credit terms with early-pay discount**: **state it on the invoice** (e.g. "2/10 Net 30"). **At payment
time, if the customer takes the discount, reduce AR / revenue net or use a Sales Discount contra
account.**

**Tax-exempt customers**: **capture the customer's exemption certificate. Apply zero tax. Mark "Tax
Exempt — Certificate #…" on the invoice.** The certificate is **[manual]**, and invoicing a customer
tax-free without one on file is the entity's exposure, not theirs.

**Cross-border B2B**: in many VAT jurisdictions, B2B cross-border services use **reverse charge** —
**invoice with 0% tax and the legend "Reverse charge — recipient to account for VAT". Apply only if the
jurisdiction's rules support it**, and only where the customer's tax registration is valid — which is
**[manual]** to verify.

**Customer in a jurisdiction requiring withholding tax**: the customer may withhold at source. **Book gross
AR but expect a partial cash receipt plus a withholding tax credit. Coordinate with the customer** — and
see `cash-application`, where the short receipt shows up.

**Refunds and credits**: a **separate document (credit memo)** — see `credit-memo-and-refund-handler`.
Never amend an issued invoice to reflect a credit.

**Re-issued / corrected invoice**: **usually requires voiding the original and issuing a new one with a new
number — depends on the jurisdiction's rules.** *Mosofin note*: a voided number still occupies the
sequence, which is why the gap check must distinguish voids from missing documents.

**Mandatory e-invoicing jurisdictions**: **data must be submitted to a government portal, not just sent to
the customer. The skill prepares the data; submission is via the platform** — and Mosofin cannot submit.

**The invoice was not actually created** — *Mosofin-specific, and the expectation to manage up front*.
Mosofin is read-only. The document and the data are prepared; entering or importing them is a human
action, and until that happens the invoice does not exist and its number is not reserved.

**A gap in the invoice number sequence** — *Mosofin-specific and directly detectable*. Usually a deleted or
voided invoice. In several jurisdictions an unexplained gap is a compliance finding, so report gaps with
their numbers rather than only a count. Test only inside the fixed range (Step 0): a number missing at the
edge of the search window is not a gap. A voided invoice still appears (at zero); a deleted one does not,
and only the audit log can confirm a deletion.

**A duplicate invoice number** — *Mosofin-specific*. Two documents with the same number is a genuine
problem, and in a multi-entity workspace it most often arises from two entities sharing a convention
without separate ranges.

**A price departing from both the standard price and the customer's history** — *Mosofin-specific*. Either
a concession or a keying error. Cheap to ask about before issuing; expensive afterwards.

**The tax ID on file is stale** — *Mosofin-specific*. The record holds what was typed, possibly years ago.
For reverse charge and cross-border treatment the registration's current validity is the basis of the tax
position, and it cannot be checked here.

**A company file is connected but not active** — *Mosofin-specific*. If it is the selling entity, no
invoice can be prepared from it. Name it and stop rather than drafting from a sibling.

**A result comes back with `mock: true`** — *Mosofin-specific*. A draft built on fixture data would carry
invented customer details to a real customer, and a fixture-derived number would collide with the real
sequence.

**A stored template holds live payment details** — *Mosofin-specific*. Do not persist them. Payment
instructions are the target of invoice fraud and belong in the system that controls them.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's numbering scheme or tax treatment to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
