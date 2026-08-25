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
7. Run `scripts/validate-skill.sh skills` before opening a PR.

## Adding a reference file

Reference files orient; **`get_datasource_tools` is authority.** Do not put tool
identifiers in a reference — they go stale silently and a reader trusting them gets
`UNKNOWN_TOOL` with no idea why.

## Style

See `docs/conventions/house-style.md`. Do not mix the two styles within one file.
