#!/usr/bin/env bash

set -euo pipefail

GKE_PROJECT_ID="homelab-338008"
DNS_PROJECT_ID="homelab-338008"

GKE_CLUSTER_NAME="javelin"
GKE_REGION="europe-west4"

DNS_SA_NAME="external-dns-sa"
DNS_SA_EMAIL="$DNS_SA_NAME@${GKE_PROJECT_ID}.iam.gserviceaccount.com"

gcloud iam service-accounts create $DNS_SA_NAME --display-name $DNS_SA_NAME
gcloud projects add-iam-policy-binding $DNS_PROJECT_ID \
   --member serviceAccount:$DNS_SA_EMAIL --role "roles/dns.admin"

gcloud iam service-accounts add-iam-policy-binding $DNS_SA_EMAIL \
  --role "roles/iam.workloadIdentityUser" \
  --member "serviceAccount:$GKE_PROJECT_ID.svc.id.goog[${EXTERNALDNS_NS:-"default"}/external-dns]"