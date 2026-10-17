#!/usr/bin/env bash
echo '=== Git Local Cleanup ==='
git --no-pager branch --merged | grep -v 'main' || true
