# Deployment Plan — Mosofin Accounting Skills → GitHub

114 converted skills. Ship in four waves, gated on review decisions, with a CI
validator that already passes 114/114.

**Read `REVIEW-REQUIRED.md` first.** Two items there block Wave 1; everything else
gates later waves.

---

## 0. Position

| | |
|---|---|
| Skills | 114 (+1 converted reference file) |
| Volume | 75,658 lines, 3.61× the source |
| Conformance | 4 gates · verdicts · coverage sheet · lifecycle — **114/114** |
| Tool hygiene | 0 prefixed or client-namespaced tool names; 0 numeric tenant IDs |
| Validator | `scripts/validate-skill.sh` — **114/114, 0 failures** |
| Blocking decisions | **2** (repo visibility, house style) |

---

## 1. Repository

**Name:** `mosofin-finance-skills`
**Distribution:** standalone skills for Mosofin subscribers — **not a plugin.** Each skill carries its own onboarding and gateway handling.

**Visibility:** decide before first push. See R1 — the source pack carries no
licence, and public release is a decision you make deliberately, not a default.

```
mosofin-finance-skills/
├── README.md                     # what this is, how to use a skill, the gate model
├── LICENSE                       # ⚠️ blocked on R1 — do not populate until settled
├── CONTRIBUTING.md               # conversion conventions; how to add/change a skill
├── CHANGELOG.md                  # per-release, per-wave
├── skills/
│   └── <skill-name>/
│       ├── SKILL.md
│       └── references/           # only where a skill bundles one
├── docs/
│   ├── DEPLOYMENT-PLAN.md        # this file
│   ├── REVIEW-REQUIRED.md        # your decisions
│   ├── RANKING.md                # demand ordering + method
│   └── conventions/
│       ├── gates.md              # Gate 0–3 contract
│       ├── verdicts.md           # [auto] / [gated] / [manual]
│       └── house-style.md        # the two styles, per R6
├── scripts/
│   └── validate-skill.sh         # dependency-free conformance validator
├── deploy-queue.tsv              # machine-readable ship order
└── .github/
    ├── workflows/validate.yml    # CI on every PR
    ├── ISSUE_TEMPLATE/
    └── PULL_REQUEST_TEMPLATE.md
```

**Why `skills/<name>/SKILL.md` and not flat files:** several skills bundle a
`references/` directory, and the marketplace convention in this workspace's
`CLAUDE.md` is a folder per skill. Keeping the shape means a skill folder can be
zipped and shipped without restructuring.

---

## 2. Waves

Each wave is a tagged release. **A wave does not start until the previous one has
been used by someone who is not us.**

### Wave 0 — Scaffolding (no skills)

Repo, README, conventions, CI, validator, templates. Proves the gate works before
any content lands.

- **Gate:** CI green on an empty `skills/`
- **Tag:** `v0.1.0-scaffold`

### Wave 1 — Core Ten

The ten highest-demand skills (see `RANKING.md`). Transactional, high frequency,
highest automation ratios, no review blockers.

`journal-entry-builder` · `three-way-match` · `invoice-data-extractor` ·
`gl-coding-assistant` · `duplicate-invoice-detection` · `month-end-close-checklist` ·
`bank-reconciliation` · `ar-aging-and-collections` · `expense-report-processor` ·
`financial-statement-builder`

- **Blocked on:** R1 (visibility), R6 (house style)
- **Gate:** validator green; one real workspace run per skill; README links resolve
- **Tag:** `v0.2.0-core`

### Wave 2 — Recurring finance operations (24)

Monthly/quarterly operational skills. See `RANKING.md`.

- **Blocked on:** Wave 1 feedback; dedupe decision on `cash-application`
- **Gate:** validator green; cross-references resolve to shipped skills
- **Tag:** `v0.3.0-operations`

### Wave 3 — Standards, reporting and controls (32)

The credibility tranche — what makes a qualified accountant take the pack seriously.

- **Blocked on:** nothing beyond Wave 2
- **Tag:** `v0.4.0-standards`

### Wave 4 — Specialist and regulated (48)

Long tail. Split into sub-batches so the review-gated ones don't hold up the rest.

| Batch | Contents | Gated on |
|---|---|---|
| 4a | Sector-specific, specialist technical | — |
| 4b | Public reporting (SEC, XBRL, segment, MD&A) | — |
| 4c | **Tax** (11 skills) | **R2** |
| 4d | **Valuation / transactions** (7 skills) | **R2** |
| 4e | `quickbooks-ar-aging-collections` | **R3** |
| 4f | Sensitive-data skills | **R4** |

- **Tag:** `v1.0.0` once all batches land

---

## 3. Cross-reference integrity

**The single biggest technical risk in a phased rollout.** These skills reference
each other heavily — `month-end-close-checklist` alone points at 33 others, and
`year-end-close` at roughly 20. **Ship Wave 1 alone and most of those links point
at nothing.**

Three options, in order of preference:

| Option | Effect |
|---|---|
| **A. Ship all 114 to a private repo at once**, then stage *public* visibility by wave | Links always resolve. **Recommended.** |
| **B. Link-check at build; render unshipped references as plain text** | Requires a rendering step; links degrade gracefully |
| **C. Accept broken links in early waves** | Poor first impression; do not do this on a public repo |

**If R1 resolves to a private repo, take option A** — the wave structure then
governs *announcement and support*, not file availability, which is the useful
part anyway.

A link checker is worth adding to CI once Wave 2 lands:

```bash
# every `skill-name` in backticks should exist under skills/
grep -rhoE '`[a-z0-9]+(-[a-z0-9]+)+`' skills/*/SKILL.md \
  | tr -d '`' | sort -u \
  | while read -r s; do [ -d "skills/$s" ] || echo "unresolved: $s"; done
```

Expect false positives — that pattern also matches things like `data_source_id`
and `effective_policy`. Filter against the known skill list before failing a build.

---

## 4. CI

`.github/workflows/validate.yml` runs `scripts/validate-skill.sh` on every PR and
push. Per skill it enforces:

1. Frontmatter present, with `name:` and `description:`
2. **Exactly four gates** (`## Gate 0`–`3`)
3. Both `[auto]` and `[manual]` verdicts present
4. A coverage/provenance section
5. A seed-to-evolved lifecycle section
6. **Tool-name hygiene** — no `mosofin_` prefix, no `mcp__` namespace used as a
   tool name *(prohibition text is allowed and detected as such)*
7. **No numeric tenant or workspace IDs**
8. Gate 0 calls `list_workspaces`

Currently **114/114 pass, 0 failures.**

The validator is a plain shell script with no dependencies — consistent with this
workspace's rule against adding dependencies to tooling.

---

## 5. Execution

Run from the workspace root. **Nothing below has been run** — the repo skeleton and
docs exist; no git history, no remote, no skills copied.

```bash
cd /Users/travis/Mosofin-skills-workplace/mosofin-finance-skills
```

**Step 1 — copy skills in queue order** (all 114, per option A above):

```bash
SRC="../competitor_resources/claude_accounting_os/Accounting Automation Complete Pack_v1/01-Skills/Mosofin-Complete/mosofin-finance-skills"
while IFS=$'\t' read -r wave name auto gate; do
  case "$wave" in \#*|"") continue;; esac
  mkdir -p "skills/$name" && cp -R "$SRC/$name/." "skills/$name/"
done < deploy-queue.tsv
find skills -name .DS_Store -delete
```

**Step 2 — validate before committing:**

```bash
scripts/validate-skill.sh skills
```

**Step 3 — initialise and commit** *(only after R1 is settled)*:

```bash
git init -b main
git add -A
git commit -m "Wave 0: scaffolding, conventions, validator"
```

**Step 4 — create the remote as private:**

```bash
gh repo create mosofin-finance-skills --private --source=. --remote=origin --push
```

**Step 5 — tag the wave:**

```bash
git tag -a v0.1.0-scaffold -m "Scaffolding and validator" && git push --tags
```

`.DS_Store` deletion is deliberate — this workspace's `CLAUDE.md` lists shipping
them as an anti-pattern, and there are several in the tree.

---

## 6. Rollback

Each wave is a tag, so rollback is `git revert` of the wave's merge commit plus a
new patch tag. **Do not delete tags** — a consumer may have pinned one.

For a skill that turns out to be wrong in the field: fix forward in a patch release
rather than pulling the folder. Removing a skill breaks every cross-reference
pointing at it.

---

## 7. Success criteria

**Wave 1:**
- Each of the ten runs end-to-end against one real connected workspace
- Gate 0 refuses to proceed without explicit workspace confirmation — verify by trying
- No skill claims `[auto]` for something the gateway returned as `permission` or `disabled`
- A coverage sheet is produced on every run, including the runs that go well

**Overall:**
- Cross-references resolve
- No `mock: true` output presented without its fixture warning
- The second run of any skill is measurably cheaper than the first — that is the
  seed-to-evolved lifecycle working, and it is the pack's main claim

---

## 8. Open questions

1. **Promote `working-capital-optimization` to Wave 1?** 74 auto / 47 manual, one
   of the best workspace fits in the pack, and it finds cash — which makes it a
   strong demo. Against: it is a periodic advisory exercise, not a daily one.
2. **Marketplace sync.** This workspace has `sync-marketplace-skills.sh` targeting
   `marketplace-backend/input-skills`. Is GitHub the source of truth with the
   marketplace syncing *from* it, or are they independent distributions?
3. **Two-HTML convention.** `CLAUDE.md` requires dashboard skills to ship an
   injection template plus a pre-rendered preview. **None of these 114 produce
   dashboards** — they produce `.xlsx` workpapers — so the convention appears not
   to apply. Worth confirming.
4. **Versioning granularity.** One version for the pack, or per-skill versions?
   Per-skill is friendlier to consumers and considerably more overhead.
