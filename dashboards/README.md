# Dashboard skills

Skills whose output is an **interactive HTML file** rather than a written analysis. Same
read-only posture and the same choice of data path as the analysis skills in
[`skills/`](../skills/), but built around a visual spec and a generator script instead of the
four-gate protocol — so they carry their own standard, checked by
[`.github/validate-dashboard.sh`](../.github/validate-dashboard.sh).

| Dashboard | Builds |
|---|---|
| [`multi-entity-forecast-dashboard`](multi-entity-forecast-dashboard/) | A single-file cash forecast for a multi-entity group: Overview / Accounts / Forecast / Report tabs, an entity switcher, scenario sliders, a P10–P90 band, and receivables detail. |

---

## Using one dashboard on its own

Each dashboard is self-contained: its `SKILL.md`, `references/`, `assets/` and `scripts/` are
everything it needs. It comes with the `mosofin-finance` plugin (see Claude Code's
[Install and manage plugins](https://code.claude.com/docs/en/plugins/install)), or you can use
the dashboard's folder by itself as a skill. Claude Code's
[skills documentation](https://code.claude.com/docs/en/skills) says where a skill folder goes for
one project or for all of them. No build step.

### What it needs

**Python 3, and nothing else.** The generator uses only the standard library — no third-party
packages, no chart library, no build step. Verify the copy works:

```bash
cd ~/.claude/skills/multi-entity-forecast-dashboard && python3 scripts/build_dashboard.py --data assets/example-data.json --out /tmp/check.html
```

That should print `wrote /tmp/check.html (3 entities, 8 months, mode=mosofin)`. Open the file —
a working dashboard means the copy is complete.

### Do you need a MosoFin subscription?

No. The dashboard reads your live books through MosoFin when you have it connected **and agree
to it**, and otherwise builds from a CSV you upload — `assets/example-manual.csv` is the
template it hands you. The visual output is the same either way; only the source of the numbers
changes.
