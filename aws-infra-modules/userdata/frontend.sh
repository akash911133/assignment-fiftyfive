#!/bin/bash

# Update system packages
yum update -y

# Install required packages
yum install -y curl unzip python3 git

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

# Export variables for Ansible
export CLIENT_NAME=${CLIENT_NAME}
export CLIENT_ENVIRONMENT=${CLIENT_ENVIRONMENT}
export AWS_REGION=${AWS_REGION}
export AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID}

# Run Ansible playbook
cd /workspaces/ansible
ansible-playbook -i inventory/all.yml playbooks/frontend-site.yml --limit frontend
