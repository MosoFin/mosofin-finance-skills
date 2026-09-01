#!/usr/bin/env python3
"""Inject a dashboard data file into the template and write the finished HTML.

Usage:
  python3 build_dashboard.py --data data.json --out dashboard.html
  python3 build_dashboard.py --csv entities.csv --group "Acme Group" --out dashboard.html [--mode manual]

CSV mode expects one row per entity-month with these columns:
  entity, month, year, operating_cf, investing_cf, financing_cf, net_income,
  accounts_receivable, ar_intercompany, accounts_payable, inventory
Balance-sheet columns (accounts_receivable, ar_intercompany, accounts_payable,
inventory) are read from each entity's LAST row only.
"""
import argparse, csv, json, os, sys, collections

HERE = os.path.dirname(os.path.abspath(__file__))
TEMPLATE = os.path.join(HERE, "..", "assets", "dashboard-template.html")
MONTH_ORDER = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]

def num(v):
    v = (v or "").strip().replace(",", "").replace("$", "")
    if v in ("", "-", "—"): return 0.0
    if v.startswith("(") and v.endswith(")"): v = "-" + v[1:-1]
    return round(float(v), 2)

def short_of(label, group):
    g = group
    for suf in (" Group", " Holdings", " Inc", " Inc.", " LLC"):
        if g.endswith(suf): g = g[: -len(suf)]
    s = label[len(g):].strip() if label.startswith(g) else label
    for w in ("LLC", "Inc.", "Inc", "Ltd.", "Ltd", "Corp.", "Corp"):
        s = s.replace(w, "")
    return (s.split() or [label])[0]

def from_csv(path, group, mode, source, fetched):
    rows = list(csv.DictReader(open(path, newline="")))
    if not rows: sys.exit("CSV is empty")
    need = {"entity","month","operating_cf","investing_cf","financing_cf","net_income"}
    missing = need - set(rows[0].keys())
    if missing: sys.exit("CSV missing columns: " + ", ".join(sorted(missing)))
    by = collections.OrderedDict()
    for r in rows: by.setdefault(r["entity"].strip(), []).append(r)
    months, year = None, None
    entities, order = {}, []
    for label, rs in by.items():
        rs.sort(key=lambda r: (int(r.get("year") or 0), MONTH_ORDER.index(r["month"][:3].title())))
        m = [r["month"][:3].title() for r in rs]
        if months is None: months = m; year = int(rs[0].get("year") or 2026)
        elif m != months: sys.exit(f"Entity '{label}' has months {m}, expected {months} (all entities must share the same months)")
        last = rs[-1]
        key = short_of(label, group).lower()
        order.append(key)
        entities[key] = {
            "label": label, "short": short_of(label, group),
            "ocf": [num(r["operating_cf"]) for r in rs],
            "icf": [num(r["investing_cf"]) for r in rs],
            "fcf": [num(r["financing_cf"]) for r in rs],
            "ni":  [num(r["net_income"]) for r in rs],
            "ar": num(last.get("accounts_receivable")), "arIc": num(last.get("ar_intercompany")),
            "ap": num(last.get("accounts_payable")), "inv": num(last.get("inventory")),
            "aging": None, "customers": None,
        }
    return {"group": group, "mode": mode, "source": source, "fetched": fetched,
            "asOf": "", "year": year, "months": months, "entities": entities, "order": order, "notes": []}

def validate(d):
    for k in ("group","mode","source","months","entities","order"):
        if k not in d: sys.exit(f"data missing '{k}'")
    n = len(d["months"])
    for key in d["order"]:
        e = d["entities"][key]
        for s in ("ocf","icf","fcf","ni"):
            if len(e[s]) != n: sys.exit(f"{key}.{s} has {len(e[s])} values, expected {n}")
    if n < 2: sys.exit("Need at least two months of history")

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data"); ap.add_argument("--csv")
    ap.add_argument("--group", default="Group"); ap.add_argument("--mode", default="manual", choices=["manual","mosofin"])
    ap.add_argument("--source", default="Uploaded CSV"); ap.add_argument("--fetched", default="")
    ap.add_argument("--out", required=True)
    a = ap.parse_args()
    if a.data: d = json.load(open(a.data))
    elif a.csv: d = from_csv(a.csv, a.group, a.mode, a.source, a.fetched)
    else: sys.exit("give --data or --csv")
    validate(d)
    tpl = open(TEMPLATE, encoding="utf-8").read()
    marker = "var DATA=/*__DATA__*/null;"
    if marker not in tpl: sys.exit("template marker not found")
    out = tpl.replace(marker, "var DATA=" + json.dumps(d, ensure_ascii=False) + ";")
    open(a.out, "w", encoding="utf-8").write(out)
    print(f"wrote {a.out}  ({len(d['order'])} entities, {len(d['months'])} months, mode={d['mode']})")

if __name__ == "__main__": main()
