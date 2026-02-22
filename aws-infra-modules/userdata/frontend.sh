#!/bin/bash

# Update system packages
apt update -y
apt upgrade -y

# Install prerequisites
apt install -y curl software-properties-common unzip

# Install Ansible
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update -y
apt install -y ansible

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
rm -rf awscliv2.zip aws

# Create directory for Ansible files
mkdir -p /workspaces/ansible

# Copy Ansible folder from S3 bucket using variables
aws s3 cp s3://${S3_BUCKET_NAME}/ansible/ /workspaces/ansible/ --recursive

# Export variables for Ansible
export CLIENT_NAME=$CLIENT_NAME
export CLIENT_ENVIRONMENT=$CLIENT_ENVIRONMENT
export AWS_REGION=$AWS_REGION
export AWS_ACCOUNT_ID=$AWS_ACCOUNT_ID

# Run Ansible playbook with dynamic inventory
cd /workspaces/ansible
ansible-playbook -i inventory/all.yml playbooks/frontend-site.yml --limit frontend
