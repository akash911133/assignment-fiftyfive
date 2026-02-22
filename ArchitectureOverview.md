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

### Components

#### Infrastructure Layer
- **VPC**: Custom networking with public and private subnets
- **Public Application Load Balancer**: Internet-facing load balancer for frontend access
- **Internal Application Load Balancer**: Internal load balancer for frontend→backend communication
- **Security Groups**: Tier-based network security rules
- **Auto Scaling Groups**: Separate ASGs for frontend and backend instances
- **EC2 Instances**: Frontend and backend compute resources in private subnets
- **SSM Parameter Store**: Centralized configuration management

#### Application Layer
- **Frontend**: nginx reverse proxy + frontend application container
- **Backend**: API service container with MongoDB database
- **Containerization**: Docker Compose orchestration
- **ECR Integration**: Private container registry for images

## Deployment Process

### 1. Infrastructure Provisioning (Terraform)

The infrastructure is deployed using Terraform.

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

#### ECR Image Repository Structure
```
${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/
├── app-frontend:{git_short_sha}
└── app-backend:{git_short_sha}
```

#### Image Deployment Flow
1. **Change Detection**: CI/CD pipeline monitors `images/` directory for changes
2. **Build Phase**: Images built with Git short SHA tags
3. **ECR Push**: Images pushed to private ECR repositories
4. **SSM Registration**: Image URIs with Git SHA tags stored in SSM Parameter Store
5. **EC2 Bootstrap**: Instances retrieve current image information from SSM
6. **Ansible Deployment**: Ansible pulls specific Git SHA tagged images and deploys containers

### 3. User Data Execution Process

#### Frontend Bootstrap (`frontend.sh`)
#### Backend Bootstrap (`backend.sh`)

### 4. Ansible Configuration Management

#### SSM Parameter Retrieval
The custom Ansible module `ssm_params.py` retrieves configuration:
```python
# Parameters retrieved:
- internal_alb_dns: /${client_name}/${client_environment}/internal-alb-dns
- ecr_frontend_image: /${client_name}/${client_environment}/ecr-frontend-image  
- ecr_backend_image: /${client_name}/${client_environment}/ecr-backend-image
```

#### Frontend Deployment (`frontend-site.yml`)
1. **Common Setup**: Base system configuration
2. **Frontend Role**:
   - Docker installation and service start
   - ECR login and image pull
   - nginx configuration generation
   - Docker Compose deployment

#### Backend Deployment (`backend-site.yml`)
1. **Common Setup**: Base system configuration  
2. **Backend Role**:
   - Docker installation and service start
   - ECR login and image pull
   - MongoDB container deployment
   - Backend application deployment

## Required Parameters

### Terraform Variables

Create a `terraform.tfvars` file with the following parameters:

```hcl
# Client Identification
client_name        = "example-client"
client_environment = "production"

# AWS Configuration  
aws_region         = "eu-west-1"
aws_account_id     = "123456789012"

# Networking
vpc_cidr           = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# Compute
ami_id             = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2
instance_type      = "t3.medium"
key_name           = "your-key-pair"

# Container Images
front_image_tag    = "a1b2c3d"  # Git short SHA for frontend
backend_image_tag  = "a1b2c3d"  # Git short SHA for backend

# Storage
s3_bucket_name     = "your-ansible-artifacts-bucket"
```

### Environment Variables for User Data

The EC2 instances require these environment variables:

```bash
# Client Configuration
CLIENT_NAME="example-client"
CLIENT_ENVIRONMENT="production"

# AWS Configuration  
AWS_REGION="eu-west-1"
AWS_ACCOUNT_ID="123456789012"

# Ansible Artifacts
S3_BUCKET_NAME="your-ansible-artifacts-bucket"
```

### SSM Parameters Structure

The infrastructure automatically creates these SSM parameters:

```
/${client_name}/${client_environment}/
├── internal-alb-dns
├── ecr-frontend-image  
└── ecr-backend-image
```

## Deployment Steps

### Prerequisites
1. AWS CLI configured with appropriate permissions
2. Terraform installed
3. Git repository with `images/frontend/` and `images/backend/` directories
4. CI/CD pipeline configured for automatic image builds
5. Ansible playbooks uploaded to S3 bucket

### Step-by-Step Deployment

1. **Prepare Infrastructure Variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your values
   ```

2. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan -var-file="terraform.tfvars"
   terraform apply -var-file="terraform.tfvars"
   ```

## Monitor Deployment ##
   - Check EC2 instance initialization via AWS Console
   - Verify SSM parameters are created with correct Git SHA tags
   - Monitor ALB target group health



## Security Considerations

- **Network Security**: Security groups restrict traffic between tiers
- **IAM Roles**: EC2 instances have least-privilege access
- **Private Subnets**: Both frontend and backend in private subnets for enhanced security
- **Public Access**: Only Public ALB has internet access via public subnets
- **Internal Communication**: Frontend→Backend traffic via Internal ALB only
- **Container Security**: Images stored in private ECR repository

## Monitoring and Troubleshooting

### Health Checks
- **Public ALB Health**: Frontend instances monitored for external access
- **Internal ALB Health**: Backend instances monitored on `/health` endpoint
- **Auto Scaling**: Unhealthy instances automatically replaced in both ASGs

### Logs
- **System Logs**: `/var/log/cloud-init-output.log`
- **Ansible Logs**: Ansible output during configuration
- **Application Logs**: Docker container logs

### Common Issues
1. **SSM Parameter Access**: Verify IAM permissions for SSM
2. **ECR Pull**: Check ECR repository permissions
3. **Network Connectivity**: Verify security group rules
4. **Container Health**: Check Docker logs and resource constraints

## Scaling and Maintenance

### Auto Scaling
- **Frontend ASG**: Automatically scales based on Public ALB health and traffic
- **Backend ASG**: Automatically scales based on Internal ALB health and traffic
- **Manual Scaling**: Update `desired_capacity` in Terraform for either ASG

### Updates
- **Image Updates**: 
  - Commit changes to `images/frontend/` or `images/backend/` directories
  - CI/CD automatically builds new images with Git short SHA tags
  - Update Terraform variables with new Git SHA and re-apply
- **Configuration Changes**: Update Ansible playbooks in S3 bucket
- **Infrastructure Changes**: Modify Terraform modules and re-apply

This infrastructure provides a scalable, secure, and automated deployment platform for multi-customer 3-tier applications.
