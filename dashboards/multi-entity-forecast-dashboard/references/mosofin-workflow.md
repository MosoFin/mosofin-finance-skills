# MosoFin path — pulling multi-entity data

Follow the gates in order. The MCP server is stateless; pass `workspace_id` and `data_source_id`
on every call. Everything is read-only.

## Gates

1. **Consent.** Ask: "Use your MosoFin connection to read the books, or supply the data yourself?"
   If they decline → `manual-workflow.md`.
2. **Workspace.** `list_workspaces` (no args). If more than one, ask which by name — never
   auto-pick. Confirm with `list_workspaces(workspace_ids=[id], mode="single")`.
3. **Company files.** `get_agent_datasources(workspace_id)`. Collect every row with
   `connector_key == "quickbooks"` and `connected == true`. If more than one, ask:
   one file / each separately / consolidated. This skill's dashboard always shows both per-entity
   and group views, so "consolidated" is the normal answer.
4. **Reads.** For each company file, in parallel where possible:

| Tool | Params | Gives |
|---|---|---|
| `get_cash_flow` | `start_date`, `end_date`, `summarize_column_by: "Month"` | operating / investing / financing per month, Net Income row, A/R, A/P, Inventory adjustment rows |
| `get_aged_receivables` | none (as-of today) or `report_date` | aging buckets + customer rows |
| `get_profit_and_loss` | same dates, `summarize_column_by: "Month"` | only if you need P&L detail beyond Net Income (results are large) |

   Date range: 1 Jan of the current year → end of the current month, unless the user asks
   otherwise. Compute concrete ISO dates before calling.

5. **Tool errors.** A `datasource_not_active` / `connection_unavailable` envelope carries a
   `reconnect_url` — show it and stop. A `QBO API error 500` on one file is usually transient:
   retry once, then proceed with the files that succeeded and flag the gap.

## Reading the cash flow report

Each `get_cash_flow` result has `Columns.Column` (month columns + a Total column) and nested
`Rows`. Use `Summary.ColData` on the sections with `group` of `OperatingActivities`,
`InvestingActivities`, `FinancingActivities`, `CashIncrease`. Skip the Total column. Blank cells
are 0.

Derive balances from the operating-adjustment rows summed across months (valid when the year
opened at zero, which you should state; otherwise pull `get_balance_sheet` instead):

- `ar`  = −Σ "Accounts Receivable (A/R)"
- `ap`  =  Σ "Accounts Payable (A/P)"
- `inv` = −Σ "Inventory Asset"

Cash at month end = cumulative `CashIncrease`. Cross-check one entity against
`get_balance_sheet` (bank + undeposited funds) when time allows.

## Consolidation rules

- Group series = sum of entity series month by month.
- Intercompany receivables: any aged-receivables customer whose name matches a sister entity's
  display name. Record the total in `arIc` on the entity that holds it, mark those customer rows
  with a fifth element `true`, and put a note under `where: "accounts"` stating outside
  receivables = `ar − arIc`. Never silently eliminate; show both.
- If entity months differ, truncate to the common range and say so.

## Sandbox signals — always check, always disclose

Identical figures to the cent across entities, customers matching the QuickBooks sample company
(Amy's Bird Sanctuary, Bill's Windsurf Shop, Freeman Sporting Goods…), or a company legal name
containing "Sandbox". Put one sentence in `notes` under `where: "report"`.

## Data object fields for the MosoFin path

```
mode: "mosofin"
mcpUrl: the connected MosoFin server URL from the session's connector list
source: "QuickBooks Online · via MosoFin"
fetched: "Fetched D Mon YYYY, HH:MM UTC"   (from provenance.fetched_at)
asOf: "D Month YYYY"
provenance: tools used, "mock: false · read-only"
```

## Live buttons in the dashboard

The template's **Sync from QuickBooks** button and **Ask** drawer POST to
`https://api.anthropic.com/v1/messages` with `mcp_servers: [{type:"url", url: DATA.mcpUrl}]`.
They work only when the file runs inside Claude with the MosoFin connector attached; elsewhere
they fail gracefully into the amber strip. Tell the user this once.
