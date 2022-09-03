#!/usr/bin/env bash

set -euo pipefail

terraform state rm module.gitops.github_repository.gitops || true
hcloud load-balancer delete traefik || true
terraform destroy -auto-approve

terraform import module.gitops.github_repository.gitops infrastructure
exit 0
terraform apply -auto-approve

CONTROL_PLANE="$(hcloud server describe control-plane -o json)"
PUB_IP="$(echo "$CONTROL_PLANE" | jq -r '.public_net.ipv4.ip')"
PRIV_IP="$(echo "$CONTROL_PLANE" | jq -r '.private_net[0].ip')"
hcloud server ssh control-plane cat .kube/config | sed -E "s/$PRIV_IP/$PUB_IP/; s/kubernetes(.*)?/javelin/g" > ~/.kube/javelin