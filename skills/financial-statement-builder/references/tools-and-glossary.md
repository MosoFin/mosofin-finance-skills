<!-- financial-statement-builder · tools-and-glossary.md · read for: any Stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 12. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The trial balance, both periods** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Account names, numbers and types** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Balance sheet, current and comparative | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Income statement, current and comparative | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by`, `accounting_method` |
| Platform cash flow report — **cross-check only** | `get_cash_flow_statement` | `start_date`, `end_date` |
| Movement detail behind any line | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Whether function tracking exists | `search_departments` / `search_classes` | `query`/`name`, `active_only` |
| **Legal name, currency, year-end** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no share register, no debt amortization schedule, no valuation and no prior-year audited file on
this surface.**

---

## Plain-language glossary

- **Trial balance (TB)** — the list of every account and its balance; the raw material of the statements.
- **Balance Sheet** — what the business owns and owes at a moment in time. **IFRS calls it the statement of
  financial position.**
- **Income Statement / P&L** — what it earned and spent over a period. **IFRS: statement of profit or
  loss.**
- **Statement of Cash Flows** — where the cash actually came from and went.
- **Current vs. non-current** — due or expected within twelve months, or later.
- **Operating cycle** — how long it takes to turn inventory into cash; for a few businesses it is longer
  than a year and replaces the twelve-month test.
- **By function** — grouping costs by what they were for (selling, admin). **By nature** — grouping by what
  they were (wages, materials).
- **Multi-step vs. single-step** — whether gross profit is shown as its own subtotal.
- **Comparative** — the prior period shown alongside, so the reader can see movement.
- **Restated comparative** — a prior period redrawn on the current basis after a reclassification or a
  correction.
- **OCI (other comprehensive income)** — gains and losses parked in equity rather than run through profit.
  **AOCI** is where they accumulate.
- **CTA (cumulative translation adjustment)** — the OCI item created by translating a foreign subsidiary.
- **Contra account** — an account that reduces another, such as accumulated depreciation or an allowance.
  **Shown as a deduction, never as a positive.**
- **Non-controlling interest (NCI)** — the share of a subsidiary owned by someone other than the group.
- **Discontinued operations** — a business being disposed of, shown on one line net of tax.
- **EPS** — profit per share. **Basic** uses shares actually outstanding; **diluted** assumes options and
  convertibles are exercised.
- **Tie-out** — proving two figures in different places agree.
- **Presentation vs. functional currency** — the currency the statements are shown in, versus the currency
  the entity actually operates in.

---
