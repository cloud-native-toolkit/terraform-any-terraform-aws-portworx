#!/usr/bin/env bash


echo "sleeping for 5 mins to prevent synchronization errors"
sleep 5m

echo "checking for portworx services"

oc rollout status daemonset/portworx-api -n kube-system

exit 0
