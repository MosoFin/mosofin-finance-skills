<!-- ap-accrual-cutoff · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| Open purchase orders (GRNI population) | `search_purchase_orders` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One PO's line detail (qty, unit price) | `get_purchase_order` | `id` |
| Bills in the period, and after it | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results` |
| One bill's lines and service dates | `get-bill` | `id` |
| Vendor spend history (recurring pattern, variance) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by`, `accounting_method` |
| Outstanding vendor balances | `get_vendor_balance` | `report_date`, `vendor` |
| Vendor master | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Vendor credits to net off | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Payments already made | `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| Chart of accounts (find the accrual account) | `search_accounts` | `query`/`name`, `active_only` |
| Accrued-liability balance carried in | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Transaction detail behind the balance | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Prior accruals and their reversals | `search_journal_entries` | `start_date`, `end_date` (required) |
| Work performed, where time is tracked | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Tax codes and rates in use | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accounts payable (A/P)** — money you owe suppliers.
- **Accrual** — recording a cost in the period it happened, even though no bill has arrived.
- **Cutoff** — the discipline of putting each transaction in the correct period.
- **GRNI** — "goods received, not invoiced": it arrived, the bill hasn't.
- **PO (purchase order)** — the order you placed with a supplier.
- **GRN (goods receipt note)** — the record that the goods actually arrived.
- **Three-way match** — matching the order, the receipt, and the bill before paying. GRNI is
  what you find when the third leg is missing.
- **Staff augmentation** — contract staff working alongside your own employees.
- **Subsequent events** — things that happen after period end but tell you about the period.
- **Pro rata** — split in proportion, usually by days.
- **Straddle** — a service period that crosses the period end.
- **Input tax** — the recoverable sales tax / VAT / GST on things you buy.
- **Valid tax invoice** — the document most tax regimes require before you can reclaim tax.
- **Journal entry (JE)** — the balanced two-sided record that moves numbers between accounts.
  **DR** = debit, **CR** = credit, **BS** = balance sheet.
- **Reversing entry** — an entry that undoes an accrual on the first day of the next period.
- **Chart of accounts (COA)** — the list of every account the books use.
- **Functional currency** — the main currency the entity's books are kept in.
- **Materiality threshold** — the size below which a difference isn't worth chasing.
- **Prepaid** — you paid ahead for something you'll consume later. The opposite of an accrual.

---
