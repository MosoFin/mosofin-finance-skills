<!-- prepaid-amortization-schedule · gates.md · read for: Stage 2 — confirming scope and capabilities on the Mosofin path. Edit here, not in SKILL.md. -->

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

Nothing below runs until the workspace is confirmed. Not a read, not a lookup, not a "quick check of the balance."

1. Call `list_workspaces` with no arguments.
2. If the status comes back `confirmed`, there is exactly one workspace. **Read its name back to the user and wait for an explicit yes.** Silence is not a yes. A previous message about a different task is not a yes.
3. If the status comes back `selection_required`, there are two or more. Ask, in chat: **"Is this a single-workspace task or a multi-workspace one?"** Do not guess, and do not take the first row because it is the first row.
   - Single: ask which one by name, then call `list_workspaces(workspace_ids=[<ws_...>], mode="single")`.
   - Multi: ask which ones, then call `list_workspaces(workspace_ids=[<ws_...>, ...], mode="multi")`.

Refer to a workspace by its **name** and, where a stable machine reference is unavoidable, by the opaque `ws_...` handle the tools hand back. There is an internal numeric id behind it. Never print it, never repeat it back, never ask the user for it. If it turns up inside an error message, name the workspace instead and move on.

**Why a prepaid task specifically needs this gate.** Prepaid schedules are among the most casually copied artifacts in accounting. The same insurance broker writes policies for four related companies; the same SaaS vendor bills three of them. A schedule built against the wrong entity looks entirely plausible — same vendors, same amounts, similar balance — and will reconcile to nothing. Confirming first costs one question.

---

## Gate 1 — Establish the datasource and entity scenario

Call `get_agent_datasources` for the confirmed workspace.

Then establish, **out loud with the user**, which of these you are in:

| Scenario | What it means here |
|---|---|
| **No datasource connected** | Every step below is `[manual]`. Say so immediately. Do not build a half-schedule out of what the user typed into chat and call it reconciled. |
| **Exactly one company file** | The straightforward case. Confirm the `display_name` back to the user before reading. |
| **Several company files** | Ask which one, **by `display_name`**. If the answer is "all of them," that is not one schedule — it is several, each labelled with its entity, and never merged into one column. |
| **Connected but stale or broken** | If a call returns a `reconnect_url`, the connection needs the user's attention. Stop and tell them. Do not fill the gap with assumptions. |

Refer to company files by `display_name` throughout — "Northwind Trading Ltd", not the `data_source_id`. Pass the id between tools; never show it.

**On multi-entity prepaids specifically.** Group insurance policies and group software licences are frequently paid by one entity for several. If two connected entities show prepaid balances that look related, do not net them and do not assume a recharge exists. Label every figure with the entity it came from. See the "paid by a related entity" edge case below.

---

# PART A — Explore the confirmed sources, and personalise this run

The workspace and its data sources are settled. This part finds out **what they
expose and which of it serves this request** — the tool catalogue in Gate 2, then
what is already known about this entity plus whatever still has to be asked in
Gate 3. The result is a run shaped around these books, not a generic template.

## Gate 2 — Map what you can actually do

*The write-tool guardrail that belongs here is in [`mosofin-protocol.md`](mosofin-protocol.md) under "Write tools — the Gate 2 guardrail". It applies in full at this gate.*

Call `get_datasource_tools` for the chosen company file and read the **`effective_policy`** on each returned tool. That field, not documentation and not this file, decides what is possible today.

| `effective_policy` | Verdict in this skill | Behaviour |
|---|---|---|
| `enabled` | `[auto]` | Call it. Batch it with other independent reads. |
| `permission` | `[gated]` | Calling raises `approval_required`. Explain what you want and why, get a yes, then re-invoke with `approved=true`. **Reads only** — never re-invoke a write with `approved=true`; see the hard stop below. |
| `disabled` | `[manual]` | Not available. The step still exists; the user performs it. Never quietly drop it. |

Every verdict in this document is a **default written before the gateway was consulted**. If Gate 2 disagrees with the label on a step, **Gate 2 wins**. A step marked `[auto]` here that comes back `permission` in this workspace is `[gated]` in this workspace, for this run, and the write-up should say so.

Read the tool names off the response. Do not type them from memory and do not infer them from an account name — an `UNKNOWN_TOOL` envelope means exactly that, and it is a signal to re-read the tool list, not to try a near-miss.

**Every call is stateless.** Carry `data_source_id` on each invocation, including the re-invocation after an approval. Dropping it on the retry is the single most common way an approved call fails.

**Batch independent reads.** The prepaid account transaction detail, the expense ledger, the chart of accounts, and the vendor list do not depend on one another. Issue them together in one message. Serializing four reads that could have been one round trip wastes the user's time for no gain in correctness.

### The `mock: true` flag, and what it means for a prepaid schedule

If a response carries `mock: true`, you are looking at **fixture data**, not the client's books.

The consequence here is specific and worth naming, because prepaid work is the one place it is most likely to fool you: **fixture data ties out.** A synthetic prepaid account will reconcile to a synthetic schedule perfectly, on the first pass, with a zero variance, because both were generated from the same made-up assumptions. A real prepaid account almost never does. It has a stale policy from 2023, a deposit somebody miscoded, and a month where the recurring entry silently stopped.

So a clean tie-out on mock data tells you the arithmetic in this skill works. It tells you nothing whatsoever about the client. Label the output as fixture-derived, in the file name and on the first sheet, and do not let a clean variance column be read as reassurance.

---

## Gate 3 — Read the profile, then interview for what remains

Call `get_my_skill` and `get_skills` first. If the workspace already carries a client profile — the materiality threshold, the amortization convention, the prepaid account structure, whether recoverable tax is split — **use it and say you are using it.** Asking a client a question they have already answered, on a schedule they have already agreed, is how a tool stops being trusted.

Interview only for what is genuinely still open. For this skill that is a short and specific list:

1. **Which account (or accounts) is prepaid?** Read the chart first, then confirm. Many books have several: Prepaid Expenses, Prepaid Insurance, Prepaid Rent, and something called Other Current Assets that has become a drawer.
2. **The materiality threshold** — below which an item is expensed rather than scheduled. The original skill was explicit that this is the user's call. It remains the user's call. This skill applies it; it does not set it.
3. **The convention: whole-month or daily proration?** Both are defensible. Mixing them within one schedule is not.
4. **Is recoverable tax (VAT/GST) split out at payment, or is it sitting in the asset?** This is answerable from the ledger, but the *policy* is the user's to state.
5. **The coverage dates** for each open item. This is the big one, and it does not come from the ledger. See the section immediately below.

**Decisions are the user's; state is the workspace's.** The workspace can tell you the balance moved. Only the user can tell you whether a policy runs to March or to June.

---
