###  vpc output ###

output "vpc_id" {
  value = module.stack_vpc.vpc_id
}


output "public_subnet_ids" {
  value = module.stack_vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.stack_vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  value = module.stack_vpc.nat_gateway_ids
}

####  load balancer

output "public_alb_dns" {
  value = module.stack_ec2.public_alb_dns
}

output "internal_alb_dns" {
  value = module.stack_ec2.internal_alb_dns
}
