terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}



az ad sp create-for-rbac --role=a3dcc999-0424-4c08-b563-3b7a7a9a8e91 --scopes="/subscriptions/bc1627c6-ec80-4da3-8d18-03e91330e2f1/resourcegroups/aro-y5sdwcze"

az role definition create --role-definition '{
    "Name": "portworx-cloud-drive-2",
    "Description": "",
    "AssignableScopes": [
    "/subscriptions/bc1627c6-ec80-4da3-8d18-03e91330e2f1"
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
  }]
}'