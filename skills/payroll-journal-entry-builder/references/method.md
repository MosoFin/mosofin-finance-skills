<!-- payroll-journal-entry-builder · method.md · read for: Stages 3–6 — Steps 0–9 (read, map, build, validate, output, evolve) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Understand the payroll register components
- Step 2 — Build the gross pay and withholding entry
- Step 3 — Build the employer cost entry
- Step 4 — Allocate across departments / cost centers
- Step 5 — Handle net pay funding
- Step 6 — Period-end accrual (if needed)
- Step 7 — Validate the entries
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The register is `[manual]` where no payroll platform is
connected.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the chart, the dimensions, the prior runs and the balances do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical batch, per in-scope entity:

- *`search_accounts`* — **the chart: wages, each withholding liability, each employer cost and liability,
  net pay payable, clearing, accrued payroll** — usually **[auto]**. **The primary read**
- *`search_departments`* / *`search_classes`* / *`search_locations`* — **the allocation dimensions** —
  usually **[auto]**
- *`search_journal_entries`* **for prior payroll runs** — **the run-over-run comparison, and the entry
  template actually in use** — usually **[auto]**
- *`get_general_ledger`* on **the payroll liability and clearing accounts** — **current balances, and
  whether the last accrual reversed** — usually **[auto]**
- *`get_profit_and_loss`* **by department, prior periods** — **payroll expense by department, for the
  comparison** — usually **[auto]**
- *`search_employees`* — **headcount only**, as the denominator for the comparison — usually **[auto]**
- *`get_company_info`* — legal name, **country**, currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the chart read,
  state that placeholder coding is in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **an entry validated against fixture accounts may
reference accounts that do not exist**, and it would be imported and posted.

## Step 1 — Understand the payroll register components

**A payroll register typically contains, per employee and in total** — **[gated]**, from the register:

- **Gross pay** — **salary, wages, overtime, bonus, commission**
- **Employee withholdings**, deducted from gross — **income tax withholding, employee social / payroll
  contributions, retirement contributions, benefit premiums, garnishments, other deductions**
- **Net pay** — **gross − withholdings** — what the employee receives
- **Employer costs**, on top of gross and **not deducted from it** — **employer social / payroll
  contributions, employer retirement match, employer benefit costs, other employer-borne taxes**

**The key accounting concept: gross pay is the expense; withholdings are liabilities owed to third parties;
net pay is the liability owed to employees; employer costs are additional expense and additional
liabilities.**

**Work from totals.** **The journal is built from the register's totals by component**, not employee by
employee — which is both correct accounting and correct handling of personal data.

**[auto]** mapping check: **every component in the register needs an account, and every payroll account in
the chart should receive something.** **A register component with no mapped account, or a mapped account
receiving nothing, is a gap to resolve before building** — the second often means a liability type the
entity has stopped using, or one it has started and not mapped.

## Step 2 — Build the gross pay and withholding entry

Record the employee side of payroll. `DR` is a debit, `CR` a credit. **Mosofin does not post** — this is a
proposal:

```
DR  Wages / Salaries Expense (gross pay)        $gross
    CR  Income Tax Withholding Payable               $X
    CR  Employee Social/Payroll Contribution Payable $X
    CR  Retirement Contribution Payable (employee)   $X
    CR  Benefit Premiums Payable (employee)          $X
    CR  Garnishments Payable                         $X
    CR  Net Pay Payable / Wages Payable (or Cash)    $net
```

**The debit (gross expense) equals the sum of credits — the various liabilities plus net pay. Use the
entity's actual account names and numbers from the COA mapping — do not invent account numbers.**

**[auto]** on both: **the accounts come from the live chart**, and **the identity is arithmetic.**

**If net pay is disbursed the same day from cash, credit Cash directly instead of Net Pay Payable.**

## Step 3 — Build the employer cost entry

Record **employer-borne costs** — **these are additional expense, not deducted from the employee**:

```
DR  Payroll Tax Expense (employer)              $X
DR  Retirement Match Expense (employer)         $X
DR  Benefits Expense (employer)                 $X
    CR  Employer Social/Payroll Contribution Payable $X
    CR  Retirement Match Payable                      $X
    CR  Benefits Payable                              $X
```

**Again, debits = credits, using the entity's accounts.**

**Keep this entry separate from Step 2**, even where the platform would accept one combined journal.
**Separating them is what makes the employer/employee distinction visible** — and that distinction is the
error the edge cases identify as the most common. **A combined entry hides it; two entries expose it.**

**[auto]** check: **the employer liability accounts should be distinct from the employee withholding
accounts.** Where the chart uses one account for both — a single "PAYE and NI payable", for instance —
**say so**, because the clearing reconciliation in `payroll-clearing-reconciliation` will not be able to
separate them either.

## Step 4 — Allocate across departments / cost centers

**If labor cost must be split** — for departmental P&L, project costing, or capitalization — **[gated]**:

- **Allocate gross wages and employer costs to the relevant departments / cost centers per the allocation
  basis** — **hours, headcount, direct assignment** — **the basis is `[manual]`; the dimensions are
  `[auto]`**
- **The liability side is usually not split** — one payable per type; **only the expense side is
  allocated**

**For costs that should be capitalized** — e.g. labor on a self-constructed asset or capitalized software
development — **route to the asset account rather than expense — flag these.** **[manual]** to identify; see
`fixed-asset-register-and-depreciation` and an intangibles amortization review, **where the same labor appears
from the other side.**

**[auto]** checks: **the allocation sums to the total** — Step 7's requirement — and **the allocation is
consistent with the prior run** unless something changed. **A department's share moving sharply between runs
is either a real change or an allocation error**, and it is visible.

## Step 5 — Handle net pay funding

Depending on timing — **[gated]**:

- **If net pay is paid on the pay date from the operating account: CR Cash**
- **If funded through a payroll clearing account (common): CR Payroll Clearing**, then **a separate entry
  clears it when the bank disburses** — coordinate with `payroll-clearing-reconciliation`
- **If paid via a third-party payroll provider that debits a lump sum: record the provider funding and clear
  the individual liabilities as the provider remits**

**The third case is the one most often booked wrongly.** **A single bank debit covering net pay, taxes and
the provider's fee is not one expense** — **book the components.** See the edge case, and note that **the
lump sum is `[auto]` from the bank account while its composition is `[manual]` from the provider's
statement.**

**[auto]** to determine which case applies: **whether a clearing account exists and carries payroll-cycle
movement.**

## Step 6 — Period-end accrual (if needed)

**If the pay period crosses the period-end** — employees earned wages not yet paid at month-end — **accrue**:

```
DR  Wages Expense (earned, unpaid portion)      $accrued
    CR  Accrued Payroll Liability                    $accrued
```

**Include employer costs in the accrual. Reverse in the next period when the actual payroll is booked** —
coordinate with `accruals-and-deferrals`. **Pro-rate based on days / hours earned in the period.**

**[auto]** to determine whether an accrual is needed: **the pay period end and the pay date against the
accounting period end** — pure date arithmetic. **[gated]** to compute: the pro-ration needs the register.

**And the employer-cost point is worth emphasising**: **an accrual covering only gross pay understates the
liability by the employer's contributions**, which can be a fifth of the cost again. **[auto]** check: **the
accrual's ratio to the last full run's total cost** should be plausible.

## Step 7 — Validate the entries

- **Each entry balances (debits = credits)** — **[auto]**
- **Gross pay = net pay + total employee withholdings** — **[auto]**, ⭐ **and this is the check that
  catches the employer/employee mixing error.** **If an employer contribution has been credited to an
  employee withholding account, this identity breaks** — the entry still balances, but gross no longer
  reconciles to net plus withholdings
- **Total expense recognized = gross pay + employer costs** — **[auto]**, and **the mirror of the same
  test**: if employer costs were netted into gross, total expense will be right and the split will be wrong
- **Liabilities created match amounts that will be remitted** — to tax authorities, retirement plans,
  benefit providers, employees — **[gated]**; the remittance itself is payroll tax filing work
- **Department allocations sum to the total** — **[auto]**
- **Accrual reverses correctly next period** — **[auto]** to verify in the following period

**Mosofin additions to the validation set:**

- ✅ **Every account exists in the live chart** — **[auto]**, a hard stop if not
- ✅ **Employer and employee liabilities use distinct accounts** — **[auto]**, or the limitation is stated
- ✅ **Run-over-run comparison** — **[auto]**: **gross, each withholding type, each employer cost, and the
  cost per head, against the previous runs.** **Payroll is stable; a material movement without a headcount
  change deserves a question before posting.** Report the comparison with the entry
- ✅ **The prior period's accrual actually reversed** — **[auto]**: **if it did not, this run's entry will
  double-count.** The edge case the original warns about, now checkable

## Step 8 — Output

Deliver the journal entries plus a workpaper:

**Sheet 1: Journal Entries** — **ready-to-post entries** — gross / withholding entry, employer cost entry,
accrual if needed, clearing entries — **each balanced, with account, debit, credit, memo.** **Marked
PROPOSED — NOT POSTED**, with the entity by `display_name`.

**Sheet 2: Gross-to-Net Reconciliation** — **gross → withholdings → net, tying to the payroll register
total.** **State whether the register was read or supplied.**

**Sheet 3: Employer Cost Breakdown** — **each employer cost and its liability.**

**Sheet 4: Department / Cost Center Allocation** — **labor cost split with the allocation basis**, and the
prior-run comparison.

**Sheet 5: Liability Summary** — **each payable created, amount, and to whom / when remitted** — feeds
the payroll tax filings.

**Sheet 6: Validation — NEW, Mosofin-specific** — the six original checks plus the four Mosofin ones, each
with its result and the evidence.

**Sheet 7: Run Comparison — NEW, Mosofin-specific** — this run against the prior three, by component and per
head, with movements flagged.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Payroll_JE_[YYYY-MM-DD]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`. **Every file states that the entries are proposals.**

**Grounding:** every account traces to the live chart; every validation traces to a tool result in this
conversation; **every amount traces to the register**, read or supplied. End with a single **Data sources**
line.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** — every register component to its account: gross by type, each employee withholding,
  each employer cost and liability, net pay, clearing, accrued payroll. **The most valuable stored asset
  here**, and it makes each run a fill-in
- **The entry template** — which entries, in what order, with what memo convention
- **The allocation basis** and the dimension used
- **The clearing convention** — whether clearing is used and how it is cleared
- **The funding model** — direct, clearing, or third-party provider lump sum
- **The pay calendar** — frequencies, pay dates, period ends, **and which period ends require an accrual**
- **The capitalised labour rule** — which projects or roles, and to which asset account
- **The comparison tolerances** — what movement is worth flagging
- **Whether employer and employee liabilities share accounts**, as a known limitation
- The replay recipe: the exact sequence of reads that produced the chart and the comparison

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data, and never persist amounts.** No names, no pay, no deductions,
no garnishments. **Persist the map and the template; never the run.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — gross to 7000 by department, PAYE 2210, NI employee 2211, NI employer 2212, net pay to clearing
2200, monthly on the 25th, accrual required at March and September" — not "gross to 7000". **Account maps
are chart-specific and jurisdiction-specific**, and applying one entity's map to another posts liabilities
to accounts that mean something else. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one set of entries.

**Multi-entity.** **Confirm which entity employs the people in this run before building anything.** Then:

- **One journal per entity, built against that entity's own chart.** **A payroll run covering three group
  companies produces three journals**, not one split by class — **the liabilities are owed by different
  legal entities to different authorities.**
- **A single bank payment covering several entities' payroll** must be allocated, **and the entities whose
  payroll was paid by another owe it back** — an intercompany balance, not a payroll item. It
  belongs in an intercompany reconciliation.
- **Employment jurisdiction drives the withholding types**, not the entity's own location. An entity
  employing people in two countries needs both sets of liability accounts.
- **Shared employees recharged between entities** follow the recharge agreement — **the cost sits where the
  employment is, and the recharge is a separate transaction.**
- **Currency**: payroll denominated in a currency other than the entity's functional currency creates FX
  between accrual and payment — the translation itself is an FX revaluation task.
- **Run the comparison per entity.** A group total can be stable while one entity's payroll has doubled.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
