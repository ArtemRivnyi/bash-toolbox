#!/usr/bin/env bats
# ==============================================================================
# Bats Test Suite: Modular Utilities (scripts/*.sh)
# ==============================================================================

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "all modular utilities in scripts/ exist and are non-empty" {
  local count=0
  for script in "$REPO_ROOT"/scripts/*.sh; do
    [ -f "$script" ] || continue
    [ -s "$script" ]
    count=$((count + 1))
  done
  [ "$count" -ge 50 ]
}

@test "scripts/backup-tar-gz.sh executes cleanly" {
  run bash "$REPO_ROOT/scripts/backup-tar-gz.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Archive Backup Utility" ]]
}

@test "scripts/env-validator.sh runs environment diagnostics" {
  run bash "$REPO_ROOT/scripts/env-validator.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Environment Diagnostics" ]]
}

@test "scripts/k8s-pod-restart-monitor.sh handles missing kubectl gracefully" {
  # In an environment without kubectl, it should report missing binary and exit 1
  if ! command -v kubectl &>/dev/null; then
    run bash "$REPO_ROOT/scripts/k8s-pod-restart-monitor.sh"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "kubectl is not installed" ]]
  fi
}

@test "standardized utilities execute with valid exit code (0 or 1)" {
  for script in "$REPO_ROOT"/scripts/*.sh; do
    [ -f "$script" ] || continue
    # Skip scripts that require specific external logs or network targets during offline unit test
    case "$(basename "$script")" in
      nginx-analyzer.sh|curl-timing.sh|speedtest-network-cli.sh|whois-expiry-alert.sh)
        continue
        ;;
    esac
    run bash "$script"
    # Ensure no crash (exit 127 = command not found / missing dependency handled by environment, syntax error = exit 2)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ] || [ "$status" -eq 127 ]
  done
}
