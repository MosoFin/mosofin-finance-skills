<!-- bank-reconciliation · method.md · read for: Stages 3–6 — the reconciliation itself. Edit here, not in SKILL.md. -->

## Contents

- Step 0 — Fetch the evidence (grounding)
- Step 1 — Establish the two starting points
- Step 2 — Build the reconciliation bridge
- Step 3 — Match transactions (bank vs GL)
- Step 4 — Classify all unmatched items
- Step 5 — Propose corrections / journal entries
- Step 6 — Close out and document
- Step 7 — Evolve the skill (Mosofin-specific, final step)
- Quality checks
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with
plain-language wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence
tool added.

**Never drop a task because no tool covers it.** A `[manual]` task is a task with a *named gap*,
not an absence.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — the cash
ledger, the deposits, the payments and the transfers do not depend on each other. Never serialize
them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_accounts`* — to identify the cash / bank accounts by their real names — usually
  **[auto]**
- *`get_trial_balance`* / *`get_balance_sheet`* — the GL cash ending balance — usually **[auto]**
- *`get_general_ledger`* on each cash account for the period — every book-side movement, the core
  of this skill — usually **[auto]**
- *`search_deposits`* / *`get_deposit`* — money banked, and the deposit-in-transit candidates —
  usually **[auto]**
- *`search_bill_payments`* / *`get_bill_payment`* — supplier payments, the outstanding-cheque
  candidates — usually **[auto]**
- *`search_purchases`* — cheques, card spend and direct debits — usually **[auto]**
- *`search_payments`* / *`search_sales_receipts`* — customer receipts — usually **[auto]**
- *`search_transfers`* — movements between the entity's own accounts, which appear on both sides
  and are a classic double-count — usually **[auto]**
- *`search_journal_entries`* — manual entries hitting cash, a frequent error source — usually
  **[auto]**
- *`get_company_info`* — base currency and time zone — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that task to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — it can demonstrate the bridge's format
but **cannot support a completed reconciliation**, because a reconciliation is a control and
performing it on fixtures records a control as operating when it did not.

## Step 1 — Establish the two starting points

Capture:

- **Bank statement ending balance** as of the statement end date — **[manual]**
- **GL cash account ending balance** as of the same date — **[auto]**
  (*`get_trial_balance`*, *`get_balance_sheet`*, *`get_general_ledger`*)

**Confirm both are for the same account and currency.** This sounds trivial and is a common real
error: an entity with several accounts at the same bank, or a foreign-currency account carried in
the base currency, will produce a bridge that can never balance. State the account name, the
currency, and the date on both sides before going further.

If the statement balance is not available, **stop and say so here** — do not proceed to build a
bridge with one side missing and present it as a reconciliation. Continue instead with the
book-side preparation described at the top of this file, clearly labelled.

## Step 2 — Build the reconciliation bridge

Two ladders that must meet in the middle.

```
Bank statement ending balance
+ Deposits in transit
- Outstanding checks / payments
+/- Bank errors (rare; document)
= Adjusted bank balance

Book balance (GL ending balance)
+ Bank interest and other credits not recorded
- Bank fees and other debits not recorded
+/- Errors on books
= Adjusted book balance
```

**Adjusted bank balance must equal adjusted book balance.**

- **Deposits in transit** — money you banked that the bank hasn't credited yet. **[gated]**:
  the deposits are **[auto]** (*`search_deposits`*), but *which* are still in transit needs the
  statement. Without it, list them as **candidates** by date.
- **Outstanding cheques / payments** — payments you issued that haven't been cashed. Same split:
  the payments are **[auto]** (*`search_bill_payments`*, *`search_purchases`*); which are still
  outstanding needs the statement.
- **Bank errors** — rare, and **[manual]**. Document them; banks do make mistakes and they are
  worth pursuing.
- **Interest and credits not recorded / fees and debits not recorded** — **[manual]** to identify
  without the statement, since by definition they are not in the books. This is the same blind
  spot a dedicated bank-fee and interest review has: the books cannot show what only the
  statement knows.
- **Errors on books** — **[auto]** and the strongest automated contribution here: duplicates,
  wrong amounts, wrong dates, wrong accounts, all detectable in the ledger alone.

## Step 3 — Match transactions (bank vs GL)

Work down the methods; record which one produced each match, because a level-1 match and a level-4
match carry very different confidence.

Matching process — **[gated]**, requiring both sides:

1. **Exact amount + date window match** (same day to ± 3 business days) — the strongest.
2. **Exact amount + fuzzy description match** — for when the bank's wording differs from yours.
3. **Reference match** (cheque number, ACH ID, wire reference, merchant descriptor) — often the
   most reliable of all where the reference survives on both sides.
4. **Split / combined matches** — one bank line covering several book entries, or vice versa.
   Common with batched deposits and card settlements, and the level where false matches start.

**[auto]** even without a statement: run the *book side against itself* to find duplicates — the
same amount, counterparty and date recorded twice. That is not matching, but it removes a
frequent cause of an unbalanced bridge before the statement even arrives.

## Step 4 — Classify all unmatched items

**Unmatched bank items** — **[manual]** without the statement, since these are things only the
bank knows:

- **Bank fees**
- **Interest earned**
- **Returned items / NSF** — a customer's payment bounced ("non-sufficient funds")
- **Chargebacks** — a card issuer reversing a payment
- **Merchant processor netting / reserves** — the processor taking its fee before paying you, or
  holding back a reserve
- **Loan payments (principal / interest)** — often taken automatically by direct debit
- **FX gains / losses** (if applicable)
- **Unknown (needs research)** — an honest category; give it an owner and a date

**Unmatched GL items** — **[auto]** to list, **[gated]** to classify:

- **Deposits in transit**
- **Outstanding checks**
- **Timing differences**
- **Book errors** — duplicate entry, wrong account, wrong amount, wrong date. **[auto]** to detect
  all four from the ledger alone (*`get_general_ledger`*, *`search_journal_entries`*), which makes
  this the part of Step 4 that can be completed before the statement arrives

## Step 5 — Propose corrections / journal entries

`DR` is a debit, `CR` a credit; every entry balances. **Mosofin does not post** — these are
proposals.

JE templates:

**Record bank fee**
```
DR Bank Fees Expense                 XXX
    CR Cash (Bank Account)               XXX
```

**Record interest income**
```
DR Cash (Bank Account)              XXX
    CR Interest Income                  XXX
```

Use the **real account names from the connected chart of accounts** (*`search_accounts`*,
**[auto]**) rather than the generic labels above, and say which you chose. Every proposed entry
names the statement line that evidences it — an entry proposed without that evidence is a guess
at what the bank did.

## Step 6 — Close out and document

Deliver:

- **Reconciliation summary table** — both ladders, meeting or not meeting
- **Unreconciled items list with owner + next action** — every item, including the "unknown"
  category
- **Proposed JEs with memos and support** — marked as proposals
- **Sign-off checklist** — **[manual]**. Mosofin cannot sign anything. Preparer and reviewer are
  named humans, and they should not be the same person

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them,
ask — explicitly, at that point, not earlier — whether to save this as their own customized
version. A general "yes, go ahead" from earlier does not count.

This runs every month, so the evolution step pays back quickly.

On an explicit yes, persist the **decisions**:

- **The bank account list** — by account name and the entity that owns it, with **masked**
  identifiers only
- **The cutoff policy** — posting cutoffs, deposit processing times, typical cheque clearing
  windows — which sets the Step 3 date windows
- **The escalation ages** — the deposit-in-transit and outstanding-cheque thresholds from Quality
  checks, if the entity uses different ones
- **The materiality threshold** for chasing items
- **Recurring statement items** — the standing monthly fee, the regular loan direct debit, the
  processor's settlement pattern — so each is recognised rather than re-researched every month
- The account mapping for fees, interest and FX
- Where the statement comes from and who supplies it
- The replay recipe: the exact sequence of reads that produced the book side

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference
files; set `datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write
preference files alongside the installed skill.

**Never persist bank account numbers, statement contents, balances, or unreconciled item detail.**
Account numbers are payment credentials and the top fraud target; balances and item lists are the
period's evidence and belong in the close file. Persist the *policy, the thresholds and the
account names*.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks /
Northbrook Trading — Operating account (…4471): cheques clear in ~5 days, escalate DIT over 10
business days" — not "cheques clear in ~5 days". Entities bank differently, and an unlabelled
clearing window applied to the wrong company file mis-ages every item. Record the chosen
**scenario** (single vs multi, and which set) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to
the workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is
the workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences
that is no longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Quality checks

- **Same statement end date on both sides**
- **No duplicates in the GL export** — **[auto]** to test, and worth doing on every run
- **Deposits-in-transit older than 10 business days escalated** — money banked that the bank has
  not credited after two weeks is usually a lost deposit or a booking error, not timing
- **Outstanding checks older than 90 days escalated** — a cheque uncashed for a quarter may be
  lost, may be a duplicate payment about to be made, and in many jurisdictions eventually becomes
  unclaimed property
- **Those two ages are bookkeeping practice, not a published standard.** Adjust them to the
  entity's bank cutoffs and its state's unclaimed-property rules, and record the chosen ages as a
  preference in Step 7
- **Adjusted balances tie to the cent** — not to materiality. A bridge that nearly balances has an
  unidentified item in it

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as
  excluded**, with the consequence stated
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous
  conversation or from this file
- **The output states plainly whether a bank statement was supplied**, and if not, is labelled a
  book-side preparation rather than a reconciliation
- **A book-side total is never presented as a reconciled cash balance**
- Outstanding cheques and deposits in transit identified without a statement are labelled
  **candidates**, never confirmed outstanding items
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool used, and that
  tool's policy, in the coverage sheet
- Every matched item records the matching method that produced it
- Every proposed entry names the statement line that evidences it
- Account names in every proposed JE are the **real names from the connected chart of accounts**
- `mock` status is reported wherever it applies, and **no reconciliation is signed off on mock
  data**
- Every figure traces to a tool result in this conversation or to labelled user-supplied
  evidence; the answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term
  kept alongside
- No internal numeric ids, no raw `data_source_id` values, and **no unmasked bank account
  numbers** appear in anything the user sees or in any persisted preference
- Nothing was written back to any system — every entry is a proposal, and nothing was marked
  cleared or signed off

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`, once per bank account in
scope.

**Multi-entity.** Steps 0–6 run **once per entity and per account**, each call targeting exactly
one `data_source_id`, every balance and item carrying its entity's `display_name`. Then one
cross-entity step:

- **A group cash position summary** — total reconciled cash by entity and account, with each
  entity's reconciliation status shown separately. **Group cash is only as reliable as the least
  reconciled account in it**, so report the status, not just the total.
- **Intercompany transfers appear on both entities' books** — one entity's payment is another's
  receipt. Match them across entities (*`search_transfers`*, *`search_deposits`*) and confirm both
  legs were recorded; a transfer recorded once is a classic cause of an unbalanced bridge at one
  entity and an unexplained credit at the other.
- **A bank account shared across entities** — where several entities genuinely transact through
  one account, no single entity's GL can reconcile to the full statement. Say so explicitly,
  reconcile the statement to the *combined* book activity, and treat the per-entity split as an
  allocation question, not a reconciliation.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each task's verdict per
company file and per account.

---
