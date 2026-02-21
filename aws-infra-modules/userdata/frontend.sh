#!/bin/bash
set -e

# Update system
apt update -y
apt upgrade -y

# Install dependencies
apt install -y software-properties-common curl unzip awscli

# Install Ansible
add-apt-repository --yes --update ppa:ansible/ansible
apt install -y ansible

# Create working directory
mkdir -p /opt/deployment
cd /opt/deployment

# Pull playbooks from S3
aws s3 sync s3://${bucket_name}/${client_name}/frontend ./ --delete

# Run Ansible playbook
ansible-playbook site.yml

