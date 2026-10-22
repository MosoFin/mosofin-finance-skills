<!-- three-way-match · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, including the three capability questions. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

## Contents

- ONBOARDING — Confirm the workspace and its data sources
-   - Gate 0 — Confirm the workspace before anything else
-   - Gate 1 — Establish the datasource and entity scenario
- PART A — Explore the confirmed sources, and personalise this run
-   - Gate 2 — Map what you can actually do (the three capability questions)
-   - Gate 3 — Read the profile, then interview for what remains


# ONBOARDING — Confirm the workspace and its data sources

**Required for every skill, every run — whenever Mosofin is connected.** Gates 0 and 1
settle *which books this is about*: the workspace, and the data sources inside it.
**Part A then explores what those confirmed sources can actually do** and personalises
the run around them. Nothing is read before Gate 0 is answered.

**If the Mosofin tools are not present at all, skip this part.** There is nothing to
onboard: say so once, then run the skill manually on data the user supplies. See the
precondition check below.


## Gate 0 — Confirm the workspace before anything else

1. Call `list_workspaces` with no arguments.
2. If the status is `confirmed`, there is one workspace. **Read its name back and wait for an explicit yes.**
3. If the status is `selection_required`, ask: **"Is this a single-workspace task or a multi-workspace one?"**
   - Single: ask which one by name, then `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by **name**, or by the opaque `ws_...` handle. Never print the internal numeric id, never ask for it, and if it appears in an error, name the workspace instead.

**Why this gate matters here.** The output of this skill is **a recommendation to pay, hold or reject** — it gates money leaving the business. It also names vendors and, where approval data exists, individuals.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The document-by-document match still works exactly as the original describes, on uploaded files. **The population-wide match does not.** Say so. |
| **Exactly one company file** | Confirm the `display_name`. **Entity matching (Step 2) is against this entity.** |
| **Several company files** | **The buyer entity is one of the header checks.** An invoice billed to the wrong group company is exception 13's cousin and is common in groups sharing suppliers. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. Stop — **a partial population produces "no exceptions" for invoices that were simply not read.** |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

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

**Three capability questions decide this skill, and they must be answered before anything is promised:**

1. **Does the surface expose purchase orders?** With line detail, or header only?
2. **Does it expose item receipts?** With quantities, or only as a status flag?
3. **Does it expose approval status and the approver's identity?** Exceptions 11 and 12 depend on it, and so does the SoD observation above.

**Read the returned schemas and answer all three.** Do not assume in either direction.

**A scope note**: if a tool that pays a bill or releases a payment appears in the listing, it is **out of scope regardless of `effective_policy`.** This skill produces a recommendation; a person pays.

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** Open bills, purchase orders, item receipts, the vendor master and payment history are independent. **Read the whole open population**, not a sample — that is the point.

### The `mock: true` flag

Fixture data has **POs, receipts and invoices that agree**, because they were generated together from the same source. **Every one of the fifteen exception tests passes.**

**And the output of this skill is a payment recommendation.** Label it in the file name, on the match summary, and beside every Pay recommendation.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Interview for:

1. **The tolerance policy** — price %, quantity %, total amount. `[manual]`. **If none is provided, default to exact match and flag every variance** — the original's rule, preserved.
2. **The approval matrix** — who may approve at what amount. `[manual]`, **and persist it**; it changes rarely and exception 12 cannot run without it.
3. **Whether services POs are in scope**, and what substitutes for a GRN.
4. **The FX policy** for multi-currency POs. `[manual]`.
5. **Who owns exception resolution.** `[manual]` — Sheet 3 needs an owner per row.

**Decisions are the user's; state is the workspace's.**

---
