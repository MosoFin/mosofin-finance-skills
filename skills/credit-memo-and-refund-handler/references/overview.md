<!-- credit-memo-and-refund-handler · overview.md · read for: background — the credit types, why Step 2 is automatable, and the unapplied-credit finding; read when a user asks why. Edit here, not in SKILL.md. -->

# Credit Memo and Refund Handler (Mosofin)

Processes **customer credit memos, customer refunds, vendor credit notes, and chargebacks**. Determines
the correct accounting treatment, produces posting inputs, and tracks application against the original
invoice.

**In plain words:** sometimes money has to go back the other way — a customer returns goods, a price was
wrong, a supplier over-billed you, or a card payment gets reversed. Each of those looks similar on the
surface and is accounted for quite differently underneath. This skill works out which one you have, what
happens to the tax, and how the credit gets used up.

This skill is **jurisdiction-agnostic** and **chart-of-accounts-agnostic**. It captures tax reversal
exactly as it appears on the credit memo and uses the user's COA.

It is **workspace-scoped**: original invoices, existing credits and open balances come from tool calls
against a company file connected to your Mosofin workspace in this conversation, or from something you
supplied by hand and that is labelled as such.

## Why this skill fits a connected workspace unusually well

**Step 2 — "validate against the original" — is fully automatable.** Every one of its four checks is a
query rather than a request:

- **Does the invoice exist?** — readable
- **Is the credit ≤ the invoice balance?** — readable, and a credit exceeding the balance is exactly the
  case the original says needs management approval
- **Is the period right?** — readable, including whether the original sits in a closed year
- **Does the currency match?** — readable

**And Step 3's discipline is checkable.** Tax on a credit must mirror tax on the original. The original
invoice's tax codes and amounts are readable, so "does this reversal actually mirror the original?"
stops being an instruction and becomes a test.

**One more finding worth running every time: unapplied credits sitting on account.** Both directions
matter, and the second is often overlooked:

- **Customer credits unapplied** — money you owe a customer that is quietly ageing. It overstates
  receivables and eventually becomes a refund request or unclaimed property.
- **Vendor credits unapplied** — **money you are entitled to and have not taken.** A vendor credit note
  sitting unused is a discount you already negotiated and are not receiving. This is the closest thing to
  free money in the whole pack, and it is one query away.

**Mosofin is read-only.** It cannot issue a credit memo, send a refund, or apply a credit. Every entry
below is a *proposal* for a human.

---
