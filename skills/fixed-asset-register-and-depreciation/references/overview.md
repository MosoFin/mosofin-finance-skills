<!-- fixed-asset-register-and-depreciation · overview.md · read for: background — what the ledger holds, what it does not, and the checks that makes possible; read when a user asks why. Edit here, not in SKILL.md. -->

# Fixed Asset Register and Depreciation (Mosofin)

Maintains the **fixed asset (PP&E) register**, computes depreciation by various methods, handles
capitalization and disposals, and **reconciles FA balances to the GL**.

**In plain words:** when a business buys something that will last for years — a van, a machine, a building
fit-out — the cost is not an expense all at once. It goes on the balance sheet and is written down a bit
each month over the years it will be used. Doing that properly needs a list of every asset, what it cost,
when it went into use, and how fast it is being written down.

This skill is **framework-aware** — it applies US GAAP, IFRS, or local GAAP depreciation rules per the
user's framework.

It is **workspace-scoped**: the ledger balances, the additions and disposals, and the recorded depreciation
come from tool calls against a company file connected to your Mosofin workspace in this conversation, or
from something you supplied by hand and that is labelled as such.

## The shape of this skill: totals without detail — and what that makes possible

**The general ledger holds the balances. It does not hold the register.** Gross cost, accumulated
depreciation and depreciation expense are all readable as totals per account. **Asset-level cost, in-service
date, useful life, salvage value, depreciation method, location and condition are not in the accounting
system at all** — they live in a fixed-asset module, a spreadsheet, or nobody's hands.

So the register itself is **`[manual]`**. But that is not the end of the story, because **the movements are
readable**, and that inverts the usual reconciliation into something more useful:

1. **Additions can be derived independently.** **Debits to the fixed asset accounts during the period are
   the capitalizations** (*`get_general_ledger`*, *`search_purchases`*). You do not have to ask for a list
   of acquisitions — you can read them, and then compare. **A debit to the asset account that is not in the
   register is an unrecorded asset; a register entry with no matching debit is a phantom.** Reconciling
   both directions is the whole game, and here both directions are available.
2. **Disposals likewise.** **Credits to the asset accounts, and any movement on gain-or-loss-on-disposal
   accounts**, are the disposal population.
3. **The capitalization threshold can be tested against the expense accounts.** **[auto]**, and this is the
   check auditors actually perform: scan repairs, maintenance, equipment and small-tools expense for
   **individual items at or above the threshold**. **Capital items hide in repairs and maintenance**, and
   finding them is one query.
4. **Depreciation can be sanity-checked without the register.** Recorded depreciation divided by gross cost
   gives an **implied rate**; compare it to the policy useful lives. **A rate far from policy means wrong
   lives, missed assets, or depreciation that stopped running.**
5. **Fully depreciated assets are visible** — where accumulated depreciation equals cost. **Assets still in
   use at zero net book value** are a register-hygiene finding and often an impairment or replacement
   signal.

**What remains genuinely out of reach:** every useful life and method, salvage values, the capitalization
policy itself, impairment testing (which needs forecasts and fair values), tax depreciation, and the
physical count — which is a physical act, not a query.

**Mosofin is read-only.** It cannot capitalize, depreciate, dispose or impair anything. Every entry below is
a *proposal*.

---
