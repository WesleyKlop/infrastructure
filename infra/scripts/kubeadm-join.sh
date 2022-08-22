#!/usr/bin/env bash

set -e

eval "$(jq -r '@sh "HOST=\(.host)"')"

CMD="$(ssh -o BatchMode=yes \
 -o StrictHostKeyChecking=no \
 -o UserKnownHostsFile=/dev/null \
  root@$HOST kubeadm token create --print-join-command)"

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg command "$CMD" '{"command":$command}'