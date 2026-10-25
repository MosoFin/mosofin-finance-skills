<!-- payroll-journal-entry-builder · tools-and-glossary.md · read for: any stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **The chart: wages, withholdings, employer costs, clearing — the primary read** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The allocation dimensions** | `search_departments` / `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| **Prior payroll runs — the comparison and the template in use** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **Liability and clearing balances; whether the last accrual reversed** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Payroll expense by department, prior periods** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `department` |
| Headcount, as the comparison denominator | `search_employees` | `query`/`name`, `active_only` |
| Legal name, **country**, currency | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register and component tools appear in **its
own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no rate table and no benefit schedule on this surface.**

---

## Plain-language glossary

- **Payroll register** — the detailed output of a payroll run: every employee, every component. **The
  journal's source, and where the personal data stays.**
- **Gross pay** — the full cost of employing someone before anything is deducted. **The expense.**
- **Withholding / deduction** — money taken from gross pay and owed to somebody else: tax, pension,
  insurance, a court. **Never the employer's money.**
- **Net pay** — what actually reaches the employee. **A liability until it is paid.**
- **Employer costs** — what the employer owes **on top of** gross pay: social contributions, pension match,
  benefit costs. **Additional expense, not a deduction.**
- **The mixing error** — treating an employer contribution as an employee deduction, or the reverse.
  **Balances perfectly and is wrong.**
- **Payroll clearing** — a holding account between recording payroll and paying it out. **Should return to
  nil.**
- **Accrued payroll** — wages earned before the period end but paid after it.
- **Reversing entry** — undoing an accrual next period so the real payroll does not double-count.
- **Retroactive pay** — an adjustment for an earlier period, paid now.
- **Benefit in kind** — non-cash compensation that is still taxable. **Increases expense and the withholding
  base without affecting net pay.**
- **Capitalised labour** — wages that become part of an asset rather than an expense, because the work built
  something lasting.
- **Cost centre / department allocation** — splitting labour cost across the parts of the business that used
  it.

---
