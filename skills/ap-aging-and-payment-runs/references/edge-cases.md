<!-- ap-aging-and-payment-runs · edge-cases.md · read for: Stages 4–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Vendor on credit hold** (the entity is intentionally withholding payment pending a dispute):
exclude from the payment run; show on a separate "Held" tab. **[manual]** — a hold is a
decision, rarely a field in the books — so hold status must come from the user or from a
stored preference, and a hold that has been forgotten is how a disputed bill gets paid by
accident.

**Credit memos applied to specific bills**: net the credit against the bill. Show the original
amount, the credit applied, and the net open amount — not just the net, or the tie-out to the
control balance will not be checkable.

**Partial payments already in flight**: payments recorded in the books are already in the
open amount — do not deduct them again. Ask for payments **scheduled or released outside the
books** (bill-pay platform, bank portal, cheques written but not entered) and deduct those,
labelled user-supplied. **[manual]**: no tool sees a payment that is not yet recorded, and
paying a bill that is already on its way is a genuine double-payment risk.

**Vendors with multiple billing entities**: group by **remit-to entity**, not just by vendor
name. Two vendor records with the same trading name may be different legal payees, and one
payee may bill under several names.

**Cross-border vendors with currency mismatch**: pay from a same-currency bank if one is
available; otherwise convert at the wire rate. Flag the FX cost.

**Vendor with both bills and credits open**: net to a single proposed payment — never pay
gross and wait for a refund of the credit.

**Bills approved but not yet due, where the vendor offers an early-pay discount**: surface them
in the discount tab even if the bill is not due in this run's window. The whole point of a
discount is that it expires before the due date.

**Statement-based vendors** (some prefer payment by statement total rather than per invoice):
group their bills and propose one payment with the list of bills it covers. Cross-check
against `vendor-statement-reconciliation` before paying a statement total.

**Bills with disputed line items**: pay the undisputed portion; flag the disputed amount on
hold. **[manual]** — a dispute is not a ledger field.

**Vendor change of bank details**: re-verify before sending payment to a new bank — **this is
the top payment-fraud vector**, and a convincing email asking to update bank details is the
most common way businesses lose money. Flag it and require user confirmation through a
channel the vendor did not supply. *Mosofin note*: Mosofin is read-only and cannot change,
verify, or transmit bank details, and this skill must never carry them into an output or a
stored preference. Each vendor the user names at intake (question E) is flagged on Sheet 3:
"Hold until confirmed by phone on a number from your records, not from the request." If the
user did not answer, Sheet 3 states "bank-detail changes not screened".

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say whose payables are therefore missing. Surface any `reconnect_url`.

**The aging report is `disabled` in this workspace** — *Mosofin-specific*. **Reconstruct** the
aging from bills, payments and credits, label it as reconstructed, and tie the total to the
A/P control balance. Do **not** substitute a vendor balance report: it gives one number per
vendor with no due-date buckets, which cannot answer what is overdue or which discount
expires this week.

**A reconstructed aging does not tie to the A/P control balance** — *Mosofin-specific*.
Report the gap rather than forcing the total. The difference is usually unposted bills,
bills outside the search window, or credits applied differently — say which you checked.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can illustrate the
aging but must never drive a payment run, because the payment would be real and the bill would
not be. Mark the run illustrative only.

**"Cash available" was read from a bank balance rather than confirmed** — *Mosofin-specific*.
A bank balance is not available cash: it has not netted off cheques in flight, imminent
payroll, or any minimum the business keeps back. Always ask; never infer.

**A bill has no due date in the books** — *Mosofin-specific*. Derive it from the terms record,
say that it was derived, and put the bill on the exceptions sheet. A derived due date drives a
bucket, a priority, and possibly a payment.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
