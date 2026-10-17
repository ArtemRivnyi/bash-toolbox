#!/usr/bin/env bash
echo '=== Listening Ports ==='
ss -tuln || netstat -tuln
