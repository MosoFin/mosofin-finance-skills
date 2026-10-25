<!-- inventory-to-gl-reconciliation · method.md · read for: Stages 3–6 — every Step of the reconciliation (0–10, including 0b), and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 0b — Establish the systems and the count status (Mosofin addition)
- Step 1 — Capture balances and structure
- Step 2 — Three-way comparison
- Step 3 — Reconcile GL to Subledger
- Step 4 — Reconcile Subledger to Physical Count
- Step 5 — Common reconciling items
- Step 6 — Investigate variances
- Step 7 — Compute shrinkage
- Step 8 — Construct cleanup JEs
- Step 9 — Output
- Step 10 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The physical count is `[manual]` by its nature — it stays
in the workflow with an owner and a date.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the items and the cut-off
population do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **raw materials, WIP, finished goods, in-transit, consignment, reserve, shrinkage
  and variance accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **the GL balances by inventory account** — usually
  **[auto]**
- *`search_items`* / *`search_products`* — **quantity on hand, unit cost, extended value, location** —
  usually **[auto]**
- *`get_general_ledger`* on the **inventory, reserve, shrinkage and variance accounts** — **movements, and
  the reserve roll-forward** — usually **[auto]**
- *`search_invoices`* / *`search_purchases`* / *`search_bills`* **around the period boundary** — **the
  cut-off population** — usually **[auto]**
- *`search_journal_entries`* — manual inventory adjustments — usually **[auto]**
- *`search_locations`* — the location structure — usually **[auto]**
- *`get_company_info`* — legal name, currency, year-end — usually **[auto]**

**Pull the cut-off population deliberately**: **transactions dated in the last days of the period and the
first days of the next, plus anything posted after the period end regardless of its date.** That second
group is where most cut-off errors actually live.

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a reconciliation against fixture balances is not
a reconciliation**, and inventory is frequently the largest asset on the balance sheet.

## Step 0b — Establish the systems and the count status (Mosofin addition)

**Run before Step 1**, and put the answer in the workpaper header.

1. **Is the subledger a separate system?** **[manual]** to confirm, **[gated]** to corroborate: if the item
   module and the GL are one platform, **the extended value of all items should equal the inventory account
   exactly.** **If it does, that is construction, not agreement.**
2. **When was the last physical count?** **[manual]**. **If the answer is "never" or "some years ago", that
   is the headline finding** — the GL and subledger may have been agreeing with each other about
   non-existent stock for a long time.
3. **What is the count cadence?** Full annual, cycle counting, or none.

**Report all three.** A perfect GL-to-subledger reconciliation with no count in three years is a weaker
result than a messy one with a count last month.

## Step 1 — Capture balances and structure

For each inventory category / location — **[auto]** on the GL side:

**GL side:**
- **Raw materials**
- **Work-in-progress (WIP)**
- **Finished goods**
- **In-transit**
- **Consignment-out** — the entity's inventory at another's location
- **Consignment-in** — third party's inventory at the entity's location — **typically NOT on the entity's
  balance sheet**
- **Inventory reserve (contra)**

**Subledger side:**
- **Sum of (qty × unit cost) per SKU / location** — **[gated]**, per Step 0b

**[auto]** structural check: **does the chart actually separate these categories?** Many do not — a single
"Inventory" account covering raw materials, WIP and finished goods **makes category-level reconciliation
impossible**, and that is worth reporting as a structural limitation rather than working around silently.

**And check consignment-in explicitly.** **Third-party goods on the entity's balance sheet overstate both
assets and liabilities**, and it is one of the commonest inventory errors — see the edge cases.

## Step 2 — Three-way comparison

**For a robust reconciliation, ideally:**

1. **GL ← compare to → Subledger** — **[gated]**, and **possibly meaningless per Step 0b**
2. **Subledger ← compare to → Physical count** — **[manual]**, **and the leg that matters**
3. **Confirm GL ↔ Subledger ↔ Physical (transitively)**

**If only the subledger is available — no recent physical count — the GL / subledger rec is partial.
Recommend a physical count cadence.**

**Mosofin emphasis**: that last sentence is the crux. **Where the subledger and GL are one system, leg 1 is
not merely partial — it is vacuous**, and the reconciliation reduces to leg 2, which the workspace cannot
perform. **Say this plainly rather than presenting a complete-looking three-way schedule with one leg
missing.**

## Step 3 — Reconcile GL to Subledger

For each inventory account — **[gated]**:

```
GL balance                                           $X
+ items in subledger not in GL (rare)                $A
- items in GL not in subledger                       $B
+/- FX revaluation (if multi-currency)               $C
+/- Standard cost variances not yet absorbed         $D
+/- In-transit / cut-off items                       $E
= Adjusted subledger basis                           $X + A − B + C + D + E

Subledger balance (sum of extended values)           $Y

Reconciled difference                                $(X + A − B + C + D + E) − $Y
```

**Investigate every non-zero difference.**

**[auto]** contributions to the reconciling items: **standard cost variance balances (D)** are readable where
variance accounts exist; **cut-off items (E)** come from the Step 0 boundary population; **FX (C)** is
readable where multi-currency is in use — though note inventory is a **non-monetary** item held at
historical rates, so a genuine FX revaluation of inventory is usually an error rather than a reconciling
item.

**Report the difference including zero** — and where the systems are one, **report it as "nil by
construction"** rather than as a reconciliation result.

## Step 4 — Reconcile Subledger to Physical Count

**For full counts: every SKU is counted. For cycle counts: a subset of SKUs is counted**, typically rotating
per **ABC stratification**.

**For each counted SKU** — **[gated]**: the subledger quantity and unit cost are `[auto]`, **the counted
quantity is `[manual]`**:

```
Subledger qty
Counted qty
Difference (in units)
× Unit cost
= Value of variance
```

**Classify the variance:**

- **Shrinkage**: physical < subledger — **theft, damage, miscount, spoilage**
- **Overage**: physical > subledger — **count error, returned goods not booked, found inventory**
- **Cut-off**: **receipt or shipment posted in the wrong period** — **[auto]** to corroborate from the
  boundary population
- **Wrong location**: **inventory moved but not transferred in system** — **[gated]** where locations are
  tracked
- **Damaged but still in subledger**: **needs write-down** — **[manual]**; condition is physical

**Three of the five classifications can be corroborated from readable data; two cannot.** Say which is
which per variance, rather than assigning causes uniformly.

## Step 5 — Common reconciling items

| Item | Description | Treatment | Verdict |
|------|-------------|-----------|---|
| **Goods received not invoiced (GRNI)** | Goods in inventory but no vendor invoice yet | **Booked via `ap-accrual-cutoff`; should NOT cause GL / subledger variance if properly accrued** | **[auto]** — the GRNI accrual balance is readable |
| **Goods invoiced not received** | Vendor invoice booked but goods not yet in subledger | **Cut-off issue — either reverse the invoice or accept inventory-in-transit** | **[auto]** — bills near the boundary |
| **In-transit inventory** (entity-owned in shipping) | **Title has transferred per Incoterms** | **Should be on subledger; ensure GL reflects** | **[gated]** — **Incoterms are `[manual]`** |
| **Returns from customers in transit** | Returned but not yet received | **Hold in "Returns Pending" account** | **[gated]** — credit memos are readable |
| **WIP component cost adjustments** | Re-costing of WIP at period end | **Usually GL-driven; ensure subledger reflects** | **[auto]** on the balance, `[manual]` on the basis |
| **Inventory write-downs (NRV, obsolescence)** | Lower of cost or NRV adjustments | **GL reserve account; subledger may stay at cost — track contra** | **[auto]** — setting the reserve itself is an obsolescence task |
| **Sample / promotional inventory consumed** | No invoice, but units gone | **Track separately as marketing expense** | **[gated]** — a common untracked shrinkage cause |
| **Manufacturing variances** | Standard vs. actual cost differences | **PPV, MUV, etc. — see standard costing** | **[auto]** on balances |

**Note the first row carefully**: **a properly accrued GRNI should not cause a variance at all.** Where it
does, the accrual is wrong — which points at `ap-accrual-cutoff` rather than at the warehouse.

## Step 6 — Investigate variances

For each material variance — **[gated]**, and the split is instructive:

1. **Look at recent transactions on the SKU** — **[auto]**
2. **Check for posting cutoffs** — **[auto]**
3. **Check for location transfers** — **[gated]**, where locations are tracked
4. **Check for incorrectly entered transactions** — **[auto]**: duplicates, reversals, wrong-sign entries
5. **Cross-reference with physical area / storage location** — **[manual]**
6. **Get the warehouse team's input on operational reasons** — **[manual]**, **and frequently the step that
   actually explains it**

**Document the investigation.**

**Four of six start in the data; two require people — and the two requiring people are where causes come
from.** A variance investigation that stops after step 4 will produce a classification, not an explanation.

## Step 7 — Compute shrinkage

**For genuine shrinkage — loss confirmed, not just a count error** — **[gated]**:

- **Total shrinkage value = sum of confirmed shortages × unit cost**
- **Shrinkage % = shrinkage value / average inventory value or revenue** — **[auto]** on both denominators
- **Compare to historical / industry rates** — **[auto]** for historical, **[manual]** for industry
- **Investigate if shrinkage is materially elevated**

**Note the precondition — "loss confirmed, not just a count error".** **Shrinkage requires a count.** A
shrinkage figure computed without one is not shrinkage; it is an unexplained GL difference wearing the
name.

**[auto]** trend: **shrinkage posted to an identifiable account, by period, as a percentage of inventory and
of revenue.** The trend is what tells you whether this period is unusual, and it is the context an isolated
number lacks.

## Step 8 — Construct cleanup JEs

**Hand off to `journal-entry-builder`.** `DR` is a debit, `CR` a credit. **Mosofin does not post** — these
are proposals:

**Inventory shrinkage / write-down**:
```
DR  Inventory Shrinkage / Loss / COGS              $loss value
    CR  Inventory                                     $loss value
Memo: Period shrinkage — physical count [date]
```

**Inventory overage** (rare; usually count error correction):
```
DR  Inventory                                       $overage value
    CR  Inventory Adjustments / Other Income           $overage value
Memo: Period overage — physical count [date]
```

**Write-down to NRV** (lower of cost or net realizable value):
```
DR  Cost of Goods Sold / Inventory Write-Down       $write-down
    CR  Inventory Reserve (or directly Inventory)     $write-down
Memo: NRV write-down — [SKU or category]
```

**Cut-off correction**: **reverse or move the misposted entry to the right period** (if
cross-year, it is a prior-period adjustment).

**Note the memo lines reference a count date** — which is the original's own reminder that these entries
follow a count, not a query.

## Step 9 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Reconciliation Summary**
- **Period**
- **GL balances by inventory account**
- **Subledger balances**
- **Physical count results (if conducted)**
- **Reconciled variances by category**
- **Shrinkage % and trend**

Plus the Mosofin header block: workspace name; the entity by `display_name`; excluded company files;
**whether the subledger is a separate system or the same one**; **when the last physical count was
performed**; whether any figure rests on `mock` data.

**Sheet 2: GL to Subledger Detail**

| GL Account | GL Balance | Subledger Balance | Difference | Reason | Action |

**Marked "nil by construction" where the systems are one.**

**Sheet 3: Physical Count Variances** (if applicable)

| SKU | Description | Location | Sub Qty | Count Qty | Variance Qty | Unit Cost | Variance Value | Classification | Action |

**Sheet 4: In-Transit and Cut-Off Items**

| Reference | Type | Description | Value | Period It Belongs | Correct Treatment |

**Populated from the `[auto]` boundary population.**

**Sheet 5: Write-Downs and Reserves**

| Item / Category | At Cost | NRV | Write-Down | Reserve Category | Authority |

**With the reserve roll-forward tied to the reserve account.**

**Sheet 6: GL Posting** — pass-through to `journal-entry-builder`, marked as **proposals**.

**Sheet 7: Ledger Checks — NEW, Mosofin-specific**

| Check | Result | Detail |

**Negative quantities** — every one, always wrong; **cut-off exceptions**; **consignment-in on the balance
sheet**; **category structure limitations**; **variance account balances**; **shrinkage trend**.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

**Record the physical count as `[manual]` with its owner and last-performed date**, even — especially — when
it has not been done.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Inventory_Recon_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the count, the 3PL statement, the title terms — **name the source required** instead of
estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **Whether the subledger is a separate system**, and if so which
- **The account map**: raw materials, WIP, finished goods, in-transit, consignment-out, consignment-in,
  reserve, shrinkage, and each variance account
- **The location structure** and which locations are third-party or 3PL
- **The count cadence and method** — full annual, cycle counting with its stratification, or none — **and
  the owner**
- **The known recurring reconciling items** — expressed as rules: "the 3PL feed posts three days in
  arrears, so a three-day timing difference is expected"
- **The consignment arrangements** — which stock is consignment-in and which consignment-out, and with whom
- **The standard cost variance absorption policy**
- **The cut-off testing window** used
- **The materiality threshold** for variance investigation
- The replay recipe: the exact sequence of reads that produced the balances and the boundary population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist quantities, balances, variance amounts, shrinkage figures or count results.** All state.
**And never persist item-level costs or supplier pricing** — commercially sensitive, and not needed to
repeat the procedure.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Distribution — items module is the subledger, single Inventory account 1300 covering all categories, no
separate WIP, cycle counts monthly on A items, 3PL at Location 'Midlands'" — not "cycle counts monthly".
**Account structures and count regimes are entity-specific**, and applying one entity's map to another
reconciles the wrong accounts. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of accounts, one item master,
one count.

**Multi-entity.** Steps 0–9 run **once per entity**, each call targeting exactly one `data_source_id`, every
balance and quantity carrying its entity's `display_name`. Then the points specific to inventory:

- **Stock held by one entity for another is the owner's, wherever it sits.** The same rule as consignment,
  applied within the group. **A distribution entity holding manufacturer-owned stock should not carry it**,
  and if it does, both entities are misstated.
- **Goods in transit between group entities belong to whichever entity holds title**, per the internal
  terms. **At period end this stock is frequently on neither balance sheet or on both** — check both sides
  explicitly, exactly as an intercompany reconciliation checks both sides of a balance.
- **An intra-group sale creates inventory in the buyer at the transfer price**, carrying mark-up that is not
  group profit. **The reconciliation is per entity at each entity's own cost; the elimination is a
  consolidation step**, outside this reconciliation.
- **Shrinkage should be computed and investigated per entity and per location.** A group shrinkage rate
  averages away the one site with a problem, which is the only thing the number was going to tell you.
- **Counts happen per location, not per entity**, and a group with ten sites may have counted three.
  **Report count coverage by location**, not as a single yes or no.
- **Category structures may differ across entities**, which makes a group-level category reconciliation
  impossible without a mapping. Store it.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
