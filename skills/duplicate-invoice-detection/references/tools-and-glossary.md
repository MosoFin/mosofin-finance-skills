<!-- duplicate-invoice-detection · tools-and-glossary.md · read for: Stages 2–3 for a tool name, any Stage for a term. Edit here, not in SKILL.md. -->

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
| **The whole bill population — paginate to completion** | `search_bills` | `start_date`, `end_date` (required), `vendor_id`, `max_results`, `offset` |
| One bill's number, date, amount, PO reference | `get-bill` | `id` |
| **What was actually paid, when and how** | `search_bill_payments` / `get_bill_payment` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Direct payments bypassing the bill process | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required); `id` |
| **The vendor master — include inactive records** | `search_vendors` / `get-vendor` | `query`/`name`, `active_only`, `max_results`, `offset`; `id` |
| **Credits never applied (Rule 10)** | `search_vendor_credits` / `get_vendor_credit` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Spend per supplier, for clustering | `get_vendor_expenses` | `start_date`, `end_date`, `vendor`, `summarize_column_by` |
| Open vs. paid status | `get_aged_payables` / `get_vendor_balance` | `report_date`, `vendor` |
| Payment methods, for Rule 9 | `search_payment_methods` / `get_payment_method` | `query`/`name`, `active_only`; `id` |
| PO references, for the different-PO case | `search_purchase_orders` / `get_purchase_order` | `start_date`, `end_date` (required); `id` |
| Manual entries that bypassed AP | `search_journal_entries` | `start_date`, `end_date` (required) |
| Base currency and year-end | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no vendor bank detail on this surface — Rule 7 cannot be run here.**

---

## Plain-language glossary

- **AP register** — the list of supplier bills and what has been paid against them.
- **Duplicate payment** — paying the same bill twice.
- **Vendor master** — the list of supplier records. **Vendor alias** — the same supplier existing under
  more than one record.
- **Remit-to address** — where a supplier asks to be paid.
- **Fuzzy / string-similarity matching** — comparing names that are close but not identical.
  **Jaro-Winkler** is one scoring method; 0.85 is a common threshold.
- **Monotonic** — always increasing. Invoice numbers from one supplier usually are.
- **Cluster** — a group of records suspected of being the same underlying invoice.
- **Confidence level** — how strong the evidence for a match is.
- **Sensitivity** — how eagerly the scan flags: strict flags more, permissive flags less.
- **Set-off** — deducting what you are owed from what you owe.
- **Void / reversal** — cancelling a record after it was entered.
- **Tranche** — one part of a payment made in instalments.
- **False positive** — a flag that turns out to be legitimate. **False negative** — a real duplicate the
  scan missed.

---
