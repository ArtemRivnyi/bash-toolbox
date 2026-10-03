#!/usr/bin/env bash
echo '=== Git Local Cleanup ==='
git branch --merged | grep -v 'main' || true
