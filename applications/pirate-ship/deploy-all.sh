#!/usr/bin/env bash

set -euo pipefail

echo "Deploying base config"

kubectl apply -f .

echo "Deploying all applications"
kubectl apply \
 -f bazarr \
 -f radarr \
 -f sonarr \
 -f jackett \
 -f calibre-web \
 -f plex \
 -f transmission

echo "Finished"
