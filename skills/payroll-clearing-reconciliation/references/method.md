<!-- payroll-clearing-reconciliation · method.md · read for: Stages 3–6 — Steps 0–10 (read and age, roll forward and reconcile, stale balances, cleanup entries, output, evolve) and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 0b — Age every balance and test its behaviour (Mosofin addition)
- Step 1 — Identify the payroll accounts in scope
- Step 2 — Pull the expected balance for each account
- Step 3 — Compare actual GL to expected
- Step 4 — Itemize reconciling items per account
- Step 5 — Reconcile to bank disbursements
- Step 6 — Year-to-date reconciliations
- Step 7 — Investigate stale balances
- Step 8 — Construct cleanup JEs
- Step 9 — Output
- Step 10 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The register and the provider statements are legitimately
`[manual]` where their systems are not connected.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the accounts, the balances, the movements and the payments do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **every payroll liability, clearing and suspense account, plus the payroll expense
  accounts** — usually **[auto]**
- *`get_balance_sheet`* / *`get_trial_balance`* at period end **and prior period end** — **the roll-forward
  anchors** — usually **[auto]**
- *`get_general_ledger`* on **each payroll account** — **every movement, and the ageing of what remains** —
  usually **[auto]**. **The central read of this skill**
- *`search_payments`* / *`search_checks`* — **remittances out**, by payee and date — usually **[auto]**
- *`search_journal_entries`* — **the payroll journals themselves, and any manual entries to clearing** —
  usually **[auto]**
- *`get_profit_and_loss`* — payroll expense by period, for reasonableness — usually **[auto]**
- *`search_employees`* — **headcount only**, for scale — usually **[auto]**
- *`get_company_info`* — legal name, **country**, currency — usually **[auto]**

**Pull the prior twelve months.** **The behaviour test in Step 0b needs the pattern**, not one balance.

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **payroll liabilities are amounts owed to people
and to tax authorities**, and a fixture-based conclusion that they were remitted is worse than no
conclusion.

## Step 0b — Age every balance and test its behaviour (Mosofin addition)

**Run before Step 1's account identification is finalised**, because it tells you which accounts are
actually behaving as intended. **[auto]**, and this is the skill's strongest contribution.

**1. Age every payroll account balance.** **[auto]** from the account history: **how long has each component
of the closing balance been sitting there?** Report by band — current period, 1–2 periods, 3–6 periods,
**over 6 periods**. Age by **FIFO** (remittances settle the oldest accruals first) unless the remittance memo
identifies the period it pays; **state the convention on the workpaper** — a liability account is a running
balance, not an open-item ledger.

**2. Test the behaviour against the cadence.** For each liability account, given its remittance cadence:

| Expected behaviour | What a failure looks like |
|---|---|
| **Accrues on each payroll, clears on each remittance** | **A residual that survives every remittance** |
| **Peaks at one period's withholdings** | **A balance that only ever grows** |
| **Returns to nil after the cycle** — clearing and suspense accounts | **A permanent balance in a clearing account** |

**3. Identify the never-clearing residual.** **[auto]**: for a liability account, **the lowest balance reached
immediately after each remittance** (the trough of each cycle) over the last twelve cycles, **less any amount
the cadence says should still be carried**; for a clearing or suspense account, which should reach nil, **the
lowest running balance** from GL detail, not period-end balances. A month-end balance on a monthly-remitted
account is the month's withholdings, not a residual. What remains is, in effect, **a permanent balance
masquerading as a payroll liability.** **That
figure is the finding**, and it is usually the sum of several old items nobody has looked at.

**Report all three before anything else.** A reconciliation that explains this period's movement while a
four-year-old residual sits underneath it has explained the wrong thing.

## Step 1 — Identify the payroll accounts in scope

**Common payroll-related accounts** — the specific accounts depend on the COA and jurisdiction —
**[auto]** to enumerate:

**Liability accounts:**
- **Net pay payable / payroll clearing** — between booking the payroll JE and disbursing cash
- **Income tax withheld** — federal, state / provincial, local, **per jurisdiction**
- **Social charges withheld** — **FICA / EI / CPP / NI / equivalent**
- **Employer-side social charges payable**
- **Benefits withheld** — health insurance, dental, vision
- **Retirement contributions withheld** — **401(k), RRSP, pension**
- **Employer-match retirement payable**
- **Garnishments / wage assignments**
- **Union dues**
- **Other withholdings**

**Suspense / clearing:**
- **Payroll clearing**
- **Payroll suspense**

**P&L accounts** — not reconciled in the same way, but referenced:
- **Salaries & wages expense**
- **Employer tax expense**
- **Benefits expense**
- **Stock-based compensation expense** (an equity compensation accounting matter)

**Ask the user for their specific account list.** **[auto]** to propose it: **read the chart and present the
payroll accounts found**, so the user confirms a list rather than assembling one.

**[auto]** completeness check worth running: **an account with payroll-cycle movement that is not on the
supplied list**, and **a listed account with no movement at all** — the first is a scope gap, the second is
either dormant or a jurisdiction the entity has exited.

## Step 2 — Pull the expected balance for each account

**For each liability account, the expected balance at period end equals:**

```
Opening balance
+ Accrued during the period (per payroll register)
- Remitted during the period (per remittance records)
= Expected closing balance
```

**[gated]**: **opening `[auto]`; accrued `[manual]` without the register — though the payroll journal's
credit to the account is a proxy worth stating as one; remitted `[auto]` from payments.**

**The expected closing balance is usually:**

- **Zero for "clearing" or "in-transit" accounts after the payroll cycle settles**
- **Non-zero but predictable for liability accounts based on remittance schedule** — e.g. income tax
  withheld in the current month, remitted next month → **balance = current month's withholdings**

**Mosofin note on the proxy**: **where the register is unavailable, the payroll journal's posting to the
account is the best available accrual figure** — and **it is what was posted, not what the register says.**
**If they differ, the payroll journal is wrong**, which is precisely what a register-based reconciliation
exists to find. **State clearly which basis was used.**

## Step 3 — Compare actual GL to expected

For each account — **[gated]**:

```
GL closing balance                            $X
Expected closing balance                       $Y
Difference                                     $X − $Y
```

**Investigate every non-zero difference.**

**Report the difference for every account, including zero** — and **note that a nil difference is not a
reconciled account** where the expected balance was derived from the same postings as the actual. **Where
the register is absent, say what the comparison actually proves**: that the account moved as the journals
say, not that the journals were right.

## Step 4 — Itemize reconciling items per account

For each account with a difference, identify the components — **each with its detectability**:

| Cause | Example | Detectable? |
|-------|---------|---|
| **Timing — remittance after period end** | Withholding remitted on the 15th of next month | **[auto]** — the payment appears next period |
| **Manual JE posted to clearing** | Year-end true-ups | **[auto]** — a journal with no payroll cycle behind it |
| **Misclassified entry** | Wrong account used | **[auto]** — an entry inconsistent with the account's usual pattern |
| **FX revaluation** | Foreign-currency payroll | **[gated]** — the translation itself is an FX revaluation task |
| **Rounding** | Per-employee penny differences | **[auto]** — small, persistent, proportional to headcount |
| **Voided / cancelled payments** | Stop payments, recovered amounts | **[auto]** — a reversal in the account |
| **Adjustment to prior period** | Corrections, retroactive pay | **[auto]** — an entry dated or referencing a prior period |
| **Open accruals** — e.g. vacation accrual | Carry from prior periods | **[auto]** — a balance that never clears |
| **Benefit invoice timing** | Provider invoiced quarterly vs. monthly accrual | **[auto]** — a saw-tooth pattern |

**Eight of nine are detectable from the ledger**, and **most of them announce themselves in the account's
movement pattern rather than requiring investigation.** **Classify first from the pattern, then confirm.**

## Step 5 — Reconcile to bank disbursements

Net pay for each payroll cycle; tax and benefit remittances **per deposit period set by the cadence (input
D)**, not per pay run — **[gated]**:

- **Net pay disbursed** (per payroll register) **= sum of cash disbursements to employees + any direct
  deposits** — **[auto]** for the disbursements, `[manual]` for the register figure
- **Tax remittances = sum of withholdings + employer share accrued for the deposit period, by tax
  authority** — **[auto]** for the payments, by payee
- **Benefit remittances = sum of withholdings + employer share accrued for the deposit period, by
  provider** — **[auto]** for the payments
- **Total payroll cash impact = above sums** — **[auto]**

**Compare to the bank statement entries for the period. Differences here are typically timing** — e.g.
direct deposits initiated late and cleared post-period.

**Mosofin precision on that last instruction**: **the bank statement is `[manual]`.** **What is `[auto]` is
the recorded disbursement.** **Tying payroll to recorded disbursements proves the bookkeeping; tying it to
the bank statement proves the money left.** **State which was performed** — the same distinction as
`bank-reconciliation` and `merchant-and-payment-processor-rec`.

## Step 6 — Year-to-date reconciliations

**For tax-withholding accounts especially, YTD figures must reconcile to** — **[gated]**:

- **Cumulative payroll register YTD** — **[manual]** without the payroll system
- **Cumulative remittances YTD** — **[auto]** from payments
- **Year-end forms (W-2 / T4 / equivalent) when produced** — **[manual]**; they are produced with the payroll tax filings

**Mid-year, the YTD reconciliation is a preview; year-end is the formal one.**

**[auto]** contribution: **YTD remittances per payments ≥ opening liability + YTD accruals − closing
liability** — the opening balance matters, since December's withholdings remitted in January open nearly
every withholding account. Then tie **YTD withholdings per the register** to **YTD remittances + closing
liability − opening liability**: a real two-source test. **Without the register, say that the YTD test
proves only ledger arithmetic** — both sides then come from the same ledger.

## Step 7 — Investigate stale balances

**Any clearing or suspense balance over 60 days, and any liability amount older than one full remittance
cycle plus its due-date lag, warrants investigation.** **[auto]** — **and this is the step
the workspace performs best.**

**Common causes:**

- **Unclaimed pay** — returned direct deposits, uncashed cheques
- **Garnishments awaiting court direction**
- **Terminated employees with final-pay disputes**
- **Benefit reconciliation lagging the provider's invoice cycle**

**Stale balances may need to be:**

- **Returned to employees (if owed)**
- **Escheated to the state** — in jurisdictions with unclaimed property laws
- **Written off** — with proper authority and tax treatment

**Three points worth emphasising in a Mosofin run:**

**The ageing is specific, by the stated convention.** **[auto]**: not "this looks old" but **"£4,180 has been
in this account since March 2023, comprising nine items (FIFO)."** That specificity is what moves a stale balance from a note to an action.

**Escheatment is a legal obligation, not housekeeping.** **Unclaimed wages are unclaimed property**, and
jurisdictions with such laws impose **reporting deadlines and penalties for failing to remit.** **Writing
off unclaimed pay to income is frequently not permitted** — it belongs to the employee until it belongs to
the state. **Flag it as a compliance matter and name the determination as `[manual]`.**

**Handle garnishment balances carefully.** **They concern court orders and personal circumstances.**
**Report the total and the count; refer to individual items by reference.**

## Step 8 — Construct cleanup JEs

**Hand off to `journal-entry-builder`.** **Mosofin does not post** — these are proposals.

**For permanent differences requiring correction:**

- **Reclass**: post to the right account from the wrong account
- **Write-off**: **small immaterial residuals** to a payroll-related expense or other-income line, **per
  policy**
- **True-up**: correct an accrual error from a prior period

**For timing differences: document but do not adjust.**

**Before proposing a write-off on a withholding, employer-contribution or benefit account**, obtain the
authority's or provider's **statement of account** for the period — `[manual]`. A credit residual it does not
explain is a **remittance to make**; a debit residual is a **refund or credit to claim**. **Neither is written
off.** A liability is removed only when it is paid or the creditor releases it.

**Two cautions**: **do not write off what is owed to a person** — see escheatment above; **and a residual
that recurs every period is not immaterial**, however small each instance is. **[auto]** to detect: **the
same small write-off proposed repeatedly is a process fault**, and writing it off again treats the symptom.

## Step 9 — Output

Deliver an `.xlsx` workpaper, **one tab per account**:

**Header per account:**
- **Account number and name**
- **Period**
- **GL balance**
- **Expected balance** (formula and inputs)
- **Difference**
- **Status** (tied / within tolerance / investigating)
- **Opening agreed to prior reconciliation** — Y/N, difference, and the carried items
- **Prepared by / date; Reviewed by / date** — `[manual]`

**Add the Mosofin rows**: **the ageing profile**, **the never-clearing residual**, and **the basis of the
expected balance** — register or payroll journal proxy.

**Detail per account:**

| Item | Description | Type (Timing / Permanent / Investigating) | Amount | Age | Owner | Target Resolution |

**Age is `[auto]`.** **Descriptions refer to individuals by reference, never by name.**

**Roll-Forward per account:**

| Opening | + Accruals | − Remittances | +/− Adjustments | = Closing |

**Master summary:**

| Account | GL Balance | Expected | Difference | Status | Materiality Breach Y/N |

**Bank tie-out:**

| Pay Date | Cycle | Net Pay Disbursed | Per Bank | Difference |

**With a column stating whether "Per Bank" is the recorded disbursement or the bank statement.**

**Proposed JEs:** pass-through to `journal-entry-builder`, marked as **proposals**.

**Stale Balances — NEW, Mosofin-specific:**

| Account | Amount | Age | Item count | Probable cause | Treatment | Escheatment applicable? |

**Coverage — NEW, Mosofin-specific:**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Payroll_Recs_[YYYY-MM]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the register, the provider statements, the bank statement — **name the source required**
instead of estimating.

## Step 10 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The payroll account list** and what each one holds
- **The remittance cadence per liability** — **the input the expected-balance pattern depends on**, and it
  changes rarely
- **The expected-balance pattern per account** — what "behaving correctly" looks like here
- **The payroll cycle calendar** — pay dates, remittance dates
- **The materiality tolerance** for write-offs, and the approval required
- **The escheatment position** — which jurisdictions apply and what the reporting deadlines are, **by
  reference**
- **Known recurring reconciling items** — expressed as rules: "the benefit provider invoices quarterly, so a
  two-month accrual is expected at those period ends"
- **The benefit providers and tax authorities** by payee name, so remittances match automatically
- **Whether a payroll platform is connected**, and which figures it supplies
- The replay recipe: the exact sequence of reads that produced the roll-forward and the ageing

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist any individual's payroll data** — no names, no pay amounts, no deductions, no garnishment
details, no bank details. **This is absolute.** **Garnishment information in particular reveals court
judgments and personal debts**, and it must not exist in a skill bundle in any form. **And never persist
balances, ageings or reconciling items** — all state.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — clearing 2200, PAYE 2210 remitted monthly on the 22nd, pension 2230 remitted monthly, benefits
invoiced quarterly, tolerance 50" — not "clearing 2200, PAYE 2210". **Account maps and cadences are
entity-specific and jurisdiction-specific**, and applying one entity's expected-balance pattern to another
produces false exceptions across the board. Record the chosen **scenario** (single vs multi) as a preference
too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of payroll accounts, one
cadence.

**Multi-entity.** Steps 0–9 run **once per entity**, each call targeting exactly one `data_source_id`, every
balance carrying its entity's `display_name`. Then:

- **A shared payroll service running several entities is common**, and **the clearing account is per
  entity.** **One payroll run covering three companies produces three sets of liabilities**, and a single
  bank payment covering all three must be allocated. **The allocation basis is `[manual]`.**
- **A payment made by one entity for another's payroll creates an intercompany balance** — not a payroll
  reconciling item. It belongs in an intercompany reconciliation; both sides must agree.
- **Employment jurisdiction, not entity location, drives the withholding accounts.** An entity employing
  people in three countries has three sets of withholding liabilities and three cadences.
- **Age and reconcile per entity.** A group-level clearing balance that nets to nil can conceal one entity
  owing and another over-remitted.
- **Escheatment obligations follow the employment jurisdiction**, and differ by state or country. **Do not
  apply one entity's position to another.**
- **Currency**: payroll in a currency other than the entity's functional currency creates FX on the
  liability between accrual and remittance — the translation itself is an FX revaluation task.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
