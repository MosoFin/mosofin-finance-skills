<!-- cash-application · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on discovery; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 8. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The complete open invoice population** | `get_aged_receivables` | `report_date`, `customer`, `aging_method`, `num_periods` |
| Invoice detail: balance, dates, PO reference | `search_invoices` / `read_invoice` | `start_date`, `end_date` (required), `customer_id`, `query`/`name` (DocNumber); `id` |
| Customer master (fuzzy payer matching) | `search_customers` / `get_customer` | `query`/`name`, `active_only`; `id` |
| Payments recorded and their application | `search_payments` / `get_payment` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Deposits, and the netted-fee check | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| Receipts with no invoice behind them | `search_sales_receipts` / `get_sales_receipt` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Credits that may explain a short pay | `search_credit_memos` / `get_credit_memo` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Refunds already issued | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required); `id` |
| Terms, to evidence a legitimate early-pay discount | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| Balance per customer (tie-out) | `get_customer_balance` | `report_date`, `customer` |
| Unapplied cash, credit, discount, fee, WHT, FX accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Movement on unapplied cash (aging it) | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Payment methods in use | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Cash application** — deciding which invoices an incoming payment settles.
- **Remittance advice** — the customer's note saying which invoices a payment covers.
- **Lockbox** — a bank service that receives and banks your customer payments for you.
- **Payer name / bank string** — the name as the bank shows it: often truncated, upper-cased, and
  not the customer's legal name.
- **Short pay** — the customer paid less than the invoice.
- **Overpay** — the customer paid more.
- **Unapplied cash** — money received but not yet matched to an invoice.
- **Customer credit** — money held on a customer's account for future use.
- **Customer deposit** — money received before an invoice exists. Not revenue.
- **FIFO** — first in, first out: apply to the oldest invoice first.
- **Fuzzy matching** — matching names that are similar but not identical, with a similarity score.
- **Sales discount** — a reduction for paying early, recorded as a cost.
- **Trade discount** — a price reduction already built into the invoice; not recorded separately.
- **Withholding tax (WHT)** — tax the customer deducts and pays to their government on your behalf.
  You get a credit for it once they give you a **tax certificate**.
- **FX gain / loss** — the effect of the exchange rate moving between invoicing and payment.
- **Correspondent / intermediary bank** — a bank in the middle of a cross-border transfer that may
  take its own fee.
- **Batch settlement** — one bank deposit covering many card payments, net of fees.
- **Chargeback** — a card issuer reversing a payment.
- **NSF (non-sufficient funds)** — a payment that bounced.
- **Journal entry (JE)** — the balanced two-sided record. **DR** = debit, **CR** = credit.

---
