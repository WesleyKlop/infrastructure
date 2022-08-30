#!/usr/bin/env bash

set -euo pipefail

cd infra

tf state rm github_repository.infrastructure || true
tf destroy -auto-approve

tf import github_repository.infrastructure infrastructure
tf apply -auto-approve