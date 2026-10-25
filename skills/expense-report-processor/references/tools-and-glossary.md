<!-- expense-report-processor · tools-and-glossary.md · read for: any Stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **The real chart of accounts — no placeholders** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The claimant list and departments** | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| **Transactions already posted — the duplicate population** | `search_purchases` / `search_expenses` / `search_bills` | `start_date`, `end_date` (required) |
| **Corporate card activity** | `search_credit_card_charges` / `get_general_ledger` | `start_date`, `end_date`; `account` |
| **Clearing and payable movements and ageing** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Payable and Due-from-Employee balances | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Merchant recognition | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **Historical coding patterns** | `get_profit_and_loss` / `get_general_ledger` | `start_date`, `end_date`, `summarize_column_by` |
| Dimensions available for allocation | `search_departments` / `search_classes` | `query`/`name`, `active_only` |
| Legal name, **functional currency**, country | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There are no receipt images, no policy documents, no mileage rates and no per-diem tables on this
surface.**

---

## Plain-language glossary

- **T&E (travel and entertainment)** — the category of spending staff incur on the company's behalf.
- **Out-of-pocket** — the employee paid with their own money and wants it back.
- **Corporate card** — the company already paid; nothing is owed to the employee. **The distinction drives
  the whole reimbursement calculation.**
- **Prepaid card** — a company-funded card loaded in advance; also company-paid.
- **Per-diem** — a fixed daily allowance instead of reimbursing actual costs. **M&IE** — meals and
  incidental expenses.
- **Mileage rate** — an amount per mile or kilometre covering fuel and wear when staff drive their own car.
- **Deductible / non-deductible** — whether the tax authority lets the business subtract the cost from its
  taxable profit. Meals and entertainment are commonly restricted.
- **Input tax recovery** — reclaiming sales tax or VAT paid on a business purchase.
- **Reverse charge** — a VAT mechanism where the buyer, not the seller, accounts for the tax on a
  cross-border service.
- **Clearing account** — a temporary holding account where two halves of a transaction meet. **It should
  return to zero**; a residual is unmatched activity.
- **Due from Employee** — money the employee owes the company, usually a personal charge on a company card.
- **GL coding** — deciding which account each line belongs in.
- **SmartScan / OCR** — automatic reading of a receipt image; **it makes mistakes, and confidence scores
  exist for a reason.**
- **Split transaction** — one charge divided across several categories.
- **FX rate source** — which published rate is used to convert a foreign amount, and as at when.

---
