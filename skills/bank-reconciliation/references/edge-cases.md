<!-- bank-reconciliation · edge-cases.md · read for: Stages 3–4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

*The original did not carry an Edge Cases section; these are Mosofin additions plus the hazards
implicit in the steps above.*

**No bank statement was supplied** — the default situation in an accounting-only workspace. Do the
book-side preparation, label it as such, and say the reconciliation was not completed. Never
produce a two-column document that implies otherwise.

**The connector exposes no "cleared" flag** — outstanding cheques and deposits in transit can only
be proposed as **candidates** by date. Label them that way.

**No prior reconciliation is available** — opening outstanding items are unknown, so an item
appearing unmatched may be months old. Say the bridge starts unqualified and recommend
establishing a baseline.

**A foreign-currency account carried in the base currency** — the bridge will never balance if one
side is converted and the other is not. Reconcile in the account's own currency, then translate.
The translation itself is an FX revaluation task, separate from this reconciliation.

**A transfer between the entity's own accounts recorded once** — appears as an unexplained debit on
one account and an unexplained credit on another. Always check transfers on both accounts before
classifying either as an error.

**A batched deposit or card settlement** — one bank line, many book receipts, often net of fees.
Match the batch, expect the net, and gross up the fee rather than forcing the amounts to agree.

**A duplicate payment about to be reissued** — an old outstanding cheque that is really lost will
be reissued, and if the original then clears the entity pays twice. Escalate cheques over 90 days
rather than rolling them forward.

**Deposits in transit that never clear** — after ten business days this is a missing deposit or a
booking error, not timing. Investigate rather than carrying it forward.

**Someone reconciles to materiality** — the bridge ties **to the cent**. A "close enough" bridge
has an unidentified item in it, and unidentified items are where fraud and error live.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
which accounts are therefore unreconciled. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. A reconciliation is a control;
performing it on fixture data records a control as operating when it did not.

**A bank account is shared by several entities** — *Mosofin-specific*. No single entity's GL can
tie to the whole statement. Reconcile the statement to combined activity and treat the split as an
allocation.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it.
Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.
