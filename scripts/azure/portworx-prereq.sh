#!/bin/bash

echo "Azure account setup logic goes here"


exit 0

CLUSTER_NAME="toolkit-dev-aro"
RESOURCE_GROUP_NAME="aro-toolkit-dev"

#todo: login using env vars
#az login

az account set -–subscription $SUBSCRIPTION_ID

az role definition create --role-definition '{
        "Name": "portworx-cloud-drive",
        "Description": "",
        "AssignableScopes": [
            "/subscriptions/' + $SUBSCRIPTION_ID + '"
        ],
        "Permissions": [
            {
                "Actions": [
                    "Microsoft.ContainerService/managedClusters/agentPools/read",
                    "Microsoft.Compute/disks/delete",
                    "Microsoft.Compute/disks/write",
                    "Microsoft.Compute/disks/read",
                    "Microsoft.Compute/virtualMachines/write",
                    "Microsoft.Compute/virtualMachines/read",
                    "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/write",
                    "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read"
                ],
                "NotActions": [],
                "DataActions": [],
                "NotDataActions": []
            }
        ]
}'



az aro show -n $CLUSTER_NAME -g $RESOURCE_GROUP_NAME | jq -r '.nodeResourceGroup'


az ad sp create-for-rbac --role=portworx-cloud-drive --scopes="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
{
  "appId": "1311e5f6-xxxx-xxxx-xxxx-ede45a6b2bde",
  "displayName": "azure-cli-2020-10-10-10-10-10",
  "name": "http://azure-cli-2020-10-10-10-10-10",
  "password": "ac49a307-xxxx-xxxx-xxxx-fa551e221170",
  "tenant": "ca9700ce-xxxx-xxxx-xxxx-09c48f71d0ce"
}

#todo: login to cluster
kubectl create secret generic -n kube-system px-azure --from-literal=AZURE_TENANT_ID=<tenant> \
                                                      --from-literal=AZURE_CLIENT_ID=<appId> \
                                                      --from-literal=AZURE_CLIENT_SECRET=<password>