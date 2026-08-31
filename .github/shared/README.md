# Shared blocks — the Mosofin onboarding standard

Every skill in this repo opens with the same onboarding sequence and carries the same
write guardrails. **This directory is the single source of truth for that text.** The
copies inside each `SKILL.md` are generated from here.

| File | Injected into | Lines |
|------|---------------|-------|
| [`onboarding.md`](onboarding.md) | the top of every skill, before its title | 85 |
| [`write-guardrail.md`](write-guardrail.md) | the top of every skill's **Gate 2** | 37 |

## Why the text is duplicated into every skill

These skills are distributed **standalone**: a user may copy one folder into
`~/.claude/skills/` and run it with nothing else present. A skill that referenced an
external onboarding doc would break the moment it was copied on its own, and the
subscription, setup and write-prohibition text is exactly the text that must not go
missing.

So duplication is deliberate. What this directory removes is not the duplication — it
is the *drift*. One place to edit, a script to propagate, and CI to prove every copy
still matches.

## Maintaining it

```bash
# edit the canonical text
$EDITOR .github/shared/onboarding.md

# propagate to every skill
.github/sync-shared.sh

# verify (this is what CI runs)
.github/sync-shared.sh --check
```

**Never hand-edit a shared block inside a `SKILL.md`.** It sits between
`<!-- shared:onboarding start -->` and `<!-- shared:onboarding end -->` markers; the
next sync overwrites whatever is between them, and CI fails until the file matches
the canonical copy. Change it here instead, and every skill picks it up.

Adding a skill? Put the two marker pairs where the blocks belong — the onboarding pair
immediately after the frontmatter, the guardrail pair directly under the `## Gate 2`
heading — then run `.github/sync-shared.sh` to fill them.

## The onboarding standard

What `onboarding.md` commits every skill to, in order:

| Section | Purpose |
|---------|---------|
| **Before you start** | States that a live subscription and a connected company file are required, and that the skill degrades rather than failing without them |
| **Strict rule — this skill never changes your data** | The user-facing prohibition: no write, update or delete in any data source, and no directing the user to perform one |
| **First-run onboarding** (6 steps) | Subscription → connect the gateway → confirm workspace (Gate 0) → confirm company file (Gate 1) → capability check (Gate 2) → profile (Gate 3). **No data is read until step 3 is explicitly confirmed.** |
| **Where the setup instructions live** | The docs.mosofin.com table — quickstart, account, workspace, destination and source connection, troubleshooting, billing, support |
| **What the subscription requirement means in practice** | Read-only posture, workspace scoping, permissions re-read every run, coverage sheet |
| **Running without a connection** | Degraded mode: every step becomes `[manual]`, and the output says which figures came from the books and which were supplied by hand |

And what `write-guardrail.md` commits every skill's Gate 2 to:

| Section | Purpose |
|---------|---------|
| **Write tools are out of scope — always** | A write tool is out of scope **even when `effective_policy` is `enabled`** — a permission to write is not an instruction to write |
| **Hard stop** | The four routes a write could take, and the required behaviour for each: enabled write tool, `approval_required` on a write, a user asking for one, and a write being the only way to finish |

## One line that is not in a shared block

The Gate 2 policy table lives in each skill (its wording varies by skill), so the
`[gated]` row cannot be injected. It must end with:

```
**Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
```

Without it the table says "re-invoke with `approved=true`" unqualified, which is the
one instruction that could carry a write through the approval loop.
`validate-skill.sh` fails any skill missing it.

`.github/validate-skill.sh` independently asserts that the load-bearing sentences of
both blocks are present in every skill, so a skill cannot ship with them stripped —
even if someone deletes the markers along with the text.
