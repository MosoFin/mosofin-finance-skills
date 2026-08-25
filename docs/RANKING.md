# Skill Ranking — Expected Demand

**What this is:** an ordered view of all 114 skills, used to decide shipping order.

**How honest the numbers are.** One input is computed, the rest is judgment:

| Input | Source |
|---|---|
| **Auto %** | **Computed.** Share of `[auto]` vs `[manual]` verdicts in each converted file. Objective. |
| Reach | Judgment — share of businesses that need the skill at all |
| Cadence | Judgment — daily 5 / weekly 4 / monthly 4 / quarterly 3 / annual 2 / event-driven 1 |
| Payoff | Judgment — finds money, prevents a loss, or removes large manual effort |

**There is no download or market data behind this.** It is a domain-informed
prioritisation, not a measurement. Disagree with any row and re-order — the queue
file is a plain TSV for exactly that reason.

Score = Reach×3 + Cadence×2 + Auto×2 + Payoff×3  (max 50)

---

## Wave 1 — Core Ten

Transactional, high frequency, highest automation ratios, no review blockers.
These are what a first-time user tries, and they are where the connected
workspace visibly does the work.

| # | Skill | Auto % | R | C | A | P | Score | Why it leads |
|---|---|---|---|---|---|---|---|---|
| 1 | `journal-entry-builder` | **79%** | 5 | 5 | 4 | 4 | **45** | Highest automation in the pack; every entry in every business routes through it |
| 2 | `three-way-match` | **75%** | 4 | 5 | 4 | 5 | **45** | Becomes a full-population control instead of a per-invoice check; prevents duplicate payment |
| 3 | `invoice-data-extractor` | **72%** | 5 | 5 | 4 | 4 | **45** | Highest-volume manual task in AP |
| 4 | `gl-coding-assistant` | **72%** | 5 | 5 | 4 | 4 | **45** | Daily, universal; prior mappings become readable history |
| 5 | `duplicate-invoice-detection` | **75%** | 4 | 4 | 4 | 5 | **43** | Directly recovers money; population-wide |
| 6 | `month-end-close-checklist` | 61% | 5 | 4 | 3 | 5 | **44** | The hub — 33 cross-references; scopes itself from the live chart |
| 7 | `bank-reconciliation` | 62% | 5 | 4 | 3 | 5 | **44** | Universal and one of only two genuine *external* reconciliations |
| 8 | `ar-aging-and-collections` | 46% | 5 | 4 | 2 | 5 | **42** | Cash collection. **Lowest auto ratio in Wave 1** — earns its place on reach and payoff, not automation |
| 9 | `expense-report-processor` | 65% | 5 | 5 | 3 | 4 | **43** | High volume, universally disliked |
| 10 | `financial-statement-builder` | 50% | 5 | 4 | 3 | 4 | **41** | The output everything else feeds |

---

## Wave 2 — Recurring finance operations (24)

Monthly or quarterly, broad audience, strong automation. Ships once Wave 1 has
survived contact with real users.

`closing-entries-and-trial-balance` · `balance-sheet-reconciliations` ·
`accruals-and-deferrals` · `ap-accrual-cutoff` · `prepaid-amortization-schedule` ·
`ap-aging-and-payment-runs` · `cash-application` · `ar-cash-application-lockbox` ·
`credit-card-reconciliation` · `vendor-statement-reconciliation` ·
`customer-invoicing` · `credit-memo-and-refund-handler` · `journal-entry-review` ·
`recurring-transaction-builder` · `payroll-journal-entry-builder` ·
`payroll-reconciliation` · `payroll-clearing-reconciliation` ·
`budget-vs-actual-analysis` · `cash-flow-forecast-13-week` ·
`fixed-asset-register-and-depreciation` · `inventory-to-gl-reconciliation` ·
`bad-debt-and-write-offs` · `working-capital-optimization` · `kpi-dashboard-builder`

**Note `working-capital-optimization`:** one of the best workspace fits in the pack
(74 auto / 47 manual) and it finds cash. A case can be made for promoting it to
Wave 1 — see the open question in the deployment plan.

---

## Wave 3 — Standards, reporting and controls (32)

Broad but periodic; more judgment, lower automation, higher expertise signal.
These are what make the pack look credible to a qualified accountant.

`revenue-recognition-asc606` · `lease-accounting-asc842-ifrs16` ·
`intangibles-and-amortization` · `multicurrency-fx-revaluation` ·
`foreign-currency-translation-asc830` · `consolidation-and-eliminations` ·
`intercompany-reconciliation` · `quarter-end-close` · `year-end-close` ·
`cash-flow-statement-indirect-method` · `statement-of-equity-changes` ·
`notes-to-financial-statements` · `chart-of-accounts-designer` ·
`rolling-forecast` · `budget-builder` · `three-statement-financial-model` ·
`model-builder-integrated-three-statement` · `scenario-and-sensitivity-analysis` ·
`inventory-costing-fifo-lifo-wavg` · `inventory-obsolescence-and-reserve` ·
`standard-costing-and-variance-analysis` · `cost-accounting-job-order` ·
`cost-accounting-process-costing` · `fraud-detection-and-forensics` ·
`sox-controls-design-and-testing` · `internal-audit-workpaper` ·
`audit-prep-pbc-list` · `debt-and-covenant-tracking` ·
`cash-management-and-treasury` · `bank-fee-and-interest-analysis` ·
`credit-limit-and-customer-risk` · `customer-credit-and-collections-policy`

---

## Wave 4 — Specialist, regulated and review-gated (48)

Narrow audience, or gated on a review decision (see `REVIEW-REQUIRED.md`).
Long tail — valuable for credibility and search coverage, low first-run demand.

**Tax (review-gated):** `tax-planning-and-projections` ·
`tax-return-prep-corporate` · `personal-tax-return-prep` ·
`corporate-tax-provision-asc740` · `income-tax-deferred-tax-rollforward` ·
`r-and-d-tax-credit` · `sales-tax-us-multistate` · `vat-gst-international` ·
`transfer-pricing-documentation` · `payroll-tax-filings` · `1099-and-t4a-prep`

**Valuation / transactions (review-gated):** `business-valuation` ·
`valuation-agent-dcf-comps-football-field` · `model-auditor-financial-model-review` ·
`due-diligence-quality-of-earnings` · `business-combinations-asc805` ·
`goodwill-and-impairment-testing` · `ipo-readiness-accounting`

**Public reporting:** `sec-10q-10k-prep` · `xbrl-tagging-checklist` ·
`segment-reporting` · `management-discussion-and-analysis` ·
`restatement-and-prior-period-adjustment` · `subsequent-events-asc855` ·
`related-party-disclosures-asc850` · `contingencies-and-litigation-asc450`

**Sector-specific:** `nonprofit-fund-accounting` ·
`grant-accounting-nonprofit-restricted-funds` · `government-fund-accounting-gasb` ·
`healthcare-revenue-cycle-accounting` · `insurance-accounting-overview` ·
`real-estate-and-property-accounting` · `construction-percentage-of-completion` ·
`crypto-and-digital-asset-accounting` · `esg-sustainability-reporting`

**Specialist technical:** `equity-compensation-accounting` ·
`pensions-and-postretirement-asc715` · `derivatives-and-hedging-asc815` ·
`restructuring-and-severance-asc420` · `gaap-vs-ifrs-conversion` ·
`benefits-and-401k-accounting` · `cohort-and-unit-economics` ·
`merchant-and-payment-processor-rec` · `petty-cash-management` ·
`vendor-onboarding-and-w9-tin` · `aml-kyc-procedures` ·
`ap-invoice-processing-and-3way-match` · `quickbooks-ar-aging-collections`

---

## Deduplication candidates

Two pairs overlap in the source pack and should not both ship as separate
products without a decision:

| Pair | Question |
|---|---|
| `three-way-match` **vs** `ap-invoice-processing-and-3way-match` | Merge, or position the second as the wider AP-process skill? |
| `cash-application` **vs** `ar-cash-application-lockbox` | Merge, or is lockbox a genuinely distinct workflow? |

Recommendation: ship `three-way-match` and `cash-application` in the queue;
hold the other two in Wave 4 pending a merge decision.
