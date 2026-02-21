output "public_alb_dns" {
  value = aws_lb.public_alb.dns_name
}

output "internal_alb_dns" {
  value = aws_lb.internal_alb.dns_name
}