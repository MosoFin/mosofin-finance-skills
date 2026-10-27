<!-- inventory-to-gl-reconciliation · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| Inventory category, reserve, shrinkage and variance accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The GL balances by inventory account** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Quantity on hand, unit cost, extended value, location** | `search_items` / `search_products` / `get_item` | `query`/`name`, `active_only`; `id` |
| **Movements, and the reserve roll-forward** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **The cut-off population around the period boundary** | `search_invoices` / `search_purchases` / `search_bills` | `start_date`, `end_date` (required) |
| Manual inventory adjustments | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| The location structure | `search_locations` | `query`/`name`, `active_only` |
| Legal name, currency, year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no physical count, no 3PL statement, no Incoterms and no warehouse team on this surface.**

---

## Plain-language glossary

- **Subledger** — the detailed stock records behind the single inventory figure in the accounts. **Sometimes
  a separate system, sometimes the same one.**
- **Control account** — the single inventory line in the general ledger that the subledger is supposed to
  add up to.
- **Physical count** — actually counting. **Full** counts everything at once; **cycle counting** counts a
  rotating subset continuously.
- **ABC stratification** — counting high-value items more often than low-value ones.
- **Shrinkage** — stock that has gone: theft, damage, spoilage, or errors nobody caught.
- **Overage** — more stock than the records say. **Usually an earlier error, not good news.**
- **Cut-off** — whether a receipt or shipment landed in the right period. **A large share of variances start
  here.**
- **In-transit** — goods on the move. **Whose they are depends on the shipping terms, not on where the lorry
  is.**
- **Incoterms** — the standard shipping terms that decide when title and risk pass.
- **Consignment-out** — your goods at someone else's site. **Still yours.** **Consignment-in** — their goods
  at yours. **Not yours, and not on your balance sheet.**
- **3PL** — a third-party logistics provider holding stock for you.
- **GRNI (goods received not invoiced)** — goods arrived, invoice hasn't. **Accrued, not a variance.**
- **WIP (work in progress)** — part-made goods: materials plus labour plus overhead so far.
- **PPV (purchase price variance)** — the difference between standard and actual purchase cost.
  **MUV (material usage variance)** — between standard and actual quantity used.
- **Negative inventory** — the system says you hold less than nothing. **Always an error.**
- **Reserve roll-forward** — opening reserve, additions, write-offs, releases, closing reserve.

---
