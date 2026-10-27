<!-- bank-reconciliation · output.md · read for: Stage 5 — what to deliver and how to name it; check before presenting. Edit here, not in SKILL.md. -->

## Outputs

1. **Reconciliation summary** — with a header stating the workspace, the entity `display_name`,
   the account by name, the period, **whether a bank statement was supplied**, and whether any
   figure rests on `mock` data.
2. **Matched transaction list** — each with the matching method (1–4) that produced it.
3. **Unmatched lists with classification** — bank side and book side, per Step 4.
4. **Exception log with recommended next actions** — each with an owner and a target date.
5. **Proposed entries** — marked as proposals, each with its evidence.
6. **Sign-off block** — preparer and reviewer, two different people, left blank.

**Coverage sheet — NEW, Mosofin-specific.**

One row per task in Steps 1–6:

| Task | Entity (`display_name`) | Account | Verdict (auto / gated / manual) | Tool used | Policy (enabled / permission / disabled) | `mock` | Gap — what could not be verified and what the user must supply |

If no statement was supplied, the rows for the bank side, the matching step and the unmatched-bank
classification all read `manual` with the gap "bank statement not supplied", and **the summary
says the reconciliation was not completed**. That is the correct, expected output — not a defect,
and not something to disguise with a book-side total.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming — Mosofin addition** (the original left it unstated, and multi-account, multi-entity
output needs it): `Bank_Rec_[AccountName]_[YYYY-MM].xlsx`, and in a multi-entity run
`Bank_Rec_[EntityDisplayName]_[AccountName]_[YYYY-MM].xlsx`. Every file states which datasource,
which `display_name` and which account it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource.
Where the data does not cover something, **name the tool that would have covered it** instead of
estimating.

---
