#!/bin/bash
# Parameterized node bootstrap: same script for frontend and backend.
# Terraform passes: NODE_TYPE (frontend|backend), S3_BUCKET_NAME, CLIENT_NAME,
# CLIENT_ENVIRONMENT, AWS_REGION, AWS_ACCOUNT_ID

set -e

PLAYBOOK="${NODE_TYPE}-site.yml"
LIMIT="${NODE_TYPE}"

# Update system packages
yum update -y

# Install required packages
yum install -y curl unzip python3 python3-pip git ansible
pip3 install boto3 botocore

# Verify installations
ansible --version
aws --version

# Create directory for Ansible files and pull from S3
mkdir -p /workspaces/ansible
aws s3 cp "s3://${S3_BUCKET_NAME}/ansible/main" /workspaces/ansible/ --recursive

# Run Ansible playbook for this node type
cd /workspaces/ansible
ansible-playbook -i inventory/all.yml "playbooks/$${PLAYBOOK}" --limit "$${LIMIT}" \
  --extra-vars "client_name=${CLIENT_NAME} client_environment=${CLIENT_ENVIRONMENT} aws_region=${AWS_REGION} aws_account_id=${AWS_ACCOUNT_ID}"
