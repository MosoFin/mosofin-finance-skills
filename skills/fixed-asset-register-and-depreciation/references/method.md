<!-- fixed-asset-register-and-depreciation · method.md · read for: Stages 3–6 — every Step of the register work (0–13, including 2b), and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Establish asset classes and policies
- Step 2 — Capitalization decisions
- Step 2b — Test the threshold against the expense accounts (Mosofin addition)
- Step 3 — Choose depreciation method
- Step 4 — Convention for the first and last periods
- Step 5 — Compute depreciation for the period
- Step 6 — Construct the depreciation JE
- Step 7 — Capitalization JE for new acquisitions
- Step 8 — Disposals
- Step 9 — Roll-forward and tie-out
- Step 10 — Impairment review
- Step 11 — Periodic physical count
- Step 12 — Output
- Step 13 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The physical count is `[manual]` by its nature — it stays
in the workflow with an owner and a date.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the asset accounts, the expense accounts, the depreciation
accounts and the profile do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the fixed asset, accumulated depreciation, depreciation expense, gain / loss on
  disposal, and repairs and maintenance accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* — **gross cost and accumulated depreciation by account**,
  opening and closing — usually **[auto]**
- *`get_general_ledger`* on the **FA accounts** — **every debit and credit, which is the additions and
  disposals population** — usually **[auto]**
- *`get_general_ledger`* on **accumulated depreciation and depreciation expense** — the recorded charge and
  its pattern — usually **[auto]**
- *`search_purchases`* / *`search_bills`* — **the acquisition documents behind the debits**, with vendor and
  description — usually **[auto]**
- *`get_profit_and_loss`* — **repairs, maintenance, small tools and equipment expense**, for the threshold
  scan — usually **[auto]**
- *`search_fixed_assets`* — **where the platform exposes an asset list at all** — often absent; check
- *`search_departments`* / *`search_classes`* / *`search_locations`* — allocation dimensions — usually
  **[auto]**
- *`get_company_info`* — legal name, currency, year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a register reconciled to fixture balances is
not reconciled**, and depreciation computed from it must not be proposed for posting.

## Step 1 — Establish asset classes and policies

**Common asset classes** — the user's specific classes may differ. **[manual]** to set, `[auto]` to compare
against the actual chart of accounts:

| Asset Class | Typical useful life range | Common depreciation method |
|-------------|---------------------------|----------------------------|
| **Land** | **Not depreciated** | N/A |
| **Buildings — structure** | 25–40 years | Straight-line |
| **Buildings — improvements** | 5–20 years | Straight-line |
| **Leasehold improvements** | **Lesser of useful life or lease term** | Straight-line |
| **Machinery & equipment** | 5–15 years | Straight-line or Units-of-Production |
| **Vehicles** | 3–7 years | Straight-line or DDB |
| **Computer hardware** | 3–5 years | Straight-line |
| **Computer software (capitalized)** | 3–5 years | Straight-line — but consider whether it is an intangible |
| **Office furniture & fixtures** | 5–10 years | Straight-line |
| **Tools & small equipment** | 3–7 years | Straight-line |

**These are common ranges, not mandates. The entity's specific policy drives useful lives. Document.**

**Mosofin addition — map classes to real accounts.** **[auto]**: read the chart of accounts and map each
class to the accounts that actually exist here. **Two mismatches are worth reporting immediately:**

- **A class in the policy with no account** — where is it being posted?
- **An asset account with no class policy** — what life is it being depreciated over?

**And check land.** **[auto]**: if a land account carries accumulated depreciation, **land is being
depreciated**, which it should not be. It is a small check that finds a real error.

## Step 2 — Capitalization decisions

**For each new acquisition, capitalize if:**

- **Amount ≥ capitalization threshold**
- **Useful life > 1 year**
- **Tangible** — intangibles handled separately
- **Used in operations** — not held for sale

**Capitalized cost includes:**

- **Purchase price net of discounts and rebates**
- **Sales / use tax that's not recoverable**
- **Freight and import duties**
- **Installation costs**
- **Site preparation**
- **Testing and commissioning costs**
- **For self-constructed assets: direct materials, direct labor, and a share of overhead**

**Excluded from capitalized cost:**

- **Recoverable taxes** (VAT / GST input credits)
- **Operating costs after the asset is in service**
- **Training** — typically expensed
- **General administrative costs not directly related**

**[gated]**: the purchase documents are `[auto]` (*`search_purchases`*, *`search_bills`*) and often show
freight and installation as separate lines on the same invoice — **so the cost build-up is partly
readable.** Whether a cost belongs in the asset is judgment.

**Mosofin check — freight and installation expensed on a capitalized purchase.** **[auto]**: where an
invoice has one line to the asset account and another to freight or installation expense, **the asset may
be understated.** Same invoice, same vendor, same date — a readable pattern worth flagging.

## Step 2b — Test the threshold against the expense accounts (Mosofin addition)

**Run this every period.** **[auto]**, and it is the highest-value check in the skill.

Scan the expense accounts most likely to conceal capital items — **repairs and maintenance, small tools,
equipment, computer expense, leasehold or building costs** — for **individual transactions at or above the
capitalization threshold** (*`get_general_ledger`*, *`search_purchases`*).

Report each hit with **vendor, date, amount, description and account**, and a proposed treatment. **Do not
assert that a repair is a capital item** — a genuine large repair is still a repair. **Report the
candidates; the policy call is the user's.**

Run the reverse too: **items below the threshold sitting in asset accounts.** Capitalizing small items
inflates the register and creates depreciation nobody tracks.

## Step 3 — Choose depreciation method

Common methods — **[manual]** to elect, `[auto]` to compute:

**Straight-line (SL)**
```
Annual depreciation = (Cost − Salvage value) / Useful life
Monthly depreciation = Annual / 12
```
**Most common. Simple. Default for many asset classes.**

**Declining balance (DB) / Double-declining (DDB)**
```
Period depreciation = Beginning NBV × (Rate)
DDB rate = 2 / Useful life (annual; / 12 for monthly)
```
**Front-loaded. More depreciation in early years. Stop when NBV reaches salvage.**

**Sum-of-the-years'-digits (SYD)**
```
SYD = n × (n + 1) / 2  where n = useful life in years
Year 1 depreciation = (Cost − Salvage) × (n / SYD)
Year 2 depreciation = (Cost − Salvage) × ((n − 1) / SYD)
...etc.
```
**Front-loaded; less aggressive than DDB. Less common today.**

**Units of production (UOP)**
```
Depreciation per unit = (Cost − Salvage) / Total estimated units
Period depreciation = Units produced × per-unit rate
```
**For assets whose life is better measured in usage** — machinery hours, vehicle miles, units produced.
**[manual]** on the usage data: **units produced and hours run are not in the accounting system.**

**Tax depreciation is jurisdiction-specific** — **[manual]**, always:

- **US: MACRS** (Modified Accelerated Cost Recovery System) — **half-year or mid-quarter convention,
  specific recovery periods, declining balance switching to straight-line**
- **Other jurisdictions: capital allowances, AIA (UK), CCA (Canada), bonus depreciation, Section 179**

**Book depreciation and tax depreciation often differ — this creates deferred tax differences**, which
the tax provision accounts for.

**For book purposes, apply the entity's policy method. For tax depreciation specifically, hand off to the
tax return prep skills.**

## Step 4 — Convention for the first and last periods

**Pick a convention for the first month of service** — **[manual]**:

- **Half-month / mid-month**: half depreciation in the month placed in service
- **Full month**: depreciate from the first day of the month placed in service
- **Pro-rata**: depreciate from the actual in-service date through end of month

**Most entities use full month or half-month. Apply consistently. Document.**

**Same logic for the disposal period.**

*Mosofin note*: **the convention is invisible in the ledger but visible in the first month's charge.** Where
a register exists, check that the first period's depreciation matches the stated convention — a mismatch
means the convention in the policy is not the convention in the spreadsheet.

## Step 5 — Compute depreciation for the period

For each asset in service — **[gated]**: the arithmetic is `[auto]`, but it needs the register:

- **Apply the method, useful life, cost, salvage, and convention**
- **Compute the period's depreciation**
- **Update accumulated depreciation**
- **Update net book value (Cost − Accumulated Depreciation)**

**Verify: cumulative depreciation never exceeds (Cost − Salvage).**

**Mosofin addition — the implied-rate check, which runs without a register.** **[auto]**: divide the
period's recorded depreciation by gross cost per class and annualize. **Compare the implied life to the
policy life.** A machinery class on a 10-year policy showing an implied 3-year rate, or a 40-year rate,
means something is wrong — wrong lives applied, assets missing from the schedule, or a recurring journal
that no longer matches the register. **It is a coarse check, and it still finds real errors.**

Also **[auto]**: **has depreciation been posted at all this period?** A zero or absent charge in a month
where assets exist is worth surfacing before anything else.

## Step 6 — Construct the depreciation JE

**Hand off to `journal-entry-builder`.** Aggregate by expense account — often by department, project, or
asset class. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a proposal:

```
DR  Depreciation Expense                              $period depreciation
    CR  Accumulated Depreciation (per asset class)       $period depreciation
Memo: Monthly depreciation — [period]
```

**Use the user's COA. Some entities have multiple Accumulated Depreciation accounts (one per asset class);
others have one consolidated. Match the COA structure.** **[auto]** to determine which
(*`search_accounts`*) — read it rather than asking.

## Step 7 — Capitalization JE for new acquisitions

```
DR  Fixed Asset (specific asset class)                $capitalized cost
DR  Input Tax Recoverable (if applicable)             $tax
    CR  Cash / AP                                       $gross
Memo: Capitalize [asset description] — placed in service [date]
```

*Mosofin note*: **for assets already posted, this entry has happened** — the value of Step 2 is checking it
was right and complete, not re-proposing it. Propose the entry only for items the threshold scan surfaced
as wrongly expensed.

## Step 8 — Disposals

**When an asset is sold, scrapped, or retired:**

```
Compute gain or loss on disposal:
Gain/loss = Proceeds − (Cost − Accumulated depreciation at disposal date)
         = Proceeds − Net book value at disposal date
```

```
DR  Cash / AR                                         $proceeds (if any)
DR  Accumulated Depreciation                          $accumulated depreciation at disposal
DR  Loss on Disposal (if loss)                        $loss
    CR  Fixed Asset                                     $original cost
    CR  Gain on Disposal (if gain)                      $gain
    CR  Output Tax Payable                              $tax on proceeds (if applicable)
Memo: Disposal of [asset] — [reason]
```

**Remove the asset from the FA register; document the disposal date and reason.**

**Mosofin check — the half-disposal.** **[auto]**: a common error is removing the **cost** but not the
**accumulated depreciation**, or vice versa. Read both sides of the movement: **a credit to the asset
account with no corresponding debit to accumulated depreciation** leaves the balance sheet wrong and usually
produces a spurious loss. Likewise **proceeds received with no asset removed** — cash in with no disposal
entry — is a disposal nobody recorded.

## Step 9 — Roll-forward and tie-out

For each asset class — **[auto]** on the GL side, **[gated]** overall since the register side is manual:

```
Opening Cost
+ Capitalizations
- Disposals (at original cost)
+/- Transfers / reclassifications
+/- FX revaluation (foreign-currency assets)
= Closing Cost

Opening Accumulated Depreciation
+ Period depreciation
- Disposals (accumulated depreciation removed)
+/- FX revaluation
= Closing Accumulated Depreciation

Net Book Value = Closing Cost − Closing Accumulated Depreciation
```

**The roll-forward must tie to:**

- **GL fixed asset balances (gross and accumulated)** — **[auto]**
- **The FA register at period end** — **[gated]**, and only where a register was supplied

**Mosofin addition — reconcile in both directions.** The original ties the register to the GL. **Do both:**

1. **Register → GL.** Every register asset should have cost in the GL. **A register asset with no GL cost is
   a phantom** — often an asset disposed of years ago and never removed.
2. **GL → register.** Every GL debit in the period should appear in the register. **A capitalization with no
   register entry is an asset that will never be depreciated** — it sits at full cost forever, overstating
   assets and understating expense, and nothing else in the close will catch it.

**Report both difference lists separately.** They have different causes and different owners.

## Step 10 — Impairment review

**At least annually — and on triggering events — review for impairment.** **[manual]** throughout: the
forecasts and fair values are not on this surface.

**US GAAP (ASC 360):**
- **Step 1: Test recoverability** — are **undiscounted** future cash flows > carrying value?
- **Step 2: If not, impairment loss = carrying value − fair value**

**IFRS (IAS 36):**
- **Recoverable amount = higher of fair value less costs of disposal and value in use**
- **Impairment loss = carrying value − recoverable amount**
- **Reversal allowed if circumstances change** — **US GAAP does not allow reversal**

**Triggering events: significant decline in asset value, change in use, physical damage, obsolescence,
regulatory changes.**

**Document the test, the conclusion, and any impairment booking.**

**[auto]** contribution — indicators, not conclusions: **assets in a class whose associated revenue or
department has collapsed**, and **assets fully depreciated but still carried**, are both readable and both
worth raising as *candidates for review*. **Never conclude impairment from ledger data** — the test needs
cash flows the workspace does not hold.

## Step 11 — Periodic physical count

**At least annually** — **[manual]**, and it stays in the workflow with an owner and a due date:

- **Physical inspection of major assets**
- **Confirm location and condition**
- **Match to FA register**
- **Identify missing, damaged, or unrecognized assets**
- **Trigger disposals or impairments as needed**

**No amount of ledger access substitutes for looking at the asset.** The GL will report a machine that was
scrapped three years ago exactly as confidently as one running today. **Record the count as `[manual]`, with
its owner and its last-performed date** — and if it has never been performed, say so, because that is the
finding.

## Step 12 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Asset Register Master**

| Asset ID | Description | Asset Class | Acquisition Date | In-Service Date | Original Cost | Salvage Value | Useful Life | Method | Currency | Location | Department |

Add a **Source** column: register-supplied, or derived from a GL movement.

**Sheet 2: Depreciation Schedule (current period)**

| Asset ID | Asset Class | Opening NBV | Period Depreciation | Closing NBV |

**Sheet 3: Acquisitions** — current period additions with JE references. **Now GL-derived**, with the
vendor and document reference from the purchase record.

**Sheet 4: Disposals** — current period disposals with gain / loss calculations and JE references.

**Sheet 5: Roll-Forward by Class** — gross cost and accumulated depreciation movements.

**Sheet 6: GL Tie-Out** — FA register summary vs. GL balances, **with both direction lists**: register
assets missing from the GL, and GL movements missing from the register.

**Sheet 7: Impairment Review** — documentation of any impairment indicators and test results, with
`[auto]`-derived candidates clearly marked as candidates.

**Sheet 8: GL Posting** — all JEs for the period, marked as **proposals**.

**Sheet 9: Tax-Book Depreciation Differences** — for tracking deferred tax, if material.

**Sheet 10: Capitalization Threshold Scan — NEW, Mosofin-specific**

| Date | Vendor | Account | Amount | Description | Above threshold? | Proposed treatment |

Both directions: expensed items at or above the threshold, and capitalized items below it.

**Sheet 11: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Policy | `mock` | Gap |

Include a row for the **physical count** with its owner and last-performed date, even — especially — when it
has not been done.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `FA_Register_and_Depreciation_[YYYY-MM].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — useful lives, salvage values, impairment, the count — **name the source required**
instead of estimating.

## Step 13 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The asset class policies**: useful life and method per class, as this entity has set them
- **The capitalization threshold**, with its effective date
- **The first / last period convention**
- **The account map**: which accounts are cost, which are accumulated depreciation, whether accumulated
  depreciation is per class or consolidated, and which expense accounts the threshold scan covers
- **The class-to-account mapping** — the join that makes the roll-forward automatic
- **The framework** and the elections within it: componentization, revaluation model, impairment approach
- **The salvage value policy** — how salvage is set, not the values themselves
- **The depreciation allocation basis** — which departments or classes the charge is split across
- **The physical count cadence** and its owner
- The replay recipe: the exact sequence of reads that produced the movements and the threshold scan

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist the asset register itself, asset-level costs, net book values, locations or serial
numbers.** The register is state — and asset locations and serial numbers are security-relevant detail
about physical property.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Manufacturing — threshold 2,500 from 2025-01-01, machinery 10yr SL, vehicles 5yr SL, full-month convention,
accdep per class" — not "threshold 2,500". **Thresholds and lives differ by company file**, and applying one
entity's ten-year machinery life to another's produces a depreciation charge that is wrong every month and
never obviously so. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the register, the balances and the accumulated depreciation are all state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One register, one roll-forward, one
tie-out.

**Multi-entity.** Steps 0–12 run **once per entity**, each call targeting exactly one `data_source_id`,
every asset and balance carrying its entity's `display_name`. Then the points specific to fixed assets:

- **Assets are often held in one entity and used by another.** A property company owning the premises, an
  operating company using them. **Depreciation belongs where the asset is held**, and the use is usually
  charged on as rent or a recharge. **Never move depreciation to the using entity** to make a management
  report look right — that is a different transaction.
- **Intra-group asset transfers are the classic trap.** On transfer, the receiving entity records cost at
  the transfer price, but **on consolidation the asset must be carried at original group cost, with the
  intra-group profit and the excess depreciation eliminated.** That elimination is a consolidation step.
  **Reading each entity's register separately will not reveal this** — it needs the transfer history.
- **Policies must be consistent for consolidation.** Different useful lives for the same class in different
  subsidiaries produce a group charge that is not comparable. **Flag policy differences across entities**;
  they are readable once each entity's class policy is stored.
- **Currency**: **at acquisition, cost is converted at the acquisition-date rate and held at that historical
  rate.** Each entity depreciates in its own functional currency; group translation is a separate step.
- **The threshold may differ by entity** — legitimately, since materiality differs. Store thresholds keyed
  by entity and never apply one across the group.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
