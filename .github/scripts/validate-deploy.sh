#!/usr/bin/env bash


echo "sleeping for 2 mins to prevent synchronization errors"
sleep 2m

echo "checking for portworx services"

oc rollout status daemonset/portworx-api -n kube-system


sleep 8m


exit 0
