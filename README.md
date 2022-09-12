# Infrastructure

![Cloudlab Status](https://argocd-javelin.wesl.io/api/badge?name=argo-cd&revision=true)

This repository contains the infrastructure for my Homelab & Cloudlab.

The Homelab is a single node kubeadm cluster running on Ubuntu 20.04 The
Cloudlab is a 3 node kubeadm cluster running on Ubuntu 20.04, deployed fully
automatically using Terraform!

## Repository layout

The repository is trying to follow Flux repository conventions. This means that:

-   Cluster configuration can be found under [clusters](clusters)
-   Infrastructure can be found under [infrastructure](infrastructure)
-   Applications can be found under [applications](applications)

## Environment management

Most applications use secrets to be configured. These are encrypted using sops
and are automatically decrypted by Flux. If you want to create a new secret, you
can just create a secret inside a yaml file like you normally would, and then
run `create-encrypted-secret.sh [filename]`. These can be safely committed to
the repository.

This should preferably not be used though. Instead, the cluster has
1password-connect installed and will automatically install secrets derived from
references OnePasswordItems.

## Storage

The node has a 6TB storage pool on ZFS. Persistent Volume Claims can be created
using the `tank-zfspv` storage class to use that storage.

## Logging & alerts

Logging is not really configured at the moment. I do have Lens metrics deployed.
Flux reconciliation and upgrade notifications are automatically send to Slack.

## Todo

-   [x] Logging with prometheus
-   [x] Dashboard with Grafana
-   [x] Automatedtesting
-   [ ] Improve automated image updates
-   [ ] Reduce usage of hostPath volumes

# Javelin

Climate change forcing me to migrate to the cloud smh.

## Bootstrapping

This time I wanted it to be :sparkles: automated :sparkles: so this cluster is
created on the Hetzner cloud platform using Terraform.

All required packages are installed using cloud-init and then Terraform
provisioners are used to bootstrap the kubernetes cluster using kubeadm. Once
the cluster is bootstrapped, Argo CD will be deployed and automatically pull in
all configuration from this repository, which will further reconciliate the
cluster into the desired state. Magic! :sparkles:

## Secrets

So all secrets originate either from Terraform or from 1Password Connect. There
are several secrets defined by Terraform that need to be provided beforehand:

-   `hcloud_token` giving Hetzner api access for Terraform.
-   `github_token` giving Github api access for Terraform.

-   `cluster_api_token` giving Hetzner api access for the Hcloud Cloud
    Controller manager and Container Storage Interface.
-   `management_ssh_key_id` defining an extra ssh key id that should be added to
    the nodes for management purposes. This is either a pubkey or hetzner ssh
    key id

-   `op_credentials` giving 1password-connect access to 1password.
-   `op_token` giving external-secrets access to the vault via
    1password-connect.

## GitOps

Once bootstrapping is done, all state is managed following the GitOps pattern.

## Security & Maintenance

YOLO :shrug: :shipit: <sup>I don't know yet... will get back to this
later.</sup>

The Cloudlab is secured by disabling all auth except ssh key auth. Almost all
ports are closed by the configured firewall.

Package updating etc I'm still thinking about. This is because nodes need to be
upgraded manually using kubeadm. I will probably create a terraform resource to
handle that in the future.
