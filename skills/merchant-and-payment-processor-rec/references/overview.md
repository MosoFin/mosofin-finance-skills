<!-- merchant-and-payment-processor-rec · overview.md · read for: background — what this reconciles and the error it exists to catch. Edit here, not in SKILL.md. -->

# Merchant and Payment Processor Reconciliation (Mosofin)

Reconciles **payment processor activity** — gross sales, fees, refunds, chargebacks, settlements — **to the
GL**. Designed for entities receiving payments through **Stripe, Square, PayPal, Braintree, Adyen, Shopify
Payments**, and similar.

**In plain words:** a customer pays £100 online. The processor keeps a fee, holds the rest for a couple of
days, and then sends a lump sum covering many sales at once, minus refunds and disputes. The accounts have
to show the full £100 as revenue, the fee as a cost, and the lump sum as it arrives — three things that
never happen on the same day.

This skill is **jurisdiction-agnostic** and applies the same decomposition logic to any processor's export
format.

**Where the numbers come from:** when Mosofin is connected and the user agrees, the general ledger side —
clearing balance, revenue, fees, refunds, chargebacks and recorded deposits — comes from tool calls against a
company file in the confirmed workspace. Otherwise it comes from the GL detail or trial balance the user
uploads. **The processor side may or may not be connected**, which decides how much of this
reconciliation is possible; see Gate 1.

## Two sides, and one error worth the whole skill

**This is a two-sided reconciliation, like an intercompany reconciliation**, and the same rule applies:
**a one-sided read is not a reconciliation.**

| Side | Verdict |
|---|---|
| **The GL side** — clearing balance, revenue, fees, refunds, chargebacks, recorded deposits | **`[auto]`**, always |
| **The processor side** — charges, fees, refunds, chargebacks, payouts, available balance | **`[auto]` if the processor is a connected datasource; `[manual]` otherwise** |
| **The bank statement** — proving the payouts actually arrived | **`[manual]`**, always — **there is no bank statement on this surface**, the same limit as `bank-reconciliation` |

**Establish at Gate 1 which case you are in**, because it determines whether Step 4's clearing roll-forward
can be compared to anything.

**And the error this skill should test for every time:**

> **Revenue recorded net of processor fees.** Step 7 names it: *"A common error is recognizing revenue net
> of processor fees — wrong."* **It is also detectable.** **[auto]**: if **revenue recorded from the
> processor approximates net payouts rather than gross charges**, and **the merchant processing fee account carries
> little or nothing** while a processor is clearly in use, **revenue is being recorded net.**
>
> **This understates revenue and understates expense by the same amount** — so profit is right and **every
> margin, every ratio and the revenue figure itself are wrong.** For an entity approaching a filing, a
> lender or a sale, it is a presentation error with real consequences. **It is extremely common in
> small-business books**, because the bank feed shows the net payout and that is what gets coded.

Three more `[auto]` contributions:

1. **The clearing account should clear.** Its balance and its age are readable — which surfaces **unsettled
   charges past the payout window** and **the pause-or-freeze case** where a processor stops paying out and
   the balance balloons.
2. **Recorded deposits are readable**, so the payout tie-out has a real second side even without the bank
   statement — **the ledger's record of the deposit**, which is not the same as the bank's but is the thing
   the GL is built on.
3. **Fee rate reasonableness** — fees as a percentage of gross, by period. **A rate that moves without a
   contract change** is one of the Step 9 exceptions, and it is measurable.

**Mosofin is read-only.** It cannot post an entry or settle anything. Every entry below is a *proposal*.

---
