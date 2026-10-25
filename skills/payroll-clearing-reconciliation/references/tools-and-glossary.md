<!-- payroll-clearing-reconciliation · tools-and-glossary.md · read for: any stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **Every payroll liability, clearing and expense account** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Roll-forward anchors, both period ends** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Every movement, and the ageing — the central read** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Remittances out, by payee and date** | `search_payments` / `search_checks` | `start_date`, `end_date` (required) |
| **The payroll journals, and manual entries to clearing** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Payroll expense by period | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` |
| Headcount, for scale only | `search_employees` | `query`/`name`, `active_only` |
| Legal name, **country**, currency | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register, YTD and component tools appear in
**its own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no benefit provider statement, no court order and no bank statement on this
surface.**

---

## Plain-language glossary

- **Payroll clearing / suspense** — a holding account between recording the payroll and paying it out.
  **It should return to nil after each cycle.**
- **Withholding** — money deducted from pay on someone else's behalf: tax, pension, union dues. **It is
  never the employer's money.**
- **Employer-side charges** — what the employer owes on top of gross pay: social contributions, pension
  match.
- **Remittance** — paying a withholding over to whoever it belongs to.
- **Remittance cadence** — how often that must happen. **Set by the authority, not the employer**, and it
  determines what a correct balance looks like.
- **Garnishment / wage assignment** — a legally required deduction paid to a third party, usually under a
  court order.
- **Escheatment** — handing unclaimed money to the state after a statutory period. **A legal obligation with
  deadlines and penalties**, not a write-off option.
- **Unclaimed property** — money owed to someone who cannot be found. **Still theirs.**
- **Stale balance** — an amount sitting in a control account long past when it should have cleared.
- **Roll-forward** — opening, plus accruals, less remittances, equals closing.
- **YTD reconciliation** — checking the cumulative year's figures, which is what year-end forms are built
  from.
- **Retroactive pay** — an adjustment for a past period, paid now.
- **Direct deposit reversal** — a payment returned because the account was closed. **Creates a balance owed
  to the employee.**

---
