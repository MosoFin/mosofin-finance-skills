<!-- invoice-data-extractor · tools-and-glossary.md · read for: Stages 2 and 4 for a tool name, any Stage for a term. Edit here, not in SKILL.md. -->

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
| **The vendor master: name, tax ID, address, terms** | `search_vendors` / `get_vendor` | `query`/`name`, `active_only`; `id` |
| **Posted bills — the duplicate check** | `search_bills` / `search_purchases` / `get_bill` | `start_date`, `end_date` (required); `id` |
| **Whether it has already been paid** | `search_payments` / `get_aged_payables` | `start_date`, `end_date`; `as_of_date` |
| **How this vendor is usually coded** | `get_general_ledger` / `get_profit_and_loss` | `start_date`, `end_date`, `account` |
| PO matching, where POs are used | `search_purchase_orders` | `start_date`, `end_date` |
| **Legal name for Bill-To validation, currency, country** | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There are no documents, no bank details and no vendor verification service on this surface.**

---

## Plain-language glossary

- **Extraction** — turning what a document shows into fields a system can use. **Semantic, not just OCR**:
  knowing that a number is the tax and not the total.
- **OCR** — reading text off an image. **It makes mistakes**, which is what confidence ratings are for.
- **Header fields** — the invoice-level information: who, when, how much in total.
- **Line items** — the individual things being charged for.
- **Tax-inclusive vs. exclusive** — whether the prices shown already contain the tax. **Misreading one for
  the other overstates expense and understates tax.**
- **Remit-to** — where the supplier wants to be paid, which may differ from their trading address.
- **Bill-To** — who the invoice is addressed to. **In a group, this decides whose books it belongs in.**
- **PO (purchase order)** — the order placed before the goods came. **Matching to it is the first half of a
  three-way match.**
- **Pro forma invoice** — a quote dressed as an invoice. **Not a legal invoice and not an accounting
  document.**
- **Statement** — a summary of many invoices. **The invoices get posted, not the statement.**
- **Credit memo** — a negative invoice: money coming back.
- **DBA / trading name** — a name a business operates under that is not its legal name.
- **Duplicate invoice** — the same bill entered twice. **The single most expensive routine AP error.**
- **Out-of-band verification** — confirming a change through a separate channel, using contact details you
  already had. **The only control that reliably catches payment redirection.**

---
