<!-- payroll-reconciliation · tools-and-glossary.md · read for: any stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| Every payroll expense and liability account | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Wages and employer cost expense — the Step 1 target** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `department` |
| **Liability roll-forward anchors** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Movements, ageing and manual adjustments — the central read** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Net pay disbursements and remittances, by payee** | `search_payments` / `search_checks` | `start_date`, `end_date` (required) |
| **Payroll journals and manual entries to payroll accounts** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Headcount, for scale only | `search_employees` | `query`/`name`, `active_only` |
| Legal name, country, **fiscal calendar** | `get_company_info` | none (uses the connected company) |

**Where a payroll platform is a connected datasource**, its register, wage base and YTD tools appear in
**its own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no payroll register, no taxable wage base, no bank statement and no filing on this surface.**

---

## Plain-language glossary

- **Payroll register** — the payroll system's detailed output for a run. **One of the four sources, and the
  only one holding wage bases.**
- **Register-to-GL bridge** — the schedule explaining why the payroll system's total and the accounts'
  total differ.
- **Taxable wage base** — the amount a particular tax is actually charged on. **Not gross**, and different
  for different taxes.
- **Pre-tax deduction** — something taken from pay before a tax is calculated, reducing that tax's base.
- **Cap / ceiling** — an annual limit above which a contribution stops. **Applies per employee, which is why
  aggregate arithmetic cannot recover it.**
- **Remittance** — paying a withholding over to whoever it belongs to. **Due dates are set by the
  authority.**
- **Unremitted liability past its due date** — money withheld from employees and not passed on. **Penalties,
  interest, and in many places personal liability for directors.**
- **Negative liability balance** — the accounts say the authority owes you. **Always an exception**: an error,
  a claim, or a prepayment to reclassify.
- **Wage statement** — the annual summary given to each employee for their own tax return. **Must agree to
  the filings and the GL before it is issued.**
- **Off-cycle run** — a payroll outside the normal schedule: a bonus, a correction, a final payment.
- **Third-party provider** — an outsourced payroll company that pays staff and remits taxes on the
  employer's behalf. **The employer remains liable if it does not.**
- **Capitalised labour** — wages charged to an asset rather than expense, so the register legitimately
  exceeds wage expense.

---
