#!/bin/bash

#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

if [[ -z "${INSTALLER_WORKSPACE}" ]]; then
  echo "INSTALLER_WORKSPACE must be provided as an environment variable" >&2
  exit 1
fi

export region=$1
export AWS_DEFAULT_REGION=${region}
INSTALL=$2
VAR=`date '+%F-%H-%M-%S'`

#Install aws CLI
if ! [ -x "$(command -v pip)" ]; then
    curl -O https://bootstrap.pypa.io/get-pip.py > /dev/null
    python3 get-pip.py --user > /dev/null
    rm -f get-pip.py
fi
if ! [ -x "$(command -v aws)" ]; then
    pip install awscli --upgrade --user > /dev/null
fi


#aws configure list

CLUSTERID=$(oc get machineset -n openshift-machine-api -o jsonpath='{.items[0].metadata.labels.machine\.openshift\.io/cluster-api-cluster}')
echo "CLUSTERID : ${CLUSTERID}"
#Providing permissions for all the instances in the autoscaling cluster
INST_PROFILE_NAME=`aws ec2 describe-instances --query 'Reservations[*].Instances[*].[IamInstanceProfile.Arn]' --output text --region $region | cut -d ':' -f 6 | cut -d '/' -f 2 | grep "$CLUSTERID-worker-profile" | uniq`
echo " INST_PROFILE_NAME : ${INST_PROFILE_NAME}"

ROLE_NAME=`aws iam get-instance-profile --instance-profile-name $INST_PROFILE_NAME --query 'InstanceProfile.Roles[*].[RoleName]' --output text --region $region`



WORKER_TAG=`aws ec2 describe-security-groups --query 'SecurityGroups[*].Tags[*][Value]' --output text --region $region | grep "$CLUSTERID-worker-sg"`
MASTER_TAG=`aws ec2 describe-security-groups --query 'SecurityGroups[*].Tags[*][Value]' --output text --region $region | grep "$CLUSTERID-master-sg"`
WORKER_GROUP_ID=`aws ec2 describe-security-groups --filters Name=tag:Name,Values=$WORKER_TAG --query "SecurityGroups[*].{Name:GroupId}" --output text --region $region`
MASTER_GROUP_ID=`aws ec2 describe-security-groups --filters Name=tag:Name,Values=$MASTER_TAG --query "SecurityGroups[*].{Name:GroupId}" --output text --region $region`

echo "WORKER_GROUP_ID ${WORKER_GROUP_ID}"
echo "MASTER_GROUP_ID ${MASTER_GROUP_ID}"

if [[ "${INSTALL}" == "true" ]]; then
  echo "Installing portworx pre-reqs"
  #POLICY_ARN=`aws iam create-policy --policy-name portworx-policy-${VAR} --policy-document file:///${SCRIPT_DIR}/policy.json --query 'Policy.Arn' --output text --region $region`
    echo "${SCRIPT_DIR} : ${SCRIPT_DIR}"
    
    POLICY_ARN=`aws iam create-policy --policy-name portworx-policy-${VAR} --policy-document  file:///${SCRIPT_DIR}/policy.json --query 'Policy.Arn' --output text --region $region`

    echo " POLICY_ARN : ${POLICY_ARN}"
    aws iam attach-role-policy --role-name $ROLE_NAME --policy-arn $POLICY_ARN
    
    #Add rule for 17001-17020 port
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 17001-17020 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 17001-17020 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 111 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 111 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 2049 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 2049 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 20048 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 authorize-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 20048 --source-group $WORKER_GROUP_ID --region $region

  exit 0
fi


if [[ "${INSTALL}" == "false" ]]; then
  echo "Uninstalling portworx pre-re qs"
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 17001-17020 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 17001-17020 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 111 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 111 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 2049 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 2049 --source-group $WORKER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 20048 --source-group $MASTER_GROUP_ID --region $region
    aws ec2 revoke-security-group-ingress --group-id $WORKER_GROUP_ID --protocol tcp --port 20048 --source-group $WORKER_GROUP_ID --region $region

  exit 0
fi

