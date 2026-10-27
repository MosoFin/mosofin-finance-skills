<!-- fixed-asset-register-and-depreciation · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Composite assets** — a building with roof, HVAC and structure, each with different useful lives: **under
IFRS, must be componentized; under US GAAP, optional. The framework determines treatment.**

**Leasehold improvements**: **depreciated over the lesser of useful life or remaining lease term. When the
lease term changes, adjust depreciation prospectively.**

**Land**: **not depreciated. The building on the land is depreciated. Allocate purchase price between land
and building.** *Mosofin check*: accumulated depreciation on a land account is a readable error.

**Construction-in-progress (CIP)**: **not depreciated until placed in service. When placed in service,
transfer from CIP to the appropriate asset class and start depreciation.** *Mosofin note*: **a CIP balance
that has not moved in several periods is worth flagging** — either the project stalled, or it went into
service and nobody transferred it, which means depreciation never started.

**Capitalized interest** (ASC 835-20 / IAS 23): **for qualifying long-duration assets being constructed,
capitalize interest on borrowings. Calculation per the standard.**

**Asset transferred between classes** — a building reclassified as investment property under IFRS:
**special accounting required at reclassification.**

**Foreign-currency assets**: **at acquisition, the cost is converted to functional currency at the
acquisition-date rate and held at that historical rate. No ongoing FX revaluation of historical cost.
Depreciation is on the historical cost in functional currency.**

**Revaluation model (IFRS only)**: **IFRS allows carrying assets at fair value with periodic revaluation
through OCI. US GAAP does not.** If the user is IFRS and elects revaluation, **account separately** — and
note the valuation is `[manual]`.

**Government grants for asset acquisition**: **reduce the asset cost or set up a deferred grant liability
that amortizes alongside depreciation** — per framework choice.

**Assets held for sale** (ASC 360 / IFRS 5): **once held-for-sale criteria are met, reclassify, stop
depreciating, and measure at lower of carrying value or fair value less costs to sell.**

**Spare parts**: **major spare parts not used in normal operation can be capitalized; routine spares are
inventory or expense.**

**Software**: **typically intangible, not PP&E. Internal-use software has specific capitalization rules**
(ASC 350-40 / IAS 38).

**Disposal where the asset is donated**: **no proceeds; full NBV is a loss** — with a possible tax deduction
at fair value depending on jurisdiction.

**Trade-in of old asset for new**: **treat as two separate transactions: dispose old, acquire new. Fair
value of trade-in = proceeds on the old asset.** *Mosofin note*: on the invoice this appears as one net
amount, so **the gross cost of the new asset and the disposal of the old are both understated** if the net
figure is capitalized. A readable pattern worth checking on vehicle and equipment purchases.

**Group depreciation**: **a group of similar assets depreciated as one pool. Disposals don't trigger
gain / loss — just remove from the pool. Less common; used in some industries.**

**A capitalization appears in the GL but not in the register** — *Mosofin-specific, and the most damaging*.
**That asset will never be depreciated.** It sits at full cost indefinitely. Nothing else in the close
catches it.

**A register asset has no cost in the GL** — *Mosofin-specific*. A phantom, usually disposed of years ago
and never removed.

**A capital item is sitting in repairs and maintenance** — *Mosofin-specific check, and a standard audit
procedure*. Run the threshold scan every period. **Report candidates, not conclusions.**

**Cost removed on disposal but accumulated depreciation left behind** — *Mosofin-specific*. Or the reverse.
Both leave the balance sheet wrong and usually produce a spurious gain or loss.

**Proceeds received with no asset removed** — *Mosofin-specific*. Cash in from an equipment sale with no
disposal entry: the asset is still on the books.

**Depreciation has not been posted this period** — *Mosofin-specific*. Check before anything else; a
recurring journal that stopped is silent.

**The implied depreciation rate is far from the policy life** — *Mosofin-specific*. Wrong lives, missing
assets, or a stale recurring entry. Coarse, and it still finds real errors.

**Assets fully depreciated but still in use** — *Mosofin-specific*. Readable where accumulated depreciation
equals cost. A register-hygiene and replacement-planning finding, not an error in itself.

**The physical count has never been performed** — *Mosofin-specific emphasis*. **That is the finding.**
Record it with an owner; do not let a clean GL tie-out imply the assets exist.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
assets are therefore unexamined.

**A result comes back with `mock: true`** — *Mosofin-specific*. A register reconciled to fixture balances is
not reconciled, and depreciation computed from it must not be proposed for posting.

**A stored register or net book value is reused** — *Mosofin-specific*. Both are state. Persist the policies
and the account map; re-obtain the register and the balances.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it. Never
apply one entity's lives or threshold to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
