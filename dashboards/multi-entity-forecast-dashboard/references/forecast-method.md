# Forecast method

The dashboard computes this client-side; use the same rules when writing prose.

## Scenario rates (per selected entity or group)

| Scenario | Monthly rate | Meaning |
|---|---|---|
| Conservative (P10 edge) | Net income of the last month | working-capital tailwind stops |
| Base | Operating cash flow of the last month | last month repeats |
| Upside (P90 edge) | Mean of the last two months' operating cash flow | recent momentum continues |

User sliders: monthly operating cash flow (overrides base), month-on-month change (%), one-off
spend in month 1. P10/P90 edges follow the slider when it moves outside the preset range.

Horizon: 6 months. Opening cash = last actual month-end. No further investing, financing, or
debt service is assumed — say so.

## Why the last month, not a trailing average

Small QuickBooks files often have sparse early months and one large month with capex, loans, or
opening-balance-equity entries. Averaging blends those in and produces a nonsense run rate. Anchor
on the most recent month with ordinary trading, and write a `where: "history"` note naming what
was excluded and why. If the last month itself contains one-offs, pick the most recent clean
month and say so.

## Sanity checks to state in the report

- Operating + investing + financing = net cash increase, every month (QuickBooks guarantees this;
  say you checked).
- Cumulative net cash increase = cash at month end (matches balance sheet bank + undeposited).
- If P10 goes below zero, the outlook card names the first negative month.
