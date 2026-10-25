<!-- budget-vs-actual-analysis · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 10. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Actuals by line, by month** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` (Month), `accounting_method`, `department`, `class`, `customer` |
| **The budget, by account and period** | `search_budgets` | `name`, `active`/`limit`, `include_details`, `detail_start_date`, `detail_end_date`, `detail_account`, `detail_rollup` |
| Chart of accounts and line types | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Reporting groupings | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Transactions behind a variance; one-off detection | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Accrual true-ups and reclassifications | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Revenue by customer (mix, concentration) | `get_customer_sales` | `start_date`, `end_date`, `customer`, `summarize_column_by` |
| Units, prices and product mix | `search_invoices` / `read_invoice` / `search_items` | `start_date`, `end_date` (required); `id`; `query`/`name` |
| Spend by supplier behind a cost variance | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Bills and their dates (timing variances) | `search_bills` / `get-bill` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Headcount for personnel decomposition | `search_employees` | `query`/`name`, `active_only` |
| Billable hours (services volume) | `search_time_activities` | `start_date`, `end_date` (required), `customer_id` |
| Balance-sheet context for accrual movements | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Fiscal calendar and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Budget vs. actual (BvA)** — comparing what happened to what you planned.
- **Variance** — the gap between them.
- **Favorable / unfavorable (F/U)** — whether the gap is good or bad, which depends on the line
  type, not the sign.
- **FP&A** — financial planning and analysis: the function that plans, forecasts and explains.
- **Materiality threshold** — the size below which a variance isn't worth explaining.
- **Decomposition** — breaking a variance into the reasons for it.
- **Volume variance** — the effect of selling or using a different quantity.
- **Price / rate variance** — the effect of a different price or unit cost.
- **Mix variance** — the effect of a different blend of products or customers.
- **Efficiency variance** — using more or less input per unit of output than planned.
- **FX variance** — the effect of exchange rates moving.
- **Constant currency** — restating at one exchange rate so currency movement is stripped out.
- **Timing variance** — it will still happen, just in a different period.
- **Permanent variance** — a real departure from plan.
- **Run-rate** — the annualised level implied by a recent period.
- **True-up** — correcting an earlier estimate once the real figure is known.
- **Phasing** — how an annual budget is spread across months.
- **Waterfall / bridge** — a chart showing how you got from one number to another in steps.
- **QTD / YTD** — quarter to date / year to date, measured against the *fiscal* year.
- **YoY** — year on year.

---
