# Manual path — user supplies the data

Use when the user declines MosoFin, has no connector, or the connector fails.

## Ask for a CSV in this shape

One row per entity per month. Column names exactly:

```
entity, month, year, operating_cf, investing_cf, financing_cf, net_income,
accounts_receivable, ar_intercompany, accounts_payable, inventory
```

- `month` is `Jan`…`Dec`; `year` is four digits.
- All entities must cover the same months.
- The four balance columns are read from each entity's **last** row only; leave them blank on
  earlier rows. `ar_intercompany` is the part of receivables owed by sister entities (0 if none).
- Negative numbers as `-1234` or `(1234)`; currency symbols and thousands separators are fine.

`assets/example-manual.csv` is a complete example — offer it as a template.

## If they give something else

- **QuickBooks cash flow exports (one per entity):** transcribe the section subtotals per month
  into the CSV yourself; show the user the CSV before building.
- **A P&L only:** you can fill `net_income` but not the cash flow columns. Do not fabricate them.
  Explain that the forecast then anchors on net income and the KPI band will be incomplete.
- **A single consolidated series with no entity split:** build with one entity named after the
  group; the entity switcher will show just "Group" and that name.

## Validate before building

Run `python3 scripts/build_dashboard.py --csv <file> --group "<Group name>" --mode manual
--source "Uploaded CSV" --fetched "Uploaded <date>" --out <path>`. The script rejects missing
columns and mismatched month ranges with a plain message — relay it, don't patch the data.

## What changes in the dashboard

- Status pill is neutral "Uploaded data"; sync button and Ask drawer are hidden.
- Provenance reads "Uploaded CSV" (or whatever you pass to `--source`).
- No aging chart or customer table unless the user also supplies aging data (add `aging` and
  `customers` to the entity objects by hand via `--data` JSON if they do).
