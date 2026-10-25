<!-- gl-coding-assistant · tools-and-glossary.md · read for: Stages 2–3 for a tool name, any Stage for a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 6. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **The real chart of accounts, plus suspense accounts** | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The coding history — Tier 1 evidence** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Prior transactions by vendor, with their accounts** | `search_purchases` / `search_bills` / `search_expenses` | `start_date`, `end_date` (required) |
| Vendor master, defaults, addresses | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **The tax codes configured in this entity** | `search_tax_codes` / `search_tax_rates` | varies |
| Related-party name comparison | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| Loan balances, for the interest / principal split | `get_balance_sheet` / `get_general_ledger` | `start_date`, `end_date`, `account` |
| **Country, industry, currency** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no tax rule engine, no capitalization policy and no receipt image on this surface.**

---

## Plain-language glossary

- **GL coding** — deciding which account a transaction belongs in.
- **Chart of accounts (COA)** — the list of headings this business uses.
- **Uncategorized / suspense account** — where transactions sit when nobody has decided yet. **A growing
  balance there is a backlog.**
- **Vendor normalization** — stripping the noise a bank feed adds to a merchant name.
- **Payment-processor prefix** — the "SQ *" or "PAYPAL *" that shows who processed the payment rather than
  who sold you anything.
- **Tier / decision hierarchy** — trying the most reliable rule first and only falling back when it does not
  apply.
- **Confidence rating** — how much the suggestion should be trusted before someone checks it.
- **Tax code** — the label controlling how sales tax or VAT is treated on a transaction.
- **Input credit / recoverability** — whether tax paid on a purchase can be reclaimed.
- **Reverse charge** — where the buyer, not the seller, accounts for tax on a cross-border service.
- **Capitalization threshold** — the amount above which a purchase becomes an asset rather than an expense.
- **Contra** — an entry reducing another account rather than creating a new one. **A refund is a contra, not
  income.**
- **Inter-account transfer** — moving your own money between your own accounts. **Not income and not
  expense.**
- **Related party** — an owner, director, employee or connected business. Their transactions need separate
  treatment.
- **Split coding** — dividing one payment across several accounts.

---
