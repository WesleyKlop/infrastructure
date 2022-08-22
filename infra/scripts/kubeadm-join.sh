#!/usr/bin/env bash

set -e

eval "$(jq -r '@sh "HOST=\(.host) PRIV_KEY=\(.sshkey) HOST_INTERNAL=\(.hostinternal)"')"

echo "$PRIV_KEY" > /tmp/tmp_key
chmod 600 /tmp/tmp_key

CMD="$(ssh -o BatchMode=yes \
 -o StrictHostKeyChecking=no \
 -o UserKnownHostsFile=/dev/null \
 -i /tmp/tmp_key \
  root@$HOST kubeadm token create --print-join-command --ttl 1h)"
CMD="$(echo "$CMD" | sed "s/$HOST/$HOST_INTERNAL/")"

rm /tmp/tmp_key

# Safely produce a JSON object containing the result value.
# jq will ensure that the value is properly quoted
# and escaped to produce a valid JSON string.
jq -n --arg command "$CMD" '{"command":$command}'