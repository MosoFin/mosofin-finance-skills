<!-- cash-application · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Lockbox files**: typically standardized formats from banks. Map fields to invoices automatically.
Some lockboxes include OCR'd remittance — **use it.** *Mosofin note*: the file itself is `[manual]`;
once its rows are supplied, matching against the open population is `[auto]`.

**Payment processor batch settlements** (Stripe, Square, PayPal): **one bank deposit = many customer
payments minus processor fees.** Decompose the gross sales, fees, refunds and chargebacks — see
`merchant-and-payment-processor-rec`. *Mosofin note*: if the processor is connected, this is
`[auto]`; if not, the deposit-versus-receipts comparison still detects that netting occurred, even
without the settlement report.

**Payment for an invoice not yet in the system**: **hold as a customer deposit; apply when the
invoice is created.** Do not force it onto an unrelated open invoice.

**Partial payment with no explanation**: **do not auto-write-off the residual.** Leave it open, flag
for collections.

**Payment from a related entity / parent paying on behalf of a subsidiary**: apply to the
subsidiary's invoices; **capture the parent as payer-of-record.** Coordinate with intercompany; clearing the pair is an
intercompany reconciliation.

**Reversed payment / NSF**: **reverse the cash application JE, restore the invoice to open, charge
any bank NSF fee.** *Mosofin note*: an invoice that reverts to open after being marked paid is
detectable in the payment history — check for it before treating a re-received payment as new.

**Customer pays in advance for not-yet-issued invoices**: **customer deposit, not revenue.** Hold
until the invoice is issued.

**Cross-border wire with intermediary bank fees deducted multiple times**: each correspondent bank
may take a cut. **Reconcile against the customer's intended amount, not just the entity's gross
receipt** — otherwise a series of small deductions looks like a customer dispute.

**Trade discounts vs. early-pay discounts**: trade discounts are typically **already netted in the
invoice**; only book **early-pay** discounts as a sales discount expense. *Mosofin note*: the
invoice and its terms are both readable, so which one applies is usually evidenced rather than
assumed.

**Withheld tax at source**: customers in some jurisdictions withhold tax. The entity received less
cash but gets a **withholding-tax credit**. **Track WHT receivable; reconcile to tax certificates
received from the customer.** The certificate is `[manual]`, and a WHT receivable with no
certificate is an asset you cannot yet claim — age them.

**The payer name does not match any customer** — *Mosofin-specific and the commonest cause of
unidentified cash*. Run fuzzy matching against the customer master, present the score and the
alternatives, and **store the confirmed alias** so it never recurs.

**Two open invoices share the same amount** — *Mosofin-specific*. A level-2 match is no longer
unambiguous. Drop to research or present both; do not pick silently.

**Several invoice combinations sum to the payment** — *Mosofin-specific*. Report the combination
chosen and note that another existed. This is where level-3 matching quietly goes wrong.

**The invoice search window excluded old invoices** — *Mosofin-specific*. A default recent range
will miss exactly the aged invoices a payment may be settling. Use the aging as the population and
state the window searched.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
whose invoices were therefore not available to match against. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
matching logic but must never drive a real application against a named customer.

**The payments are already recorded and applied** — *Mosofin-specific*. This becomes a **review** of
how they were applied, not a proposal to apply them. Say which of the two you did; they carry
different assurance.

**A stored payer alias is wrong or stale** — *Mosofin-specific*. An alias that has changed will
credit the wrong customer. Re-confirm when the match it produces is contradicted by amount or
timing.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
