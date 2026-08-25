# The Four Gates

Every skill opens with these, in order, before any analysis.

## Gate 0 — Confirm the workspace

Call `list_workspaces` with no arguments.

- `confirmed` → one workspace. **Read its name back and wait for an explicit yes.**
  Silence is not a yes.
- `selection_required` → ask in chat: *"Is this a single-workspace task or a
  multi-workspace one?"* Never assume; never take the first row because it is first.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. **Never print
the internal numeric id**, never ask for it, and if it appears in an error message,
name the workspace instead.

## Gate 1 — Datasource and entity scenario

Call `get_agent_datasources`. Establish out loud whether there is no datasource,
one company file, several, or a broken connection (`reconnect_url`).

Refer to company files by **`display_name`**, never by `data_source_id`. Pass the
id between tools; do not display it.

## Gate 2 — Capability map

Call `get_datasource_tools` and read **`effective_policy`** on each tool.

| `effective_policy` | Verdict |
|---|---|
| `enabled` | `[auto]` |
| `permission` | `[gated]` |
| `disabled` | `[manual]` |

**Read it every run.** A capability map baked into a file is wrong the first time
anything changes — and wrong *silently*, still reporting `[auto]` for something
disabled a month ago.

Take tool names from the response. `UNKNOWN_TOOL` means re-read the list, not try
a near-miss.

## Gate 3 — Profile, then interview

Call `get_my_skill` and `get_skills` **before asking the user anything**. Use what
the profile already holds and say you are using it. Interview only for what is
genuinely open.

> **Decisions are the user's; state is the workspace's.**

## Standing rules

- **Every call is stateless.** Carry `data_source_id` on every invocation,
  including the retry after an approval — dropping it on the retry is the
  commonest way an approved call still fails.
- **Batch independent reads** into one message.
- **`mock: true` means fixture data.** Say so in the file name and in the output,
  and state what it invalidates for that particular skill.
