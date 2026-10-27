<!-- vendor-statement-reconciliation · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path, including which entity the statement addresses. Edit here, not in SKILL.md. -->

# Gates 0–3 — confirming scope on the Mosofin path

## Contents

- ONBOARDING — Confirm the workspace and its data sources
  - Gate 0 — Confirm the workspace before anything else
  - Gate 1 — Establish the datasource and entity scenario
- PART A — Explore the confirmed sources, and personalise this run
  - Gate 2 — Map what you can actually do
  - Gate 3 — Read the profile, then interview for what remains


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

**Why this gate matters here.** In a group sharing suppliers, **a statement addressed to one entity reconciled against another's ledger will show every invoice as missing** — a spectacular and entirely artificial set of exceptions. **Confirm which entity the statement is addressed to**, and see the note below.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

| Scenario | What it means here |
|---|---|
| **No datasource connected** | The AP side must be exported. The reconciliation works as the original describes. **Step 0's prioritisation does not run.** |
| **Exactly one company file** | Confirm the `display_name` — **and that it is the entity the statement addresses.** |
| **Several company files** | **Groups share suppliers.** See below — this is a common and confusing failure. |
| **Connected but stale or broken** | A `reconnect_url` means the connection needs the user. Stop — **a partial AP ledger makes recorded invoices look missing**, which points the reconciliation in exactly the wrong direction. |

Refer to company files by `display_name`. Pass `data_source_id` between tools; never display it.

**The shared-supplier problem, and it is worth anticipating.** Where a group buys from one supplier through several entities, **the supplier may issue one statement covering all of them, or separate statements per account.**

- **One combined statement**: reconciling it against a single entity's ledger produces false "missing invoice" exceptions for everything belonging to the siblings. **`[auto]` where the other entities are connected** — read all of them and match across, then split the result by entity.
- **Separate statements**: check the account reference on the statement matches the entity being reconciled. **A statement for the wrong account is the commonest cause of a reconciliation that will not converge.**

And a related vendor-master trap: **if the supplier exists twice in one vendor master, half the invoices are under the other record** and will present as missing. **Run the duplicate check before concluding anything.**

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

Read tool names off the response. `UNKNOWN_TOOL` means re-read the list.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the retry after approval.

**Batch independent reads.** The AP ageing, the full vendor transaction ledger, the payment register, the vendor master and spend by vendor are independent. **Read beyond the cutoff date** — payments in transit and post-cutoff activity are needed to explain differences, and a read stopping at the cutoff cannot distinguish a timing difference from a missing item.

### The `mock: true` flag

Fixture data has **an AP ledger with no missing invoices, no unclaimed credits and no duplicates** — and no vendor statement at all to reconcile it against.

Label it in the file name and on the reconciliation summary.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` before asking anything.

Interview for — only those not answered at Stage 1:

1. **The vendor statement(s).** `[manual]` — the whole point, and not obtainable from the workspace.
2. **The cutoff date.** `[manual]` — and see Step 1; **a statement's cutoff and yours frequently differ.**
3. **The dispute log.** `[manual]`.
4. **The reconciliation policy** — which vendors, how often, who owns exceptions. `[manual]`, **and Step 0 informs it.**

**Decisions are the user's; state is the workspace's.**

---
