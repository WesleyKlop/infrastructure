#!/usr/bin/env bash

set -euo pipefail

curl -Lo kube-flannel-new.yml "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"

if cmp -s "kube-flannel.yml" "kube-flannel-new.yml"; then
    >&2 echo "Files are identical, so there is nothing to do."
    exit 0
fi

echo -e "Downloaded new version, here is the diff:\n\n\n"

diff kube-flannel.yml kube-flannel-new.yml || true

read -p "Keep the new version? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    mv kube-flannel-new.yml kube-flannel.yml
    echo "To apply: "
    echo "kubectl apply -f kube-flannel.yml"
fi

echo "Finished."
