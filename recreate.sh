#!/usr/bin/env bash

set -euo pipefail

cd infra

terraform state rm github_repository.infrastructure || true
terraform destroy -auto-approve

terraform import github_repository.infrastructure infrastructure
terraform apply -auto-approve