<!-- fixed-asset-register-and-depreciation · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 13. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| Asset, accumulated depreciation, expense and disposal accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| Gross cost and accumulated depreciation, opening and closing | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Additions and disposals — every FA account movement** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **The acquisition documents behind the debits** | `search_purchases` / `search_bills` / `get_bill` | `start_date`, `end_date` (required); `id` |
| **The threshold scan across expense accounts** | `get_profit_and_loss` / `get_general_ledger` | `start_date`, `end_date`, `account` |
| An asset list, where the platform exposes one | `search_fixed_assets` | varies — **often absent** |
| Depreciation allocation dimensions | `search_departments` / `search_classes` / `search_locations` | `query`/`name`, `active_only` |
| Legal name, currency, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no fixed-asset register, no useful life, no salvage value, no valuation and no physical
verification on this surface.**

---

## Plain-language glossary

- **Fixed asset / PP&E (property, plant and equipment)** — something the business owns and uses for years
  rather than sells.
- **Capitalize** — put the cost on the balance sheet instead of charging it as an expense now.
- **Capitalization threshold** — the amount below which something is simply expensed, however long it
  lasts, because tracking it is not worth the effort.
- **Depreciation** — spreading an asset's cost across the years it is used.
- **Useful life** — how long the business expects to use it. **Salvage / residual value** — what it will be
  worth at the end.
- **Net book value (NBV)** — cost minus depreciation charged so far. **Not** what it would sell for.
- **Accumulated depreciation** — the running total charged to date; a **contra account** shown as a
  deduction from cost.
- **Straight-line** — the same amount every period. **Declining balance / double-declining** — more early,
  less later. **Sum-of-the-years'-digits** — front-loaded, more gently. **Units of production** — by usage
  rather than time.
- **Convention** — the rule for the first and last part-month.
- **In-service date** — when the asset was ready for use, which starts depreciation. **Not** the purchase
  date.
- **CIP (construction in progress)** — an asset being built. **Not depreciated until it is in use.**
- **Componentization** — splitting one asset into parts with different lives (a roof, a boiler, a shell).
- **Impairment** — writing an asset down because it is worth less than its book value.
- **Recoverable amount / value in use** — IFRS measures of what an asset is really worth to the business.
- **MACRS, capital allowances, AIA, CCA, Section 179, bonus depreciation** — tax depreciation systems.
  **They rarely match book depreciation, and the difference creates deferred tax.**
- **Roll-forward** — opening balance, plus additions, less disposals, equals closing balance.
- **Held for sale** — an asset being sold rather than used; **depreciation stops.**

---
