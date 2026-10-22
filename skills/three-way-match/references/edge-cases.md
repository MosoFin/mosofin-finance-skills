<!-- three-way-match · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All eleven preserved, in order.

**Multiple invoices against one PO** — progress billings: **each invoice matched against the PO; cumulative billed cannot exceed the PO total. Track a running balance.** **`[auto]`, and materially easier at population level** — the cumulative test requires seeing every invoice against that PO at once, which is exactly what a document-by-document match cannot do. **This is a case where the manual method structurally cannot perform the test properly.**

**Multiple POs combined on one invoice**: **split the invoice virtually and match per PO. Each invoice line maps to one PO.** `[auto]`.

**Service POs with no GRN**: **substitute a service-completion confirmation, signed by the service receiver. Treat the confirmation as the GRN equivalent.** `[manual]` — a signed confirmation is not usually in the accounting system. **And this is two-way by design**, per the Inputs note.

**Blanket POs with releases**: **match against the release, not the blanket. Roll up to the blanket for commitment tracking.** `[auto]` where releases are recorded; **matching an invoice to a blanket PO's total will pass almost anything**, which is why the release is the right unit.

**Partial deliveries / partial billing**: **match the delivered or billed portion. Carry forward the open balance. Multi-period matching tracked.** **`[auto]`, and again easier at population level**, since the open balance persists across periods and a per-trio match loses it.

**Substitutions** — vendor delivers a similar but different SKU: **if authorised, match by authorisation reference. Otherwise flag.** `[manual]` for the authorisation; `[auto]` to flag the SKU mismatch.

**Price changes mid-PO** — long-running POs where market price moved: **if the PO has a price-adjustment clause, the invoice price may legitimately differ. Confirm against the contract or clause reference.** `[manual]` — **the clause is in the contract, not the PO record**, and this is a common source of exceptions that are not errors.

**Multi-currency POs and invoices**: **convert at the PO's stated rate or the invoice date's rate per policy. Flag the FX treatment.** `[manual]` for the policy; `[auto]` for the conversion. **A price variance that is really an FX movement is the classic false positive here** — separate the two before raising exception 1; the translation itself is an FX revaluation task.

**Tax discrepancies** — PO had estimated tax, invoice has actual: **flag for total reconciliation; the tax line itself may not need a match if pricing aligns.** `[auto]`. **Note the use-tax angle: an invoice with no tax charged may create a self-assessment obligation**, which is a finding this population read can supply for free.

**Goods received before the PO was issued** — rush orders: **require retroactive PO approval. Flag as a process exception even if the amounts match.** **`[auto]` — compare the receipt date to the PO date**, which is a trivially cheap test and catches a real control breakdown that a value-based match never sees. **The amounts agreeing is precisely what makes it invisible otherwise.**

**Open POs received and billed but not yet matched in the system** — **backlog cleanup mode: match historic transactions and update commitment balances.** **`[auto]`, and this is where a population run earns its keep on the first engagement.** A business that has never run the match has a backlog; **clearing it is one query rather than months of clerical work**, and the GRNI figure that falls out of it is usually the most valuable single number produced.

---
