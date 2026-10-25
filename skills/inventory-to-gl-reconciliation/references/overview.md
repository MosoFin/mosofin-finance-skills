<!-- inventory-to-gl-reconciliation · overview.md · read for: background — what the skill does, the one-system-or-two question, and what the ledger cannot prove; read when a user asks why. Edit here, not in SKILL.md. -->

# Inventory to GL Reconciliation (Mosofin)

Reconciles the **inventory subledger** (or **physical count**) to the **general ledger inventory control
account**. Identifies variances, classifies them — **shrinkage, count error, costing variance, in-transit** —
and produces **cleanup JEs**.

**In plain words:** the accounts say there is a certain value of stock. The stock system says there is a
certain quantity. The warehouse, when someone actually walks round and counts it, says something else again.
This finds out where the three disagree and why.

This skill works **across product categories**. **The costing method — FIFO / LIFO / weighted average /
standard cost — drives the valuation but not the reconciliation procedure**;
choosing and applying the costing method is a separate inventory-costing task.

It is **workspace-scoped**: the GL balances, the item quantities, the transaction cut-off evidence and the
reserve movements come from tool calls against a company file connected to your Mosofin workspace in this
conversation, or from something you supplied by hand and that is labelled as such.

## The question that decides what this reconciliation is worth

**Before anything else: are the subledger and the GL two systems, or one?**

**In many small and mid-market accounting platforms they are one.** The item module *is* the subledger, and
posting a sale updates the item quantity and the inventory account **in the same transaction, in the same
database.** Where that is so:

> **GL-to-subledger reconciles by construction. It cannot disagree, and proving that it agrees proves the
> software works — not that the inventory is right.** It is the same trap as the system-generated balance
> sheet in `financial-statement-builder`, and it should not be presented as a completed reconciliation.

**Where they are genuinely two systems** — a warehouse management system, a manufacturing ERP or a 3PL
platform feeding summary entries into the accounting ledger — **the reconciliation is real, and it is one of
the most valuable controls in the close.** Differences accumulate quietly in interface failures, timing and
mapping errors.

**Establish which case you are in and say so on the face of the workpaper.** Everything downstream depends
on it.

**And then the harder truth about the third leg:**

> **The physical count is the only comparison that tests whether the goods exist**, and it is **`[manual]`,
> always. No query substitutes for someone walking the racks.** The ledger and the subledger can agree
> perfectly on stock that was stolen last March.

**So what does the workspace actually contribute here?** Rather more than that framing suggests, but none of
it is existence:

1. **Negative quantities.** **[auto]**, and **always wrong** — a missing receipt or a duplicated sale. One
   query, and it finds real errors every time.
2. **Cut-off testing.** **[auto]**: receipts and shipments dated close to the period boundary, and entries
   posted after period end. **This is where a large share of genuine variances originate.**
3. **The reserve roll-forward.** **[auto]**, and it must tie to the reserve account.
4. **Shrinkage trending.** **[auto]** where shrinkage is posted to an identifiable account — the rate over
   time, which is what tells you whether this period is unusual.
5. **The GL side of everything**, exactly and by category.
6. **Standard cost variance balances**, where variance accounts exist.

**What stays outside:** the physical count, the 3PL statement, consignment arrangements, Incoterms and title
terms, and the operational explanation for any variance.

**Mosofin is read-only.** It cannot post an adjustment, a write-down or a cut-off correction. Every entry
below is a *proposal*.

---
