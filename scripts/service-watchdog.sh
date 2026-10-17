#!/usr/bin/env bash
echo '=== Service Status ==='
systemctl is-active docker || true
