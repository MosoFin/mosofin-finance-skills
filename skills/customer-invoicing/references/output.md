<!-- customer-invoicing · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Mandatory jurisdiction fields included or flagged for the user to confirm**
- **Each line has description, qty, price, tax — no blanks**
- **Math verified: subtotal + tax = total, line by line and in summary**
- **Invoice number unique within the entity's numbering scheme**
- **JE balances and books AR / Revenue / Tax separately**
- File naming consistent
- **Currency identified by ISO code**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- **The selling entity is named by `display_name`**, and its legal name and registration come from that
  entity's own profile — never a sibling's
- Every excluded company file is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **The output states plainly that Mosofin did not create the invoice** and that the number is proposed,
  not reserved
- **The next invoice number was read from the live sequence**, and the **gap and duplicate checks were
  run** with any gaps listed by number
- **Every pre-filled field states whether it came from the books or was supplied**
- **The tax point is captured separately from the invoice date** where they differ
- **Prices are compared against the item's standard price and the customer's own history**, and departures
  flagged
- **Every draft document is marked for review**, and payment instructions are confirmed from a trusted
  source rather than reproduced from memory
- Account names in every proposed JE are the **real names from the connected chart of accounts**, using the
  item's own default income account where one exists
- In validate mode, **every existing invoice's mandatory fields, line validity and arithmetic were checked**
  and the results reported
- `mock` status is reported wherever it applies, and **no invoice is drafted to a real customer on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No customer tax IDs, bank details or invoice contents are persisted** into a skill bundle; every
  persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no invoice was created, numbered, posted or sent
