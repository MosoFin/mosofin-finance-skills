<!-- journal-entry-builder · tools-and-glossary.md · read for: Stages 2–3 for a tool name, any Stage for a term. Edit here, not in SKILL.md. -->

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
| **The chart: numbers, names and types — the primary read** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Current balances on the accounts being touched** | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| **Accrual, prepaid, deferred and clearing balances — the Pitfall 1 check** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Whether a document already exists for this item** | `search_invoices` / `search_bills` | `start_date`, `end_date` (required) |
| **The numbering convention, and the original entry for a reversal or reclass** | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Net income for a closing entry | `get_profit_and_loss` | `start_date`, `end_date` |
| Legal name, **functional currency**, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no posting capability, no materiality policy and no tax rule engine on this surface.**

---

## Plain-language glossary

- **Journal entry (JE)** — the record of an accounting event as balancing debits and credits.
- **Debit and credit** — the two sides. **Not good and bad**: what each does depends on the account type.
- **Normal balance** — the side an account usually sits on. **Contra accounts sit on the opposite side to
  what their category suggests.**
- **Accrual** — recording something that has happened before the paperwork arrives. **Deferral** — holding
  back something paid or received before it has been earned or used.
- **Reversing entry** — undoing an accrual on the first day of the next period, so the real invoice posts
  cleanly.
- **Reclass** — moving a balance between accounts with no economic event behind it.
- **Correcting entry** — fixing an error. **Never by editing the original**, which destroys the audit trail.
- **Mirror entry** — the matching entry in the other entity of an intercompany transaction.
- **Closing entry** — clearing profit and loss accounts to retained earnings at year end.
- **Control account** — a summary account fed by a subledger, like AR or AP. **Manual entries into one are
  an auditor red flag** because they bypass the subledger.
- **Clearing / suspense account** — a temporary holding place. **It should return to zero.**
- **Plug** — a figure inserted to make something balance. **Never acceptable without explaining what it
  is.**
- **Import template** — the column layout a particular accounting system expects.
- **Materiality threshold** — the size above which an entry needs extra review.
- **Proposal** — an entry prepared but not posted. **Everything this skill produces.**

---
