#!/usr/bin/env sh

set -eu

exec helm upgrade -f values.yaml --namespace traefik traefik traefik/traefik
