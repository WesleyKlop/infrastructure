fmt:
    npx prettier --write '.'
    terraform fmt -recursive

# Remove persistent objects from state and destroy all other resources
destroy:
    # We do not want to actually remove the github repository that would be bad
    terraform state rm module.gitops.github_repository.gitops || true
    # This is created by the hetzner cloud controller manager
    hcloud load-balancer delete traefik || true
    # Destroy all the things
    terraform destroy -auto-approve

# Import persistent objects to state and apply all other resources
apply:
    # Reimport already existing stuff
    terraform import module.gitops.github_repository.gitops infrastructure
    # Create all the things, this takes like 5-10 minutes
    terraform apply -auto-approve

# Import kubeconfig from the control-plane server
kubeconfig:
    #!/usr/bin/env bash
    set -euo pipefail
    CONTROL_PLANE="$(hcloud server describe control-plane -o json)"
    PUB_IP="$(echo "$CONTROL_PLANE" | jq -r '.public_net.ipv4.ip')"
    PRIV_IP="$(echo "$CONTROL_PLANE" | jq -r '.private_net[0].ip')"
    hcloud server ssh control-plane cat .kube/config | sed -E "s/$PRIV_IP/$PUB_IP/; s/kubernetes(.*)?/javelin/g" > ~/.kube/javelin

recreate: destroy apply kubeconfig