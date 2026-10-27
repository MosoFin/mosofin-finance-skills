<!-- closing-entries-and-trial-balance · tools-and-glossary.md · read for: when you need a tool name, an argument, or a term explained. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 11. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Pre-closing trial balance; and the new-year auto-close test** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Every account with its type** (temporary vs permanent) | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Net income and the Step 4 category totals | `get_profit_and_loss` | `start_date`, `end_date`, `accounting_method`, `summarize_column_by` |
| Opening RE, closing equity, the Step 8 tie-out | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Dividends / draws declared; direct-to-equity postings | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Adjusting entries posted; any existing closing entry** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Fiscal year end, currency, legal name | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no tool to lock a period, and there never will be.**

---

## Plain-language glossary

- **Closing entries** — the year-end entries that empty the profit and loss accounts back to zero.
- **Trial balance (TB)** — a list of every account and its balance, where total debits must equal
  total credits.
- **Pre-closing / post-closing TB** — before and after the closing entries.
- **Temporary accounts** — revenue, expense and drawings accounts, which reset each year.
- **Permanent accounts** — assets, liabilities and equity, which carry forward.
- **Retained earnings (RE)** — accumulated profits kept in the business rather than distributed.
- **Income Summary** — an optional holding account used in the four-step method.
- **Adjusting entries** — the corrections and accruals posted before closing.
- **Dividends / distributions / draws** — money taken out by owners, under three names for three
  legal forms.
- **APIC (additional paid-in capital)** — money shareholders paid above the nominal share value.
- **Treasury stock** — the company's own shares it has bought back; a contra-equity account.
- **OCI (other comprehensive income)** — gains and losses that bypass the profit and loss account.
- **AOCI** — the equity account where OCI accumulates.
- **CTA (cumulative translation adjustment)** — the OCI item from translating a foreign business.
- **Recycling** — later moving an OCI item into profit and loss.
- **Revaluation surplus** — the IFRS reserve from revaluing assets upward.
- **Net assets with / without donor restrictions** — the nonprofit equivalent of equity.
- **Soft close / hard close** — a period closed but still amendable, versus one locked.
- **Roll forward** — carrying closing balances into the next period as opening balances.

---
