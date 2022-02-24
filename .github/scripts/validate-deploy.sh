#!/usr/bin/env bash


echo "sleeping for 2 mins to prevent synchronization errors"
sleep 2m

echo "checking for portworx services"


count=0
until kubectl get daemonset/portworx-api -n kube-system || [[ $count -eq 20 ]]; do
  echo "Waiting for daemonset/portworx-api -n kube-system"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for daemonset/portworx-api -n kube-system"
  kubectl get all -n ${NAMESPACE}
  exit 1
fi

exit 0
