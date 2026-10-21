<!-- merchant-and-payment-processor-rec · tools-and-glossary.md · read for: when you need a tool name, an argument, or a term explained. Edit here, not in SKILL.md. -->

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
| Clearing, revenue, fee, refund, chargeback and tax accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| **The clearing roll-forward and its ageing** | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Clearing balance at both period ends | `get_balance_sheet` / `get_trial_balance` | `start_date`, `end_date`, `accounting_method` |
| **Revenue, fees, refunds and chargebacks — the net-revenue test** | `get_profit_and_loss` | `start_date`, `end_date`, `summarize_column_by` |
| **Recorded payouts into the bank account** | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| The underlying sales, where recorded individually | `search_invoices` / `search_sales_receipts` | `start_date`, `end_date` (required) |
| Legal name, **functional currency**, country | `get_company_info` | none (uses the connected company) |

**Where a payment processor is a connected datasource**, its charge, refund, chargeback, fee, payout and
balance tools appear in **its own** Gate 2 catalog. **Resolve them there; do not assume names.**

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and failure
envelopes. Where this table and the live description disagree, the live description wins.

**There is no bank statement and no processor contract on this surface.**

---

## Plain-language glossary

- **Payment processor / merchant acquirer** — the company that takes card payments on your behalf and sends
  you the money later, minus its cut.
- **Gross charge** — what the customer paid. **Net payout** — what actually reaches your bank. **They are
  never the same, and revenue is the first one.**
- **Clearing account** — the balance the processor owes you between the sale and the payout. **It should
  clear.**
- **Payout / settlement** — the lump sum transfer to your bank, usually covering many transactions.
- **Refund** — money returned to a customer voluntarily. **Chargeback** — money taken back by the customer's
  bank after a dispute, **usually with a fee attached whether you win or lose.**
- **Reserve / rolling hold** — a portion the processor keeps against future chargebacks. **Still your
  asset.**
- **Available / pending / in transit** — the processor's own categories for money it holds. **Every
  processor defines them differently.**
- **Adjustment** — a manual correction by the processor.
- **Application fee** — in marketplace setups, the platform's cut of a seller's transaction.
- **Marketplace facilitator rules** — where the platform, not the seller, remits sales tax.
- **Output tax** — tax you owe on what you sold. **Charged on the gross sale, never on the net payout.**
- **Input tax** — tax you paid on what you bought, including processor fees, sometimes recoverable.
- **Recorded deposit vs. bank statement** — what the books say arrived, versus what the bank says arrived.
  **Only the second one is independent.**

---
