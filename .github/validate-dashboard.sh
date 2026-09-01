#!/usr/bin/env bash
# Conformance validator for dashboard skills (dashboards/).
#
# Dashboard skills are a different genre from the gate-based analysis skills in
# skills/, and they carry their OWN standard — the rules below are taken from
# the skill's own Guardrails and workflow, not from validate-skill.sh. They are
# not checked against the four-gate protocol, [auto]/[manual] verdicts, the
# coverage sheet or the seed-to-evolved lifecycle: those belong to the analysis
# genre and do not describe how a dashboard is built.
#
# Usage: .github/validate-dashboard.sh [dashboards-dir]   (default: dashboards)
set -u
DIR="${1:-dashboards}"
fail=0; checked=0

reqn() { # reqn <file> <label> <regex> — wrap-proof prose match
  local f="$1" label="$2" pat="$3"
  if ! tr '\n' ' ' < "$f" | tr -s ' \t' ' ' | grep -qiE "$pat"; then
    echo "  FAIL  $label"; fail=$((fail+1))
  fi
}
has() { # has <path> <label>
  [ -e "$1" ] || { echo "  FAIL  $2"; fail=$((fail+1)); }
}

for f in "$DIR"/*/SKILL.md; do
  [ -e "$f" ] || { echo "no dashboard skills found in $DIR"; exit 1; }
  d="$(dirname "$f")"; name=$(basename "$d"); errs_before=$fail
  checked=$((checked+1))

  # 1. frontmatter
  head -1 "$f" | grep -q '^---$' || { echo "  FAIL  $name: missing frontmatter"; fail=$((fail+1)); }
  grep -q '^name: '        "$f" || { echo "  FAIL  $name: frontmatter name:"; fail=$((fail+1)); }
  grep -q '^description: ' "$f" || { echo "  FAIL  $name: frontmatter description:"; fail=$((fail+1)); }

  # 2. the bundle is complete — SKILL.md points at each of these
  has "$d/references/ui-spec.md"          "$name: missing references/ui-spec.md"
  has "$d/references/mosofin-workflow.md" "$name: missing references/mosofin-workflow.md"
  has "$d/references/manual-workflow.md"  "$name: missing references/manual-workflow.md"
  has "$d/assets"                         "$name: missing assets/"
  has "$d/scripts"                        "$name: missing scripts/"

  # 2b. every bundled path named in SKILL.md must actually be present.
  #     Catches a file dropped by .gitignore or left out of the package.
  missing=$(python3 - "$f" "$d" <<'PYEOF'
import re, sys, os
skill, root = sys.argv[1], sys.argv[2]
text = open(skill).read()
paths = set(re.findall(r'`((?:references|assets|scripts)/[A-Za-z0-9_.\-]+)`', text))
gone = [p for p in sorted(paths) if not os.path.exists(os.path.join(root, p))]
print(' '.join(gone))
PYEOF
)
  if [ -n "$missing" ]; then
    for m in $missing; do
      echo "  FAIL  $name: SKILL.md references $m, which is not in the bundle"; fail=$((fail+1))
    done
  fi

  # 3. the user chooses the data path, and there is a real manual path
  reqn "$f" "$name: does not ask which data path to use" \
      "[Uu]se your MosoFin connection to read the books, or supply the data yourself"
  reqn "$f" "$name: no manual / opted-out path" "[Mm]anual"
  reqn "$f" "$name: does not refuse to mix paths on partial failure" \
      "rather than inventing figures"

  # 4. read-only, and every number traceable
  reqn "$f" "$name: missing the read-only guardrail" \
      "never writes to QuickBooks or MosoFin"
  reqn "$f" "$name: does not require every number to be traceable" \
      "comes from the tool results or the user.s file"
  reqn "$f" "$name: does not forbid interpolated or typical values" \
      "[Nn]o interpolation, no .typical. values"
  reqn "$f" "$name: does not require disclosing sandbox and intercompany" \
      "[Dd]isclose sandbox signals and intercompany balances"

  # 5. the visual standard is fixed and the template is generated, not hand-edited
  reqn "$f" "$name: does not make the UI spec authoritative" \
      "ui-spec\.md.{0,120}before"
  reqn "$f" "$name: does not forbid editing the template in place" \
      "never edit in place|do not edit .* in place"
  reqn "$f" "$name: does not forbid new libraries, CDN fonts or colours" \
      "[Dd]o not add chart libraries"

  # 6. the output is verified before it is shown
  reqn "$f" "$name: no verify-before-presenting step" \
      "[Vv]erify before presenting"

  # 7. the template is self-contained: no scripts or styles from a CDN.
  #    A Google Fonts stylesheet is allowed — the UI spec names the face.
  for t in "$d"/assets/*.html; do
    [ -e "$t" ] || continue
    if grep -oE 'src="https?://[^"]*"' "$t" | grep -qv 'fonts\.g'; then
      echo "  FAIL  $name: $(basename "$t") loads a script from a remote host"; fail=$((fail+1))
    fi
    if grep -oE 'href="https?://[^"]*"' "$t" | grep -qvE 'fonts\.(googleapis|gstatic)\.com'; then
      echo "  FAIL  $name: $(basename "$t") loads a stylesheet from a non-font host"; fail=$((fail+1))
    fi
    grep -q '__DATA__' "$t" || { echo "  FAIL  $name: $(basename "$t") has no __DATA__ placeholder"; fail=$((fail+1)); }
  done

  # 8. the generator and its example data actually work together
  for s in "$d"/scripts/*.py; do
    [ -e "$s" ] || continue
    python3 -c 'import sys; compile(open(sys.argv[1]).read(), sys.argv[1], "exec")' "$s" 2>/dev/null \
      || { echo "  FAIL  $name: $(basename "$s") does not compile"; fail=$((fail+1)); }
  done
  for j in "$d"/assets/*.json; do
    [ -e "$j" ] || continue
    python3 -c "import json,sys; json.load(open(sys.argv[1]))" "$j" 2>/dev/null \
      || { echo "  FAIL  $name: $(basename "$j") is not valid JSON"; fail=$((fail+1)); }
  done

  [ "$fail" -eq "$errs_before" ] && echo "  ok    $name"
done

echo
echo "checked: $checked   failures: $fail"
[ "$fail" -eq 0 ] || exit 1
