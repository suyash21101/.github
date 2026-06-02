#!/usr/bin/env bash
# Minimal contract-test helpers for reusable-workflow modules.
# Usage: source this file, then call assert_contains / assert_absent / done_ok.
set -euo pipefail

FAILS=0

# assert_contains <file> <grep-extended-pattern> <human description>
assert_contains() {
  local file="$1" pat="$2" desc="$3"
  if grep -Eq -- "$pat" "$file"; then
    echo "  ok: $desc"
  else
    echo "  FAIL: $desc (pattern: $pat)"
    FAILS=$((FAILS + 1))
  fi
}

# assert_absent <file> <grep-extended-pattern> <human description>
assert_absent() {
  local file="$1" pat="$2" desc="$3"
  if grep -Eq -- "$pat" "$file"; then
    echo "  FAIL: $desc (unexpected pattern present: $pat)"
    FAILS=$((FAILS + 1))
  else
    echo "  ok: $desc"
  fi
}

done_ok() {
  if [ "$FAILS" -ne 0 ]; then
    echo "CONTRACT FAILED: $FAILS assertion(s) failed"
    exit 1
  fi
  echo "CONTRACT PASSED"
}
