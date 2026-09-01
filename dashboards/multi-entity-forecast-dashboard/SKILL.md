---
name: multi-entity-forecast-dashboard
description: Build an interactive, single-file cash forecast dashboard for a multi-entity business (several QuickBooks company files) in a fixed "quiet analytics" visual style, with per-entity and consolidated views, P10/P90 forecast band, accounts/receivables detail, and a paper-style report. Pulls live data through the MosoFin connector when the user agrees, or falls back to a manual CSV upload when they opt out or have no connector. Use this whenever the user asks for a cash flow forecast, runway, cash dashboard, multi-entity or group consolidation view, "how much cash will we have", or a forecast for their MosoFin / QuickBooks workspace — even if they don't say "dashboard". Also use it to refresh or restyle an existing forecast dashboard so it stays visually consistent.
---

# Multi-entity forecast dashboard

Produces one self-contained HTML file: Overview · Accounts · Forecast · Report tabs, an entity
switcher (Group + each company file), scenario presets and sliders, and — on the MosoFin path —
a live **Sync from QuickBooks** button and an **Ask** drawer that read the books through the
connector.

The look is fixed. Read `references/ui-spec.md` before touching any HTML and never restyle
ad hoc; the template already implements the spec.

## Workflow

### 1. Choose the data path

Ask one question first: *"Use your MosoFin connection to read the books, or supply the data
yourself?"* Then:

- **MosoFin** → follow `references/mosofin-workflow.md` (workspace confirm → company files →
  `get_cash_flow` per entity → `get_aged_receivables` → consolidate).
- **Manual / opted out / no connector** → follow `references/manual-workflow.md` (CSV schema,
  validation, what the dashboard hides).

Never mix: if a MosoFin read fails partway, tell the user what succeeded and offer the manual
path for the rest rather than inventing figures.

### 2. Assemble the data object

Write a JSON file matching `assets/example-data.json`. Required keys: `group`, `mode`
(`"mosofin"` | `"manual"`), `source`, `fetched`, `year`, `months`, `order`, `entities`, `notes`.
Each entity needs `label`, `short`, and equal-length `ocf`, `icf`, `fcf`, `ni` arrays, plus
`ar`, `arIc`, `ap`, `inv`; `aging` and `customers` are optional (`null` when not pulled).

`notes` drive every explanatory callout in the UI. Use `where: "history"` for run-rate
exclusions, `where: "accounts"` for intercompany and aging caveats, `where: "report"` for
sandbox/data-quality warnings. Write them from what the data actually shows — see
`references/forecast-method.md` for what must be stated.

### 3. Build

```
python3 scripts/build_dashboard.py --data <data.json> --out /mnt/user-data/outputs/<group>-forecast-dashboard.html
```
or, for a CSV:
```
python3 scripts/build_dashboard.py --csv <file.csv> --group "<Group>" --mode manual --source "Uploaded CSV" --fetched "Uploaded <date>" --out <path>
```

### 4. Verify before presenting

Run the file headlessly (jsdom is fine) and confirm: zero JS errors, KPI band shows four values,
the entity switcher lists Group + every entity, all four tabs render, and the first KPI equals
the last cumulative cash figure you computed. Then `present_files`.

### 5. Tell the user

In prose, not bullets: the cash position, which scenario rate was chosen and why, the largest
caveat (intercompany, sandbox data, missing aging), and — MosoFin path only — that the Sync and
Ask buttons work when the file runs inside Claude with the connector attached and degrade to an
amber strip elsewhere. End with a single "Data sources" line listing the tools and fetch time.

## Files

| Path | Read when |
|---|---|
| `references/ui-spec.md` | always, before any HTML work |
| `references/mosofin-workflow.md` | MosoFin path |
| `references/manual-workflow.md` | manual path |
| `references/forecast-method.md` | writing notes or the report prose |
| `assets/dashboard-template.html` | never edit in place; the script fills it |
| `assets/example-data.json` | shape reference (real Nomad Bowls Group run, 1 Sep 2026) |
| `assets/example-manual.csv` | template to hand the user |
| `scripts/build_dashboard.py` | step 3 |

## Guardrails

- Every number in the dashboard comes from the tool results or the user's file. No
  interpolation, no "typical" values.
- Disclose sandbox signals and intercompany balances every time they appear.
- Read-only: this skill never writes to QuickBooks or MosoFin.
- Do not add chart libraries, fonts from CDNs, or new colors. If a requested change conflicts
  with the UI spec, say so and offer the closest spec-compliant option.
