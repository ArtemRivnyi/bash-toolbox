#!/usr/bin/env bash
echo '=== Environment Diagnostics ==='
env | grep -iE 'path|user|lang' || true
