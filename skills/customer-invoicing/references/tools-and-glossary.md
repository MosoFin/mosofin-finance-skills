<!-- customer-invoicing · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| `create_skill` | Persists the evolved skill. Step 7. | `name`, `description`, `destination`, `files`, `datasources`, `confirmed` |

Typical evidence tools — **resolve real names and policies from your Gate 2 catalog**:

| Purpose | Typical tool | Key arguments |
|---|---|---|
| **Seller's legal name, address, base currency** | `get_company_info` | none (uses the connected company) |
| **Customer name, address, tax ID, default terms** | `search_customers` / `get_customer` | `query`/`name`, `active_only`; `id` |
| **Item descriptions, SKUs, prices, income accounts** | `search_items` / `read_item` | `query`/`name`, `active_only`; `id` |
| **Tax codes, rates and agencies in use** | `search_tax_codes` / `search_tax_rates` / `search_tax_agencies` | `query`/`name`, `active_only` |
| **Terms, including early-pay discounts** | `search_terms` / `get_term` | `query`/`name`, `active_only`; `id` |
| **The invoice sequence — next number, gaps, duplicates** | `search_invoices` | `start_date`, `end_date` (required), `query`/`name` (DocNumber), `max_results`, `offset` |
| **What this customer was last billed, and on what terms** | `read_invoice` | `id` |
| Revenue, output tax and deferred revenue accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| What the customer already owes | `get_customer_balance` / `get_aged_receivables` | `report_date`, `customer` |
| A quote this invoice may bill against | `search_estimates` / `get_estimate` | `start_date`, `end_date` (required), `customer_id`; `id` |
| Coding dimensions | `search_classes` / `search_departments` | `query`/`name`, `active_only` |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no invoice-creation tool, no tax-registration validation service and no e-invoicing submission
endpoint on this surface.**

---

## Plain-language glossary

- **Tax invoice** — an invoice meeting the legal requirements that let your customer reclaim the tax on it.
- **Tax point / date of supply** — the date that decides which tax period a sale falls in. **Not always
  the invoice date.**
- **Output tax** — tax you charge a customer. **Input tax** — tax you pay a supplier and reclaim.
- **Reverse charge** — a rule where the customer accounts for the tax instead of the supplier, common in
  cross-border B2B services. The invoice shows no tax and carries a required legend.
- **Zero-rated** — taxable at 0%, which is different from exempt: it still counts as a taxable supply.
- **Exemption certificate** — a customer's proof that they need not be charged tax.
- **Withholding tax** — tax the customer deducts from your payment and remits to their government on your
  behalf.
- **E-invoicing mandate** — a requirement to submit invoice data to a government portal, not merely send
  it to the customer.
- **Sequential numbering** — invoices numbered in an unbroken series; gaps can be a compliance problem
  because they suggest deleted documents.
- **SKU** — a product or service code.
- **Progress billing** — invoicing in stages as a long job advances.
- **Retainage / retention** — a portion the customer withholds until the job is signed off.
- **Deferred revenue** — money invoiced for work not yet done; a liability, not income.
- **Sales discount** — a reduction for paying early, recorded either in its own contra-revenue account or
  netted against revenue; use one method consistently.
- **Remit-to** — where and how the customer should send payment.

---
