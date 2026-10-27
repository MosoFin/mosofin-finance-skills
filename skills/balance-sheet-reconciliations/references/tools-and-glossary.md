<!-- balance-sheet-reconciliations · tools-and-glossary.md · read for: when you need a tool name, an argument, or a term explained. Edit here, not in SKILL.md. -->

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
| GL balance per account at period end | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Balances as presented (current / non-current) | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Transaction detail behind a balance; roll-forwards | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Chart of accounts; find suspense / clearing accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| A/R supporting side | `get_aged_receivables` (`get_customer_balance` is **total only — not a substitute for the aging**; without the aging the support side is [manual]) | `report_date`, `customer`, `aging_method`, `num_periods` |
| A/P supporting side | `get_aged_payables` (`get_vendor_balance` is **total only — not a substitute for the aging**; without the aging the support side is [manual]) | `report_date`, `vendor`, `aging_method`, `num_periods` |
| A/R activity for the roll-forward | `search_invoices` / `search_payments` / `search_credit_memos` | `start_date`, `end_date` (required), `customer_id` |
| A/P activity for the roll-forward | `search_bills` / `search_bill_payments` / `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Manual entries (a frequent reconciling item) | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Deferred revenue receipts | `search_deposits` / `search_sales_receipts` | `start_date`, `end_date` (required) |
| Movements between own accounts | `search_transfers` | `start_date`, `end_date` (required) |
| Inventory item master | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| Dimensions, for misposting checks | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Tax codes and rates | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Attachment metadata (a schedule exists) | `search_attachables` / `get_attachable` | `query`/`name`; `id` |
| Period-end and base currency | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **General ledger (GL)** — the complete record of every transaction, summarised into accounts.
- **Subledger** — the detailed list behind one GL account (e.g. every unpaid invoice behind the
  A/R balance).
- **Control account** — the GL account a subledger must agree with.
- **Reconciliation** — proving the GL balance and its supporting detail agree, and explaining
  every difference.
- **Tie-out** — the proof that two numbers agree.
- **Reconciling item** — a legitimate reason the two sides differ.
- **Timing difference** — a difference that will clear by itself next period.
- **Permanent difference** — a difference caused by an error; it needs correcting.
- **Deposit in transit** — money banked but not yet showing on the statement.
- **Cutoff** — the point at which a period stops accepting transactions.
- **Misposting** — a transaction recorded in the wrong account or dimension.
- **Dimension** — an extra coding tag on a transaction (department, class, project).
- **FX revaluation** — restating foreign-currency balances at the period-end exchange rate.
- **Roll-forward** — opening balance, movements, closing balance.
- **Suspense / clearing account** — a temporary holding account; it should return to zero.
- **Reclass** — moving a balance from one account to another without changing the total.
- **Plug** — an unexplained figure inserted to force a total to agree. **Never acceptable.**
- **Right-of-use asset** — the asset recorded when you lease something.
- **Prior-period adjustment** — a correction to a period already reported.
- **Materiality** — the size above which a difference matters to a reader of the accounts.

---
