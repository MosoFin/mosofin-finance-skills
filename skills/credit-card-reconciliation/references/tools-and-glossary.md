<!-- credit-card-reconciliation · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| **Card charges posted, with merchant, amount and coding** | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required), `max_results`, `offset`; `id` |
| **Card liability movement: charges, payments, interest, fees** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| **Card liability balance at period end** | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| Card liability and expense accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **Payments made to the card** | `search_bill_payments` / `search_transfers` | `start_date`, `end_date` (required) |
| Merchant records and default coding | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`; `id` |
| Spend by merchant (recurring-subscription test) | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| **Evidence a receipt file exists** | `search_attachables` / `get_attachable` | `query`/`name`; `id` |
| Tax codes applied to charges | `search_tax_codes` / `search_tax_rates` | `query`/`name`, `active_only` |
| Cardholders set up as employees | `search_employees` / `get_employee` | `query`/`name`, `active_only`; `id` |
| Refunds and credits from merchants | `search_vendor_credits` | `start_date`, `end_date` (required), `vendor_id` |
| Coding dimensions | `search_classes` / `search_departments` | `query`/`name`, `active_only` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Corporate card** — a company card used by employees, where the company owes the balance.
- **Statement period** — the card issuer's billing cycle, which often does not match your accounting
  month.
- **Transaction date vs. posting date** — when you spent it, versus when the issuer recorded it.
- **Closing balance** — what the statement says you owe.
- **Reconciling item** — a legitimate reason the books and the statement differ, usually timing.
- **Payment in transit** — a payment sent but not yet showing on the statement.
- **Pre-authorization hold** — an amount a merchant reserves before the final charge is known.
- **Settled charge** — the final amount that actually goes through.
- **Chargeback / dispute** — challenging a charge with the issuer.
- **Cash advance** — withdrawing cash on a card; usually expensive and usually against policy.
- **Cashback / rewards** — value returned by the issuer; income or a cost reduction, per policy.
- **FX fee / foreign transaction fee** — the issuer's charge for a purchase in another currency.
- **Folio** — an itemised hotel bill covering several nights and charges.
- **Input tax recovery** — reclaiming sales tax / VAT / GST on business purchases.
- **Valid tax invoice** — the document most tax regimes require to reclaim tax. **A card slip is not
  one.**
- **Capitalization threshold** — the value above which a purchase becomes a fixed asset rather than an
  expense.
- **Suspense / uncategorised account** — where transactions go when nobody has decided what they are.
- **Business purpose** — the record of *why* a charge was incurred; required for meals and travel in most
  policies.

---
