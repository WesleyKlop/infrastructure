# Infrastructure

![Cloudlab Status](https://argocd.wesley.io/api/badge?name=argo-cd&revision=true)
![Homelab Status](https://argocd.wesl.io/api/badge?name=argo-cd&revision=true)

This repository contains the infrastructure for my Homelab & Cloudlab.

The Homelab is a single node kubeadm cluster running on Ubuntu 20.04 The
Cloudlab is a 4 node kubeadm cluster running on Ubuntu 20.04, deployed fully
automatically to Hetzner using Terraform!

## Repository layout

-   Terraform configuration is located in the root and [modules](modules)
    folders. These define the node, control-plane, worker and this repo config.
-   Init configuration to kick-start a cluster is located under [init](init).
    These define some required secrets and configuration to setup argo-cd for
    phase-2. At this point Argo CD takes over.
-   Bootstrap configuration for phase-2 of initializing is located under
    [bootstrap](bootstrap).
-   Deployed app configuration is under [apps](apps).

# Homelab

## Storage

The node has a 6TB storage pool on ZFS. Persistent Volume Claims can be created
using the `tank-zfspv` storage class to use that storage.

# Cloudlab

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
-   `github_token` giving GitHub api access for Terraform.

-   `cluster_api_token` giving Hetzner api access for the Hcloud Cloud
    Controller manager and Container Storage Interface.
-   `management_ssh_key_id` defining an extra ssh key id that should be added to
    the nodes for management purposes. This is either a pubkey or Hetzner ssh
    key id

-   `op_credentials` giving 1password-connect access to 1password.
-   `op_token` giving external-secrets access to the vault via
    1password-connect.

-   `gha_tf_api_token` giving GitHub actions access to Terraform Cloud.

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
