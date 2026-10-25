<!-- fixed-asset-register-and-depreciation · output.md · read for: Stage 5 — the output quality standards; check before presenting. Edit here, not in SKILL.md. -->

## Output Quality Standards

All of the original standards, plus the Mosofin ones.

- **Every asset has class, useful life, method, and depreciation calculation**
- **Acquisitions match capitalization policy**
- **Disposals show original cost, accumulated depreciation, NBV, proceeds, gain / loss**
- **Roll-forward ties to GL**
- **Impairment review documented**
- **Tax-book differences captured if material**
- **Multi-currency handled per policy**
- **File naming consistent**
- **No depreciation past (Cost − Salvage)**

**Mosofin additions:**

- The workspace was confirmed **by name** and the user said yes before any data was read
- Every in-scope company file is named by `display_name`; every excluded one is named **as excluded**
- The capability map was discovered **this run** via Gate 2 — never recalled from a previous conversation
  or from this file
- **Additions and disposals were derived from the ledger movements**, not only accepted as supplied
- **The tie-out runs in both directions**, with register-not-in-GL and GL-not-in-register reported as
  separate lists
- **The capitalization threshold was tested against the expense accounts**, both directions, with candidates
  reported as candidates and the policy call left to the user
- **The implied depreciation rate was compared to the policy life** per class, and any large divergence
  reported
- **Whether depreciation was posted at all this period is stated**
- **Disposals were checked for the half-entry error** — cost without accumulated depreciation, or proceeds
  without a disposal
- **Land carrying accumulated depreciation is flagged**, and a stalled CIP balance is surfaced
- Impairment candidates derived from ledger data are **marked as candidates**, never as conclusions
- **The physical count is recorded as `[manual]` with an owner and its last-performed date**, and its
  absence is reported as a finding
- Useful lives, salvage values, the threshold and the convention are **all stated with their source**, and
  none was assumed
- In a multi-entity run, **depreciation stays with the entity holding the asset**, policy differences across
  entities are flagged, and intra-group transfers are raised for the consolidation
- Every task carries its verdict (`[auto]` / `[gated]` / `[manual]`), the tool or external source used, and
  its as-at date, in the coverage sheet
- `mock` status is reported wherever it applies, and no proposed entry rests on mock data
- Every figure traces to a tool result in this conversation or to labelled user-supplied evidence; the
  answer ends with a single **Data sources** line
- Every jargon term carries a plain-language gloss at first mention, with the professional term kept
  alongside
- No internal numeric ids and no raw `data_source_id` values appear in anything the user sees
- **No register, asset-level cost, net book value, location or serial number is persisted** into a skill
  bundle; every persisted preference states the datasource and `display_name` it covers
- Nothing was written back to any system — no asset capitalized, depreciated, disposed or impaired
