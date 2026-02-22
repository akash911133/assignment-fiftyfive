#!/bin/bash

# Update system packages
yum update -y

# Install required packages
yum install -y curl unzip python3 python3-pip git --allowerasing
pip3 install boto3 botocore

# Install Ansible (stable version)
amazon-linux-extras enable ansible2
yum install -y ansible

# Verify installations
ansible --version
aws --version

# Create directory for Ansible files
mkdir -p /workspaces/ansible

# Copy Ansible folder from S3 bucket
aws s3 cp s3://${S3_BUCKET_NAME}/ansible/ /workspaces/ansible/ --recursive

# Run Ansible playbook
cd /workspaces/ansible
ansible-playbook -i inventory/all.yml playbooks/frontend-site.yml --limit frontend --extra-vars "client_name=${CLIENT_NAME} client_environment=${CLIENT_ENVIRONMENT} aws_region=${AWS_REGION} aws_account_id=${AWS_ACCOUNT_ID}"
