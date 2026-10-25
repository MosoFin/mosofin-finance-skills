<!-- customer-invoicing · overview.md · read for: background — what the skill prepares and validates, and what a read-only workspace cannot do; read when a user asks why. Edit here, not in SKILL.md. -->

# Customer Invoicing (Mosofin)

Generates customer-facing invoices with full required content for any jurisdiction, including line
items, taxes, payment terms, and remit-to details. Produces the matching **AR / Revenue / Tax** journal
entry.

**In plain words:** an invoice is a legal document, not just a request for money. Most tax regimes
specify exactly what must appear on one before your customer can reclaim the tax — and if a field is
missing, they may refuse to pay until you reissue it. This skill builds invoices that carry everything
they need, and checks the ones you have already sent.

This skill is **jurisdiction-agnostic** and **chart-of-accounts-agnostic**. Tax handling, mandatory
invoice fields, and document numbering schemes vary widely by country — **the skill applies what the
user specifies**.

It is **workspace-scoped**: customer records, items, prices, tax codes, terms and the existing invoice
sequence come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## What this skill is, in a read-only workspace

**Mosofin cannot create an invoice.** It is read-only, so it cannot write a document into the accounting
system, allocate a number in that system's sequence, or send anything to a customer. **The invoice
document and the data are the deliverable; entering or importing them is a human action.** Say so plainly
rather than implying an invoice has been raised.

That constraint splits this skill into **two genuinely useful modes**, and the second is the one most
teams have never run:

**1. Prepare.** Build the invoice with almost everything pre-filled from the books:

- **Customer name, address and tax ID** — from the customer record
- **Your own legal name, address and registration** — from the company profile
- **Items, descriptions, SKUs and standard prices** — from the item list
- **Tax codes and rates in use** — from the tax catalogue
- **Payment terms** — the customer's own terms, and what prior invoices to them actually carried
- **The next invoice number** in the entity's existing sequence — an input the original marks *Required*
  and the workspace can simply answer

**2. Validate.** Run the same rules against **invoices already issued**. Step 1's mandatory-field check,
Step 2's line validation and Step 3's arithmetic check are all `[auto]` over existing invoices — plus
**duplicate numbers and gaps in the sequence**, which is a control matter: a missing number usually means
an invoice was deleted, and in many jurisdictions a gap in the sequence is itself a compliance problem.

**What stays `[manual]`:** what to bill and for how much, the jurisdiction's specific mandatory-field
list, exemption certificates, progress-billing milestones, and any e-invoicing submission.

**Mosofin sends nothing.** Every draft is marked for review.

---
