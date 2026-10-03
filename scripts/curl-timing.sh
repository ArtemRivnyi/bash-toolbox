#!/usr/bin/env bash
echo '=== HTTP Request Timing ==='
curl -w 'Total: %{time_total}s\n' -s -o /dev/null https://httpbin.org/get || true
