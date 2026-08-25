#!/usr/bin/env bash
# Dependency-free conformance validator for Mosofin accounting skills.
# Usage: scripts/validate-skill.sh [skills-dir]   (default: skills)
set -u
DIR="${1:-skills}"
fail=0; checked=0

req() { # req <file> <label> <grep-args...>
  local f="$1" label="$2"; shift 2
  if ! grep -qE "$@" "$f"; then
    echo "  FAIL  $label"; fail=$((fail+1))
  fi
}

for f in "$DIR"/*/SKILL.md; do
  [ -e "$f" ] || { echo "no skills found in $DIR"; exit 1; }
  name=$(basename "$(dirname "$f")")
  errs_before=$fail
  checked=$((checked+1))

  # 1. frontmatter with name + description
  head -1 "$f" | grep -q '^---$' || { echo "  FAIL  $name: missing frontmatter"; fail=$((fail+1)); }
  req "$f" "$name: frontmatter name:"        '^name: '
  req "$f" "$name: frontmatter description:" '^description: '

  # 2. exactly four gates
  g=$(grep -c '^## Gate ' "$f")
  [ "$g" -eq 4 ] || { echo "  FAIL  $name: expected 4 gates, found $g"; fail=$((fail+1)); }

  # 3. verdict annotations present
  req "$f" "$name: no [auto] verdicts"   '\[auto'
  req "$f" "$name: no [manual] verdicts" '\[manual\]'

  # 4. coverage/provenance and lifecycle
  req "$f" "$name: no coverage/provenance section" -i 'coverage and provenance|coverage sheet|provenance'
  req "$f" "$name: no seed-to-evolved lifecycle"   -i 'seed to evolved|evolve the skill|evolved version'

  # 5. tool-name hygiene: bare registry names only
  if grep -nE 'mosofin_(list_workspaces|get_|invoke_|create_)' "$f" >/dev/null; then
    echo "  FAIL  $name: prefixed tool name (mosofin_...)"; fail=$((fail+1))
  fi
  if grep -n 'mcp__' "$f" | grep -viE 'do not|don.t|never|no |not |remov|prefix|namespace|forbid|avoid|wrong' >/dev/null; then
    echo "  FAIL  $name: client-side mcp__ namespace used as a tool name"; fail=$((fail+1))
  fi

  # 6. no numeric tenant/workspace ids
  if grep -nE 'tenant[ _]?id[ ]*[:=][ ]*[0-9]|workspace[ _]?id[ ]*[:=][ ]*[0-9]' "$f" >/dev/null; then
    echo "  FAIL  $name: numeric tenant/workspace id present"; fail=$((fail+1))
  fi

  # 7. subscription onboarding block — required for standalone distribution
  req "$f" "$name: missing subscription onboarding block" -i "requires a Mosofin subscription"
  req "$f" "$name: onboarding missing gateway endpoint"    "mcp\\.mosofin\\.com"
  req "$f" "$name: onboarding missing degraded-mode note"  -i "running without a connection"

  # 8. Gate 0 must call list_workspaces
  req "$f" "$name: Gate 0 does not call list_workspaces" 'list_workspaces'

  [ "$fail" -eq "$errs_before" ] && echo "  ok    $name"
done

echo
echo "checked: $checked   failures: $fail"
[ "$fail" -eq 0 ] || exit 1
