<!-- credit-memo-and-refund-handler · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 7. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Customer credits recorded, and unapplied ones** | `search_credit_memos` / `get_credit_memo` | `start_date`, `end_date` (required), `customer_id`, `query`/`name`; `id` |
| **Refunds already paid out** | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required), `customer_id`; `id` |
| **Vendor credits held — including unapplied** | `search_vendor_credits` / `get_vendor_credit` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| **The original invoice: amount, balance, date, currency, tax codes** | `search_invoices` / `read_invoice` | `start_date`, `end_date` (required), `customer_id`, `query`/`name`; `id` |
| **The original bill, and the account the cost was booked to** | `search_bills` / `get-bill` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Open customer position, incl. credit balances | `get_customer_balance` / `get_aged_receivables` | `report_date`, `customer` |
| Open vendor position | `get_vendor_balance` / `get_aged_payables` | `report_date`, `vendor` |
| Sales returns, chargeback fee, write-off and tax accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Tax codes and rates on the original | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Item cost for a sales return | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| Cash impact of refunds paid | `search_purchases` / `get_general_ledger` | `start_date`, `end_date` (required); `account` |
| Base currency and fiscal year end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Credit memo / credit note** — a document reducing what a customer owes you, or what you owe a
  supplier.
- **Refund** — money actually sent back, rather than a credit held on account.
- **On account** — a credit sitting on a customer's or supplier's record, not yet used.
- **Application** — using a credit to settle part of an invoice.
- **Sales return** — goods coming back, which affects inventory as well as receivables.
- **Chargeback** — a customer reversing a card payment through their bank or card issuer.
- **Goodwill credit** — a credit given to keep a customer happy, not because anything was wrong.
- **Contra-revenue** — an account that reduces sales rather than adding to costs.
- **Sales returns & allowances** — the standard contra-revenue account for credits.
- **Output tax** — tax you charged a customer. **Input tax** — tax you paid a supplier and can reclaim.
- **Bad-debt relief** — the formal process some tax regimes require before you can reclaim tax on an
  unpaid invoice.
- **Restocking fee** — a charge for taking goods back, which reduces the credit.
- **NRV (net realisable value)** — what returned goods are actually worth now, which may be less than
  their original cost.
- **Volume rebate** — a discount earned by buying a lot, not tied to any one bill.
- **Merchant clearing** — the holding account for money moving through a card processor.
- **Sub-ledger** — the detailed customer or supplier records behind the general ledger totals.

---
