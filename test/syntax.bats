#!/usr/bin/env bats
# ==============================================================================
# Bats Test Suite: Syntax & Integrity Validation
# ==============================================================================

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "all shell scripts pass syntax check (bash -n)" {
  for script in "$REPO_ROOT"/*.sh "$REPO_ROOT"/scripts/*.sh; do
    [ -f "$script" ] || continue
    run bash -n "$script"
    [ "$status" -eq 0 ]
  done
}

@test "all shell scripts have a valid bash shebang" {
  for script in "$REPO_ROOT"/*.sh "$REPO_ROOT"/scripts/*.sh; do
    [ -f "$script" ] || continue
    first_line=$(head -n 1 "$script")
    [[ "$first_line" =~ ^#!.*bash ]]
  done
}

@test "all shell scripts have executable permissions" {
  for script in "$REPO_ROOT"/*.sh "$REPO_ROOT"/scripts/*.sh; do
    [ -f "$script" ] || continue
    [ -x "$script" ]
  done
}
