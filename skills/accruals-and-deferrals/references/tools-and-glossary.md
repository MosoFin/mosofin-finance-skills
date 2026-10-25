<!-- accruals-and-deferrals · tools-and-glossary.md · read for: when you need a tool name, an argument, or a term explained. Edit here, not in SKILL.md. -->

## Tool reference

Mosofin workflow tools — call by these bare names, whatever your client displays them as:

| Tool | What it does | Key arguments |
|---|---|---|
| `list_workspaces` | Lists / confirms the workspace(s). Gate 0. | none on the discovery call; then `workspace_ids`, `mode` (`single` / `multi`) |
| `get_agent_datasources` | Lists live connections and their `connected` flag. Gate 1. | `workspace_id` |
| `get_datasource_tools` | Lists a datasource's read tools and each one's `effective_policy`. Gate 2. | `workspace_id`, `datasource`, `data_source_id` (required when several company files are live) |
| `invoke_datasource_api_tool` | Reads business data. | `datasource`, `tool_name`, `params`, `data_source_id` (**every call**), `approved` (only after an explicit yes) |
| `get_skills` | Lists saved skills in this workspace. | `workspace_id` |
| `get_my_skill` | Fetches one saved skill's bundle. | `skill_id`, `confirmed` |
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools for this skill — **resolve the real names and policies from your Gate 2
catalog**; names and policies vary by workspace:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Chart of accounts (find the accrual accounts) | `search_accounts` | `query`/`name`, `active_only`, `max_results` |
| One account's detail | `get_account` | `id` |
| Every balance at period end | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Accrued liabilities / deferred revenue as presented | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Transaction detail behind a balance (roll-forward) | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Prior accruals and their reversals | `search_journal_entries` | `start_date`, `end_date` (required), `max_results` |
| Expense run-rate for estimates | `get_profit_and_loss` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Utility / service billing history | `search_bills` / `get_vendor_expenses` | `start_date`, `end_date` (required); `vendor`, `accounting_method` |
| What has already been billed to customers | `search_invoices` | `start_date`, `end_date` (required), `customer_id` |
| Unbilled hours for revenue accrual | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Contracted but unbilled work | `search_estimates` | `start_date`, `end_date` (required), `customer_id` |
| Customer money received in advance | `search_payments` / `search_deposits` / `search_sales_receipts` | `start_date`, `end_date` (required) |
| Sales by customer (commission basis) | `get_customer_sales` | `start_date`, `end_date`, `customer` |
| Employee population | `search_employees` | `query`/`name`, `active_only` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description
wins.

---

## Plain-language glossary

- **Accrual basis of accounting** — record income and costs when they happen, not when cash
  moves. **Cash basis** is the opposite.
- **Accrual** — an entry for something that has happened but hasn't been billed or paid yet.
- **Deferral** — an entry that pushes income or cost *forward*, because the money moved before
  the thing was earned or used.
- **GRNI** — "goods received, not invoiced": stock or supplies you've received but haven't
  been billed for. Handled by `ap-accrual-cutoff`.
- **PTO** — paid time off; holiday and leave employees have earned.
- **Deferred revenue** — money customers paid you for work you still owe them. A liability.
- **Unbilled receivables / accrued revenue** — work you've done and could bill for, but
  haven't.
- **Escheat** — handing unclaimed money (e.g. a never-redeemed gift card) to the state.
- **In arrears** — billed after the service, rather than before.
- **Day-count convention** — the agreed rule for counting days in an interest calculation
  (actual/365, actual/360, 30/360). The same loan gives different interest under each.
- **Compounding** — charging interest on unpaid interest.
- **True-up** — correcting an estimate once the real number is known.
- **Clawback** — a contract term letting the company take back money already paid, if
  conditions fail.
- **Vesting** — the point at which someone's entitlement to a payment or share becomes
  unconditional.
- **Materiality threshold** — the size below which a difference isn't worth chasing.
- **Functional currency** — the main currency the entity's books are kept in.
- **Chart of accounts (COA)** — the list of every account the books use.
- **Journal entry (JE)** — the balanced two-sided record that moves numbers between accounts.
  **DR** = debit, **CR** = credit, **BS** = balance sheet.
- **Reversing entry** — an entry that undoes an accrual at the start of the next period.
- **Roll-forward** — a table showing how a balance moved from opening to closing.
- **Restatement** — formally correcting a prior period's published figures.
- **Current vs non-current** — due within twelve months, versus later.
- **Output tax** — sales tax / VAT / GST collected from a customer on the authority's behalf;
  never your revenue.
- **OPEB** — other post-employment benefits, e.g. retiree healthcare.

---
