<!-- cash-application · overview.md · read for: background — what the skill does and why; read when a user asks why. Edit here, not in SKILL.md. -->

# Cash Application (Mosofin)

Applies customer payments to specific open invoices. Handles **partial payments, short pays, lump
payments covering multiple invoices, lockbox files, and unidentified deposits**.

**In plain words:** money arrives from a customer. Somebody has to decide which invoices it was
meant to pay. That sounds trivial and is not: the name on the bank line often isn't the customer's
name, the amount often doesn't match any single invoice, and when it is short you have to work out
whether that is a discount, a bank fee, a tax withheld at source, or a complaint nobody told you
about. This skill does that matching and writes the entry.

This skill is **jurisdiction-agnostic** — it applies whatever tax and discount rules the user
identifies.

It is **not** system-agnostic. It is **workspace-scoped**: every invoice, payment, customer and
account name comes from a tool call against a company file connected to your Mosofin workspace in
this conversation, or from something you supplied by hand and that is labelled as such.

**Related work:** a lockbox cash-application skill, queued for this library, covers the same
ground from the **operations** angle — the deduction-case workflow, the unapplied-cash aging, and
the daily tie-out to bank deposits. **This skill covers the matching logic and the resulting journal
entry in detail.** When that skill ships, the two share the same evidence base and should agree.

**The structural limit, stated up front.** Mosofin connects the **accounting system**. It reads
payments **once they are recorded** and it reads the **open invoice population** in full. It cannot
read a **lockbox file**, a **bank statement**, a **remittance advice** arriving by email or EDI, or
a **payment processor's settlement report** — unless that processor is itself a connected
datasource.

So the honest shape here is:

- **`[auto]` and strong**: the open invoice population with balances and dates; the customer master
  for fuzzy payer matching; payments already recorded and what they were applied to; credit memos
  that may explain a short pay; the deposit-versus-receipts comparison that reveals a netted fee.
- **`[manual]`**: the incoming payment file itself where payments are not yet recorded, every
  remittance advice, FX rates, and withholding tax certificates.

**Mosofin is read-only.** It cannot apply a payment, create a customer credit, post a write-off, or
move anything out of unapplied cash. Every application below is a *proposal* for a human.

---
