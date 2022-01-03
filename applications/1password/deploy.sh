#!/usr/bin/env sh

set -eu

exec helm install -n 1password connect 1password/connect \
  --set-file connect.credentials=1password-credentials.json \
  --set-file operator.token.value=access-token \
  --set operator.create=true
