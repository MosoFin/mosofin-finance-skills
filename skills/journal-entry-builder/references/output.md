<!-- journal-entry-builder · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every entry balances to the penny**
- **Every line has an account, an amount in either Debit or Credit — never both — and a memo**
- **Header memo explains the business event in plain language**
- **Account names and numbers match the user's COA exactly**
- **Entry type, date, reference always present**
- **Reversing entries clearly flagged with the reversal date**
- **File naming**: `[EntityName]_JE_[Description]_[YYYY-MM-DD].xlsx`
- **Never use "Plug", "Misc", "Other", or "Suspense" without explaining what needs to be resolved**
- **Never use account numbers not in the user's COA**

**Mosofin additions:**

- **Every entry is labelled a proposal and nothing is described as posted**
- The workspace was confirmed **by name** and the entity confirmed by `display_name` before the entry was
  built
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Every account was confirmed to exist in the live chart**, and a missing account is a hard stop; where
  the chart could not be read, **the placeholder fallback is stated**
- **Sign conventions were checked against real account types**, and any unusual direction carries a reason
  in the memo
- **Period status was checked**, and the warning distinguishes software-open from already-reported
- **The Pitfall checks were run**: no open accrual already covers the item, no open invoice exists for a
  receipt booked to revenue, a loan payment is split, and the target is not a control account
- **Clearing and suspense balances touched by the entry are reported with their age**
- **The validation result is delivered with the entry**, check by check, with the evidence behind each
- **The import format matches the connected platform** by default rather than by question
- **Where an original entry is referenced** — a reversal, reclass or correction — **its number and date come
  from the ledger**, not from memory
- In a multi-entity run, **each entry is built against its own entity's chart**, intercompany entries are
  mirrored against both real charts where both are connected, and **consolidation-only entries are labelled
  so they are never imported into a subsidiary**
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and **no entry is offered for import on fixture-validated
  accounts**
- Every account traces to the live chart and every validation to a tool result; the answer ends with a
  single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No amounts, balances, entry contents or transaction details are persisted** into a skill bundle; every
  persisted template states the datasource and `display_name` it covers
- Nothing was written back to any system — **no entry posted, reversed, altered or deleted**

---
