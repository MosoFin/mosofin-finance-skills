<!-- duplicate-invoice-detection · method.md · read for: Stages 3–6 — Steps 0–1 read and normalize, Steps 2–4 run the rules and alias checks, Steps 5–6 assess recovery and present, Step 7 saves; plus both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding)
- Step 1 — Normalize the data
- Step 2 — Apply duplicate-detection rules
- Step 3 — Sensitivity tuning
- Step 4 — Vendor alias detection
- Step 5 — Recoverability assessment
- Step 6 — Output
- Step 7 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a rule because no tool covers it.** Rule 7 is `[manual]` and must still appear in the output,
marked as not run.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding)

Pull the `[auto]` / `[gated]` reads. **Batch independent reads into one message** — bills, payments,
vendors and credits do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_bills`* — **the whole bill population for the period**, paginated to completion — usually
  **[auto]**
- *`get-bill`* — one bill's detail: number, date, amount, PO reference, lines — usually **[auto]**
- *`search_bill_payments`* / *`get_bill_payment`* — **what was actually paid, when, and how** — usually
  **[auto]**
- *`search_purchases`* — direct payments and card charges that bypassed the bill process — usually
  **[auto]**
- *`search_vendors`* / *`get-vendor`* — **the vendor master, including inactive records** — usually
  **[auto]**
- *`search_vendor_credits`* — **credits never applied** (Rule 10) — usually **[auto]**
- *`get_vendor_expenses`* — spend per supplier, for context and clustering — usually **[auto]**
- *`get_aged_payables`* — open items, to separate paid from unpaid duplicates — usually **[auto]**
- *`search_payment_methods`* — how methods are labelled, for Rule 9 — usually **[auto]**
- *`search_purchase_orders`* — PO references, for the same-amount-different-PO edge case — usually
  **[auto]**
- *`get_company_info`* — base currency and year-end — usually **[auto]**

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that rule to **[manual]** and record the gap.
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a duplicate finding accuses someone of an error
or worse**, and a recovery request sent to a real supplier on fixture evidence is embarrassing at best.

## Step 1 — Normalize the data

For each record — **[auto]**:

- **Strip whitespace, normalize case** on vendor name and invoice number
- **Remove punctuation and special characters from invoice numbers** — some systems prefix or suffix
- **Group records by vendor** — use vendor ID as primary; **also link by vendor name fuzzy match for
  aliases**
- **Convert amounts to a common currency for comparison** if the register is multi-currency — **but flag
  any FX-related comparisons separately**

Two additions worth making explicit, because both cause false negatives:

- **Include inactive vendor records** in the master. A duplicate paid through a since-deactivated vendor
  record is exactly the pattern Rule 6 is looking for, and an active-only search will miss it.
- **Include voided and reversed records in the read**, then exclude them from the live scan and report them
  separately — per the edge case. Reading them is how you confirm the void was actually processed.

## Step 2 — Apply duplicate-detection rules

**Run each rule and assign confidence.** Rules ordered from highest confidence to lowest.

**Rule 1 — Exact invoice number + same vendor (Confidence: Very High)** — **[auto]**
Same vendor + identical invoice number = **almost certainly a duplicate entry. Even if dates and amounts
differ slightly, this is highly suspicious.** Flag.

**Rule 2 — Same amount + same vendor + same invoice date (Confidence: High)** — **[auto]**
Same vendor, same date, same amount, different invoice numbers = **could be two legitimate same-day
invoices or could be a duplicate with an altered invoice number.** Flag for review.

**Rule 3 — Same amount + same vendor + dates within N days (Confidence: Medium)** — **[auto]**
**N defaults to 7.** Same vendor, identical amount, near dates = possible duplicate.

**Rule 4 — Same amount + similar vendor name + same period (Confidence: Medium)** — **[auto]**
Vendor name slightly altered — **"Acme Corp" vs "Acme Corporation" vs "Acme Inc."**. Use string-similarity
matching (**Jaro-Winkler ≥ 0.85** or similar). Flag for review. Present the similarity score with each
match so a reviewer can judge it.

**Rule 5 — Invoice number sequence anomaly (Confidence: Medium-Low)** — **[auto]**
Invoice numbers from a vendor **typically increase monotonically. A sudden number out of sequence —
particularly a number lower than ones already paid — is suspicious.** Flag.

**Rule 6 — Same invoice number across different vendor IDs (Confidence: High)** — **[auto]**
Same invoice number paid to different vendor records = **likely a vendor master duplicate** (two vendor
records for the same vendor) **AND a duplicate payment**. Two findings from one match.

**Rule 7 — Same bank account, different vendors (Confidence: High)** — **`[manual]` — CANNOT RUN HERE**
Two vendor records sharing one bank account = **likely either the same vendor under two records or a fraud
setup. Flag both.**

**This rule cannot be executed from a Mosofin workspace.** Vendor bank details are not exposed on this
surface. **It must be run in the AP or banking system directly**, and it should be — it is the highest-value
fraud test in the list. **Report it as not run**, with a named owner, rather than omitting it.

**Rule 8 — Round-number duplicate amounts within short windows (Confidence: Low)** — **[auto]**
**Many vendors do issue same-amount recurring invoices (rent, subscriptions). Don't auto-flag, but check
for an above-threshold cluster.**

**Rule 9 — Identical invoice attributes but one paid via cheque, one via wire (Confidence: High)** —
**[gated]**
**Paid through two channels = classic duplicate-payment pattern.** The payment method is recorded in most
systems (*`search_bill_payments`*, *`search_payment_methods`*); where it is not, this rule degrades to
Rule 2 and should be marked as such.

**Rule 10 — Credit memo never applied (Confidence: Low for duplicate, but flag for AP hygiene)** —
**[auto]**
**A credit memo sitting open while subsequent invoices to the same vendor were paid in full = the credit
was never applied. Not a duplicate per se but worth surfacing** — and worth surfacing prominently, because
**it is money the entity is owed and has not taken.** See `credit-memo-and-refund-handler`.

## Step 3 — Sensitivity tuning

- **Strict**: flag any rule match with **Medium+** confidence
- **Standard** (default): flag any rule match with **High+** confidence
- **Permissive**: only flag **Very High** confidence matches

**[manual]** to set; **[auto]** to apply. **State the setting used on the output** — a "clean" result under
Permissive means something very different from a clean result under Strict, and the two are
indistinguishable without the label.

## Step 4 — Vendor alias detection

For each suspected duplicate, also check whether the vendors involved should be **merged in the vendor
master** — verdicts differ per check:

- **Same legal name with formatting differences** — **[auto]**
- **Same tax ID across different vendor records** — **[gated]**: readable where the vendor record carries a
  tax identifier; **[manual]** where it does not
- **Same bank account** — **[manual]**, per Rule 7
- **Same remit-to address** — **[auto]** where the address is on the vendor record, and a useful
  substitute signal for the bank-account test: **two vendor records at one address is the same shape of
  finding**, even though it is weaker evidence

**If so, recommend a vendor master merge plus retroactive duplicate cleanup.** Mosofin cannot merge
records — this is a proposal, and merging vendors is not reversible in most systems, so it warrants care.

## Step 5 — Recoverability assessment

For confirmed duplicates that have already been paid — **[auto]** to determine paid status
(*`search_bill_payments`*, *`get_aged_payables`*):

- **Status: paid out of the business**
- **Recovery options:**
  - **Vendor credit on the next invoice** — preferred; most cooperative vendors will issue a credit memo
  - **Refund from the vendor** — request explicitly
  - **Set off against an open balance** — **[auto]** to check whether one exists, which decides whether
    this option is even available
- **For open (unpaid) duplicates, simply void or remove the duplicate before payment** — and these are the
  valuable ones: **a duplicate caught before payment costs nothing to fix.** Sort the output so unpaid
  duplicates appear first

**Quantify the dollar exposure: total amount in flagged duplicates by confidence level.**

## Step 6 — Output

Deliver an `.xlsx` workpaper.

**Sheet 1: Summary**

- **Period scanned, record count** — and **state the population scanned versus the population available**,
  so a truncated scan is visible
- **Total flagged by confidence level**
- **Total exposure ($) by confidence level**
- **Already-paid vs. open**
- **Recovery actions proposed**

Add a header block: workspace name; each in-scope company file by `display_name`; each excluded one and
why; **the sensitivity setting used**; **that Rule 7 was not run**; whether any figure rests on `mock`
data.

**Sheet 2: Flagged Pairs (and Groups)**

| Cluster ID | Vendor (Primary) | Records in Cluster | Rule Matched | Confidence | Amount per Record | Cluster Total | Paid Status | Recovery Action |

**Each cluster expanded to show the 2+ underlying records side by side** — this is what lets a reviewer
agree or dismiss in seconds rather than investigating.

**Sheet 3: Detail**

Per-record fields including **everything used to match**: vendor name (raw + normalized), invoice # (raw +
normalized), date, amount, payment method, payment date, status.

**Sheet 4: Vendor Aliases to Merge**

| Alias Group | Vendor IDs | Vendor Names | Recommended Master Record | Justification |

**Sheet 5: Recovery Plan**

Per cluster, the recommended action and the contact to pursue it. **Unpaid duplicates first.**

**Sheet 6: Rules Run — NEW, Mosofin-specific**

| Rule | Verdict (auto / gated / manual — not run) | Records evaluated | Matches found | Note |

**Rule 7 appears here marked not run, with its owner.** A rules-run sheet is what turns "no duplicates
found" into a defensible statement.

**Sheet 7: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict | Tool used | Population scanned | Policy | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `Duplicate_Invoice_Scan_[YYYY-MM-DD].xlsx`

In a multi-entity run: `Duplicate_Invoice_Scan_[YYYY-MM-DD]_[EntityDisplayName].xlsx`, plus one
cross-entity file. Every file states which datasource and `display_name` it covers.

**Grounding:** every figure traces to a tool result in this conversation or to labelled user-supplied
evidence. End with a single **Data sources** line grouping calls by datasource. Where a rule could not be
run, **say so** rather than reporting it as finding nothing.

## Step 7 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

This is a scan that should run every month, so the evolution step matters: **without it, the same false
positives come back every time and the report stops being read.**

On an explicit yes, persist the **decisions**:

- **Cleared clusters** — pairs and groups reviewed and dismissed, with the reason and the date. **The
  single most valuable artefact here**, because a recurring false positive is what kills a control report
- **Known legitimate recurring suppliers** — rent, subscriptions, retainers — so Rule 8 stays quiet
- **Confirmed vendor aliases** that have been merged, and those deliberately kept separate
- **The sensitivity setting** and the Rule 3 date window
- **The recovery playbook** — who to contact per supplier, and whether they prefer credit or refund
- **Whether Rule 7 is run elsewhere**, by whom, and how often
- The replay recipe: the exact sequence of reads that produced the population

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist vendor bank details, invoice-level data, or any suspicion attached to a named person.** Bank
details are the fraud target this skill exists to protect; **a stored note that a named employee's
transactions were flagged is an allegation**, and duplicates are usually error rather than misconduct.
Persist **cleared cluster references and supplier-level settings**, not the accusations.

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — recurring at fixed amount: landlord, insurer, three SaaS suppliers; sensitivity Standard; Rule 3
window 7 days" — not "sensitivity Standard". Suppliers and billing patterns differ by entity, and an
unlabelled recurring-supplier list applied to the wrong company file suppresses real duplicates. Record the
chosen **scenario** (single vs multi, and whether cross-entity scanning applies) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One population, one rule set.

**Multi-entity.** Steps 0–6 run **once per entity**, each call targeting exactly one `data_source_id`,
every cluster carrying its entity's `display_name`. **Then run the cross-entity scan**, which finds
duplicates no single-entity scan can:

- **The same supplier invoice paid by two group entities.** Common wherever suppliers serve several group
  companies and AP is decentralised — and **completely invisible to each entity's own scan**, because each
  sees only one payment. Match on **vendor name plus invoice number plus amount across entities**; Rule 1
  applied across the group is the highest-value cross-entity test available.
- **A supplier existing under different vendor records in different entities** is normal and expected —
  do not propose merging vendor masters across legal entities. The alias analysis is *within* an entity;
  the duplicate analysis is *across*.
- **An invoice legitimately split between entities** — a shared service recharged in parts — is not a
  duplicate. Check whether the amounts sum to the invoice total rather than each equalling it.
- **Intercompany invoices** between group entities will match themselves across the two sets of books by
  construction. Exclude group entities from the counterparty population before running the cross-entity
  scan, or every intercompany charge appears as a duplicate.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each rule's verdict per company
file.

---
