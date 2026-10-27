<!-- ap-accrual-cutoff · edge-cases.md · read for: Stage 4, and whenever something looks unusual. Edit here, not in SKILL.md. -->

## Edge Cases

All of the original edge cases, plus the ones Mosofin's workspace model introduces.

**GRN with no PO price** (rare; usually a process exception): estimate from prior receipts or
the contract; flag it. **[auto]** to find prior receipts of the same item
(*`search_items`*, *`search_purchase_orders`*); the estimate itself is a judgment.

**PO with multiple receipts, partial invoicing**: track cumulatively — GRNI = cumulative
received to period end − cumulative invoiced to period end, **per line**. Line-level tracking matters; a PO-level netting
hides a line that is fully received and unbilled behind another that is fully billed.

**Services delivered but no GRN equivalent**: depend on a service-completion confirmation,
time sheets, or vendor-side milestone declarations. If none exists, ask the user for the
basis — do not manufacture one.

**Significant variance vs. expected**: a recurring vendor's bill that is normally $1,000
estimated this month at $1,500 — flag it and ask the user to confirm or adjust. **Don't
silently post a 50% larger accrual.**

**Multi-currency**: accrue in the functional currency at the period-end FX rate. The reversal
mirrors the accrual exactly, **at the same rate**. Any revaluation is a separate FX
revaluation task.

**Tax-inclusive vs exclusive estimates**: make sure the accrual is on the expense amount, not
the gross. If the expected total includes tax, decompose it.

**Cross-period contracts** (e.g. a three-year service contract billed annually in advance):
different accounting — that is a **prepaid**, not an accrual. Hand to
`prepaid-amortization-schedule`.

**Bills received but not yet posted to A/P** (sitting in an inbox or approval queue): a bill
**dated on or before period end** is **not an accrual** — it should simply be posted. A bill
dated **after** period end for in-period work posts into the new period, so it is reviewed
under Step 3 like a posted bill. Check the approval queue first. **[manual]** in Mosofin: an
unposted bill is by definition not yet in the books, so no tool can see it. Ask the user to
send any vendor invoices received since period end that are not yet entered (PDFs from the
inbox or approval queue), and say that the schedule assumes none were left out.

**Items accrued last period and reversed this period, but the invoice never arrived**:
investigate. Either the service didn't happen and no accrual is needed, or the invoice is
delayed and should be re-accrued. **[auto]** to detect this — compare last period's accrual
JEs against bills received since (*`search_journal_entries`*, *`search_bills`*).

**Year-end vs. period-end materiality**: year-end may use a tighter materiality; check with
the user rather than reusing the monthly figure. The profile's fiscal year-end
(*`get_company_info`*) tells you when to ask.

**Subsequent-event window**: how many days after period end should you look back for
invoices? A common cutoff is the date the books close. Confirm with the user — this is a
Gate 3 question because it sets the Step 3 search range.

**A company file is connected but not active** — *Mosofin-specific*. Name it as excluded and
say which costs are therefore unaccrued. Surface any `reconnect_url`.

**No goods-receipt record exists in the connected books** — *Mosofin-specific, and the most
common gap in this skill*. Most accounting connectors carry orders and bills but not
receipts. Do not infer that an open PO was received just because it is open — an unreceived
order is a commitment, **not** a liability, and accruing it overstates costs. Mark the
receipt quantity `[manual]`, name where receipts actually live, and ask for them.

**A bill does not carry a link to its PO** — *Mosofin-specific*. Match by vendor, date, amount
and description, and **record the match as inferred**. An inferred match that is wrong
produces exactly the double-count the quality standards forbid, so it belongs in the
exceptions sheet.

**The purchase-order tool is `disabled` in this workspace** — *Mosofin-specific*. Do not
substitute a vendor spend report: spend is what was already billed, which is the population
that does **not** need accruing. Mark GRNI `[manual]`, name the tool, and ask for an open-PO
export.

**A result comes back with `mock: true`** — *Mosofin-specific*. Fixture data can demonstrate
the schedule's shape but cannot support a posted entry. Flag it at the top of the deliverable.

**The books are kept on a cash basis** — *Mosofin-specific*. A cash-basis ledger does not
carry accruals at all, so the opening accrued-liability balance may legitimately be zero. Say
that explicitly, and confirm whether the user is converting to accrual basis for reporting.

**A stored recurring-vendor preference no longer matches reality** — *Mosofin-specific*. A
vendor whose contract ended will otherwise be accrued forever. On every run, re-check each
stored recurring vendor against actual recent bills before accruing it.

**A stored preference names an entity that is no longer connected** — *Mosofin-specific*.
Flag it. Never apply it to a different entity; never drop it silently.

**A tool is `permission`-gated mid-run** — *Mosofin-specific*. Ask in chat, re-invoke with
`approved=true` (**reads only — never for a write**) after an explicit yes, and record the task as `[gated]` in the coverage sheet.

---
