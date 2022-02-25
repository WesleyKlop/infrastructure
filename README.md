# Infrastructure

This repository contains the infrastructure for my Homelab. It currently 
consists of a single node kubernetes cluster deployed using kubeadm on Ubuntu 
20.04.

## Repository layout

The repository is trying to follow Flux repository conventions. This means that:

- Cluster configuration can be found under [clusters](clusters)
- Infrastructure can be found under [infrastructure](infrastructure)
- Applications can be found under [applications](applications)

## Environment management

Most applications use secrets to be configured. These are encrypted using sops
and are automatically decrypted by Flux. If you want to create a new secret, 
you can just create a secret inside a yaml file like you normally would, and 
then run `create-encrypted-secret.sh [filename]`. These can be safely committed
to the repository.

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

- [x] Logging with prometheus
- [x] Dashboard with Grafana
- [x] Automated testing
- [ ] Improve automated image updates
- [ ] Reduce usage of hostPath volumes
