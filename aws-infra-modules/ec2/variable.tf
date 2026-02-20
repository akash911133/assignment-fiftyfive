variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "frontend_sg_id" {
  type = string
}

variable "backend_sg_id" {
  type = string
}

variable "public_alb_sg_id" {
  type = string
}

variable "internal_alb_sg_id" {
  type = string
}

variable "frontend_ami" {
  type = string
}

variable "backend_ami" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}