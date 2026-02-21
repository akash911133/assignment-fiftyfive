## customer variable ########
client_name = "ClientA"
client_environment = "prod"
aws_region = "eu-west-1"

#### vpc specific variables ##########
vpc_cidr = "10.0.0.0/16"

azs = ["eu-west-1a", "eu-west-1b"]

public_subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnet_cidrs = [
  "10.0.11.0/24",
  "10.0.12.0/24"
]

#### vpc specific variables ##########

ami_id = "ami-03446a3af42c5e74e"

instance_type = "t2.micro"

front_image_tag = "53fefc0"
backend_image_tag = "53fefc0"

