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

## Install one dashboard — without cloning the repo

Each dashboard is self-contained: its `SKILL.md`, `references/`, `assets/` and `scripts/` are
everything it needs. Pull just that folder into your skills directory.

**Into `~/.claude/skills/` (available in every project):**

```bash
curl -sL https://github.com/MosoFin/mosofin-finance-skills/archive/refs/heads/main.tar.gz | tar -xz -C ~/.claude/skills --strip-components=2 mosofin-finance-skills-main/dashboards/multi-entity-forecast-dashboard
```

**Into the current project (`.claude/skills/`):**

```bash
mkdir -p .claude/skills && curl -sL https://github.com/MosoFin/mosofin-finance-skills/archive/refs/heads/main.tar.gz | tar -xz -C .claude/skills --strip-components=2 mosofin-finance-skills-main/dashboards/multi-entity-forecast-dashboard
```

No git, no clone, no build step. The path is written out in full rather than globbed so it works
with both BSD tar (macOS) and GNU tar (Linux).

**Pin a release** by swapping the branch for a tag — the top-level directory in the archive
changes to match, so both halves of the path move together:

```bash
curl -sL https://github.com/MosoFin/mosofin-finance-skills/archive/refs/tags/v0.3.0.tar.gz | tar -xz -C ~/.claude/skills --strip-components=2 mosofin-finance-skills-0.3.0/dashboards/multi-entity-forecast-dashboard
```

### If you would rather use git

`git sparse-checkout` fetches the same folder and lets you `git pull` for updates. It also
brings the repository's root files (README, LICENSE, and so on) — that is normal, they always
come with a sparse checkout.

```bash
git clone --depth 1 --filter=blob:none --sparse https://github.com/MosoFin/mosofin-finance-skills.git
cd mosofin-finance-skills && git sparse-checkout set dashboards/multi-entity-forecast-dashboard
```

### What it needs

**Python 3, and nothing else.** The generator uses only the standard library — no pip install,
no chart library, no build step. Verify the copy works:

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
