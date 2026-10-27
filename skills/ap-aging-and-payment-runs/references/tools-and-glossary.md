<!-- ap-aging-and-payment-runs · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| A/P aging with due-date buckets | `get_aged_payables` | `report_date`, `vendor`, `aging_method` (Current / Report_Date), `days_per_aging_period`, `num_periods` |
| Open bills (and the raw material to reconstruct an aging) | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One bill's lines, terms and due date | `get-bill` | `id` |
| Payments already made against bills | `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| One bill payment's detail | `get_bill_payment` | `id` |
| Credits available to net off | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Total owed per vendor (tie-out only, **not** an aging) | `get_vendor_balance` | `report_date`, `vendor` |
| Vendor master, remit-to, terms | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Payment-terms catalogue, incl. discount terms | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| Payment methods in use | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| A/P control balance and bank balances | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Bank and A/P accounts | `search_accounts` | `query`/`name`, `active_only` |
| Transaction detail behind the A/P balance | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Spend history per vendor (concentration, patterns) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Purchase orders behind a disputed bill | `search_purchase_orders` / `get_purchase_order` | `start_date`, `end_date` (required); `id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accounts payable (A/P)** — money you owe suppliers.
- **Aging** — a list of unpaid bills sorted by how overdue they are.
- **Aging bucket** — a band of lateness (e.g. 31–60 days overdue).
- **Days past due** — how long a bill has been overdue, counted from its due date.
- **Payment run** — a batch of supplier payments sent out together.
- **Payment terms** — the agreed rules for when and how a bill is paid.
- **2/10 Net 30** — 2% off if paid within 10 days; otherwise the full amount at 30 days.
- **Early-pay discount** — a reduction for paying sooner than required.
- **Implied annualized return** — the discount expressed as an annual rate of return, so it
  can be compared with other uses of the same cash.
- **Late-pay penalty** — a fee or interest charged for paying after the due date.
- **Credit memo** — a credit from a supplier that reduces what you owe them.
- **Credit hold** — deliberately withholding payment, usually pending a dispute.
- **Remit-to entity** — the legal entity a supplier wants to be paid to, which is not always
  the name on the invoice.
- **Control balance** — the single total in the general ledger that the detailed list must
  agree with.
- **Tie-out** — the proof that the detail and the control balance agree.
- **Functional currency** — the main currency the entity's books are kept in.
- **FX gain / loss** — the difference caused by the exchange rate moving between when a bill
  was booked and when it was paid.
- **ACH / wire / cheque / card** — ways of moving the money.
- **Discretionary** — a supplier you could delay paying without the business stopping.

---
