#!/usr/bin/env bash
# Dependency-free conformance validator for Mosofin accounting skills.
# Usage: scripts/validate-skill.sh [skills-dir]   (default: skills)
set -u
DIR="${1:-skills}"
fail=0; checked=0

reqn() { # reqn <file> <label> <regex>  — prose match, wrap-proof.
         # Collapses all runs of whitespace to single spaces before matching, so a
         # phrase that happens to break across two lines still matches. Use this for
         # any sentence-shaped assertion; use req() for line-anchored ones.
  local f="$1" label="$2" pat="$3"
  if ! tr '\n' ' ' < "$f" | tr -s ' \t' ' ' | grep -qiE "$pat"; then
    echo "  FAIL  $label"; fail=$((fail+1))
  fi
}

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
  reqn "$f" "$name: missing the with/without-Mosofin opening" \
      "works with or without Mosofin"
  reqn "$f" "$name: does not say the skill works without Mosofin" \
      "Without it, the skill still works"
  reqn "$f" "$name: does not say the user is not blocked without a subscription" \
      "not blocked and you are not asked to buy anything first"

  # 8. setup documentation must be linked, including the destination connect page
  req "$f" "$name: onboarding does not link docs.mosofin.com" "docs\\.mosofin\\.com"
  req "$f" "$name: does not point at the shared onboarding" "shared/onboarding\\.md"

  # 8b. onboarding is required, and Part A is the exploration that follows it
  reqn "$f" "$name: onboarding is not stated as required" \
      "Onboarding . required, every skill, once per workspace|Required for every skill, every run"
  req "$f" "$name: missing the ONBOARDING part heading"  '^# ONBOARDING'
  req "$f" "$name: missing the PART A part heading"      '^# PART A'
  req "$f" "$name: Part A is not framed as explore/personalise" \
      '^# PART A .* [Ee]xplore the confirmed sources, and personalise this run'
  # ordering: ONBOARDING must precede PART A, and both must precede Gate 2
  ob=$(grep -n '^# ONBOARDING' "$f" | head -1 | cut -d: -f1)
  pa=$(grep -n '^# PART A'     "$f" | head -1 | cut -d: -f1)
  g0=$(grep -n '^## Gate 0'    "$f" | head -1 | cut -d: -f1)
  g2=$(grep -n '^## Gate 2'    "$f" | head -1 | cut -d: -f1)
  if [ -n "$ob" ] && [ -n "$pa" ] && [ -n "$g0" ] && [ -n "$g2" ]; then
    if ! { [ "$ob" -lt "$g0" ] && [ "$g0" -lt "$pa" ] && [ "$pa" -lt "$g2" ]; }; then
      echo "  FAIL  $name: parts out of order (ONBOARDING<Gate0<PART A<Gate2)"; fail=$((fail+1))
    fi
  fi

  # 8c. a skill with no Mosofin connector must still work, manually
  reqn "$f" "$name: does not ask whether to use Mosofin" \
      "ask whether to use Mosofin for this run"
  reqn "$f" "$name: does not wait for the answer" \
      "A connected gateway is \\*\\*not\\*\\* consent to read from it"
  reqn "$f" "$name: no check for an absent gateway" \
      "Are the Mosofin tools present at all"
  reqn "$f" "$name: asks even when the gateway is absent" \
      "If the tools are not present, do not ask"
  reqn "$f" "$name: does not skip the gates without Mosofin" "skip Gates 0-2 entirely"
  reqn "$f" "$name: makes connecting a condition of helping" \
      "not make connecting a condition of helping"
  reqn "$f" "$name: does not fall back to the normal manual workflow" \
      "carry on with the skill.s normal workflow"
  reqn "$f" "$name: does not distinguish absent from unauthenticated" \
      "Present but not authenticated is not the same as absent"

  # 8d. the manual run must be specified, not just permitted
  reqn "$f" "$name: does not spell out a manual run gate by gate" \
      "What a manual run actually does, gate by gate"
  reqn "$f" "$name: manual run does not make Gate 3 ask what the profile would derive" \
      "everything it would have derived silently becomes a"
  reqn "$f" "$name: manual run does not mark every task manual" \
      "it is uniform.{0,40}every task is"
  reqn "$f" "$name: manual run does not forbid estimating missing figures" \
      "[Nn]ever estimate a figure that was meant to come from the books"
  reqn "$f" "$name: manual run does not say what a partial output will be" \
      "say what the output will and will not be"
  reqn "$f" "$name: manual run treats supplied data as pre-validated" \
      "Manual input is not more trustworthy than a ledger read"

  # 9. the shared scope-confirmation protocol: workspace -> datasources -> tools
  reqn "$f" "$name: missing the scope-confirmation protocol" "Confirming scope"
  reqn "$f" "$name: scope protocol does not order the three questions" \
      "workspace, then data sources, then tools"
  reqn "$f" "$name: scope protocol does not forbid auto-picking" "never auto-pick"
  reqn "$f" "$name: scope protocol does not say silence is not a yes" "silence is not a yes"
  reqn "$f" "$name: scope protocol does not forbid disabled tools" \
      "[Nn]ever call a tool whose .effective_policy. is .disabled"
  reqn "$f" "$name: scope protocol does not forbid inventing tool names" "do not.{0,3}invent a tool name"
  reqn "$f" "$name: scope protocol does not note per-company permissions" "permissions are per compan"

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
  reqn "$f" "$name: missing the Gate 2 hard stop" \
      "Hard stop"
  reqn "$f" "$name: hard stop does not close the approval loop" \
      "Do not re-invoke with .approved=true"
  reqn "$f" "$name: gated policy row is not limited to reads" \
      "never re-invoke a write with .approved=true"
  reqn "$f" "$name: hard stop does not refuse a user-instructed write" \
      "Asking again does not change the answer"
  reqn "$f" "$name: hard stop does not forbid routing around the rule" \
      "Never route around this rule"
  reqn "$f" "$name: hard stop does not forbid trading the rule for completeness" \
      "no path through this skill that ends in changed data"

  # The user-facing strict rule must be present and explicit.
  reqn "$f" "$name: missing the strict no-change rule" \
      "this skill never changes your data"
  reqn "$f" "$name: strict rule does not name write/update/delete" \
      "never write, update or delete existing data in any data source"
  reqn "$f" "$name: strict rule does not disclaim directing the user" \
      "direct you to update, overwrite or delete existing data"

  # The Gate 2 guardrail must be present and must override effective_policy.
  reqn "$f" "$name: missing the Gate 2 write-tool guardrail" \
      "Write tools are out of scope"
  reqn "$f" "$name: guardrail does not override effective_policy" \
      "scope even when .effective_policy. is .enabled."
  reqn "$f" "$name: guardrail is not platform-agnostic" \
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
