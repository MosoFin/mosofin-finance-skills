<!-- month-end-close-checklist · tools-and-glossary.md · read for: any Stage — when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **The chart — the scoping instrument** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Status evidence for every entry-based task** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **The tie-out and inter-period continuity check** | `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Balance sheet, current and prior | `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| **Reasonableness review and variance** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` |
| **Cutoff evidence around the period boundary** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Subledger cutoff populations | `search_invoices` / `search_bills` | `start_date`, `end_date` (required) |
| Segment structure | `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| **Industry, currency, period ends** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no bank statement, no close software, no task tracker and no team calendar on this surface.**

---

## Plain-language glossary

- **Close** — finishing a period's accounts so they can be reported.
- **Cutoff** — the line between this period and the next. **Getting it wrong moves profit between
  months.**
- **Subledger** — the detailed records behind a summary account: receivables, payables, inventory, fixed
  assets.
- **Adjusting entry** — an entry made at period end to record something no transaction captured:
  depreciation, an accrual, a release.
- **Reconciliation** — comparing a ledger balance to something outside the ledger. **That "outside" is why
  most reconciliations cannot be confirmed from the books alone.**
- **Control account** — a summary account fed by a subledger.
- **Soft close** — locked for reporting, still adjustable. **Hard close** — final, as at quarter or year
  end.
- **Critical path** — the chain of tasks whose delay delays everything.
- **Dependency** — a task that must finish before another can start.
- **Materiality** — the size below which an error would not change anyone's decision.
- **Inter-period continuity** — this period's opening balances equalling last period's closing ones. **A
  break means history changed after it was reported.**
- **Tie-out** — the final set of proofs that the books are reportable.
- **Books locked** — the period is closed in the system and no further posting is allowed.
- **Re-open** — unlocking a closed period. **Always a documented decision, never a quiet one.**
- **Topside adjustment** — an entry made above the subledgers, usually at consolidation.

---
