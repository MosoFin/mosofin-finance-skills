# Mosofin Accounting Skills

Accounting agent skills that work against **your own books**, read live through the
Mosofin gateway.

> ## Requires an active Mosofin subscription
>
> These skills read your accounting data through the Mosofin gateway
> (`https://mcp.mosofin.com/mcp`). **An active subscription and a connected company
> file are required.** Without them a skill still runs, but every step becomes manual
> and you supply the data by export.
>
> **These are standalone skills, not a plugin.** Each one carries its own onboarding
> section and its own gateway handling — install only the ones you need.

---

## Getting started

**1. Subscribe.** The gateway returns data only for an authenticated, subscribed account.

**2. Connect the gateway.**

```bash
claude mcp add --transport http mosofin https://mcp.mosofin.com/mcp
```

On claude.ai, add it through connector settings instead. Authentication is **OAuth** —
no credentials are stored locally, and **no skill here ever asks you for a password,
token or account number.**

**3. Install a skill.** Copy the folder into `~/.claude/skills/` (all projects) or
`.claude/skills/` (one project):

```bash
cp -R skills/month-end-close-checklist ~/.claude/skills/
```

**4. Run it.** The skill confirms your workspace by name and waits for an explicit yes
before reading anything.

Start with `month-end-close-checklist` — it's the hub, and it points at the others.

---

## What these skills do differently

**Every task is annotated with who does it.**

| | |
|---|---|
| `[auto]` | Read from your books, unattended |
| `[gated]` | The gateway asks your permission first |
| `[manual]` | **Not in your accounting system.** The step stays; a person does it. |

A skill never quietly drops a step it can't perform. If the evidence isn't in the
ledger — a bank statement, a physical count, a signed confirmation, a cap table — **it
says so and names who owns it.**

**Nothing is ever posted.** The gateway is read-only. Every entry, filing and
communication these skills produce is a **proposal for a person to review and act on.**

**Your permissions are read fresh every run.** No skill assumes what it could do last
time. If your access changes, its behaviour changes with it — and the coverage sheet
produced on every run records exactly what was available.

**Fixture data is always labelled.** If a response comes back as sample rather than
live data, the output says so in the filename and on the first page.

---

## The skills

| Skill | Automated | What it's for |
|---|---:|---|
| `journal-entry-builder` | 79% | Build and validate any journal entry against your real chart |
| `three-way-match` | 75% | PO / receipt / invoice matching across the whole population |
| `duplicate-invoice-detection` | 75% | Find duplicate payments before they go out |
| `invoice-data-extractor` | 72% | Pull structured data from supplier invoices |
| `gl-coding-assistant` | 72% | Code transactions using your own posting history |
| `expense-report-processor` | 65% | Review expense claims against policy |
| `bank-reconciliation` | 62% | Reconcile an account and explain what doesn't match |
| `month-end-close-checklist` | 61% | Run the close; scopes itself from your live chart |
| `financial-statement-builder` | 50% | Produce the statement set with its tie-outs |
| `ar-aging-and-collections` | 46% | Age receivables and prioritise collection |

**Automated %** is the measured share of `[auto]` versus `[manual]` steps in each skill —
computed from the files, not estimated. **It is not a quality score.** A low percentage
usually means the work genuinely needs evidence from outside the accounting system, and
the skill tells you which parts and why.

---

## Validating

```bash
.github/validate-skill.sh skills
```

Dependency-free. Every skill must carry frontmatter, the four gates, verdict
annotations, a coverage sheet, a lifecycle section, **the subscription onboarding
block**, and clean tool naming with no internal identifiers leaked. Runs on every PR.

---

## Docs

| | |
|---|---|
| [`deploy-queue.tsv`](deploy-queue.tsv) | Full ship order |

---

---

## Licence

Copyright © 2026 MosoFin.

This program is free software: you can redistribute it and/or modify it under the
terms of the **GNU Affero General Public License, version 3**, as published by the
Free Software Foundation. See [LICENSE](LICENSE).

**AGPL §13 — network use.** If you modify these skills and make them available to
users over a network, you must offer those users the source of your modified version.

This licence governs the skills themselves. It does not grant access to the MosoFin
service — **running these skills against live data still requires an active MosoFin
subscription**, governed separately by the MosoFin Terms of Service.

This program is distributed in the hope that it will be useful, but **WITHOUT ANY
WARRANTY**; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.

## Support

Skills are delivered to Mosofin subscribers. For access, billing or connection issues,
contact Mosofin support. For a problem with a skill's accounting logic, open an issue.
