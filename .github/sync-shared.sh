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

mode="apply"; dir=""
for a in "$@"; do
  case "$a" in
    --check) mode="check" ;;
    -*)      echo "unknown option: $a" >&2; exit 2 ;;
    *)       dir="$a" ;;
  esac
done
dir="${dir:-skills}"
[ -d "$dir" ] || { echo "no such directory: $dir" >&2; exit 2; }
rc=0; changed=0; checked=0

for f in "$dir"/*/SKILL.md; do
  [ -f "$f" ] || continue
  name=$(basename "$(dirname "$f")")
  checked=$((checked+1))
  for block in onboarding-inline write-guardrail; do
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

  # the procedural half lives in the skill's own references/ dir so it travels
  # with a copied folder; SKILL.md points at it
  ref="$(dirname "$f")/references/onboarding.md"
  src=".github/shared/onboarding-reference.md"
  if [ ! -f "$src" ]; then
    echo "  FAIL  missing $src"; rc=1
  elif [ -f "$ref" ] && cmp -s "$ref" "$src"; then
    :
  elif [ "$mode" = "check" ]; then
    if [ -f "$ref" ]; then echo "  DRIFT $name: references/onboarding.md does not match $src"
    else echo "  DRIFT $name: references/onboarding.md is missing"; fi
    rc=1
  else
    mkdir -p "$(dirname "$ref")" && cp "$src" "$ref"
    echo "  sync  $name: references/onboarding.md"; changed=$((changed+1))
  fi
done

echo
if [ "$mode" = "check" ]; then
  [ "$rc" -eq 0 ] && echo "in sync: $checked skills" || echo "OUT OF SYNC — run .github/sync-shared.sh"
else
  echo "checked $checked skills, updated $changed block(s)"
fi
exit $rc
