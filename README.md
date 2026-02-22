# 3-Tier Application Infrastructure Deployment Guide

## Overview

This project provides a production-ready 3-tier application infrastructure designed for multi-customer environments. The infrastructure automates deployment of containerized applications using Terraform for infrastructure provisioning and Ansible for configuration management.

## Architecture

### 3-Tier Structure

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Public ALB     │    │  Internal ALB   │    │   Backend       │
│   (Internet)     │───▶│  (Frontend→     │───▶│   (API +        │
│   Port 80/443    │    │   Backend)      │    │   App Server)   │
│   Public Subnet  │    │  Private Subnet │    │   Private Subnet│
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                        │                        │
         ▼                        ▼                        ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend ASG  │    │   Frontend      │    │   Database      │
│   (Multiple     │    │   (nginx +      │    │   (MongoDB)     │
│   Instances)    │    │   Frontend App) │    │                 │
│   Private Subnet│    │   Private Subnet│    │   Private Subnet│
└─────────────────┘    └─────────────────┘    └─────────────────┘
```


# Stack Deployment Guide

### Deployment Workflow

1. **Configuration Setup**
   - Create `terraform.tfvars` with client-specific variables
   - Trigger deployment via GitHub Actions
   - Pass `client_name` and `aws_account_id` as inputs

2. **Infrastructure Creation**
   - GitHub Actions executes Terraform deployment
   - Creates secure infrastructure based on configuration
   - Includes VPC, security groups, ALBs, ASGs, and EC2 instances

3. **Automated Configuration**
   - EC2 instances boot with user data scripts
   - User data executes Ansible playbooks on localhost
   - Ansible fetches variables from SSM parameters and runtime environment and execute the playbook

4. **Success Validation**
   - Upon successful Ansible execution, instances are tagged:
     - `node-configure: success`
     - `configuration-timestamp: <timestamp>`
     - `configured-by: ansible`

## Required Configuration

### terraform.tfvars Variables
```hcl
# Client Configuration
client_name        = "example-client"
client_environment = "production"

# AWS Configuration  
aws_region         = "eu-west-1"
aws_account_id     = "123456789012"

# Container Images (Git SHA)
front_image_tag    = "a1b2c3d"
backend_image_tag  = "a1b2c3d"

# Infrastructure
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# Compute
ami_id             = "ami-0c55b159cbfafe1f0"
instance_type      = "t3.medium"
key_name           = "your-key-pair"

# Storage
s3_bucket_name     = "your-ansible-artifacts-bucket"
```

## Access Method

### Bastion Host Access
- **Purpose**: Secure access to application nodes
- **Method**: SSH through bastion host only
- **Restriction**: Limited access with security controls
- **Flow**: User → Bastion → Application instances

## Deployment Process Summary

1. **Configure**: Set up `terraform.tfvars` with client parameters
2. **Deploy**: Trigger GitHub Actions with client name and AWS account
3. **Create**: Infrastructure automatically provisioned
4. **Configure**: Ansible executes via user data, tags success on completion
5. **Access**: Connect through bastion host for management

This ensures secure, automated, and repeatable deployments for multi-customer environments.



### 2. Image Deployment Pipeline

#### Image Build Process
Images are automatically built from the `images/` directory when changes are detected:

```
images/
├── frontend/
│   ├── Dockerfile
│   ├── src/
│   └── nginx.conf
└── backend/
    ├── Dockerfile
    ├── src/
    └── requirements.txt
```

#### Git-based Tagging Strategy
- **Trigger**: Changes detected in `images/frontend/` or `images/backend/` directories
- **Tag Format**: `frontend:{git_short_sha}` and `backend:{git_short_sha}`
- **Git Short SHA**: First 7 characters of the commit hash (e.g., `a1b2c3d`)
