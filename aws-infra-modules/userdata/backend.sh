#!/bin/bash
set -e

yum update -y

yum install -y curl unzip python3 python3-pip git --allowerasing
pip3 install boto3 botocore
pip3 install --upgrade pip

pip3 install ansible
ansible --version
aws --version

mkdir -p /workspaces/ansible

aws s3 cp s3://${S3_BUCKET_NAME}/ansible/ /workspaces/ansible/ --recursive

cd /workspaces/ansible
ansible-playbook -i inventory/all.yml playbooks/backend-site.yml --limit backend --extra-vars "client_name=${CLIENT_NAME} client_environment=${CLIENT_ENVIRONMENT} aws_region=${AWS_REGION} aws_account_id=${AWS_ACCOUNT_ID}"
