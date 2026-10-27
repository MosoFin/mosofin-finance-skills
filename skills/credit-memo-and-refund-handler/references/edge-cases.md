<!-- credit-memo-and-refund-handler · edge-cases.md · read for: Stages 4–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Credit issued in a different period than the original invoice**: **post to the credit's own date. If the
credit is dated after a period end but relates to sales before it and that period is still open, propose
an accrual (`DR Sales Returns & Allowances / CR Refund Liability (or Allowance for Returns)`) in the earlier
period, reversed the next day — whether to book it is the user's call. Restate a prior period only to
correct an error. Note in the memo.** *Mosofin note*: **detectable
automatically** — compare the credit date against the invoice date and the fiscal year end.

**Foreign-currency credit**: **issue it in the invoice currency. Apply it at the original invoice rate; the
difference from the credit-date rate is a realised FX gain or loss on application.** A credit in a
different currency from the invoice cannot be applied; flag it. The currency mismatch itself is **[auto]**
to detect; the rate is **[manual]**.

**Partial sales return with a restocking fee**: **the restocking fee is income; reduce the credit by the
fee. Two-line treatment** — never a single net figure, or the fee income disappears.

**Customer overpaid and is now owed a refund**: **not a credit memo — it's a customer deposit / refund of
overpayment. Different posting (DR Accounts Receivable — or Customer Deposits, if the overpayment was
reclassified there — CR Cash). Flag for the user.** *Mosofin note*:
distinguishable — an overpayment sits as an unapplied *payment*, not as a credit memo.

**Vendor offers a credit as a discount on future bills (volume rebate)**: **this is a rebate, not a credit
against a specific bill. Different treatment — often Other Income or contra-COGS. Flag.** A rebate credited
against one arbitrary bill distorts that bill's cost.

**Chargeback where the original sale's tax has already been remitted**: **the tax reversal may not reduce
the current period's tax liability — depends on jurisdiction. Flag.**

**Credit memo with no original invoice**: **document the business reason; recommend an approval
workflow.** **[auto]** to detect, and worth listing every one in the period rather than only the credit at
hand.

**Inventory return where the item is damaged**: **the returned inventory's value may be less than original
cost. Capture the full credit to the customer, but bring inventory back at NRV. The difference is a
write-down** (Loss on Returns / Inventory Write-Down). **[manual]** — the books cannot tell you the goods
came back broken, and bringing damaged stock back at full cost overstates inventory.

**A credit exceeds the amount originally invoiced, net of earlier credits** — *Mosofin-specific and exactly checkable*. It needs management
approval. Report every instance found in the period, not only the one being processed — the historic ones
were never approved either.

**Tax on the credit does not mirror the original** — *Mosofin-specific*. Compute the expected reversal from
the original's tax codes and compare. A mismatch over- or under-claims tax and is invisible without the
original.

**A vendor credit posted to income instead of the original expense account** — *Mosofin-specific and
common*. The original bill shows where the cost went; the credit should reverse it there. Posting it to
income leaves the expense overstated and the margin wrong in two places.

**A second journal proposed when a credit is applied** — *Mosofin-specific*. Application is a sub-ledger
event; the general ledger already reflects the credit. A second entry double-counts it.

**Unapplied vendor credits ageing on account** — *Mosofin-specific and valuable*. Money the entity has
already negotiated and is not taking. Sweep for them every run and total them.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
credits are therefore unreviewed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A refund proposed on fixture data would send
real money against an imaginary invoice.

**A stored reason-to-treatment map is stale** — *Mosofin-specific*. Where a reason code starts producing
overridden treatments, revisit the map.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's approval threshold or tax position to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
