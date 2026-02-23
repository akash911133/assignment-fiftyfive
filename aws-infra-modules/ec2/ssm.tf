############################
# SSM PARAMETERS (reusable for_each from local map)
############################

locals {
  ssm_parameters = {
    "internal-alb-dns"    = aws_lb.internal_alb.dns_name
    "ecr-frontend-image"  = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app-frontend:${var.front_image_tag}"
    "ecr-backend-image"   = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app-backend:${var.backend_image_tag}"
  }
}

resource "aws_ssm_parameter" "params" {
  for_each = local.ssm_parameters

  name  = "/${var.client_name}/${var.client_environment}/${each.key}"
  type  = "String"
  value = each.value

  tags = {
    Name        = "${var.client_name}-${each.key}"
    Environment = var.client_environment
  }
}
