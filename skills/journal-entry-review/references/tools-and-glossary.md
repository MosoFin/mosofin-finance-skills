<!-- journal-entry-review · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **The entry population, in full** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| **The chart with account types — the account-combination criteria** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Entries by account, and dormant-account detection** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Prior periods — the baseline and the pattern population** | `search_journal_entries` | `start_date`, `end_date` (required) |
| **The reserves-move-with-earnings test** | `get_profit_and_loss` / `get_balance_sheet` | `start_date`, `end_date`, `summarize_column_by` |
| Legal name, **period ends** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no approval workflow, no supporting document and no interview on this surface.**

---

## Plain-language glossary

- **Journal entry testing** — examining manual entries for signs of error or manipulation. **A required
  audit procedure**, because manual entries are how controls get bypassed.
- **Manual vs. system-generated** — typed in by a person, or produced automatically by a process. **Manual
  is where the risk concentrates.**
- **Topside entry** — an adjustment made above the subledgers, usually at consolidation, often by senior
  finance. **Higher risk and less visible.**
- **Management override** — senior people bypassing the controls that bind everyone else. **The classic
  fraud risk**, precisely because they can.
- **Back-dated entry** — recorded later than the date it claims. **One of the strongest single
  indicators.**
- **Segregation of duties (SoD)** — the person who posts an entry should not be the person who approves it.
- **Suspense / clearing account** — a temporary holding place. **Entries into one deserve attention because
  they are meant to be transient.**
- **Dormant account** — one with no normal activity. **Sudden use is unusual by definition.**
- **Net-zero entry** — an entry whose total effect is nil but which moves amounts between accounts.
  **Look at the movement, not the net.**
- **Risk scoring** — combining indicators so attention goes where it is most warranted.
- **Screen vs. review** — testing everything cheaply, then examining a few things properly.
- **Reserve smoothing** — adjusting provisions so reported results move less than the underlying business.
- **Escalation** — handing an unresolved anomaly to investigation. **Not an accusation.**

---
