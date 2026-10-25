<!-- expense-report-processor · method.md · read for: Stages 3–6 — Steps 0–1 at Stage 3, Steps 2–4 at Stage 4, Steps 5–6 at Stage 5, Step 7 at Stage 6, and the entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Parse the report
- Step 2 — Validate against policy
- Step 3 — Code to GL accounts
- Step 4 — Calculate reimbursement
- Step 5 — Construct the GL posting
- Step 6 — Output
- Step 7 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** Policy validation without a policy is the original's own
documented limit and remains so.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

Pull the `[auto]` / `[gated]` reads **before** parsing, because the COA and the posted transactions are
what make the coding and the duplicate check real rather than generic.

**Batch independent reads into one message** — the accounts, the employees, the posted expenses and the
balances do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — **the real chart of accounts**, including the travel, meals, entertainment, gift
  and clearing accounts — usually **[auto]**
- *`search_employees`* — **the claimant list**, with departments where set up — usually **[auto]**
- *`search_purchases`* / *`search_expenses`* / *`search_bills`* — **transactions already posted in the
  period**, which is the duplicate-check population — usually **[auto]**
- *`search_credit_card_charges`* or the card account in *`get_general_ledger`* — **corporate card
  activity** — usually **[auto]**
- *`get_general_ledger`* on **Corporate Card Clearing** and **Employee Reimbursement Payable** — usually
  **[auto]**
- *`get_balance_sheet`* — the **payable and Due-from-Employee balances** — usually **[auto]**
- *`search_vendors`* — merchant recognition — usually **[auto]**
- *`get_profit_and_loss`* by department / class — **historical coding patterns** — usually **[auto]**
- *`search_departments`* / *`search_classes`* — the dimensions available for allocation — usually **[auto]**
- *`get_company_info`* — legal name, **functional currency**, country — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap. **If it is the COA read,
  say explicitly that coding has degraded to placeholders.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate check against fixture transactions
proves nothing**, and must not be reported as a clean result.

## Step 1 — Parse the report

Extract per line — **[manual]** unless a T&E platform is connected:

- Employee name
- Expense date
- Category (Airfare, Lodging, Meals, Ground Transport, Mileage, Supplies, Other)
- Vendor / merchant
- Description / business purpose
- Amount (gross; **tax and tip separately if shown**)
- Currency
- Payment method (employee cash / card, corporate card, reimbursement requested?)
- Receipt attached: Y/N
- Reference number / unique line ID

**Tool-specific normalization tips:**

- **Concur**: handles **split transactions across categories — preserve splits, don't merge.**
- **Expensify**: **SmartScan confidence — flag low-confidence OCR'd lines.**
- **Brex / Ramp / Pleo / Spendesk**: **corporate card transactions already paid — distinguish from
  out-of-pocket.**
- **Soldo / Mooncard / Pleo**: **prepaid card transactions — treat as company-paid.**

That distinction is now load-bearing: **company-paid lines are the ones that should already exist in the
ledger**, and Step 2's duplicate check depends on classifying them correctly.

**Normalize messy data:**

- **Mileage entries** → capture **distance and unit (mi or km), and rate (or flag as missing)**
- **Foreign currency** → **preserve original**; use the provided FX rate or **flag for the user to supply**
- **Tip separately captured if shown**

**Mosofin addition — match each claimant to an employee record.** **[auto]** via *`search_employees`*. A
claimant with no employee record is worth flagging: a leaver, a contractor claiming on an employee form, or
a misspelling.

## Step 2 — Validate against policy

**Policy validation only runs if the user provided a policy.** If no policy, **skip the policy checks and move to
Step 3** — GL coding, math check and obvious-personal flags. **Duplicate detection, below, needs no policy
and runs either way.** **[manual]** on the policy throughout;
the arithmetic against it is `[auto]`.

When a policy is provided, validate per its rules. Common dimensions:

### Receipt requirements

Apply **the user's** policy thresholds. Common patterns to look for in the policy:

- **A minimum amount above which receipts are required**
- **Specific categories that always require receipts regardless of amount** — commonly lodging, client
  entertainment, anything reimbursable cross-border
- **Tax-authority requirements for the entity's jurisdiction** — if the policy doesn't address this, **flag
  for the user to confirm**

**Flag missing-receipt items per the policy's stated rules.** **[gated]**: the threshold comparison is
arithmetic, but **the receipt flag comes from the T&E tool and the image is not visible here.** Report it as
"per the report", not as verified.

### Per-diem

If the entity uses per-diems for lodging and/or meals — **[manual]** table, `[auto]` comparison:

- **Compare claimed amount to the per-diem table provided**
- **Flag any claim exceeding the per-diem**
- **For mixed regimes** (per-diem M&IE + actual lodging) — **flag meal receipts as potential duplicate
  claims**

### Meals & entertainment

- **Per-person caps from policy**
- **Alcohol allowed / restricted per policy**
- **Client meals: require attendees + business purpose per policy**
- **Deductibility treatment per jurisdiction** (if the user provided the jurisdiction): some jurisdictions
  allow full deduction, some partial, some none — **split the GL coding accordingly only if the user
  provided the rule**

**[auto]** contribution: whether the COA *has* separate deductible and non-deductible accounts is readable
(*`search_accounts`*). If it does not, that is the Step 3 flag, raised early.

### Airfare / rail / sea travel

- **Class restrictions per policy** (economy, premium economy, business)
- **Booking source restrictions**
- **Personal segment allocation if the trip extends personal days**

### Lodging

- **Per-night caps from policy**
- **Resort / cleaning / incidental fees — reimbursable per policy**
- **Personal nights — non-reimbursable**

### Ground transport

- **Ride-share, taxi, rental car — per policy**
- **Mileage at the rate provided by the user / policy / jurisdiction's prevailing rate** — **[manual]**,
  and **never supplied from memory**

### Entertainment

- **Deductibility flag per the entity's jurisdiction** (only if the user provided it)
- **Per policy: allowed / restricted / requires pre-approval**

### Gifts

- **Cap per recipient per policy**
- **Deductibility cap per jurisdiction** (only if the user provided the rule)

### Personal-expense patterns (red flags)

**These are universal red flags regardless of jurisdiction** — and they are pattern checks, so `[auto]`
against the parsed report:

- **Weekend charges in non-business locations**
- **Personal retail / grocery / liquor / personal services**
- **Family-member-named travel or accommodation**
- **Recurring personal subscriptions**

**Flag as "Policy violation — possible personal" for manager review.** *Mosofin note*: a recurring personal
subscription often also appears in the ledger month after month (*`get_general_ledger`*), which turns a
suspicion into a documented pattern with a start date.

### Duplicate detection

- **Same vendor + amount + date submitted twice by the same employee** — `[auto]` within the report
- **Same expense claimed on both employee report and corporate-card reconciliation** — **`[auto]` against
  the ledger, and this is the check the original could only describe.** Match each claim line against
  posted card transactions on vendor, amount and a date window. **A claim for a charge the company already
  paid is a double reimbursement**, and it is the highest-value finding this skill produces.

**Match tolerances**: exact amount and same merchant is a strong match; allow a **±3 day** window for
posting lag, and treat a near-amount match (tip added later) as a **review**, not a reject. Where the
merchant name differs between the card feed and the claim, fall back to amount plus date — and say the
match was made on those alone.

See `duplicate-invoice-detection` for the full matching discipline; the same reasoning applies.

## Step 3 — Code to GL accounts

**Hand off the coding logic to the `gl-coding-assistant` skill's conceptual category mappings.** **Account
numbers come from the user's COA only. Never invent account numbers.** **[auto]** here — the COA is
connected.

Common T&E category → conceptual GL category (mapped to the user's COA):

- **Airfare** → Travel — Airfare
- **Lodging** → Travel — Lodging
- **Meals (business, deductible portion)** → Meals (deductible)
- **Meals (non-deductible portion, per jurisdiction)** → Meals (non-deductible)
- **Ground transport / mileage** → Travel — Local Transport
- **Conferences / training** → Training & Development
- **Office supplies** → Office Supplies
- **Software / subscriptions** → Software Subscriptions
- **Client gifts (deductible portion)** → Client Gifts
- **Client gifts (non-deductible portion)** → Non-deductible / disallowed
- **Entertainment (deductible per jurisdiction)** → Entertainment
- **Entertainment (non-deductible per jurisdiction)** → Entertainment — Non-Deductible
- **Communications** → Telephone & Internet
- **Miscellaneous** → Other — **flag for review**

**If the user's COA does not separately track deductible vs. non-deductible portions, flag and suggest
creating sub-accounts or using a class / department dimension.** **[auto]** to determine — read the COA and
the available dimensions and say which is actually available in this entity.

**Mosofin addition — ground each mapping in history.** **[auto]**: before proposing an account, check how
this entity has coded the same category, and the same merchant, previously (*`get_general_ledger`*,
*`get_profit_and_loss`*). **Report the suggestion with its support** — "Travel — Airfare (6410); this
merchant coded there 12 of 12 times" — and **flag where history is inconsistent**, because an inconsistent
history is itself worth knowing before the reviewer perpetuates it.

## Step 4 — Calculate reimbursement

For each employee:

| Component | Calculation |
|-----------|-------------|
| **Total claimed** | Sum of all approved lines |
| **Less: Corporate-card-paid items** | Reduce reimbursement |
| **Less: Policy violations / disallowed** | Removed |
| **Less: Personal portion** | Allocated to employee |
| **Plus: Mileage at provided rate** | Distance × rate |
| **Net reimbursable to employee** | Sum |

**[auto]** arithmetic; the rate and the policy calls behind it are `[manual]`.

**Multi-currency: convert to functional currency using a stated FX source** — ask the user: **central bank
close, accounting system rate, or report-date rate from a stated provider. Do not assume a source.** The
**functional currency itself is now `[auto]`** from the profile; the *rate source* is not.

**Mosofin addition — reconcile to the payable.** **[auto]**: the proposed net reimbursable, added to the
existing **Employee Reimbursement Payable** balance, should explain that account's movement once paid.
**A payable balance that does not correspond to outstanding claims means either a claim was paid twice or
one was never paid** — both worth surfacing.

## Step 5 — Construct the GL posting

**Hand off to the `journal-entry-builder` skill.** Provide it with:

- **Posting date**
- **Employee name and period**
- **Sum of expenses by GL account** (using the user's COA — **`[auto]`, real accounts**)
- **Sum of input tax recoverable** (if the jurisdiction supports it and the user has provided the rule)
- **Reimbursable amount** → **AP / Employee Reimbursement Payable**
- **Corporate-card-paid amount** → **Corporate Card Clearing**

**The JE skill produces the balanced entry. This skill provides the inputs.** **Mosofin does not post** —
the entry is a proposal, whichever skill assembles it.

**Mosofin addition — the clearing account test.** **[auto]**: **Corporate Card Clearing should clear.**
Read its balance and its ageing (*`get_general_ledger`*). A persistent residual means card charges posted
with no matching claim, or claims posted with no matching charge — the two halves that were supposed to
meet. **Report the residual with its oldest item**, because age is what tells you whether it is timing or a
genuine break.

## Step 6 — Output

Deliver an `.xlsx` workpaper:

**Sheet 1: Summary**
- **Employee(s), report period**
- **Total claimed / approved / rejected**
- **Reimbursement amount**
- **Policy violations summary**
- **Policy assumptions used** — if any were not explicit in the policy doc, **list them here for the user to
  confirm**

Plus the Mosofin header block: workspace name; the entity by `display_name`; each excluded company file and
why; whether any figure rests on `mock` data; **and whether a policy was supplied at all**.

**Sheet 2: Line Detail**

| Line # | Date | Category | Vendor | Description | Amount | Currency | FX Rate | Functional Amount | GL Account | Tax Code | Policy Check | Receipt? | Notes |

Add two Mosofin columns: **Already Posted?** (the duplicate-check result, with the matched transaction) and
**Coding Support** (how this entity coded the same thing before).

**Sheet 3: Exceptions**

| Line # | Issue | Severity | Recommended Action |

Severities:
- 🔴 **Reject** — Policy violation, must be removed
- 🟡 **Review** — Manager judgment required
- 🟢 **Approve with Note** — Minor flag

**A confirmed match against an already-posted card transaction is a 🔴 Reject**, not a review — the money
has already left the company.

**Sheet 4: GL Posting Inputs** — pass-through to `journal-entry-builder`.

**Sheet 5: Ledger Checks — NEW, Mosofin-specific**

| Check | Result | Detail |

Covering: duplicate matches against posted transactions; the Corporate Card Clearing residual and its
ageing; the Employee Reimbursement Payable reconciliation; claimants with no employee record.

**Sheet 6: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | Policy | `mock` | Gap |

**If no policy was supplied, every Step 2 policy row reads `manual — not performed`; duplicate detection needs no policy and is reported as run.** That is the honest entry,
and it is more useful than a validation that did not happen.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**Output naming:** `[Employee]_ExpenseReport_[YYYY-MM].xlsx`

For a batch, `[Batch]_ExpenseReport_[YYYY-MM].xlsx`. Every file states which datasource and `display_name`
it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where the data does not
cover something — the policy, the rates, the receipts — **name the source required** instead of estimating.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The policy parameters in force**: receipt thresholds, per-person caps, class restrictions, per-night
  caps, gift caps, alcohol rules, pre-approval requirements — **with the policy version and date**
- **The mileage rate and per-diem table in force**, with **effective dates** — these change annually, so a
  stored rate without a date is a liability
- **The category-to-account map** — the single biggest time saver, and now grounded in the real COA
- **The clearing and payable account map**: Corporate Card Clearing, Employee Reimbursement Payable, Due
  from Employee
- **The deductible / non-deductible treatment** and whether the COA supports it
- **The FX rate source**
- **The T&E platform in use** and its parsing quirks — splits, OCR confidence, prepaid vs. card
- **The duplicate-match tolerances** — the date window and amount tolerance agreed with this client
- The replay recipe: the exact sequence of reads that produced the COA, the posted-transaction population
  and the balance checks

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist employee names, individual claims, claim amounts, card numbers, home addresses, or
travel itineraries.** Expense data is personal data about identifiable people — where they went, when, and
with whom. **Persist the policy and the mapping; never the claims.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — receipts required above 25, mileage 0.45/mi effective 2026-01-01, meals 50% non-deductible split
to 6455, card clearing 2150" — not "receipts above 25". **Thresholds and account numbers differ by
company file**, and an unlabelled threshold applied to the wrong entity rejects valid claims or passes
invalid ones. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and the claims, the balances and the clearing residual are all state.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One COA, one employee list, one set of
posted transactions to check against.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every claim and account carrying its entity's `display_name`. Then the points specific to expenses:

- **Ask which entity employs each claimant, and which entity bears the cost.** They differ often —
  an employee of the services company travelling to a client of the trading company. **The duplicate check
  must run against the entity whose card paid**, which may not be the entity employing the claimant.
- **A claim charged to the wrong entity is an intercompany balance**, not just a coding error. Flag it for
  elimination at consolidation rather than silently recoding.
- **Policies may differ by entity** — different countries, different caps, different mileage rates.
  **Never apply one entity's per-diem table to another's staff.** Store rates keyed by entity.
- **Corporate cards are often issued centrally.** The clearing account may sit in one entity while the
  expenses belong to several, so **the clearing test runs where the card is, and the coding runs where the
  cost is.**
- **Currency differs by entity**, so the FX conversion and the rate source must be applied per entity, not
  once for the group.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per company
file.

---
