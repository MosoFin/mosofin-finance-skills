# House Style — Known Variance

The pack contains **two section-naming conventions**, split by when each file was
written. Both satisfy every requirement; the validator passes 114/114 against
either. **Only the names differ.**

| | Style A (82 files) | Style B (32 files) |
|---|---|---|
| Lifecycle | `## Step N — Evolve the skill` | `## Seed to evolved` |
| Coverage | within `## Tool reference` / a step | `## Coverage and Provenance sheet` |
| Cautions | inline + `## Pitfalls` | `## Anti-patterns` |
| Plain language | `## Plain-language glossary` | handled inline |
| Cross-references | inline | `## Related skills` table |

**Decision outstanding** — see R6 in `REVIEW-REQUIRED.md`. Options: document and
leave; normalise B→A; or normalise A→B (recommended if uniformity is wanted, since
Style B has a dedicated coverage sheet and explicit anti-patterns).

Until it is settled, **do not mix styles within a single file.**
