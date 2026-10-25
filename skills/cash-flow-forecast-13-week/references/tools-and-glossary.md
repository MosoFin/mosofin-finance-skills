<!-- cash-flow-forecast-13-week · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 9. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Identify cash / bank accounts, and restricted ones | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Opening cash by account** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Open invoices with due dates | `get_aged_receivables` | `report_date`, `customer`, `aging_method`, `num_periods` |
| Open bills with due dates | `get_aged_payables` | `report_date`, `vendor`, `aging_method`, `num_periods` |
| **Invoice dates and terms** (days-to-pay start date) | `search_invoices` / `read_invoice` / `get_term` | `start_date`, `end_date` (required), `customer_id`; `id` |
| **When invoices were actually paid** (days-to-pay end date) | `search_payments` / `get_payment` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Bill dates and when bills were actually paid | `search_bills` / `search_bill_payments` | `start_date`, `end_date` (required), `vendor_id` |
| **Recurring disbursement patterns** | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| **Actual weekly cash movement; payroll rhythm; annual one-offs** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Historical cash generation (sanity check) | `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by` |
| Deposits and transfers between own accounts | `search_deposits` / `search_transfers` | `start_date`, `end_date` (required) |
| Counterparty names for the detail sheets | `search_customers` / `search_vendors` | `query`/`name`, `active_only` |
| Credits reducing expected collections | `search_credit_memos` | `start_date`, `end_date` (required), `customer_id` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **13-week cash flow (TWCF)** — the standard short-term liquidity forecast, week by week.
- **Direct method** — forecasting actual money in and out, rather than starting from profit.
- **Receipts / disbursements** — cash coming in / going out.
- **Opening and closing cash** — the balance at the start and end of each week; one week's closing
  is the next week's opening.
- **Runway** — how long the cash lasts at the current rate.
- **Minimum cash threshold / floor** — the balance you must not go below, by policy or by covenant.
- **Headroom** — how far above the floor you are.
- **Covenant** — a promise to a lender, often that cash or a ratio stays above a level. Breaching it
  can make the loan repayable immediately.
- **Revolver** — a credit facility you can draw on and repay repeatedly.
- **Borrowing base** — the formula limiting how much of a facility you may actually draw, usually
  based on receivables and inventory.
- **Clean-down** — a requirement to repay a facility to zero for a period each year.
- **Days-to-pay** — how long a customer actually takes to pay, measured from invoice or due date.
- **Float / clearing time** — the delay between initiating a payment and the money moving.
- **Probability-weighting** — including an uncertain receipt at less than its full value.
- **Debt service** — scheduled loan repayments of principal and interest.
- **Capex** — spending on long-lived assets.
- **Distributions / dividends** — payments out to owners.
- **Earn-out** — a deferred payment on an acquisition, contingent on performance.
- **Restricted cash** — cash you cannot freely use, so not liquidity.

---
