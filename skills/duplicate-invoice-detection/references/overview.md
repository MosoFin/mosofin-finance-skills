<!-- duplicate-invoice-detection · overview.md · read for: background for the card and Stage 1 — what the skill does, which of the ten rules run, and why Rule 7 cannot; read when a user asks why. Edit here, not in SKILL.md. -->

# Duplicate Invoice Detection (Mosofin)

Scans the **accounts payable register** for likely duplicate invoices and payments. Designed to catch the
common patterns: **the same invoice resubmitted, the same amount paid twice via different paths, slightly
altered invoice numbers, and vendor variants used to evade duplicate checks.**

**In plain words:** businesses pay the same bill twice more often than they realise. A supplier chases an
invoice that was already paid, someone enters it again, and it goes out a second time. Sometimes it is an
honest mistake; sometimes someone is exploiting the fact that nobody checks. This skill finds both.

This skill is **jurisdiction-agnostic**.

It is **not** system-agnostic. It is **workspace-scoped** — and that turns out to be its great advantage.

## This is the best-fitting skill in the pack

Most skills here need something the accounting system does not hold — a bank statement, a valuation, a
contract. **This one needs the AP register and the vendor master, and the workspace holds both,
completely.** So the detection rules are not a procedure to be performed; **they are queries**.

**Nine of the ten rules run directly:**

| Rule | Runs? |
|---|---|
| 1 — Exact invoice number + same vendor | **`[auto]`** |
| 2 — Same amount + vendor + invoice date | **`[auto]`** |
| 3 — Same amount + vendor + dates within N days | **`[auto]`** |
| 4 — Same amount + similar vendor name | **`[auto]`** |
| 5 — Invoice number sequence anomaly | **`[auto]`** |
| 6 — Same invoice number across vendor IDs | **`[auto]`** |
| 7 — **Same bank account, different vendors** | **`[manual]` — see below** |
| 8 — Round-number clusters | **`[auto]`** |
| 9 — Paid via two different channels | **`[gated]`** |
| 10 — Credit memo never applied | **`[auto]`** |

**And the one exception matters, because it is the fraud rule.** Rule 7 catches **two vendor records
sharing one bank account** — which is either a duplicated vendor or a deliberate fraud setup, and it is
the only rule aimed squarely at *fraud* rather than *error*. **Mosofin does not expose vendor bank
details**, deliberately: bank details are the single highest-value target in payment fraud, and this
surface does not carry them.

So be precise about what this skill delivers here: **a thorough duplicate-*error* detector, plus most of
the fraud-adjacent patterns (vendor aliases, sequence anomalies, cross-record reuse) — with the
bank-account test needing to be run in the AP or banking system itself.** Say so; do not let a clean
result imply the fraud test passed.

**Mosofin is read-only.** It cannot void a duplicate, merge vendor records, or recover a payment. Every
action below is a *proposal*.

---
