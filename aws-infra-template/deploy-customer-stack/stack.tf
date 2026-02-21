module "stack_vpc" {
    source  =  "../../aws-infra-modules/vpc"

    client_name  = var.client_name
    client_environment = var.client_environment
    aws_region = var.aws_region

    vpc_cidr = var.vpc_cidr
    azs = var.azs
    public_subnet_cidrs  = var.public_subnet_cidrs
    private_subnet_cidrs = var.private_subnet_cidrs
    
}

module "stack_ec2" {
    source = "../../aws-infra-modules/ec2"

    client_name        = var.client_name
    client_environment = var.client_environment
    aws_region         = var.aws_region

    vpc_id             = module.stack_vpc.vpc_id
    public_subnet_ids  = module.stack_vpc.public_subnet_ids
    private_subnet_ids = module.stack_vpc.private_subnet_ids

    ami_id        = var.ami_id
    instance_type = var.instance_type
}
