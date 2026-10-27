<!-- balance-sheet-reconciliations · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Subledger that doesn't tie to its own control** (a system bug or data issue): flag it and
require system reconciliation. **The GL / subledger rec is meaningless if the subledger is
internally inconsistent.**

**GL balance is correct but presented in two accounts** (e.g. a classification error between
current and non-current portions): reclass via JE. The total is right, the presentation is not.

**Account that should always be zero** (e.g. Suspense, Clearing): any non-zero balance requires
immediate investigation. **Don't roll forward an open clearing balance.** *Mosofin note*: this
account is fully `[auto]` — the test is not a two-source tie but "balance should be zero; every
line explained", all readable from the GL — so it is the fastest genuine win in the whole
workpaper. Run it first.

**Multi-currency accounts**: reconcile in the functional currency for the GL, but **also
reconcile in the original currency** where applicable (e.g. a foreign-currency bank account). FX
revaluation may explain differences.

**Intercompany account that's not netting to zero against the counterparty's mirror balance**:
that is an intercompany mismatch, handed to an intercompany reconciliation. *Mosofin note*: if
both entities are connected company files, **pull both sides and quantify the mismatch here**
rather than only flagging it.

**Account with timing-related items at every period end** (e.g. deposits in transit always
present): build the pattern into the standard procedure; **verify each period that they clear
within the expected window.** An item that stops clearing has stopped being a timing difference.

**Large or unusual roll-forward items**: investigate. **A 10× spike in monthly accruals deserves
an explanation, not just a roll-forward.** *Mosofin note*: comparing several periods of movement
is `[auto]`, so this check should always be performed rather than skipped.

**No prior period rec available**: do the current period as fully as possible; document the lack
of carry-forward and recommend establishing the prior-period baseline.

**Adjustments to the opening balance**: typically prior-period adjustments — flag for
review as a possible restatement. The Step 6 opening check is what detects them.

**Account that's been merged or split mid-period**: rebuild the reconciliation respecting the
merge or split, with a memo explaining. *Mosofin note*: a renamed or merged account may return a
different identifier than last period; match on the account's own history, not a remembered id.

**Account where the supporting source itself is unaudited / informal** (e.g. a
manually-maintained accrual schedule): document the source and its limitations. Recommend
systematizing.

**Tolerance threshold not provided**: **ask the user.** Suggest a reasonable basis — for example
the entity's overall financial-reporting materiality divided across the number of accounts — **but
do not silently assume.**

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say
which accounts are therefore unreconciled. Surface any `reconnect_url`.

**Both sides came from the same source** — *Mosofin-specific, and the subtlest failure here*. If
the "supporting balance" is just another view of the same GL, the account has not been
reconciled by that tie alone. An integrated subledger tie (A/R, A/P aging to control) is reported
as **"agrees to subledger (same system)"** and is not counted as independent support; the account
is reconciled only with the aging review plus at least one independent test. Say what independent
evidence is needed, and mark it `[manual]` where it lies outside the books.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate the
workpaper format but cannot support a signed reconciliation, because the reconciliation is itself
a control.

**A tool flipped from enabled to disabled since last period** — *Mosofin-specific*. An account
that reconciled automatically last month may need a manual schedule this month. Re-discover at
Gate 2 every run and tell the user what changed.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag
it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
