#!/usr/bin/env bash

set -euo pipefail

GPG_KEY="08A2 0684 5A41 CF2E 937E  C8E2 AFB0 3664 9EF9 7CB6"
FILENAME="$1"

if ! test -f "$FILENAME"; then
  echo "File $FILENAME does not exist"
  exit 1
fi

exec sops --encrypt \
--encrypted-regex '^(data|stringData)$' \
--in-place "$FILENAME"



