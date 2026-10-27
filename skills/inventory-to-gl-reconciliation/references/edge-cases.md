<!-- inventory-to-gl-reconciliation · edge-cases.md · read for: Stages 3–5, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**Standard cost system with significant variances**: **variances accumulate in PPV (purchase price
variance), MUV (material usage variance), etc. At period end, they're either expensed or capitalized back
into inventory. Document the policy.** *Mosofin note*: **the variance balances are readable**; the
absorption policy is not.

**Negative inventory** — the system allows quantity to go below zero: **always wrong. Indicates a missing
receipt or duplicate sale. Investigate every negative balance.** *Mosofin note*: **one query, and it finds
real errors every time.** Run it every period.

**Consignment inventory**: **the entity's goods at a customer location remain the entity's inventory. A
customer's goods at the entity's location are NOT the entity's inventory. Common error.** *Mosofin note*:
**consignment-in sitting on the balance sheet overstates assets and liabilities together** — check for it
explicitly.

**Inventory at third-party logistics (3PL)**: **ensure inventory is reconciled to 3PL statements; in-transit
between entity and 3PL is the entity's.** **The 3PL statement is `[manual]`.**

**Returned merchandise**: **customer returns flow back into inventory at the original cost or at NRV if
damaged. Don't reactivate damaged returns at full cost.**

**Long-aged inventory (slow-moving / obsolete)**: **candidate for write-down. The entity's policy might be:
aged > 12 months → 25% reserve; > 24 months → 50%; > 36 months → 100%. Apply per policy.** Setting the
reserve itself is an inventory obsolescence task.

**Damaged / scrap inventory**: **write off at the time of scrapping; document with photos and approvals if
material.** **Condition is `[manual]`** — nothing here can see it.

**Multi-currency inventory**: **inventory is valued in functional currency at purchase cost converted at the
purchase-date rate. No ongoing revaluation of inventory itself for FX — it's a non-monetary asset.**
*Mosofin note*: so **an FX revaluation appearing against inventory is usually an error**, not a reconciling
item.

**Component parts in WIP not yet assembled into finished goods**: **WIP value = raw materials + labor +
overhead applied to in-process units. Reconciliation must trace from raw materials through WIP into finished
goods.** **Impossible where the chart has a single inventory account** — a structural limitation to report.

**Inventory acquired in a business combination**: **opening value at fair value, often higher than book cost.
Track separately for cost-allocation purposes.** Measuring that fair value is business-combination accounting (ASC 805).

**ROU vs. inventory**: **leased equipment is not inventory — it's ROU under ASC 842 / IFRS 16. Common
misclassification.**

**Inventory reserve roll-forward**:
```
Opening reserve
+ Period write-downs / additions
- Period write-offs (inventory actually scrapped)
- Releases (NRV recovered, reserved items sold above cost)
= Closing reserve
```
**The reserve account net of inventory equals the carrying value.** **[auto]** — and it must tie to the
account.

**GL and subledger are the same system** — *Mosofin-specific, and the central point*. **They agree by
construction** — unless the inventory account was posted to directly (journal entries, account-coded bills
or expenses, opening balances). Compute the difference anyway: zero is reported as nil by construction, not as
a reconciliation; non-zero is investigated per Step 3.

**A clean reconciliation with no recent count** — *Mosofin-specific*. **The two systems may have been
agreeing about stock that is not there.** The count date belongs in the header.

**Shrinkage computed without a count** — *Mosofin-specific*. It is an unexplained GL difference, not
shrinkage. **The name matters** because shrinkage implies a cause nobody has established.

**A single inventory account covering all categories** — *Mosofin-specific structural limitation*.
Category-level reconciliation is impossible. Report it.

**Cut-off tested only on transaction dates** — *Mosofin-specific*. **Entries posted after period end,
whatever their date, are the larger population** and the one where errors hide.

**A variance account balance treated as explained** — *Mosofin-specific*. It is where unexplained
differences have been accumulating, sometimes for years.

**Investigation stopped after the data steps** — *Mosofin-specific*. **Steps 5 and 6 need people**, and they
are where causes come from. Four of six is a classification, not an explanation.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and say whose
inventory is therefore unreconciled.

**A result comes back with `mock: true`** — *Mosofin-specific*. Inventory is frequently the largest asset on
the balance sheet.

**A stored count result or variance is reused** — *Mosofin-specific*. All state. **Persist the account map
and the cadence; re-obtain the figures.**

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*. Flag it; never
apply one entity's account map to another.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
