#!/bin/bash
set -e

yum update -y

yum install -y python3 python3-pip git unzip curl

pip3 install --upgrade pip

pip3 install ansible
ansible --version
aws --version

mkdir -p /workspaces/ansible

aws s3 cp s3://${S3_BUCKET_NAME}/ansible/ /workspaces/ansible/ --recursive

export CLIENT_NAME=${CLIENT_NAME}
export CLIENT_ENVIRONMENT=${CLIENT_ENVIRONMENT}
export AWS_REGION=${AWS_REGION}
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}

cd /workspaces/ansible
ansible-playbook -i inventory/all.yml playbooks/backend-site.yml --limit backend
