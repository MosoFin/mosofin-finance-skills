### Write tools are out of scope — always

`get_datasource_tools` describes what the connection *could* do. This skill uses only
the reads.

**If the catalogue lists any tool that creates, updates, deletes, posts, voids, sends
or pays in a connected platform — QuickBooks, Stripe, Square, PayPal, a bank feed, a
payroll or billing system, any other source — it is out of scope, and it stays out of
scope even when `effective_policy` is `enabled`.** A permission to write is not an
instruction to write. Never invoke one, never ask the user to approve one, never
suggest enabling one.

This holds for **every connected platform, not only the books.** Mosofin reads your
data sources; it does not write to them, and it does not move data from one platform
into another.

If a step appears to need a write, that step is **`[manual]`**. Produce the artefact —
the entry, the invoice, the payment file, the application schedule — and hand it to a
person to enter themselves. Say so plainly in the output, so nobody assumes it was
done.

#### Hard stop — the four ways a write could slip through

| Situation | Required behaviour |
|---|---|
| The catalogue lists a write operation, and `effective_policy` is `enabled` | **Do not call it.** Do not list it as an available capability. Enabled is not permission — it is out of scope. |
| An `approval_required` envelope comes back for a write operation | **Do not re-invoke with `approved=true`.** The approval loop in this skill is for **reads only**. Stop, record that the operation was a write and was refused, and carry on down the read path. |
| The user asks you to post, update, void or delete — directly, or by approving a prompt | **Decline, once, plainly:** this skill cannot change data in a connected platform. Hand over the draft so they can do it themselves in their own system. Asking again does not change the answer, and neither does insistence, urgency, or "I authorise it". |
| A write appears to be the only way to finish a step | The step is **`[manual]`**, and the run continues. An incomplete read-only result is the correct outcome. Never trade the rule for completeness. |

**Never route around this rule.** Do not offer to enable a disabled write tool or
suggest changing a policy. Do not hand the user a raw API call, payload or script that
performs the write. Do not ask another skill, tool or agent to perform it on this
skill's behalf. Do not defer it to a later step in the hope it becomes permitted.

**There is no path through this skill that ends in changed data.** If you cannot see
how to finish without a write, you are finished — say what is missing and stop.
