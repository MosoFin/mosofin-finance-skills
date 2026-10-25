<!-- gl-coding-assistant · overview.md · read for: background for the card and Stage 1 — what the skill does, and why the ledger history becomes Tier 1; read when a user asks why. Edit here, not in SKILL.md. -->

# GL Coding Assistant (Mosofin)

Suggests the correct **general ledger account**, **expense category**, and **tax code** for transactions
based on vendor, description, amount, and context. Designed to **accelerate bookkeeper coding decisions
while flagging ambiguous items for human review**.

**In plain words:** every payment has to be filed under the right heading so the accounts mean something.
Most of them are obvious once you know how this business files things. This works out which heading each
one belongs under, says how sure it is, and separates the easy ones from the ones a person should look at.

This skill is **jurisdiction-agnostic**. **It does NOT invent account numbers and does NOT assume any
country's tax rules.** All account references come from the entity's actual chart of accounts; all tax logic
is driven by the entity's jurisdiction.

It is **workspace-scoped**: the chart of accounts, the vendor list, the tax codes and — most importantly —
**the entity's own coding history** come from tool calls against a company file connected to your Mosofin
workspace in this conversation, or from something you supplied by hand and that is labelled as such.

**Note it is no longer chart-of-accounts-agnostic in the original's sense** — it reads the entity's real
chart rather than accepting any list. That is a narrowing, and it is stated rather than left implied.

## What changes in a Mosofin workspace: Tier 1 stops being optional

The original's classification hierarchy leads with **Tier 1 — exact vendor match**, using "the user's prior
mappings", which it lists as an **optional** input that "improves accuracy". In practice almost nobody
maintains that file.

**Here, the prior mappings are the general ledger.**

> **How this entity has coded every vendor before is readable, with counts.** Not "Amazon usually goes to
> Office Supplies" as a guess, but **"this entity coded this vendor to 6120 Office Supplies in 43 of 45
> prior transactions, most recently last month."** That is the difference between a suggestion and an
> evidenced recommendation, and it makes the highest-confidence tier both automatic and auditable.

Four more things follow from the same access:

1. **The chart of accounts is `[auto]`.** The original's "stop and ask" rule and its **PLACEHOLDER — REMAP
   REQUIRED** fallback survive as a degradation path, not the normal case.
2. **You can find the work yourself.** **Uncategorized, suspense and "ask my accountant" accounts are
   readable** — so the skill can locate what actually needs coding rather than waiting for someone to paste
   a list. That is often the more useful opening move.
3. **Transfer detection becomes real.** The original infers a transfer from a one-sided bank export —
   "same amount, opposite sign, within ~3 days". **With the ledger, both sides are visible.**
4. **The tax codes actually configured in this entity are readable**, so a tax-code suggestion can name a
   code that exists rather than describing a concept.

**And one caution that matters more than all four:**

> **Frequency is not correctness.** If this entity has been coding something to the wrong account for two
> years, the history will recommend continuing with high confidence and good evidence. **Report the
> consistency, not the conclusion** — and where a vendor's history is *inconsistent*, say so rather than
> picking the most common or the most recent. An inconsistent history usually means the category was never
> actually decided.

**Mosofin is read-only.** It cannot code, recode or post anything. Every suggestion below is a *proposal*
for a person to apply.

---
