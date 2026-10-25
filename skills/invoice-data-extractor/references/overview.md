<!-- invoice-data-extractor · overview.md · read for: background for the card and Stage 1 — what the skill does, and why extraction is document work and validation workspace work; read when a user asks why. Edit here, not in SKILL.md. -->

# Invoice Data Extractor (Mosofin)

Extracts **structured data from vendor invoices** — PDFs, scans, photos — into **accounting-ready fields**.
Handles single invoices and batches. Designed to feed downstream workflows: **GL coding, AP entry,
three-way match, or accounting system import**.

**In plain words:** somebody sends a bill as a PDF. Before it can go into the accounts, every number and
date on it has to become a field — and before it gets paid, somebody should check it is a real supplier, a
bill for this company, and one nobody has already paid.

This skill is **jurisdiction-agnostic**. **It captures whatever tax fields appear on the invoice — rates,
jurisdictions, amounts — as they are; it does not assume any tax regime or recoverability rules.**

## Extraction is document work; validation is workspace work

**The invoice is not in the workspace.** Mosofin holds no PDFs, no images and no document store — **the
document comes from the user, and reading it is model work exactly as the original describes.** Steps 1
through 6 are unchanged in substance.

**But everything you would want to check that extraction against is readable**, and that is where this
skill gains most:

| Validation | How | Verdict |
|---|---|---|
| **Is this invoice already in the system?** | Vendor + invoice number + amount against posted bills | **[auto]** — **the highest-value check here** |
| **Is this a known vendor?** | Against the vendor master, by name, tax ID and address | **[auto]** |
| **Is the Bill-To the right entity?** | Against the connected company's legal name | **[auto]** |
| **Do the payment terms match the vendor record?** | Against the vendor master | **[auto]** |
| **Is there a PO to match to?** | Against purchase orders, where they exist | **[gated]** |
| **Has it already been paid?** | Against payments and the vendor balance | **[auto]** |
| **How is this vendor usually coded?** | Against posted history — see `gl-coding-assistant` | **[auto]** |
| **Is the currency plausible?** | Against the entity's currency and the vendor's history | **[gated]** |

**The duplicate check is the one that pays for the skill.** An invoice number already posted for that vendor
is a **double payment about to happen**, and it is a single query at exactly the moment it can still be
prevented. See `duplicate-invoice-detection` for the full matching discipline; the same rules apply.

**And one check the original specifies that cannot be fully performed here — stated plainly:**

> **Step 5's bank-detail fraud check.** The original says: *"If the user has prior invoices from the same
> vendor with different bank details, flag immediately."* **Vendor bank details are not exposed on this
> surface.** The prior invoices are readable; **their bank details are not.**
>
> **Report this check as NOT RUN**, with what it would have shown and how to perform it. **Do not substitute
> a weaker comparison and imply it covered the same ground** — this is the same gap named in
> `duplicate-invoice-detection` (Rule 7), and it is consistent across
> both skills.
>
> **What can be compared** is the **remit-to name and address** against the vendor master, which catches
> some redirection attempts and is worth doing. **It is not the bank-detail check.**

**Mosofin is read-only.** It cannot create a vendor, post a bill or schedule a payment. Extraction produces
a *proposal*.

---
