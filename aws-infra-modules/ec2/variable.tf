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

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "ami_id" {
  type = string
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

variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

