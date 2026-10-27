<!-- recurring-transaction-builder · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, the mock flag, and the Gate 3 standing facts. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.

*The precondition check — whether to use Mosofin at all, and what a manual run does gate by gate — and the scope protocol that belong here are in [`mosofin-protocol.md`](mosofin-protocol.md) under "First — ask whether to use Mosofin for this run" and "Confirming scope". They apply in full here.*

## Gate 0 — Confirm the workspace before anything else

1. Call `list_workspaces` with no arguments.
2. If the status is `confirmed`, there is one workspace. **Read its name back and wait for an explicit yes.**
3. If the status is `selection_required`, ask: **"Is this a single-workspace task or a multi-workspace one?"**
   - Single: ask which one by name, then `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. Never print the internal numeric id, never ask for it, and if it appears in an error, name the workspace instead.

**Why this gate matters here.** The deliverable is a set of transactions someone will load into an accounting system. **A schedule validated against one company's chart of accounts and loaded into another's** produces postings to whatever those account codes happen to mean in the second book — which is a mess that recurs monthly until somebody notices. The chart is entity-specific; so is the validation. Confirm which entity before validating anything.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The **computation** still works in full — dates, escalations, memos, calendar rolls. **The validation does not.** No account check, no duplicate check, no discovery, no run audit. Say precisely that: the schedule is arithmetically sound and has been checked against nothing. |
| **Exactly one company file** | Confirm the `display_name` before reading. |
| **Several company files** | Ask which, **by `display_name`** — the schedule is validated against one chart and is not portable to another. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. The computation can proceed; **say clearly that it is unvalidated**, because an unvalidated schedule looks identical to a validated one. |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

**The no-datasource case deserves emphasis**, because it is the one where this skill degrades most invisibly. The output file looks exactly the same either way. Put the validation status in the header of Sheet 1, not in a footnote.

---

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Map what you can actually do

*The write-tool guardrail that belongs here is in [`mosofin-protocol.md`](mosofin-protocol.md) under "Write tools — the Gate 2 guardrail". It applies in full at this gate.*

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each tool.

| `effective_policy` | Verdict | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch with other independent reads. |
| `permission` | `[gated]` | Expect `approval_required`. Explain what and why, get a yes, re-invoke with `approved=true`. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | `[manual]` | Not available. The step remains; the user performs it. |

Every verdict below is a **default written before the gateway was consulted.** Where Gate 2 disagrees, **Gate 2 wins** for this run. Do not carry a capability map between runs.

**A note that matters specifically here.** If a tool that creates or posts transactions appears in the listing, **it is out of scope for this skill regardless of its `effective_policy`.** Policy says what the gateway permits; this skill's scope says what it does. This skill reads, computes, and hands the result to a person. That is not a limitation being worked around — for an object that will fire every month without further review, it is the correct place to put a human.

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** The chart of accounts, the vendor list, the customer list, the tax codes and the recurring-charge history are all independent. One message.

### The `mock: true` flag

Fixture data will **validate cleanly**, because the fixture chart contains whatever the fixture transactions reference. Every account check, vendor check and tax-code check passes by construction — which is precisely the set of checks this skill adds.

So a clean validation on `mock: true` data means the validation logic ran, and nothing more. Label it in the file name and in Sheet 1's header, in the same place the validation status goes.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Two items in this skill's interview are **standing client facts that should never be asked twice**, and both are ones the original is right to insist on and right to refuse to default:

- **The holiday calendar.** Jurisdiction-specific, stable, and **not in the accounting system.**
- **The roll policy** — forward or backward — applied consistently.

If the profile has them, use them and say so. If not, ask once and persist them.

Interview for the rest of the schedule's parameters as set out in the Inputs table. **Decisions are the user's; state is the workspace's.**

---
