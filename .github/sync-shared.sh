#!/usr/bin/env bash
# Sync the shared onboarding + write-guardrail blocks into every skill.
#
# The skills are distributed standalone — a user may copy one folder and use it
# with nothing else present — so every skill carries its own full copy of these
# blocks. That makes them duplicated by design, not by accident. This script is
# what keeps the copies honest: .github/shared/ is the single source of truth,
# and every copy is generated from it.
#
#   .github/sync-shared.sh            apply the canonical blocks to all skills
#   .github/sync-shared.sh --check    verify they match; non-zero if any drifted
#
# Edit .github/shared/*.md, run this, commit. Never hand-edit a block inside a
# SKILL.md — the next sync overwrites it and CI fails until it matches.
set -u
cd "$(dirname "$0")/.." || exit 2

mode="apply"; [ "${1:-}" = "--check" ] && mode="check"
dir="${2:-skills}"
rc=0; changed=0; checked=0

for f in "$dir"/*/SKILL.md; do
  [ -f "$f" ] || continue
  name=$(basename "$(dirname "$f")")
  checked=$((checked+1))
  for block in onboarding write-guardrail; do
    src=".github/shared/$block.md"
    if [ ! -f "$src" ]; then echo "  FAIL  missing $src"; rc=1; continue; fi
    if ! grep -q "<!-- shared:$block start -->" "$f" || ! grep -q "<!-- shared:$block end -->" "$f"; then
      echo "  FAIL  $name: missing <!-- shared:$block --> markers"; rc=1; continue
    fi
    awk -v s="$src" -v b="$block" '
      $0 == "<!-- shared:" b " start -->" { print; while ((getline l < s) > 0) print l; close(s); skip=1; next }
      $0 == "<!-- shared:" b " end -->"   { skip=0 }
      !skip { print }
    ' "$f" > "$f.sync"
    if cmp -s "$f" "$f.sync"; then
      rm -f "$f.sync"
    else
      if [ "$mode" = "check" ]; then
        echo "  DRIFT $name: $block does not match .github/shared/$block.md"
        rm -f "$f.sync"; rc=1
      else
        mv "$f.sync" "$f"; echo "  sync  $name: $block"; changed=$((changed+1))
      fi
    fi
  done
done

echo
if [ "$mode" = "check" ]; then
  [ "$rc" -eq 0 ] && echo "in sync: $checked skills" || echo "OUT OF SYNC — run .github/sync-shared.sh"
else
  echo "checked $checked skills, updated $changed block(s)"
fi
exit $rc
