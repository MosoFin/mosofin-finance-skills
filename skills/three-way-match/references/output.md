<!-- three-way-match · output.md · read for: Stage 5 — the coverage and provenance sheet; check before presenting. Edit here, not in SKILL.md. -->

## Coverage and Provenance sheet (mandatory)

**Section A — Environment**
- Workspace name (never the numeric id)
- Company file `display_name` (never the `data_source_id`)
- **Which legs were available**: invoices / POs / receipts, and at what level of detail
- **Which of the fifteen exception tests ran, and which did not, with reasons**
- Population and period covered, or the specific trio
- Tolerance policy applied; approval matrix used
- **Fixture flag** — any `mock: true`? In bold: **generated documents agree, so every test passes — and this skill recommends payments.**

**Section B — Capability map as observed today**
Each tool used: name as returned by `get_datasource_tools`, `effective_policy`, resulting verdict. **Including the three Gate 2 questions and their answers.**

**Section C — Steps by verdict**
Every step, and **every exception type**, with whether it ran.

**Section D — What was not done, and why**
- **Goods receipts**, where the system does not hold them — **and therefore exceptions 3 (its receipt comparison), 4, 7, 8 and 15**
- **Prior bills and payments against the POs**, where not supplied on the upload path — **and therefore the cumulative-billing test and exception 9**
- **Condition data** (damaged / rejected), which is rarely digitised
- **Approval status or approver identity**, where not exposed — **and therefore exceptions 11 and 12**
- **The approval matrix**, where not supplied
- **Contract price-adjustment clauses** — in the contract, not the PO
- **Service completion confirmations**
- **Authorisation for substitutions**
- **Any conclusion of fraud** — the data shows the pattern; people conclude
- **Payment.** The gateway is read-only

**Section E — Unknowns carried forward**
Unmatched lines. Exceptions unresolved by age. Unreceipted invoices outstanding. Undocumented overrides. GRNI not yet accrued. Vendors showing within-tolerance drift.

**Section F — Parameters used**
Tolerances. Matching precedence. Population and dates. Approval matrix version. **A control test that cannot be reproduced is not evidence** — keep the parameters so it can be re-performed.

---
