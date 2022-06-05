#!/usr/bin/env bash

set -euo pipefail

flux bootstrap github \
  --owner="WesleyKlop" \
  --repository=infrastructure \
  --branch=main \
  --personal --path=./clusters/idris
