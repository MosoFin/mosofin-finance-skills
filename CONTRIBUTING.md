# Contributing

## Adding or changing a skill

1. **Preserve every professional step.** A skill that cannot perform a step marks
   it `[manual]` and names the owner. It does not drop it.
2. **Do not freeze a capability snapshot.** No skill states what the gateway can
   do; Gate 2 reads it every run.
3. **Do not hardcode a rate, threshold, bracket or taxonomy version.** Store where
   to find it, never the value.
4. **Bare tool names only.** No `mosofin_` prefix, no `mcp__` client namespace —
   that string is composed by whichever MCP client is running.
5. **Never print a numeric tenant or workspace id.** Name the workspace.
6. **Keep the professional term.** Add plain language alongside it; do not replace it.
7. Run `.github/validate-skill.sh skills` before opening a PR.

## Shared onboarding and guardrail text

The onboarding sequence and the write guardrails are **identical in every skill and
generated from one place** — [`.github/shared/`](.github/shared/README.md). Each skill
carries its own full copy because skills are distributed standalone, but the copies are
produced by a script, never by hand.

```bash
.github/sync-shared.sh            # propagate .github/shared/*.md into every skill
.github/sync-shared.sh --check    # verify nothing drifted (CI runs this)
```

Editing that text inside a `SKILL.md`, or inside a skill's
`references/onboarding.md`, will be reverted by the next sync and will fail CI in the
meantime. Edit `.github/shared/onboarding-inline.md`,
`.github/shared/onboarding-reference.md` or `.github/shared/write-guardrail.md`
instead.

## Adding a reference file

Reference files orient; **`get_datasource_tools` is authority.** Do not put tool
identifiers in a reference — they go stale silently and a reader trusting them gets
`UNKNOWN_TOOL` with no idea why.

## Style

Do not mix section-naming styles within one file.
