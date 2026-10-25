<!-- merchant-and-payment-processor-rec · edge-cases.md · read for: Stage 3 (the net-revenue test) and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Reserves / holds**: **some processors hold a rolling reserve — e.g. 10% of last 6 months' volume. This is
the entity's asset, not the processor's revenue. Track Reserve Receivable separately from Available
Clearing.**

**Adjustments and chargeback fees**: **processors may charge fees for chargebacks even if the entity wins
the dispute. Track separately.**

**Cross-currency settlements**: **the processor may settle in a currency different from where the customer
paid. FX is real and material.**

**Promotional / partner credits**: **some processors offer fee waivers or credits — capture as Other Income
or contra-Fee per policy.**

**Multi-entity setups**: **one processor account serving multiple entities of a group. Each transaction must
be attributed to the correct entity; the clearing account is per entity.**

**Disputed transactions still open at period end**: **not yet a chargeback, not yet revenue. Some entities
reserve for likely losses; others wait. Document.**

**Subscription billing through processor**: **each renewal is a new charge; ensure recognition timing matches
the service period, not the billing event** (a revenue recognition question, outside this reconciliation).

**Application fees** — for marketplaces using Stripe Connect, PayPal and similar: **the processor splits the
gross between the marketplace's fee and the seller's net. The marketplace recognizes its fee as revenue; the
seller's portion is a pass-through. Special accounting.** *Mosofin note*: **recording the seller's portion as
revenue overstates the marketplace's revenue enormously**, and it is the same gross-versus-net question as
Step 7 in a more severe form.

**Tax collection by the processor** — e.g. **marketplace facilitator rules in some US states**: **the
processor remits sales tax directly. The merchant's revenue is net of that tax. Track which transactions are
processor-remitted vs. merchant-remitted.**

**Year-end balances**: **the chargeback period — typically up to about 6 months from sale per card network
rules — means revenue at year-end can be reversed in the next year. Consider a chargeback reserve if
material.** *Mosofin note*: **historical chargeback rates are readable**, which is the basis for sizing such
a reserve.

**Pause / freeze on the account**: **if the processor pauses payouts — risk reviews, KYC issues — the
clearing balance can balloon. Investigate and resolve.** *Mosofin note*: **the ageing and the lag trend catch
this early**, before the balance is large.

**Revenue recorded net of fees** — *Mosofin-specific test, and the most valuable one here*. Revenue ≈ net
payouts, a near-empty fee account, or no clearing account at all. **Understates revenue and expense equally,
so profit hides it.**

**No clearing account exists** — *Mosofin-specific*. The net payout is going straight to revenue or cash.
**No reconciliation is possible until one is created.**

**Comparing the wrong balance definitions** — *Mosofin-specific*. Available versus pending versus reserve.
**The difference is definitional, not an error** — state which pair was compared.

**Payouts tied to recorded deposits and presented as bank-verified** — *Mosofin-specific*. **Different
assurances.** Say which was performed.

**The charge-to-payout lag is lengthening** — *Mosofin-specific*. The earliest sign of a payout pause.

**The fee rate has drifted with no contract change** — *Mosofin-specific*. A measurable Step 9 exception.

**One processor account across entities reconciled once** — *Mosofin-specific*. **Two entities' clearing
accounts can be wrong in opposite directions and still net.** Run it per entity.

**A payout landing in one entity for another's sales** — *Mosofin-specific*. An intercompany balance, and
both sides must agree.

**A result comes back with `mock: true` on either side** — *Mosofin-specific*. A reconciliation against
fixture activity proves nothing.

**A stored fee amount or balance is reused** — *Mosofin-specific*. Both are state. Persist the rate policy
and the account map; recompute.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
reconcile against another entity's clearing account.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
