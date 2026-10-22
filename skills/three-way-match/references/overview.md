<!-- three-way-match · overview.md · read for: background — what the match is, which legs the system holds, the three near-substitutes, and related skills; read when a user asks why. Edit here, not in SKILL.md. -->

# Three-Way Match — Mosofin Seed

Performs a three-way match between a purchase order (PO), a goods receipt note (GRN) or proof of delivery, and a vendor invoice. Identifies pricing, quantity and authorisation exceptions **before payment.**

This is a **seed skill**, written to be rewritten the first time it runs against a real workspace.

---

## Everything depends on which legs the system actually holds

The match has three legs, and a connected accounting system holds them to very different degrees:

| Leg | Typically in the accounting system? | Verdict |
|---|---|---|
| **Vendor invoice** | **Almost always** — it is a bill in the AP ledger | **`[auto]`** |
| **Purchase order** | **Often, but not universally.** Many systems support POs; many businesses do not use them. | **`[auto]` if present** — check |
| **Goods receipt** | **Frequently not.** Receiving is a warehouse function, and the GRN commonly lives in an inventory or WMS system, on paper, or nowhere. | **Often `[manual]`** |

**So the first question is not how to match. It is how many legs exist.**

> **If the workspace holds only invoices, this is not a three-way match. It is an invoice review.**
>
> **If it holds invoices and POs but no receipts, it is a two-way match.**

**Say which one is being performed**, in the output and in the file name. Presenting a two-leg exercise as a three-way match misrepresents the control that was operated — and the missing leg is usually the receipt, which is the leg that proves the goods actually arrived. **The strongest exceptions in Step 4 — *item billed not received*, *quantity overbilling*, *short-shipment billed in full* — all require it.** Without receipts, those tests do not run, and their absence from the exception list must not read as their having passed.

**Check at Gate 2**, and check what the PO and receipt records actually carry — a system may hold POs with no line detail, or receipts with no quantities, either of which limits the match to header level.

### The change of shape where the legs do exist

The original is written **document by document**: *"uploading a PO + receipt + invoice trio."* That is how manual three-way matching works, because a person can only look at one trio at a time.

**A connected workspace changes the unit of work.** Every open invoice, every PO, every receipt is readable together, so the match runs across **the whole population, every period**, unattended.

That converts a per-invoice clerical check into **a standing control** — and it is precisely one of the ledger-evidenced controls that a SOX controls review can test at full population rather than by sample. **The exceptions found are the same; the coverage is not.**

### Three near-substitutes

**1. A PO number written on an invoice is not a match.** Vendors put PO references on their invoices as a courtesy, and AP staff frequently treat the presence of one as evidence the invoice is authorised. **It is a reference, not a verification** — the whole point of the match is to check that what the reference points to actually agrees.

**2. An item receipt posted in the accounting system is not a goods receipt.** Where someone posts a receipt to close out a PO — often at month end, often in bulk, often to make the PO stop appearing on a report — **the record is a bookkeeping action, not evidence that anybody inspected anything.** `[auto]` can spot the signature: receipts posted in batches, all on one date, all exactly matching the PO quantity, frequently by the same user who entered the invoice. That last combination is a segregation-of-duties finding as well as a match one.

**3. Matched is not approved.** A perfectly matching invoice from an unapproved PO is still unauthorised spending. Exceptions 11 and 12 in Step 4 are about authority, not arithmetic, and they are the ones a clean match will not surface.

---


---

## Related skills

| Skill | Relationship |
|---|---|
| `invoice-data-extractor` | Extraction of uploaded invoices, explicitly out of scope for the match itself. |
| `duplicate-invoice-detection` | Exception 9, in depth. |
| `vendor-statement-reconciliation` | The other direction: what the vendor thinks is owed. |
| `month-end-close-checklist` / `accruals-and-deferrals` | The GRNI accrual falling out of exception 7. |
| `inventory-to-gl-reconciliation` | Where received-not-billed goods sit in stock. |

Skills for SOX controls testing, fraud investigation, vendor onboarding, FX revaluation, sales tax and VAT, and standard costing are queued for this library and will be linked here when they ship.
