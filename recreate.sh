#!/usr/bin/env bash

set -euo pipefail

terraform state rm github_repository.infrastructure || true
hcloud load-balancer delete traefik || true
terraform destroy -auto-approve

terraform import github_repository.infrastructure infrastructure
exit 0
terraform apply -auto-approve

CONTROL_PLANE="$(hcloud server describe control-plane -o json)"
PUB_IP="$(echo "$CONTROL_PLANE" | jq -r '.public_net.ipv4.ip')"
PRIV_IP="$(echo "$CONTROL_PLANE" | jq -r '.private_net[0].ip')"
hcloud server ssh control-plane cat .kube/config | sed -E "s/$PRIV_IP/$PUB_IP/; s/kubernetes(.*)?/javelin/g" > ~/.kube/javelin