<!-- closing-entries-and-trial-balance · method.md · read for: Stages 3–6 — Steps 0–11, the close itself, and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 0b — Test whether the year is already closed (Mosofin addition)
- Step 1 — Verify the pre-closing trial balance
- Step 2 — Identify accounts to close
- Step 3 — Two-step or four-step closing
- Step 4 — Compute the closing entries
- Step 5 — Construct the closing JEs (hand off to journal-entry-builder)
- Step 6 — OCI handling
- Step 7 — Post-closing trial balance
- Step 8 — Tie-outs
- Step 9 — Lock and roll
- Step 10 — Output
- Step 11 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool
added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*, not
an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the trial
balance, the chart of accounts, the P&L and the prior-year balance sheet do not depend on each
other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries. Pass the
**accounting basis the user confirmed at intake** (cash or accrual) as `accounting_method` on every
read — the two give different net income and retained earnings.

Typical opening batch, per in-scope entity:

- *`get_trial_balance`* **at the fiscal year end** — the pre-closing TB — usually **[auto]**
- *`search_accounts`* / *`get_account`* — **every account with its type**, which drives the temporary
  / permanent split — usually **[auto]**
- *`get_profit_and_loss`* for the year — net income, and the totals for Step 4 — usually **[auto]**
- *`get_balance_sheet`* **at the prior year end** — opening retained earnings — usually **[auto]**
- *`get_balance_sheet`* at the current year end — the closing equity section, for the Step 8 tie-out
  — usually **[auto]**
- *`get_general_ledger`* on the equity, dividend and draw accounts — distributions declared, and any
  direct-to-equity postings — usually **[auto]**
- *`search_journal_entries`* near the year end — **whether the adjusting entries actually posted**,
  and whether a closing entry already exists — usually **[auto]**
- *`get_trial_balance`* **at the first day of the new fiscal year** — the auto-close test — usually
  **[auto]**
- *`get_balance_sheet`* **at the first day of the new fiscal year** — the retained-earnings roll test
  and the Step 8 tie-out — usually **[auto]**
- *`get_company_info`* — fiscal year end and currency — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — a closing entry built on it would misstate
retained earnings permanently.

## Step 0b — Test whether the year is already closed (Mosofin addition)

**Do this before proposing any entry.** It takes one read and prevents the single most damaging error
available in this skill.

- **Read the trial balance at the first day of the new fiscal year** (*`get_trial_balance`*,
  **[auto]**). **If the revenue and expense accounts are already at zero, the platform has closed the
  year automatically.**
- **Search for an explicit closing journal entry** around the year-end date
  (*`search_journal_entries`*, **[auto]**) — a large entry to retained earnings on or near the last
  day of the year.
- **Compare retained earnings** on the balance sheet dated the **first day of the new year** with
  retained earnings **plus** the separate "Net Income" / "Current Year Earnings" line at the year end
  (*`get_balance_sheet`*, **[auto]**). If they agree, the roll has happened. Platforms that show the
  current year on its own line report retained earnings at the year end *before* this year's result,
  so comparing RE at two year ends measures last year's result, not this one's.

On the upload path the same three tests run on the uploaded new-year trial balance (or balance sheet)
and the equity GL. Without those files the state is reported as **user-asserted, not tested**.

Report which of three states applies:

1. **Not closed** — proceed with Steps 1–9 and propose the entries.
2. **Auto-closed by the platform** — **do not propose entries closing revenue or expense.** Produce the
   trial balances, the tie-outs and the documentation, and state explicitly that the system performs
   the roll. This is Step 9's "document the system's behavior", answered with evidence. **Still
   propose** the Step 5 dividends / distributions / draws entry and, for a partnership or LLC, the
   allocation of the year's income from retained earnings to each member's capital account — the
   platform's roll touches only income and expense — unless the equity GL shows these were already
   posted.
3. **Already closed by an explicit entry** — verify it rather than repeating it. Run Step 8's
   tie-outs against the entry that exists.

**Posting a closing entry on top of an automatic one overstates or understates retained earnings by
the entire year's result**, and it is a genuinely common error. This test is cheap; run it every time.

## Step 1 — Verify the pre-closing trial balance

Before any closing entries:

1. **Sum debits and sum credits. They must equal.** — **[auto]** (*`get_trial_balance`*)
2. **Confirm all adjusting entries are posted** (depreciation, accruals, deferrals, prepaid
   amortization, tax provision, etc.) — **[gated]**: entries near year-end are readable
   (*`search_journal_entries`*), and their *absence* is detectable — no depreciation entry in the
   final month is a strong signal — but confirming the full list is **[manual]**
3. **Confirm all reconciliations are tied out** — **[manual]**; see `balance-sheet-reconciliations`
4. **Confirm material variances reviewed** — **[manual]**
5. **Confirm management has approved the financial statements** — **[manual]**
6. **Agree opening retained earnings (or total capital) to last year's final statements or tax
   return**, supplied by the user — **[manual]**. A difference means the prior year changed after it
   was reported. Stop and ask before closing on top of it.

**If the TB does not balance, investigate before closing.** Common causes:

- **Unposted entry**
- **One-sided entry**
- **Wrong sign**
- **Account type mismatch** (asset booked to liability, etc.)
- **Roll-forward error from prior period**

**Build a journal-entry-by-journal-entry diff if the imbalance is small and persistent** — **[auto]**
(*`search_journal_entries`*, *`get_general_ledger`*): most systems will not let an unbalanced entry
post, so a persistent imbalance in a live system usually points to a report parameter or an account
type problem rather than a genuine one-sided entry. Check the accounting method and date range you
requested before hunting for a phantom transaction.

## Step 2 — Identify accounts to close

Two categories in a standard closing — **[auto]** to classify from account type
(*`search_accounts`*):

**Temporary accounts (closed to zero each year)**:

- **All Revenue accounts** (close to zero, transfer net to RE)
- **All Expense accounts** (close to zero, transfer net to RE)
- **Other Income / Other Expense** (close to zero, transfer net to RE)
- **Income Tax Expense** (close to zero, transfer net to RE)
- **Gains / Losses** (close to zero, transfer net to RE)
- **Dividends / Distributions / Owner Draws** (close to RE / Owner Capital)

**Permanent accounts (carry forward)**:

- **All Asset accounts**
- **All Liability accounts**
- **All Equity accounts** (Common Stock, APIC, Treasury, RE, OCI components)

**OCI items have their own treatment (see Step 6).**

Classify on **type**, never on name — and list any account whose type and name seem to disagree as an
exception for the user to confirm. A revenue-typed account called "Deferred Revenue" is a real
misconfiguration and closing it would move a liability into retained earnings.

**Exception to classify-by-type:** dividends, distributions and draws accounts are **equity-typed**
on most platforms, yet they are closed each year. Identify them from the equity GL (Step 0) and the
account's detail type, and confirm the list with the user.

## Step 3 — Two-step or four-step closing

**Two-step** (modern accounting; most common):

1. Close all revenue and expense accounts **directly to Retained Earnings** (skipping the Income
   Summary account).
2. Close **Dividends / Distributions** to Retained Earnings.

**Four-step** (traditional textbook approach; some entities use):

1. Close revenue accounts to **Income Summary**
2. Close expense accounts to Income Summary
3. Close the Income Summary balance (= net income) to Retained Earnings
4. Close Dividends / Distributions to Retained Earnings

**Both produce the same end state. Use whichever the entity has historically used or whichever the
user prefers.** **[auto]** to check which was used historically: look for an Income Summary account
in the chart of accounts and for prior-year closing entries (*`search_accounts`*,
*`search_journal_entries`*). Consistency year to year matters more than the choice itself.

## Step 4 — Compute the closing entries

Sum each account category from the pre-closing TB — **[auto]**:

```
Total Revenue                              $A
Total Other Income / Gains                 $B
                                       -------
Total credits to close                     $(A + B)

Total Cost of Revenue                      $C
Total Operating Expenses                   $D
Total Other Expenses / Losses              $E
Total Income Tax Expense                   $F
                                       -------
Total debits to close                      $(C + D + E + F)

Net Income / (Loss) = (A + B) − (C + D + E + F)

Dividends / Distributions Declared          $G  (to be closed to RE)
```

**Cross-check the computed net income against the P&L** (*`get_profit_and_loss`*, **[auto]**). If they
differ, an account is classified in a way the report and the trial balance disagree about — resolve
it before closing, not after.

## Step 5 — Construct the closing JEs (hand off to journal-entry-builder)

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — these are proposals.

**Closing Entry 1 — Close Revenue and Income accounts**
```
DR  Revenue (each account, to zero out)        $A
DR  Other Income / Gains (each account)        $B
    CR  Retained Earnings                         $(A + B)
Memo: Close revenue and other income to RE — FY[YYYY]
```

**Closing Entry 2 — Close Expense and Loss accounts**
```
DR  Retained Earnings                          $(C + D + E + F)
    CR  Cost of Revenue (each account, to zero)   $C
    CR  Operating Expenses (each account)         $D
    CR  Other Expenses / Losses                   $E
    CR  Income Tax Expense                        $F
Memo: Close expenses to RE — FY[YYYY]
```

Close each account by the **opposite of its own balance**. A debit-balance revenue account (sales
returns, discounts — contra-revenue) is credited, and a credit-balance expense account (a refund) is
debited. The category total is the net.

For a **partnership / LLC**, Entries 1–2 credit (or, for a loss, debit) **each member's capital
account** in the profit-sharing ratio the user gave at intake, not Retained Earnings —
`CR [Member A] Capital $NI × A%`, `CR [Member B] Capital $NI × B%` — or close to Income Summary and
then allocate it. For a **sole proprietor**, Entries 1–2 close to **Owner Capital**.

**Closing Entry 3 — Close Dividends / Distributions**

For a **corporation**:
```
DR  Retained Earnings                          $G
    CR  Dividends Declared                        $G
Memo: Close dividends to RE — FY[YYYY]
```

For a **partnership / LLC**:
```
DR  Member Capital (or per partner)            $G
    CR  Member Distributions / Draws              $G
Memo: Close member distributions to capital — FY[YYYY]
```

For a **sole proprietor**:
```
DR  Owner Capital                              $G
    CR  Owner Draws                               $G
Memo: Close owner draws to capital — FY[YYYY]
```

**Net effect on RE / Capital:**
- **Increased by net income** (positive) or **decreased by net loss**
- **Decreased by dividends / distributions**

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**), and list every account being zeroed individually rather than by category — a closing
entry that says "Revenue" when there are eleven revenue accounts is not postable.

## Step 6 — OCI handling

Items in **Other Comprehensive Income (OCI)** — gains and losses that bypass the profit and loss
account — **generally do NOT close to retained earnings. They close to Accumulated Other
Comprehensive Income (AOCI)**, a separate equity account that carries forward.

**OCI items** — **[gated]**: the accounts are readable, the classification is **[manual]**:

- **Foreign currency translation adjustments (CTA)**
- **Unrealized gains / losses on available-for-sale securities** (US GAAP)
- **Unrealized gains / losses on certain hedging instruments**
- **Pension actuarial gains / losses** (per framework)
- **Revaluation surplus** (IFRS)

Closing entry for OCI:
```
DR  AOCI                                       $X
    CR  OCI — [item]                              $X (if a loss — debit balance)
or
DR  OCI — [item]                               $X (if a gain — credit balance)
    CR  AOCI                                       $X
```

**OCI items that are later "recycled" (reclassified to net income) follow the recycling rules of the
relevant standard.**

The error to guard against: **an OCI item swept into net income and closed to RE**. It is easy to do
when an OCI account is typed as income in the chart of accounts, and it misstates both retained
earnings and AOCI. Check the account types explicitly.

## Step 7 — Post-closing trial balance

After closing entries, produce a **post-closing trial balance** — **[auto]** to construct from the
pre-closing TB plus the proposed entries, and **[auto]** to verify against the live system once the
entries are actually posted by a human.

Properties of a post-closing TB:

- **All revenue and expense accounts = $0**
- **Retained Earnings reflects: Opening RE + Net Income − Dividends**, with OCI closed to AOCI as a
  separate line
- **Total debits = Total credits**
- **Only permanent accounts remain**

**The post-closing TB equals the opening trial balance for the new fiscal year.**

## Step 8 — Tie-outs

Verify — **[auto]** for all four:

- **Pre-closing TB → Post-closing TB: only temporary accounts moved**
- **Pre-closing net income (per P&L) = increase in RE from closing entries**
- **Pre-closing dividends declared = decrease in RE from closing entries**
- **Permanent accounts unchanged**

```
Opening RE                          $W
+ Net Income                        $X
- Dividends declared                $Y
= Closing RE                        $(W + X − Y)

Opening AOCI ± OCI for the year     = Closing AOCI   (its own roll-forward, never inside RE)
```

**Reconcile to the equity section of the closing balance sheet** — **[auto]**
(*`get_balance_sheet`*): agree Closing RE to the RE line on the **first day of the new year**, or to
RE + Net Income at the year end on platforms that show the current year separately. This is the proof that the whole exercise worked, and it is fully
evidenced in a connected workspace.

## Step 9 — Lock and roll

Once closing entries are posted and verified:

- **Lock the fiscal year in the system** (no further entries permitted) — **[manual]**, and
  emphatically so: **Mosofin cannot lock a period.** This is a human action in the accounting
  system, and it is the control that makes the close mean anything. Name the person who will do it
- **The new fiscal year opens with the post-closing TB as its opening TB** — **[auto]** to verify
  afterwards
- **Period 1 of the new year begins with all P&L accounts at zero** — **[auto]** to verify

**Some systems do this automatically when you advance to a new fiscal year; some require explicit
closing entries. Document the system's behavior.** Step 0b answers this with evidence rather than
assumption — carry that finding into the documentation.

## Step 10 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Pre-Closing Trial Balance** — all accounts with debits and credits, summed. Add a header
block: workspace name; the entity by `display_name`; each excluded company file and why; the fiscal
year end; the **accounting basis** (cash or accrual) used on every read; **the Step 0b closed-state finding**; whether any figure rests on `mock` data.

**Sheet 2: Closing Entries** — the journal entries with full detail **per account**, marked as
**proposals**. Where Step 0b found the year already closed, this sheet says so instead.

**Sheet 3: Post-Closing Trial Balance** — only permanent accounts; temporary accounts at zero.

**Sheet 4: Income Statement (for the closed year)** — from the temporary accounts being closed.

**Sheet 5: Statement of Retained Earnings (or Statement of Equity Changes)**

| Opening RE | + Net Income | − Dividends | = Closing RE |

AOCI is shown as its own roll-forward: Opening AOCI ± OCI for the year = Closing AOCI.

If equity has multiple components, the full statement of changes in equity is a separate piece of work.

**Sheet 6: Tie-Outs** — pre-close TB to post-close TB reconciliation. **Confirmation that debits =
credits at both stages.**

**Sheet 7: Roll Forward to New Year** — the opening balances for the new fiscal year.

**Sheet 8: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used | Policy | `mock` | Gap — what could not be evidenced and who owns it |

The rows for reconciliations tied out, management approval, and **locking the period** read `manual`
with named owners. Locking in particular must never appear as done.

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Closing_Entries_TB_FY[YYYY]_[EntityName].xlsx`

`[EntityName]` is the company file's `display_name`, one file per entity — **never a combined file**,
since each entity closes its own books. Every file states which datasource and `display_name` it
covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled
user-supplied evidence. End with a single **Data sources** line grouping calls by datasource. Where
the data does not cover something, **name the tool that would have covered it** instead of
estimating.

## Step 11 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask
— explicitly, at that point, not earlier — whether to save this as their own customized version. A
general "yes, go ahead" from earlier does not count.

On an explicit yes, persist the **decisions**:

- **The entity type** and therefore which Step 5 variant applies
- **The closing method** — two-step or four-step — so it stays consistent year to year
- **Whether the platform auto-closes**, as confirmed by the Step 0b test, and what that means for the
  procedure
- **The account classification exceptions** — any account whose type and name disagree, and how it
  was resolved
- **The OCI account list** and each item's treatment
- **The equity account map**: retained earnings, AOCI, dividends / draws, capital accounts by member
  where relevant
- **Who locks the period**, and the pre-lock checklist the entity requires
- The replay recipe: the exact sequence of reads that produced the trial balances and tie-outs

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files;
set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference
files alongside the installed skill.

**Do not persist balances, net income, retained earnings or the trial balances.** They are one year's
results and belong in the year-end file. Persist the *method, the classifications and the owners*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — LLC, member capital per member, two-step close, platform auto-closes" — not
"two-step close". Entities in one group frequently have different legal forms, and applying a
corporation's dividend entry to an LLC posts to an account that does not exist. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's** — and **whether this year is closed yet is state**, re-tested every run at Step 0b.

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is
no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One set of closing entries, one
post-closing TB.

**Multi-entity.** **Each entity closes its own books, separately and completely.** Steps 0–10 run
**once per entity**, each call targeting exactly one `data_source_id`, every entry and trial balance
carrying that entity's `display_name`. Then:

- **There is no group closing entry.** Consolidation happens *after* each entity has closed, on the
  closed figures, in a separate consolidation procedure. Never combine trial balances before closing;
  the result would close intercompany balances into retained earnings.
- **Entity type may differ across the group.** A corporation subsidiary and an LLC subsidiary take
  different Step 5 entries. Confirm the type per entity rather than per group.
- **Fiscal year ends may differ.** Check each entity's own profile; closing one entity against
  another's year-end closes the wrong twelve months.
- **The auto-close test is per entity**, since platform behaviour and configuration can differ
  between company files even on the same platform.
- **CTA arising on consolidating a foreign subsidiary** belongs to the group's AOCI, not to the
  subsidiary's own closing entries — the subsidiary closes in its functional currency.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
company file.

---
