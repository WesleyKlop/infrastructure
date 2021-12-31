#!/usr/bin/env bash

set -euo pipefail

curl -Lo kube-flannel.yml "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"

if git diff --exit-code kube-flannel.yml; then
    >&2 echo "Files are identical, so there is nothing to do."
    exit 0
fi

echo -e "Downloaded new version, here is the diff:\n\n\n"

git diff kube-flannel.yml

read -p "Keep the new version? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "To apply: "
    echo "kubectl apply -f kube-flannel.yml"
fi

echo "Finished."
