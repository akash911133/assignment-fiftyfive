###########################################################
variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "client_name" {
  description = "Client Name"
  type        = string
}

variable "client_environment" {
  description = "Environment (dev/prod)"
  type        = string
}

#######################  VPC #################################

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "azs" {
  description = "Availability Zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
}


#####################  ec2 

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "s3_bucket_name" {
  description = "S3 bucket name for Ansible files"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "front_image_tag" {
  description = "Frontend image tag"
  type        = string
}

variable "backend_image_tag" {
  description = "Backend image tag"
  type        = string
}
