# Review Required Before Deployment

Items needing **your decision**, not mine. Grouped by what kind of decision it is.
Nothing in this list is broken — these are calls that are yours to make.

Each item has a **blocks** field saying what it holds up. Several block only the
*public* repo, not a private one.

---

## R1 — Licensing and provenance  ⛔ BLOCKS PUBLIC RELEASE

**Blocks:** public GitHub. Does not block a private repo.
**Applies to:** all 114 skills.

The source pack (`Accounting Automation Complete Pack_v1`) contains **no LICENSE
file, no copyright notice and no terms of use** — I checked the pack root, every
README, and grepped for licence/copyright/redistribution wording. Nothing.

**Absence of a licence is not permission.** By default the author retains
copyright and redistribution is not granted.

Two further facts you should weigh:

1. The pack sits in `competitor_resources/`, and this workspace's own `CLAUDE.md`
   states that folder is **"input for analysis, not deliverable output."**
2. The conversions are substantially transformative — 3.61× expansion, an entirely
   new gate architecture, the verdict system, and Mosofin-specific detections that
   have no source equivalent. **But the domain content was preserved deliberately**
   (edge cases, quality standards, step structures, formulas), because that was the
   brief. So a derivative-work argument is available to the other side.

**I am not qualified to tell you where that lands.** It is a legal question about
a specific commercial product.

**Your options:**

| Option | Consequence |
|---|---|
| **A. Private repo** (recommended first step) | Ship everything now; decide public later. No licensing exposure. |
| **B. Public, after clearing rights** | Confirm you hold redistribution rights, or obtain them, then publish. |
| **C. Public, after a rewrite pass** | Re-derive the domain content from primary sources (FASB/IFRS/IRS) rather than from the pack. Substantial work; removes the question. |
| **D. Public as-is on a transformation argument** | Your call and your risk. I'd want counsel on it first. |

**Recommendation: A now, decide between B/C later.** The deployment plan is built
to work either way — nothing in it changes except the repo visibility flag.

---

## R2 — Regulated advice adjacency (13 skills)

**Blocks:** Wave 4 tax/valuation tranche.

These skills produce output a reader could act on in a regulated context. I wrote
professional-advice boundaries into each — **you need to confirm the wording is what
Mosofin wants to stand behind**, because it is a statement about the limits of your
product.

`tax-planning-and-projections` · `tax-return-prep-corporate` ·
`personal-tax-return-prep` · `corporate-tax-provision-asc740` ·
`income-tax-deferred-tax-rollforward` · `r-and-d-tax-credit` ·
`sales-tax-us-multistate` · `vat-gst-international` ·
`transfer-pricing-documentation` · `business-valuation` ·
`valuation-agent-dcf-comps-football-field` · `due-diligence-quality-of-earnings` ·
`aml-kyc-procedures`

**Representative wording I used** (from `tax-planning-and-projections`):

> Mosofin produces **projections and illustrations**, not advice. A qualified
> professional signs off before anybody acts.

and from `valuation-agent-dcf-comps-football-field`:

> Mosofin produces valuation analysis. It does not produce an opinion of value,
> and it is not a licensed valuation professional.

**Decide:** accept as written / strengthen / route through counsel / add a
repo-level disclaimer instead of per-skill.

---

## R3 — Third-party product naming (2 files)

**Blocks:** publishing `quickbooks-ar-aging-collections`.

- **`quickbooks-ar-aging-collections`** — a third-party product name is in the
  **skill name itself**, so it appears in the repo path, the marketplace listing
  and any URL.
- **`quickbooks-ar-aging-collections/references/quickbooks-mcp-readonly.md`** —
  retains five links to Intuit's public developer documentation. Links to public
  docs are ordinarily fine; the naming is the question.

**Note:** I already removed the hashed client-side tool IDs
(`mcp__codex_apps__intuit_quickbooks_...`) from that reference during conversion,
because they were wrong under the gateway and go stale silently.

**Decide:** keep the name / rename to something like `ar-aging-collections-qbo` /
fold into the generic `ar-aging-and-collections` with a QuickBooks section.

---

## R4 — Sensitive personal data in scope (8 skills)

**Blocks:** nothing technically — but these deserve a privacy read before they are
publicly associated with Mosofin.

| Skill | What it handles |
|---|---|
| `vendor-onboarding-and-w9-tin` | Bank account details, tax identifiers, and — per its own edge case 10 — passport / national ID |
| `restructuring-and-severance-asc420` | Named lists of people about to be made redundant, frequently pre-announcement |
| `personal-tax-return-prep` | An individual's tax position |
| `aml-kyc-procedures` | Identity and screening data |
| `payroll-journal-entry-builder`, `payroll-reconciliation`, `payroll-clearing-reconciliation`, `payroll-tax-filings` | Employee-level compensation data |

I wrote data-handling notes into each — for example, in
`vendor-onboarding-and-w9-tin`:

> Mosofin reads what is already recorded. It does not enter, transmit, or reproduce
> banking or identity details anywhere outside the deliverable […] and where an
> analysis can be done on a masked or partial identifier, it should be.

and in `restructuring-and-severance-asc420` I directed the working paper to be built
**by cost type and headcount rather than by name** wherever the accounting permits.

**Decide:** are these sufficient, or does Mosofin need a standard data-handling
clause applied uniformly across the pack?

---

## R5 — Places I departed from the source (5 items)

Small, specific and deliberate. You should sanction them because they are cases
where I judged the source wrong or incomplete, rather than merely converting it.

| # | Skill | What I did | Why |
|---|---|---|---|
| 1 | `three-way-match` | Re-classified exception 7, *"item received not billed"*, from the source's **Information** severity to **also a period-end accrual item** | Goods received and not invoiced is a liability. It must be accrued at period end whether or not the invoice arrived. Correct as AP triage; incomplete as accounting. |
| 2 | `foreign-currency-translation-asc830` | **Recovered hyperinflation content** (IAS 29 vs ASC 830) that the source's own `description` promised but its body never delivered | The description advertised it. Shipping without it would have been a broken promise in the metadata. |
| 3 | `subsequent-events-asc855` | Added ASC 855's **US spellings** (*recognized* / *nonrecognized*) alongside the British house spelling | They are the standard's defined terms; a reader searching the exact term should find it. |
| 4 | Six tax skills | Extended the source's own **"never hardcode rates"** rule to also cover **capability maps** | Identical failure mode, different subject: a stored rate and a stored capability map are both wrong the first time they change, and both fail silently. |
| 5 | ~30 skills | Added a **Step 0 diagnostic** with no source equivalent — all explicitly marked *"(Mosofin addition)"* | This is the brief, not a deviation. Listed for completeness so nothing is a surprise. |

**Decide:** accept all / revert any.

---

## R6 — House-style variance  ⚠️ REPO-WIDE

**Blocks:** nothing. Cosmetic, but visible to anyone browsing the repo.

The pack has **two section-naming conventions**, split by when each file was written:

| | Files 1–82 | Files 83–114 |
|---|---|---|
| Lifecycle | `## Step N — Evolve the skill` | `## Seed to evolved` |
| Coverage | inside `## Tool reference` / step | `## Coverage and Provenance sheet` |
| Cautions | inline + `## Pitfalls` | `## Anti-patterns` |
| Plain language | `## Plain-language glossary` (dedicated) | handled inline |
| Cross-refs | inline | `## Related skills` table |

**Both satisfy every requirement of the conversion brief** — the validator passes
114/114 against either. Only the *names* differ.

**Decide:**

| Option | Cost |
|---|---|
| **A. Leave it, document the two styles** | Free. Slight inconsistency when browsing. |
| **B. Normalise the 32 newer → older style** | Smaller edit; loses the `Related skills` tables and explicit `Anti-patterns` sections |
| **C. Normalise the 82 older → newer style** | Larger edit; the newer style has the dedicated coverage sheet and anti-pattern sections. **My recommendation if you want uniformity.** |

I did not normalise unprompted — it would rewrite 82 already-conformant files.

---

## Decision summary

Tick these off and Wave 1 can ship the same day:

- [ ] **R1** Repo visibility: private now? *(unblocks everything)*
- [ ] **R6** House style: leave / normalise which direction?
- [ ] **Dedupe:** `three-way-match` vs `ap-invoice-processing-and-3way-match`; `cash-application` vs `ar-cash-application-lockbox`
- [ ] **R5** Accept the five source departures?
- [ ] **R2** Advice-boundary wording approved? *(gates Wave 4 tax/valuation)*
- [ ] **R3** `quickbooks-*` naming: keep / rename / merge?
- [ ] **R4** Uniform data-handling clause needed?

**Only R1 and R6 block Wave 1.** R2–R4 gate Wave 4. R5 is a sanity check.
