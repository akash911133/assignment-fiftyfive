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
