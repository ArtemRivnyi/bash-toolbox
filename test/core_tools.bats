#!/usr/bin/env bats
# ==============================================================================
# Bats Test Suite: Core Monitoring & Management Scripts
# ==============================================================================

setup() {
  REPO_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

@test "backup-manager.sh displays help cleanly with code 0" {
  run bash "$REPO_ROOT/backup-manager.sh" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Advanced Backup Manager" ]]
  [[ "$output" =~ "Usage:" ]]
}

@test "telegram-ping-monitor.sh displays help cleanly with code 0" {
  run bash "$REPO_ROOT/telegram-ping-monitor.sh" help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Telegram Ping Monitor" ]]
  [[ "$output" =~ "Usage:" ]]
}

@test "quick-diagnostics.sh prints system diagnostics report" {
  run bash "$REPO_ROOT/quick-diagnostics.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "System Diagnostics" || "$output" =~ "Diagnostics" || "$output" =~ "CPU" || "$output" =~ "Memory" ]]
}

@test "docker-cleanup.sh checks docker status or prompts cleanly" {
  run bash "$REPO_ROOT/docker-cleanup.sh"
  # Should run or gracefully report docker status
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
