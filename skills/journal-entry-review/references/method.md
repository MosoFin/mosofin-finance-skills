<!-- journal-entry-review · method.md · read for: Stages 3–6 — every Step of the review (0–9), and both entity scenarios. Edit here, not in SKILL.md. -->

## Contents

- PART B — The domain work
- Step 0 — Fetch the evidence (grounding) — Mosofin addition
- Step 1 — Understand the JE population
- Step 2 — Define risk characteristics
- Step 3 — Score and flag entries
- Step 4 — Analyze flagged entries
- Step 5 — Pattern and trend analysis
- Step 6 — Document and follow up
- Step 7 — Assess control implications
- Step 8 — Output
- Step 9 — Evolve the skill (Mosofin-specific, final step)
- Both entity scenarios


# PART B — The domain work

Every step below is the original procedure, unchanged in count, order, or substance, with plain-language
wording, an `[auto]` / `[gated]` / `[manual]` verdict, and the typical evidence tool added.

**Never drop a task because no tool covers it.** The approval-based criteria are legitimately unavailable
where approval data is not exposed, and they are recorded as not run rather than omitted.

Tool names in *italics* are typical. Resolve real names and policies from your Gate 2 catalog.

## Step 0 — Fetch the evidence (grounding) — Mosofin addition

**Batch independent reads into one message** — the entry population, the chart and the comparative history
do not depend on each other. Never serialize them.

The server is **stateless**: pass `data_source_id` on **every** call, including retries.

Typical opening batch, per in-scope entity:

- *`search_journal_entries`* **for the period** — **the population, in full** — usually **[auto]**
- *`get_journal_entry`* on individual entries — line detail where the search result is summary — usually
  **[auto]**
- *`search_accounts`* — **the chart with account types**, which drives the account-combination criteria —
  usually **[auto]**
- *`get_general_ledger`* — **entries by account, and dormant-account detection** — usually **[auto]**
- *`search_journal_entries`* **for prior periods** — **the baseline for "normal"**, and the pattern
  population — usually **[auto]**
- *`get_profit_and_loss`* / *`get_balance_sheet`* by period — **for the reserves-move-with-earnings test** —
  usually **[auto]**
- *`get_company_info`* — legal name, **period ends** — usually **[auto]**
- *`search_journal_entries`* **for the first month after the period** — **reversal pairs and post-close
  entries** — usually **[auto]**

**Pull prior periods deliberately.** **"Unusual" is meaningless without a baseline**, and Step 5's patterns
need several periods by construction.

Handle the envelopes:

- `approval_required` → **reads only:** if the tool reads, ask the user in chat, then re-invoke the same
  tool with `approved=true`. **If it would write, never re-invoke** — record it as refused and stay on the
  read path; see the hard stop in Gate 2.
- `entity_required` → ask by `display_name`, then pass that `data_source_id`.
- `tool_policy_disabled` → convert that criterion to **[manual]** and **record which criteria are therefore
  not tested.**
- `UNKNOWN_TOOL` → read the valid names from the error; do not guess.
- Dead connection → surface the `reconnect_url`.

Check the **`mock` flag**. `mock: true` is fixture data — **a JE review over fixtures produces fictional
anomalies attributed to real-sounding users.** Stop.

## Step 1 — Understand the JE population

**Prove the population first** (AU-C 240.32 and A47–A48; PCAOB AS 2401.58–61). Sum the debits and credits
of the extracted entries by account and agree them to the period's movement — *`get_general_ledger`* on the
Mosofin path, the opening and closing trial balance on the upload path. **Report the difference.** A
journal-entry search on QuickBooks Online or Xero returns only Journal Entry / Manual Journal transactions:
hand-keyed deposits, cheques or spend money, transfers and inventory adjustments fall outside it. **Say so**,
and either screen the full transaction journal (all transaction types — the GL detail, or on upload the QBO
*Journal* report / Xero *Journal Report*) or state that those manual transaction types are outside the
screen. **The screen is "complete" only when this tie-out is nil**; otherwise "N entries screened; population
not proven complete — difference $X".

**Profile the population** — **[auto]** throughout:

- **Total number and value of entries**
- **Split by source: system-generated** (automated, lower risk) **vs. manual** (higher risk — **the focus of
  most review**). From a journal-entry-type read alone this split cannot be computed — everything it returns
  is manual by type; it needs the transaction type from the full journal
- **By account, by user, by period**
- **Normal patterns**, so anomalies stand out

**Manual journal entries are the primary focus — they bypass routine controls and are where errors and
manipulation concentrate.**

**Mosofin addition — derive "normal" rather than asking for it.** The original lists *"expected posting
patterns"* as a recommended input. **[auto]**: **read several prior periods and compute them** — entries per
period, value, the manual proportion, the usual posters, the usual accounts, the usual timing. **A baseline
measured from this entity's own history is better than an expectation someone states**, and it makes every
subsequent "unusual" judgment concrete.

**Report the profile before the flags.** A population that is 4% manual behaves differently from one that is
60% manual, and the review's emphasis should follow.

## Step 2 — Define risk characteristics

**Screen entries against characteristics associated with error or manipulation.** Each indicator carries its
verdict:

### Timing

- **Entries posted at period-end or after the close cutoff** — to hit targets — **[auto]** for period-end;
  **after the close cutoff needs the close date from Stage 1**, otherwise **NOT RUN**
- **Entries posted on weekends / holidays or outside business hours** — **[gated]**: **weekends are `[auto]`
  from the date; hours need a timestamp**, which may not be exposed
- **Back-dated entries** — **created date/time later than the transaction date**, especially into a period
  before the close date — **[gated]**: runs only where a created timestamp is returned (QBO: Create date /
  Created by; Xero: Created / Posted columns); otherwise **NOT RUN**. **One of the strongest single
  indicators available**, and it depends entirely on the field being present
- **Entries to prior closed periods** — **[gated]**: needs the closed-through date from Stage 1; without it
  **NOT RUN**

### Account combinations

- **Entries hitting revenue, earnings, or reserves directly** — **[auto]** from account types
- **Unusual account pairings** — revenue credited against a non-customer account; expense reclassified to a
  balance sheet account — **[auto]**: **account types make the pairing computable**
- **Entries to suspense, clearing, or rarely-used accounts** — **[auto]**
- **Entries crossing to equity or directly to retained earnings** — **[auto]**

### Amounts

- **Round-dollar or even amounts** — e.g. exactly 50,000 — **[auto]**
- **Amounts just below approval / authorization thresholds** — **[gated]**: **the test is `[auto]`, the
  threshold is `[manual]`.** Ask for it; the test is meaningless without it
- **Large / material entries** — **[gated]**; the threshold is `[manual]`
- **Entries that net to zero across suspicious accounts** — **[auto]**

### People and process

- **Entries by users who don't normally post** — e.g. senior management overriding — **[gated]**: **`[auto]`
  where a user field exists and a baseline of usual posters has been derived**; **a user name is not a
  person**
- **Entries lacking approval** — **[manual]**. **Approval data is generally not on this surface. NOT RUN**
- **Self-approved entries** — **[manual]**. **NOT RUN** without approval data
- **Entries with missing, vague, or generic descriptions** — "adjustment," "reclass," blank — **[auto]**,
  and a good one: a length-and-content test over the memo field
- **One person both posting and approving the same entry** — **[manual]**. **NOT RUN** without approval data
- **Segregation of duties (SoD) across the user population** — who can both post and approve — **[manual]**.
  **NOT RUN** without approval data

### Other

- **Reversing entries that aren't re-posted** (or vice versa) — **[auto]**: **trace reversal pairs across
  periods**
- **Duplicate entries** — **[auto]**; see `duplicate-invoice-detection` for the matching discipline
- **Entries to seldom-used or dormant accounts** — **[auto]**: account activity frequency is readable

**Of the twenty-one indicators, ten run as queries, seven need a threshold or a field (a close date, a
timestamp, a user field) and four depend on approval data that is generally unavailable.** Where the user
has said no approval step exists (Stage 1, G), record the four as **"Control not in place"** in Sheet 7;
otherwise **report the four as NOT RUN** — and note that **they are precisely the segregation-of-duties
indicators**, which is a meaningful hole in a control-focused review, not a rounding error.

## Step 3 — Score and flag entries

**Apply the characteristics to the population** — **[auto]**:

- **Flag entries meeting one or more risk criteria**
- **Assign a risk score** — more or weightier criteria = higher score
- **Prioritize the highest-risk entries for review**

**Don't try to review every entry — screening focuses attention on the ones that matter.**

**Mosofin refinement of that last sentence: screen every entry, review the top.** The screen is complete;
the review is prioritised. **State both numbers.**

**On weighting**: **a single criterion is usually noise.** A round-number accrual at period end is a
description of most accruals. **Weight combinations** — round amount *and* posted by an unusual user *and*
to a reserve account — and **say what the weighting was**, so the score is interpretable rather than
oracular.

## Step 4 — Analyze flagged entries

For each high-priority flagged entry — **[gated]**, and the split matters:

- **Examine the description and supporting documentation** — description **[auto]**, **documentation
  `[manual]`**
- **Assess business rationale** — is there a legitimate reason? — **[manual]**
- **Check approval and segregation** — **[manual]**; not on this surface
- **Verify it ties to underlying support** — **[gated]**: **where the support is another transaction in the
  system it is findable**; where it is a contract or a calculation, it is not
- **Determine whether it's: clearly legitimate, needs explanation, or genuinely anomalous** — **[manual]**
  judgment

**Three of five need a person.** **The screen finds candidates; the analysis is where they are resolved**,
and it cannot be automated away.

## Step 5 — Pattern and trend analysis

**Beyond individual entries, look for patterns** — **[auto]** throughout, and **this is the strongest area
of the skill**:

- **A user with a cluster of high-risk entries** — **[auto]**, subject to the user-name caveat
- **Recurring period-end adjustments to the same accounts** — **[auto]**, and often the most revealing:
  the same account adjusted every quarter-end by a manual entry is a process problem at minimum
- **Entries that consistently move results toward a target** — e.g. always just enough to hit a number —
  **[auto]**: **compute the pre-entry and post-entry result and look at the direction and the proximity to
  round or threshold figures**
- **Increasing manual entry volume to a sensitive account over time** — **[auto]**
- **Reserves / accruals that move suspiciously with earnings** — **[auto]**, and **the same test a
  fraud investigation runs**: plot reserve movements against pre-reserve profit across periods. **A
  reserve that reliably moves in the smoothing direction is an indicator worth investigating**

**Patterns are often more telling than single entries.** **And they require the full population and several
periods** — which is exactly what the workspace makes cheap. **Lead the output with them.**

## Step 6 — Document and follow up

For each item requiring follow-up — **[gated]**:

- **The entry detail** — **[auto]**
- **Why it was flagged** — which criteria — **[auto]**
- **The explanation obtained (or outstanding)** — **[manual]**
- **Resolution: legitimate** (with rationale), **error** (correction needed), **or escalate** — potential
  impropriety → a fraud investigation

**On escalation**: **the fraud skill's rules apply from the moment you escalate** — objectivity, no
accusation, evidence preservation as a separate discipline, and **no approval prompt to someone within
scope.** Read it before proceeding.

## Step 7 — Assess control implications

**The review informs control assessment** (the kind a SOX controls review performs) — **[gated]**:

- **Are JE approval controls operating?** — **[manual]**; **the review cannot answer this without approval
  data**, and saying so *is* the control observation. **If the user says no approval step exists, that is a
  control finding in its own right** (a design deficiency, in AU-C 265 terms) — record "Control not in place",
  not NOT RUN
- **Is SoD enforced (post vs. approve)?** — **[manual]**; same
- **Are descriptions and support required and present?** — **descriptions `[auto]`**, support `[manual]`.
  **The proportion of entries with blank or generic descriptions is a directly measurable control
  indicator**
- **Should certain accounts / users have tighter controls?** — **[gated]**; the concentration data is
  `[auto]`, the recommendation is judgment

**The measurable control observations are worth stating numerically**: "38% of manual entries carried a
description of three words or fewer" is a control finding with a number attached, and it is more useful than
an assertion that documentation is weak.

## Step 8 — Output

Deliver an `.xlsx` review workpaper:

**Sheet 1: Population Profile** — **volume / value, manual vs. system, by account / user / period.** Add
**the derived baseline** from prior periods. Plus the header block: workspace name; the entity by
`display_name`; excluded company files; **the population size and the Step 1 tie-out — "screen complete"
only when the difference is nil, otherwise "population not proven complete — difference $X"**, and which
transaction types were in the screen; whether any read returned `mock` data; **and whether topside entries are in the population**.

**Sheet 2: Risk Criteria & Screening** — **the criteria applied and how many entries each flagged.** Add
**the verdict per criterion**, and **a clearly separated block for criteria NOT RUN**, with the reason.

**Sheet 3: Flagged Entries (Risk-Scored)**

| JE# | Date | Posted By | Approved By | Accounts | Amount | Criteria Met | Risk Score | Description | Status |

**Sorted by risk score.** The **Approved By** column is retained and **populated as "not available" where
approval data is not exposed** — the column's emptiness is itself information.

**Sheet 4: Detailed Review** — analysis of high-priority entries with explanation and resolution.

**Sheet 5: Patterns & Trends** — **clusters and recurring patterns identified.** **Lead with this sheet in
any summary**; it is where the workspace contributes most.

**Sheet 6: Follow-Up & Escalation** — items needing explanation, correction, or escalation.

| JE# | Why flagged | Asked of (role) | Date asked | Due | Support obtained (document ref) | Resolution | Reviewed by / date |

**Sheet 7: Control Observations** — implications for JE controls, **with the measurable ones quantified**.

**Sheet 8: Criteria Not Run — NEW, Mosofin-specific**

| Criterion | Why it could not run | What it would have shown | How to obtain it |

**The four approval-based indicators, and any criterion lost to a missing field or a `disabled` tool.**
**A clean Sheet 3 alongside an empty Sheet 8 would misrepresent the coverage.**

**Sheet 9: Coverage — NEW, Mosofin-specific**

| Task | Entity (`display_name`) | Verdict (auto / gated / manual) | Tool used / external source | Population and size | As-at date | `mock` | Gap |

Ask the user whether they want this workpaper as an Excel (`.xlsx`) file, and create it only on a yes, using the file name given for this skill. If they decline, or the host cannot make spreadsheets, give the same sheets as tables in the chat.

**File naming:** `JE_Review_[Period]_[EntityName].xlsx`

Every file states which datasource and `display_name` it covers.

**Grounding:** every flagged entry traces to a tool result in this conversation. End with a single **Data
sources** line grouping calls by datasource. Where a criterion could not run, **name it** rather than
omitting it.

## Step 9 — Evolve the skill (Mosofin-specific, final step)

**The file you installed is a seed.** After the user has **seen the results** and approved them, ask —
explicitly, at that point, not earlier — whether to save this as their own customized version. A general
"yes, go ahead" from earlier does not count.

On an explicit yes, persist the **method**:

- **The criteria set** in use for this entity, and **which criteria cannot run here** and why
- **The scoring weights**, so scores are comparable between periods
- **The sensitive-account list** — which accounts count as revenue, reserves, equity, suspense here
- **The authorization and materiality thresholds**, with effective dates
- **The baseline definition** — how many prior periods, and which measures
- **The cleared-pattern rules** — expressed as rules, never as entries: "the monthly depreciation journal
  is system-generated from a schedule and is expected at period end" is a rule; **a list of specific
  entries is not**
- **The escalation path** and the authorized recipients, **by role**
- **Where topside entries live**, if outside this system
- The replay recipe: the exact sequence of reads that produced the population and the baseline

Save via `create_skill` — bundle `SKILL.md`, `references/run-recipe.json`, and the preference files; set
`datasources=` to match the recipe; no `.html`, `.css`, or `.svg` files. Or write preference files
alongside the installed skill.

**Never persist flagged entries, risk scores, user names, explanations or any anomaly.** **These are
observations about how identifiable people did their jobs**, most of which will turn out to be entirely
proper. **A flag carried forward outside a formal tracker, unrebutted and unclosed, becomes a permanent mark
on someone who was never told** — the same rule a fraud investigation follows. **Persist the method;
never the results.**

**Key every preference and asset by datasource + entity `display_name`.** Write "quickbooks / Northbrook
Trading — sensitive accounts 4000–4999, 2400–2450, 3200; authorization threshold 10,000 from 2025-04-01;
baseline 6 prior periods; approval criteria not testable" — not "threshold 10,000". Record the chosen
**scenario** (single vs multi) as a preference too.

**Never persist state.** Connections, company files, tool policies, and `mock` status belong to the
workspace and are re-discovered by Gates 1–2 every run. **Decisions are the user's; state is the
workspace's.**

On later runs, match stored entity names against Gate 1's live list. An entity in preferences that is no
longer connected is **flagged as unscreened** — never silently dropped, never applied elsewhere.

---

## Both entity scenarios

**Single-entity.** The workflow above against one `data_source_id`. One population, screened completely.

**Multi-entity.** Steps 0–8 run **once per entity**, each call targeting exactly one `data_source_id`, every
entry and flag carrying its entity's `display_name`. Then:

- **Screen each entity separately, against its own baseline.** **Normal differs by entity** — a subsidiary
  with three staff has a different posting pattern from a shared service centre, and **one baseline across
  the group would flag the small entity's every entry.**
- **Sensitive accounts differ by chart.** The account-combination criteria are chart-specific; **store the
  sensitive list per entity.**
- **A user posting across several entities is worth noting** — **[gated]**, where user fields exist. It may
  be a shared finance team, which is normal, or access nobody intended.
- **Topside and consolidation entries sit above the entities**, often in a separate system. **They are the
  highest-risk population and the least visible** — see the edge cases. **If they are not in any connected
  file, say so.**
- **Intercompany entries appear in two populations**, and **a manual entry on one side with no counterpart
  on the other is both a JE-review flag and an intercompany break** — follow it up in an intercompany reconciliation too.
- **Report flag rates per entity as well as in total.** A group rate averages away the one entity where the
  control has failed, which is the only thing the rate was going to tell you.

Capability is checked **per entity** at Gate 2; the coverage sheet shows each criterion's verdict per
company file.

---
