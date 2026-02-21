module "stack_vpc" {
    source  =  "../../aws/infra-module/vpc"

    client_name  = var.client_name
    client_environment = var.client_environment
    aws_region = var.aws_region

    vpc_cidr = var.vpc_cidr
    azs = var.azs
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    
}