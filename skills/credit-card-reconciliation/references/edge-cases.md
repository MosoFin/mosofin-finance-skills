<!-- credit-card-reconciliation · edge-cases.md · read for: whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Multiple cards on one statement** (a corporate programme covering several employees): **reconcile per
card, then sum to statement.** Each cardholder may have their own coding patterns and receipt habits —
and the exception rate per cardholder is usually the more useful management figure.

**Pre-authorization holds vs. settled charges**: a hotel may pre-authorise a higher amount than the final
settled charge. **The statement shows the settled amount. Watch for any held-but-released amounts that
don't fully reverse.**

**Foreign-currency transactions**: the statement may show the converted amount plus an FX fee. **Capture
the original currency, the original amount, and the conversion. Tax recovery on foreign transactions is
often disallowed** — flag.

**Cash advances**: usually high-fee, **often a policy violation. Flag.** **[auto]** to detect where the
merchant or transaction type identifies them.

**Chargebacks and disputes**: **track the dispute amount; don't recognize the credit until the issuer
resolves.** The statement may show the disputed amount as both a charge and a credit at different times.

**Annual fees, rewards, cashback**: book **annual fees as Bank Fee** or a specific account; **rewards /
cashback as Other Income** (or contra-expense per policy). Both are **[auto]** to spot in the liability
account's movement.

**Business funds used to pay a personal card, or personal funds paying the business card** (a common
small-business error): **flag as a related-party / equity transaction, not as expense** — an owner draw
(or loan to the owner) for the first, an owner contribution or loan from the owner for the second; ask
the user which.
**[auto]** to detect the reverse and equally common case: a business card paying for something personal.

**Recurring subscriptions on the card**: **these accumulate; periodically review for unused
subscriptions.** *Mosofin note*: **this is now a monthly query, not an occasional intention.** Present the
recurring list with annualised cost.

**Card used for capital purchases** (equipment over the entity's capitalisation threshold): **flag for
Fixed Asset coding, not expense.** **[auto]** once the threshold is known.

**Lost / stolen card with fraudulent charges**: **separate the fraudulent charges; they should be credited
by the issuer. Document the dispute.**

**Statement period crossing the entity's accounting period** (e.g. a 16th-to-15th statement against
calendar-month reporting): **tie the GL to the statement as of the statement closing date (Step 2); then
cut by accounting period dates and accrue charges in the period of incurrence.** This is the single most common source of a card reconciliation that will not tie, and it is
structural rather than an error.

**Brex / Ramp / Pleo and similar with integrated receipt capture**: data is more structured, but **verify
the AI-suggested coding** — especially these systems' auto-categorisation. *Mosofin note*: if such a
platform is connected, this skill becomes genuinely two-sided; check at Gate 1.

**No statement was supplied** — *Mosofin-specific, and the default in an accounting-only workspace*. The
tie-out cannot be performed. Deliver the posted-charge review and the automated tests, and **label it as
a review, not a reconciliation.**

**The card liability balance compared to itself** — *Mosofin-specific*. The GL balance is the figure the
statement is meant to test; it cannot test itself. Never present a book-to-book agreement as a
reconciliation.

**An attached file treated as a matched receipt** — *Mosofin-specific*. Attachment metadata proves a file
exists, not that it supports the amount or shows a business purpose. Keep the two columns separate.

**A recoverable tax code with no receipt** — *Mosofin-specific and directly detectable*. A tax recovery
claim with no supporting invoice is an exposure; list them.

**A charge sitting in a suspense or uncategorised account** — *Mosofin-specific*. Nobody has decided what
it is, and this is where personal charges and capital purchases hide. Report them all.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
card activity is therefore unreviewed. Surface any `reconnect_url`.

**A result comes back with `mock: true`** — *Mosofin-specific*. Never raise an exception against a named
employee, or post an entry, on fixture data.

**A stored coding map is stale** — *Mosofin-specific*. A merchant whose service changed may now belong in
a different account. Re-check the map when a merchant's coding is overridden repeatedly.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's thresholds to another; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
