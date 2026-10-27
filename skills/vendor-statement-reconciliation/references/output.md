<!-- vendor-statement-reconciliation · output.md · read for: Stage 5 — the six sheets, the output quality standards and the coverage and provenance sheet; check before presenting. Edit here, not in SKILL.md. -->

## Outputs

All four of the original's outputs preserved, plus two additions. Delivered as an `.xlsx` workpaper.

**Sheet 1: Reconciliation Summary**
| Statement balance | Ledger balance | Difference | Explained | Unexplained |

**With both cutoff dates shown**, per Step 1, and the fixture flag. **The summary proves itself:** statement balance, then plus or minus each reconciling category (each subtotal ties to Sheet 3, with the timing items between the two dates listed one by one), equals the ledger balance at the same date. **Unexplained = Difference − the sum of the itemised explained amounts.**

**Below it, separately: Subledger to GL difference** — the AP ageing total against the AP control account, per Step 1. It is not part of the statement reconciliation.

**Sheet 2: Matched Item List**
| Statement doc | Ledger doc | Type | Date | Amount | Match tier | Notes |

**The Match tier column is the Mosofin addition** and it is what makes the sheet reviewable.

**Sheet 3: Exceptions Table**
| # | Item | Type of difference | Amount | Root cause | Owner | Next action | Target date | Age |

**Root cause, owner and next action are the original's** — **Age is added**, for recurring reconciliations.

**Sheet 4: Recommended JEs**
| Date | Account | Dr | Cr | Vendor | Support (doc ref) | Type (Accrual-reversing / Bill / Credit / Reclass) | Reversal date |

Book errors and confirmed missing entries, per the table in Step 5. **Marked PROPOSED — NOT POSTED**, and **accruals distinguished from invoice postings.**

**Sheet 5: Vendor Prioritisation** *(Mosofin addition)*
The Step 0 ranking — which suppliers should be reconciled, which never have been, which carry debit balances in your AP (overpaid), which show a broken invoice pattern.

**Sheet 6: Coverage and Provenance** *(Mosofin addition)*
The mandatory coverage sheet.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

File naming: `Vendor_Statement_Recon_[VendorName]_[YYYY-MM-DD].xlsx`

Entity `display_name` on every sheet — **and the statement's addressee**, per Gate 1.

---

## Output Quality Standards

*(A Mosofin addition — the original has no Output Quality Standards section.)*

- **Both cutoff dates are stated**, and the window between them treated as known difference.
- **The statement's scope is confirmed** — full open-item, overdue-only, or balance-forward.
- **The entity and account reference on the statement match the ledger being reconciled.**
- **The duplicate-vendor check runs before any "missing invoice" conclusion.**
- **Every matched item shows its match tier.**
- **Uncertain matches are left unmatched**, not forced.
- **Missing credits are reported separately and prominently** — they are money in the client's favour.
- **Missing invoices are classified** by likely cause, not lumped together.
- **Confirmed missing items are accrued, not posted as invoices**, until the document arrives.
- **Every exception has a root cause, an owner, a next action and a target date.**
- **Exceptions are aged across reconciliations**, so the ones that never close are visible.
- **Vendors are prioritised by amount and by whether they have ever been reconciled.**
- **Nothing is presented as posted.**
- **File naming consistent.**

---

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`), **and the entity the statement addresses**
- **Statement cutoff date and ledger cutoff date**
- **Statement scope** — full, overdue-only, balance-forward
- Vendor, and its account reference on the statement
- **Fixture flag** — any `mock: true`? In bold.

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict.

**Section C — Steps by verdict**
Every step. **A reader should see that one side of this reconciliation was read in full and the other was supplied.**

**Section D — What was not done, and why**
- **The vendor statement** — **the supplier sends it; it is not in any accounting system**
- **The dispute log** — correspondence
- **Invoice copies** for confirmed missing items — **required before posting, not before accruing**
- **Contact with the supplier**
- **Posting.** The gateway is read-only
- **On the upload path, any classification the files could not support** — payments in transit, misapplied payments and the paid half of a duplicate without payment detail; entered-late without activity after the cutoff; "missing invoice" without the vendor list or cross-vendor search

**Section E — Unknowns carried forward**
Unmatched items on both sides. Missing invoices awaiting copies. Credits not yet claimed. Exceptions open from prior reconciliations, with their age. Vendors on the Step 0 list not yet reconciled.

**Section F — Parameters used**
Cutoff dates. Normalisation applied to document numbers. Match tiers used and any fuzzy thresholds. Currency basis. **A reconciliation that cannot be reproduced cannot be rolled forward**, and this one should roll forward.

---
