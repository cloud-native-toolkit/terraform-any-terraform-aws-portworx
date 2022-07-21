#!/usr/bin/env bash

set -e

BIN_DIR=$(cat .bin_dir)
export PATH="${BIN_DIR}:${PATH}"

export KUBECONFIG=$(cat .kubeconfig)
echo "sleeping for 2 mins to prevent synchronization errors"
sleep 2m

echo "checking for portworx services"


# count=0
# until oc get daemonset/portworx-api -n kube-system || [[ $count -eq 20 ]]; do
#   echo "Waiting for daemonset/portworx-api -n kube-system"
#   count=$((count + 1))
#   sleep 15
# done

# if [[ $count -eq 20 ]]; then
#   echo "Timed out waiting for daemonset/portworx-api -n kube-system"
#   exit 1
# fi

# oc rollout status daemonset/portworx-api -n kube-system

# exit 0



oc rollout status deployment/portworx-operator -n kube-system

PX_POD=$(kubectl get pods -l name=portworx -n kube-system -o json | jq -r '.items[] | .metadata.name' | head -1)

if [[ -z "${PX_POD}" ]]; then
  echo "Portworx pod name not found" >&2
  exit 1
else
  echo "Portworx pod name: ${PX_POD}"
fi

#kubectl exec "${PX_POD}" -n kube-system -- /opt/pwx/bin/pxctl status

exit 0
