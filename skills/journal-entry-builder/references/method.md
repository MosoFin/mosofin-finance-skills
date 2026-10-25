<!-- journal-entry-builder · method.md · read for: Stages 3–6 — Step 0 reads the books, Steps 1–5 build the entry, Steps 6–7 validate and present it, Step 8 saves; plus both entity scenarios and the pitfalls. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Identify the JE type
- Step 2 — Apply the accounting equation
- Step 3 — Construct the entry
- Step 4 — Common JE patterns
- Step 5 — Tax effects (jurisdiction-driven)
- Step 6 — Validation
- Step 7 — Output format
- Step 8 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios
- Pitfalls Specific to JE Construction (not covered above)


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The event itself and the tax rules are legitimately
`[manual]`.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the chart, the balances and the validation populations do
not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical batch, per in-scope entity:

- *`search_accounts`* — **the chart with account numbers, names and types** — usually **[auto]**. **The
  single most important read here**
- *`get_trial_balance`* / *`get_balance_sheet`* — **current balances on the accounts being touched** —
  usually **[auto]**
- *`get_general_ledger`* on **the accrual, prepaid, deferred and clearing accounts** — **the Pitfall 1
  check** — usually **[auto]**
- *`search_invoices`* / *`search_bills`* — **whether a document already exists for this item** — usually
  **[auto]**
- *`search_journal_entries`* — **the numbering convention in use, and whether the period still accepts
  entries** — usually **[auto]**
- *`get_company_info`* — legal name, **functional currency**, year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that validation to **[manual]** and record the gap. **If it is the chart
  read, state that placeholder coding is in use.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **an entry validated against fixture accounts may
reference accounts that do not exist in the real chart**, and it would be imported.

## Step 1 — Identify the JE type

| Type | When to use | Typically reverses? |
|------|-------------|---------------------|
| **Standard** | Recording an actual transaction — cash receipt, payroll, sale | No |
| **Accrual** | **Expense incurred but not yet invoiced or paid, or revenue earned but not invoiced** | **Usually yes, first day of next period** |
| **Deferral** | **Cash received or paid in advance of revenue or expense recognition** | **No** — released over time |
| **Adjusting** | **Period-end true-up** — depreciation, amortization, FX reval, accruals | Sometimes |
| **Correcting** | **Fixing a prior error** | **No** — document the original |
| **Reclass** | **Moving balance from one account to another, no economic event** | No |
| **Reversing** | **Reverses a prior accrual on the first day of the next period** | **Is itself the reversal** |
| **Closing** | **Year-end close of P&L to Retained Earnings** | No |
| **Intercompany** | **Cross-entity transactions; mirror entries in both entities** | **Mirrored** |
| **Opening Balance** | **New entity setup / system migration** | No |

**State the JE type explicitly in the header.**

*Mosofin note on Closing*: **check whether the platform closes the year automatically** before proposing a
closing entry — see `closing-entries-and-trial-balance`. **[auto]**: P&L accounts at zero after year-end
with no visible closing journal means the system did it, and **a manual closing entry would double-close
retained earnings.**

## Step 2 — Apply the accounting equation

**Every JE must balance: Total Debits = Total Credits.**

**Normal balance rules:**

| Account type | Increases with | Decreases with |
|--------------|----------------|----------------|
| **Asset** | Debit | Credit |
| **Liability** | Credit | Debit |
| **Equity** | Credit | Debit |
| **Revenue** | Credit | Debit |
| **Expense** | Debit | Credit |
| **Contra-asset** (e.g. Accumulated Depreciation) | **Credit** | **Debit** |
| **Contra-revenue** (e.g. Sales Returns) | **Debit** | **Credit** |

**Walk through substance:**

1. **What did the entity receive?** → **Debit** (asset / expense) or Credit reduction
2. **What did the entity give up?** → **Credit** (asset reduced) or Debit reduction
3. **What obligation was created or settled?** → **Credit** (created) or **Debit** (settled)

**[auto]** enforcement: **account types are readable**, so **the sign convention is checkable rather than
assumed.** A debit to a revenue account, or a credit to an expense account, is not wrong in itself — but
**it is unusual enough to warrant the memo saying why**, and the check surfaces it.

## Step 3 — Construct the entry

Standard format:

```
Date: YYYY-MM-DD
Entry #: [auto or user-supplied]
Type: [Standard / Accrual / Reclass / etc.]
Reference: [Invoice #, contract, supporting doc]
Memo: [One line describing the business event]

Account No. | Account Name | Debit | Credit | Line Memo
------------|--------------|-------|--------|----------
[from user's COA] | [from user's COA] | $X | | [purpose]
[from user's COA] | [from user's COA] | | $X | [purpose]

Total                                 | $X | $X | ✓ Balanced
```

**Required for every entry:**

- **Posting date**
- **Entry type**
- **Header memo** — business purpose in plain language
- **≥ 2 lines** — one DR, one CR
- **Line-level memos when multiple debits or credits**
- **Balance check at bottom**

**Mosofin additions to the header, since the entry travels beyond this conversation:**

- **PROPOSED ENTRY — NOT POSTED**, stated plainly
- **The entity by `display_name`**
- **The validation result** from Step 6
- **The source**: which skill or analysis produced it, and the tool calls behind any figure

**Account numbers and names come from the live chart** (*`search_accounts`*, **[auto]**) — **exactly as they
appear there**, including formatting, so the import matches.

## Step 4 — Common JE patterns

`DR` is a debit, `CR` a credit. **Every pattern below is a proposal.**

### Accrual (expense incurred, not yet invoiced)
```
DR  Expense account                       $X
    CR  Accrued Liabilities (BS)              $X
Memo: Accrue [service] for [period] — invoice expected [date]
```
**Flag as reversing on first day of next period.**

### Prepaid expense (paid in advance)
```
At payment:
DR  Prepaid Expense (BS)                  $X
    CR  Cash / AP                             $X

Periodic amortization:
DR  Expense                               $X / periods
    CR  Prepaid Expense                       $X / periods
```
**Suggest `prepaid-amortization-schedule` for the full schedule.**

### Deferred revenue
```
At receipt:
DR  Cash                                  $X
    CR  Deferred Revenue (BS)                 $X

As earned:
DR  Deferred Revenue                      $X / period
    CR  Revenue                               $X / period
```

### Depreciation
```
DR  Depreciation Expense                  $X
    CR  Accumulated Depreciation              $X
Memo: Periodic depreciation — [asset class or specific asset]
```

### Reclass between accounts
```
DR  Correct Account                       $X
    CR  Incorrect Account                     $X
Memo: Reclass [item] from [wrong] to [correct]; original entry #, date
```
**[auto]**: **the original entry is findable** (*`search_journal_entries`*, *`get_general_ledger`*), so the
memo's entry number and date can be filled from the ledger rather than from memory.

### Correcting prior error

**Never delete or alter the original entry if posted.** Either:

- **Reverse and rebook** — full reversal + correct entry — **preferred for material errors or audit-trail
  needs**
- **Net correction** — just the difference — **for small true-ups**

**Reference the original entry # in the memo either way.**

*Mosofin note*: **Mosofin cannot delete or alter anything**, which enforces the first sentence structurally.
And **the original entry is readable**, so the reversal can be built from what was actually posted rather
than from what someone remembers posting.

### Intercompany

**Always create mirror entries in both entities:**
```
Entity A (lender):
DR  Intercompany Receivable — Entity B    $X
    CR  Cash                                  $X

Entity B (borrower):
DR  Cash                                  $X
    CR  Intercompany Payable — Entity A       $X
```
**Flag for intercompany reconciliation at period end.**

**[gated]**, and stronger here than the original assumes: **where both entities are connected, both sides
are built against their own real charts** — the account names differ between entities and **using the
correct ones in each is the difference between an entry that imports and one that fails.** **Where the
counterparty is not connected, build the near side and say the far side could not be built against a real
chart.**

### Reversing entries

**Date: first day of next period. Flip debits and credits from the original. Reference the original entry
#.** **[auto]**: the original is readable, so the flip is mechanical and the reference is exact.

### Closing entries (year-end)

**Close revenues and expenses to Income Summary — or directly to Retained Earnings if the system supports
it. Verify net result ties to P&L net income / loss.** **[auto]** to verify: *`get_profit_and_loss`* gives
the figure the entry must produce.

## Step 5 — Tax effects (jurisdiction-driven)

**Only include tax lines if the user provided a jurisdiction and the transaction has tax implications.**

**For sales / output side:**
- **VAT / GST / sales tax collected → Liability** (Tax Payable / Output Tax)
- **Multi-jurisdiction sales → separate lines per jurisdiction**
- **Tax-exempt or zero-rated → no tax line; note the exemption reason**

**For purchases / input side:**
- **Recoverable input tax** (where the jurisdiction allows it) **→ Asset** (Input Tax Receivable)
- **Non-recoverable input tax → included in expense**

**If the jurisdiction's rules aren't clear, ask the user. Do not assume.**

**[gated]**: **the tax accounts and any configured tax codes are `[auto]`**, so a tax line can name a real
account and a real code — **but which code applies remains `[manual]`.** See `gl-coding-assistant`, where
the same split appears.

## Step 6 — Validation

Before delivering, verify — **and here most of these are performed, not merely intended**:

- ✅ **Debits = Credits, to the penny** — **[auto]**
- ✅ **All accounts exist in the provided COA** — **[auto]** against the live chart. **An account that does
  not exist is a hard stop**, not a warning
- ✅ **Date is within an open accounting period (warn if not)** — **[gated]**: **entries existing after a
  date, or the platform's own period status, indicate it.** **Warn about reporting status too** — a period
  the software will accept may already have been reported
- ✅ **Memo explains the business purpose** — not "JE" or "adjustment"
- ✅ **References to source documents included** — **[gated]**; findable where the document is in the system
- ✅ **Reversing flag set correctly if applicable**
- ✅ **Sign conventions match account types** — **[auto]** from account types
- ✅ **No P&L accounts used for pure BS reclasses without a stated reason** — **[auto]** from account types
- ✅ **Tax lines present if jurisdiction + transaction warrant** — **[gated]**

**Mosofin additions to the validation set — the Pitfall checks, run as queries:**

- ✅ **No existing accrual already covers this item** — **[auto]**. **The Pitfall 1 double-count check.**
  Read the relevant accrual account before proposing a payment or invoice entry
- ✅ **No open invoice exists for a receipt being booked to revenue** — **[auto]**. Pitfall 2
- ✅ **A loan payment is split between interest and principal** — **[auto]** support from the liability
  balance. Pitfall 5
- ✅ **The target is not a control account** — **[auto]**: **manual entries to revenue, cash, AR or AP
  control accounts are auditor red flags**, and whether an account is one is readable
- ✅ **The entry does not exceed materiality without a review flag** — **[gated]**; **the threshold is
  `[manual]`**
- ✅ **A clearing or suspense account used here is expected to clear** — **[auto]** to report its current
  balance and age

**Report the validation result with the entry.** A proposal that says "validated: 9 of 9 checks passed;
account 6410 confirmed in chart; period open; no matching accrual found" is one a reviewer can post
quickly. **One that says "validated" is not.**

## Step 7 — Output format

**Single JE → markdown table inline. Multiple JEs / import-ready file → `.xlsx` or `.csv`.**

**Generic columns:**

| Date | Entry # | Account No. | Account Name | Debit | Credit | Memo | Reference | Class/Dept | Currency |

**System-specific column headers** — **and the connected platform is known from Gate 1**, so **use its
format by default** rather than asking:

- **QuickBooks Online**: `JournalNo`, `JournalDate`, `Line Description`, `Account`, `Debit`, `Credit`
- **Xero**: `*Narration`, `*Date`, `Description`, `*AccountCode`, `*TaxRate`, `*Amount`
- **NetSuite**: `External ID`, `Date`, `Account`, `Debit`, `Credit`, `Memo`, `Subsidiary`, `Department`,
  `Class`
- **Sage Intacct / 50 / 200**: **format varies — ask the user for the import template**
- **Microsoft Dynamics 365 / Business Central**: `Journal Batch`, `Posting Date`, `Document No.`,
  `Account Type`, `Account No.`, `Description`, `Amount`, `Bal. Account Type`, `Bal. Account No.`
- **Zoho Books / FreshBooks / Wave / Other**: **ask for the import template**

**If unknown, use the generic columns and let the user remap.**

**Add two sheets to any `.xlsx`:**

**Sheet: Validation Results — NEW, Mosofin-specific**

| Entry # | Check | Result | Evidence |

All nine original checks plus the six Mosofin ones, **each with the tool result behind it**.

**Sheet: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `[EntityName]_JE_[Description]_[YYYY-MM-DD].xlsx`

`[EntityName]` is the company file's `display_name`. **Every file states that the entries are proposals.**

**Grounding:** every account traces to the live chart; every validation traces to a tool result in this
conversation. End with a single **Data sources** line. Where a check could not run, **name it as not run**.

## Step 8 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The account map** for recurring entry types: accruals, prepaids, deferred revenue, accumulated
  depreciation, clearing, intercompany, suspense
- **The entry templates** this entity actually uses — **the most valuable stored asset here**, since a
  template that names the right accounts turns each period's entry into a fill-in
- **The import format** for the connected platform, including any local template quirks
- **The entry numbering convention**
- **The memo conventions** — what this entity's reviewers expect to see
- **The materiality threshold** for the review flag, with its date
- **The reversal policy** — which accrual types reverse automatically and which are cleared on settlement
- **The intercompany account pairs** across entities, keyed by both names
- **The tax code mapping** for common transaction types
- The replay recipe: the exact sequence of reads that performed the validations

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist amounts, balances, entry contents or transaction details.** All state. **Persist the
templates and the mappings; never the entries.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — accruals to 2110, prepaids to 1310, clearing 1999, QBO import format, JE numbering
JE-YYYYMM-nnn" — not "accruals to 2110". **Account numbers are chart-specific and therefore
entity-specific**, and an entry built with another entity's numbers will either fail to import or post to
the wrong account. Record the chosen **scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One chart, one entry, one validation.

**Multi-entity.** **Confirm which entity each entry belongs to before building it** — the first question,
not the last. Then:

- **Build each entry against its own entity's chart.** **[auto]** per entity. **Account numbers differ**,
  and an entry built with the wrong entity's numbers is the most common cross-entity failure here.
- **Intercompany entries are built in both entities**, mirrored, **each against its own chart**. Where the
  counterparty is not connected, **say the far side could not be built against a real chart** rather than
  guessing at its account names.
- **Validate both sides.** The near side's accrual check, period check and account check all apply equally
  to the far side — an intercompany reconciliation is where these entries end up being tested.
- **Currencies differ by entity.** Each entry is in its entity's functional currency; **a cross-currency
  intercompany pair will not mirror in local amounts**, and that is expected — the translation itself is a
  foreign-currency translation task.
- **Consolidation-only entries belong to neither entity's books.** Elimination entries from
  a consolidation are built for the consolidation ledger and **must be labelled so nobody
  imports them into a subsidiary.**
- **Numbering conventions differ by entity.** Store them separately.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each validation's verdict per
company file.

---

## Pitfalls Specific to JE Construction (not covered above)

**Preserved from the original, with the Mosofin verdict on each — four of the seven are now checkable.**

1. **Recording a payment when an accrual already exists** → **double-counts. Always check if a prior accrual
   covers the same item, and clear it.** — **[auto]**: **read the accrual account before proposing the
   entry.** The highest-value check in this skill.
2. **Using Cash for AR-related receipts** → **if an invoice exists, the receipt clears AR, not direct to
   revenue.** — **[auto]**: the open invoice is findable.
3. **Booking depreciation directly to the asset account** → **must use Accumulated Depreciation
   (contra-asset).** — **[auto]**: **whether a contra account exists is readable**, and the account type
   check catches the direct posting.
4. **Recording owner contributions as revenue** → **goes to Equity.** — **[auto]**: account type check.
5. **Recording full loan payment as expense** → **only interest is expense; principal reduces the loan
   liability.** — **[auto]** support: the liability balance and movement show the split; **the amortization
   schedule is `[manual]`.**
6. **Reversing entries dated the last day of the prior period** → **must be the FIRST day of the new
   period.** — **[auto]**: a date check.
7. **Forgetting the tax line** when a transaction has tax effects in the entity's jurisdiction —
   **under- or over-states the liability.** — **[gated]**: the tax accounts and codes are readable; **the
   rules are not.**
