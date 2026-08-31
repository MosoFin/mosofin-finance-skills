#!/usr/bin/env bash
# Dependency-free conformance validator for Mosofin accounting skills.
# Usage: scripts/validate-skill.sh [skills-dir]   (default: skills)
set -u
DIR="${1:-skills}"
fail=0; checked=0

req() { # req <file> <label> <grep-args...>  — must appear in SKILL.md itself
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

  # 8. setup documentation must be linked, including the destination connect page
  req "$f" "$name: onboarding does not link docs.mosofin.com" "docs\\.mosofin\\.com"
  req "$f" "$name: does not point at the shared onboarding" "shared/onboarding\\.md"

  # 9. the shared scope-confirmation protocol: workspace -> datasources -> tools
  req "$f" "$name: missing the scope-confirmation protocol" "Confirming scope"
  req "$f" "$name: scope protocol does not order the three questions" \
      "workspace, then data sources, then tools"
  req "$f" "$name: scope protocol does not forbid auto-picking" -i "never auto-pick"
  req "$f" "$name: scope protocol does not say silence is not a yes" -i "silence is not a yes"
  req "$f" "$name: scope protocol does not forbid disabled tools" \
      "[Nn]ever call a tool whose .effective_policy. is .disabled"
  req "$f" "$name: scope protocol does not forbid inventing tool names" -i "do not.{0,3}invent a tool name"
  req "$f" "$name: scope protocol does not note per-company permissions" -i "permissions are per compan"

  # 10. Gate 0 must call list_workspaces
  req "$f" "$name: Gate 0 does not call list_workspaces" 'list_workspaces'


  # 10. read-only posture — no skill may write to the accounting system.
  #     create_skill is permitted: it writes the user's own decisions back to
  #     their Mosofin workspace, never to the books, and only on explicit
  #     consent after results are shown.
  for bad in 'update_skill' 'delete_skill'; do
    if grep -nE "\\b$bad\\b" "$f" >/dev/null; then
      echo "  FAIL  $name: uses write tool '$bad'"; fail=$((fail+1))
    fi
  done
  if grep -niE '"method"[[:space:]]*:[[:space:]]*"(POST|PUT|PATCH|DELETE)"' "$f" >/dev/null; then
    echo "  FAIL  $name: HTTP write verb in a tool invocation"; fail=$((fail+1))
  fi
  # No write-back to ANY connected platform, not just the books.
  _plat='quickbooks|qbo|xero|netsuite|stripe|square|paypal|shopify|plaid|bill\.com|ramp|brex|expensify|gusto|adp|rippling|the (data ?source|platform|source system|connected (system|platform))'
  if grep -niE "(write|sync|push|post|upload) (it |them |the [a-z]+ )?(back )?(to|into) (${_plat})" "$f" >/dev/null; then
    echo "  FAIL  $name: instructs a write to a connected platform"; fail=$((fail+1))
  fi
  # The operative hard stop: every route to a write must be closed.
  req "$f" "$name: missing the Gate 2 hard stop" \
      "Hard stop"
  req "$f" "$name: hard stop does not close the approval loop" \
      "Do not re-invoke with .approved=true"
  req "$f" "$name: gated policy row is not limited to reads" \
      "never re-invoke a write with .approved=true"
  req "$f" "$name: hard stop does not refuse a user-instructed write" \
      "Asking again does not change the answer"
  req "$f" "$name: hard stop does not forbid routing around the rule" \
      "Never route around this rule"
  req "$f" "$name: hard stop does not forbid trading the rule for completeness" \
      "no path through this skill that ends in changed data"

  # The user-facing strict rule must be present and explicit.
  req "$f" "$name: missing the strict no-change rule" \
      "this skill never changes your data"
  req "$f" "$name: strict rule does not name write/update/delete" \
      "never write, update or delete existing data in any data source"
  req "$f" "$name: strict rule does not disclaim directing the user" \
      "direct you to update, overwrite or delete existing data"

  # The Gate 2 guardrail must be present and must override effective_policy.
  req "$f" "$name: missing the Gate 2 write-tool guardrail" \
      "Write tools are out of scope"
  req "$f" "$name: guardrail does not override effective_policy" \
      "scope even when .effective_policy. is .enabled."
  req "$f" "$name: guardrail is not platform-agnostic" \
      "every connected platform, not only the books" 

  [ "$fail" -eq "$errs_before" ] && echo "  ok    $name"
done

# The onboarding steps live once, at shared/onboarding.md, and every skill links
# there. Validate that file itself — the per-skill loop can no longer see its text.
SHARED="shared/onboarding.md"
if [ ! -f "$SHARED" ]; then
  echo "  FAIL  $SHARED is missing — every skill links to it"; fail=$((fail+1))
else
  req "$SHARED" "shared onboarding: no first-run step table"      -i "first-run onboarding"
  req "$SHARED" "shared onboarding: missing gateway endpoint"     "mcp\\.mosofin\\.com"
  req "$SHARED" "shared onboarding: missing degraded-mode note"   -i "running without a connection"
  req "$SHARED" "shared onboarding: no docs.mosofin.com links"    "docs\\.mosofin\\.com"
  req "$SHARED" "shared onboarding: no destination setup page"    "destinations/claude/connect-claude"
  req "$SHARED" "shared onboarding: missing read-only guarantee"  "Nothing in this skill posts an entry, files a return"
  echo "  ok    $SHARED"
fi

echo
echo "checked: $checked   failures: $fail"
[ "$fail" -eq 0 ] || exit 1
