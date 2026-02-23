## customer variable ########
client_name = "ClientB"
client_environment = "prod"
aws_region = "eu-west-1"

#### vpc specific variables ##########
vpc_cidr = "10.5.0.0/16"

azs = ["eu-west-1a", "eu-west-1b"]

public_subnet_cidrs = [
  "10.5.1.0/24",
  "10.5.2.0/24"
]

private_subnet_cidrs = [
  "10.5.11.0/24",
  "10.5.12.0/24"
]

#### vpc specific variables ##########

ami_id = "ami-09c20105c9b62f893"

instance_type = "t2.micro"

#### S3 variables for Ansible ##########
s3_bucket_name = "aws-platform-infra-bucket"

#### AWS Account & Image Tags ##########
aws_account_id = "245681210702"
front_image_tag = "62f9b4e"
backend_image_tag = "53fefc0"
