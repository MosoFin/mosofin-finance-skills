<!-- ar-aging-and-collections · tools-and-glossary.md · read for: any Stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

## Mosofin read-call reference

Use the logical Mosofin gateway below; **exact tool names come from `get_datasource_tools`**:

```json
{
  "datasource": "<datasource id, e.g. quickbooks>",
  "tool_name": "<catalog tool name>",
  "workspace_id": "<confirmed ws_... handle>",
  "data_source_id": "<selected company file id when required>",
  "params": {"report_date": "YYYY-MM-DD"}
}
```

Typical connector semantics — **verify each against your Gate 2 catalog; policies and
availability vary by workspace and by company file**:

- **`get_aged_receivables`** — as-of A/R aging summary; may be accrual-only. Key arguments:
  `report_date`, `customer`, `aging_method` (Current / Report_Date), `days_per_aging_period`,
  `num_periods`.
- **An A/R aging detail capability, when listed** — invoice-level customer, due date,
  transaction type, and open amount.
- **`search_invoices`** — selected invoice enrichment; **requires `start_date` and `end_date`**
  for transaction searches, which is exactly why it is not a complete aging population.
- **`read_invoice`** — one invoice in full. Key argument: `id`.
- **`search_payments`, `search_credit_memos`, `search_refund_receipts`** — reconciliation
  diagnostics. All require `start_date` and `end_date`.
- **`get_customer_balance`** — total owed per customer. Useful for a tie-out; **not an aging**.
- **`get_customer_sales`** — sales by customer, for concentration. It includes sales receipts
  (cash sales), so it is usable as a credit-sales basis only when filtered to invoices.
- **`search_customers` / `get_customer`** — customer master, for fuzzy-name resolution and
  contact fields.
- **`get_balance_sheet`** — the A/R control balance, for a true GL tie-out.
- **`get_general_ledger`** — transaction detail behind the A/R balance.
- **`get_profit_and_loss`** — **requires `start_date` and `end_date`**; use only for an
  approved approximate DSO proxy.
- **`get_company_info`** — company confirmation, base currency, fiscal calendar.

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this reference and the live description disagree, the live
description wins.

**Mosofin is strictly read-only. Do not call any send-reminder, create, update,
payment-application, or write-off capability.** None is exposed; do not look for one.

Envelope handling: `approval_required` → ask in chat, re-invoke the same tool with
`approved=true` (**reads only — never for a write**). `entity_required` → ask by `display_name`, then pass that `data_source_id`.
`tool_policy_disabled` → convert to `[manual]` and record the gap. Dead connection → surface
the `reconnect_url`.

---

## Plain-language glossary

- **Accounts receivable (A/R)** — money customers owe you.
- **Aging** — a list of unpaid invoices sorted by how overdue they are.
- **Bucket** — a band of lateness (e.g. 31-60 days past due).
- **Days past due** — how long an invoice has been overdue, counted from its due date.
- **Open balance** — what is still owed after payments and credits, as opposed to the original
  invoice amount.
- **Current** — not yet overdue.
- **Aging method** — the date lateness is counted to: the as-of date (*Report date*, used by
  this skill) or today (*Current*, not used). Not the same as the Current bucket.
- **DSO (days sales outstanding)** — the average number of days it takes to get paid.
- **Credit sales** — sales made on credit (invoiced), as opposed to paid on the spot. The
  correct denominator for DSO.
- **Concentration** — how much of the total is owed by a small number of customers; a risk
  measure.
- **Weighted average days past due** — the average lateness, weighted by how much money is at
  stake.
- **Dunning** — the routine sequence of payment reminders.
- **Credit hold** — deliberately pausing further service or credit for a customer.
- **Unapplied credit** — a credit sitting on a customer's account, not yet matched to an
  invoice.
- **Payment in flight** — money sent but not yet recorded or cleared.
- **Credit memo** — a document reducing what a customer owes.
- **Insolvency / bankruptcy** — a formal process when a customer cannot pay their debts; it
  changes what you are legally allowed to do.
- **Accrual basis** — income recorded when earned. **Cash basis** — recorded when paid.
- **GL control balance** — the single A/R total in the general ledger that the detail must
  agree with.
- **Tie-out** — the proof that two sets of numbers agree.
- **Provenance** — the record of exactly which call produced a figure and when.

---
