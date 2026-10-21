<!-- bank-reconciliation · tools-and-glossary.md · read for: when you need a tool name or a term. Edit here, not in SKILL.md. -->

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
| Identify the cash / bank accounts | `search_accounts` / `get_account` | `query`/`name`, `active_only`; `id` |
| GL cash ending balance | `get_trial_balance` / `get_balance_sheet` | `start_date`, `end_date`, `accounting_method` |
| Every book-side cash movement | `get_general_ledger` | `start_date`, `end_date`, `accounting_method`, `account` |
| Deposits (deposit-in-transit candidates) | `search_deposits` / `get_deposit` | `start_date`, `end_date` (required); `id` |
| Supplier payments (outstanding-cheque candidates) | `search_bill_payments` / `get_bill_payment` | `start_date`, `end_date` (required), `vendor_id`; `id` |
| Cheques, card spend, direct debits | `search_purchases` / `get_purchase` | `start_date`, `end_date` (required); `id` |
| Customer receipts | `search_payments` / `search_sales_receipts` | `start_date`, `end_date` (required), `customer_id` |
| Transfers between own accounts | `search_transfers` / `get_transfer` | `start_date`, `end_date` (required); `id` |
| Manual entries hitting cash | `search_journal_entries` / `get_journal_entry` | `start_date`, `end_date` (required); `id` |
| Refunds issued | `search_refund_receipts` / `get_refund_receipt` | `start_date`, `end_date` (required); `id` |
| Cash movement over the period | `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by` |
| Payment methods in use | `search_payment_methods` | `query`/`name`, `active_only` |
| Base currency and time zone | `get_company_info` | none (uses the connected company) |

Each tool's **own description in your Gate 2 catalog is the authority** on its arguments and
failure envelopes. Where this table and the live description disagree, the live description wins.

---

## Plain-language glossary

- **Bank reconciliation** — proving the difference between your books and the bank's records is
  fully explained.
- **General ledger (GL)** — the complete record of every transaction in the books.
- **Book balance** — cash according to your books. **Statement balance** — cash according to the
  bank.
- **Bridge** — the two ladders of adjustments that bring both balances to the same adjusted figure.
- **Deposit in transit (DIT)** — money you banked that the bank hasn't credited yet.
- **Outstanding cheque** — a payment you issued that hasn't been cashed yet.
- **Cutoff** — the point at which a period stops accepting transactions.
- **NSF (non-sufficient funds)** — a payment that bounced.
- **Returned item** — a receipt reversed because it failed.
- **Chargeback** — a card issuer reversing a payment.
- **Merchant netting** — the card processor deducting its fee before paying you.
- **Reserve** — money a processor holds back against future chargebacks.
- **ACH ID / wire reference / merchant descriptor** — identifiers that let you match a bank line
  to a book entry.
- **Split / combined match** — one bank line covering several book entries, or the reverse.
- **Tie to the cent** — the bridge must balance exactly, not approximately.
- **Unclaimed property** — money (like an uncashed cheque) that must eventually be handed to the
  state.
- **Journal entry (JE)** — the balanced two-sided record. **DR** = debit, **CR** = credit.

---
