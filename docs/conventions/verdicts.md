# Verdict Annotations

Every task in every skill carries one.

| Verdict | Meaning | Behaviour |
|---|---|---|
| `[auto]` | Live reads, unattended | Call it; batch independent reads |
| `[gated]` | Permission required | Expect `approval_required`; explain, get a yes, re-invoke with `approved=true` **and the `data_source_id`** |
| `[manual]` | Not on this surface, or not a machine's judgment | **The step stays. Name the owner.** |

Two skills use a finer split where a large block of work needs no ledger at all
(`recurring-transaction-builder`, `scenario-and-sensitivity-analysis`,
`three-statement-financial-model`):

| Verdict | Meaning |
|---|---|
| `[auto: computed]` | Pure calculation — works with **no datasource connected** |
| `[auto: read]` | Requires a live read |

That distinction answers the question "was this actually measured, or just
calculated?", which is what a reviewer wants to know.

## Rules

1. **Verdicts in a skill file are defaults**, written before the gateway was
   consulted. **Gate 2 wins** where the observed `effective_policy` disagrees, and
   the coverage sheet records the divergence.
2. **A `[manual]` task is never dropped.** It appears in the checklist with an owner.
3. **A test that could not run must never look like a test that passed.** Record it
   as not-run, with the reason.
4. A step with several parts carries several verdicts. Show them; do not average.
