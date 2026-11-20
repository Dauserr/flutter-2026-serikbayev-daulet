#!/usr/bin/env bash
set -euo pipefail

bad_http=$(grep -rl "package:http" lib/ | grep -v -e '^lib/core/api' -e '_repository.dart$' || true)
if [ -n "$bad_http" ]; then
  echo "$bad_http"
  exit 1
fi

bad_material=$(grep -rl "package:flutter/material" lib/ | grep -e '_model.dart$' -e '_repository.dart$' -e '^lib/core/api' || true)
if [ -n "$bad_material" ]; then
  echo "$bad_material"
  exit 1
fi