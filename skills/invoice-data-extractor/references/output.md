<!-- invoice-data-extractor · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **All dates in ISO `YYYY-MM-DD`**
- **All amounts numeric** — no currency symbols or commas; minus sign for negatives
- **Currency identified as ISO-4217 code or explicitly flagged ambiguous**
- **Vendor names consistent across a batch**
- **Every invoice has a Confidence rating**
- **Math is verified; discrepancies flagged, not hidden**
- **Missing fields are `null`, never guessed**
- **File naming**: `Invoices_Extracted_[YYYY-MM-DD]_[count]invoices.xlsx`
- **Audit trail: original document reference preserved**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any validation was performed
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every invoice carries a Validation Status** — Clean, Review or Stop — **separate from extraction
  confidence**, so a legible document with a serious problem is not marked High
- **Every invoice was checked against posted bills for a duplicate**, and any match is reported with the
  matching bill named and status **Stop**
- **Every invoice was checked against the vendor master**, with new vendors and duplicate vendor records
  flagged
- **The Bill-To was validated against the entity's legal name**, and an invoice for another entity is routed
  rather than posted
- **The bank-detail fraud check is reported as NOT RUN**, with what it would have shown and how to perform
  it, and **out-of-band verification is stated as the control for bank-detail changes**
- **The remit-to comparison is reported as what it is** — a partial proxy, not the bank check
- **Whether the invoice is already paid in the books is checked**, and any disagreement with a "PAID" stamp
  reported
- **Vendor names are consolidated against the vendor master's spelling**, not to a new variant
- **Service periods are captured** where shown, for downstream prepaid and accrual treatment
- **Freight and shipping are captured separately**, so inventory and fixed-asset cost treatment remains
  possible
- In a multi-entity run, **each invoice is routed by Bill-To with the routing confirmed**, the duplicate
  check considers other group entities, and a Bill-To matching no connected entity **stops rather than
  routing to the nearest match**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no duplicate check is reported as clean against mock
  data**
- Every extracted figure traces to the source document by filename and page; every validation traces to a
  tool result; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No invoice contents, amounts, bank details, remit-to addresses or documents are persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no vendor created, no bill posted, no payment scheduled
