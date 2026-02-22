############################
# BACKEND SECURITY GROUP
############################

resource "aws_security_group" "backend_sg" {
  name   = "${var.client_name}-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# INTERNAL ALB SECURITY GROUP
############################

resource "aws_security_group" "internal_alb_sg" {
  name   = "${var.client_name}-internal-alb-sg"
  vpc_id = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# SECURITY GROUP RULES (BREAKS CYCLE)
############################

# Allow Frontend → ALB (5000)
resource "aws_security_group_rule" "alb_allow_frontend" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.internal_alb_sg.id
  source_security_group_id = aws_security_group.frontend_sg.id
}

# Allow ALB → Backend (5000)
resource "aws_security_group_rule" "backend_allow_alb" {
  type                     = "ingress"
  from_port                = 5000
  to_port                  = 5000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.backend_sg.id
  source_security_group_id = aws_security_group.internal_alb_sg.id
}

############################
# INTERNAL APPLICATION LOAD BALANCER
############################

resource "aws_lb" "internal_alb" {
  name               = "${var.client_name}-internal-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.internal_alb_sg.id]
}

############################
# SSM PARAMETER FOR INTERNAL ALB DNS
############################

resource "aws_ssm_parameter" "internal_alb_dns" {
  name  = "/${var.client_name}/${var.client_environment}/internal-alb-dns"
  type  = "String"
  value = aws_lb.internal_alb.dns_name
  
  tags = {
    Name        = "${var.client_name}-internal-alb-dns"
    Environment = var.client_environment
  }
}

resource "aws_ssm_parameter" "ecr_frontend_image" {
  name  = "/${var.client_name}/${var.client_environment}/ecr-frontend-image"
  type  = "String"
  value = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app-frontend:${var.front_image_tag}"
  
  tags = {
    Name        = "${var.client_name}-ecr-frontend-image"
    Environment = var.client_environment
  }
}

resource "aws_ssm_parameter" "ecr_backend_image" {
  name  = "/${var.client_name}/${var.client_environment}/ecr-backend-image"
  type  = "String"
  value = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app-backend:${var.backend_image_tag}"
  
  tags = {
    Name        = "${var.client_name}-ecr-backend-image"
    Environment = var.client_environment
  }
}

############################
# TARGET GROUP
############################

resource "aws_lb_target_group" "backend_tg" {
  name     = "${var.client_name}-backend-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }
}

############################
# LISTENER
############################

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = 5000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

############################
# LAUNCH TEMPLATE
############################

resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.client_name}-backend"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = aws_key_pair.my-key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend_sg.id]
  }

  user_data = base64encode(templatefile("${path.module}/../userdata/backend.sh", {
    S3_BUCKET_NAME = var.s3_bucket_name
    CLIENT_NAME = var.client_name
    CLIENT_ENVIRONMENT = var.client_environment
  }))
}

############################
# AUTO SCALING GROUP
############################

resource "aws_autoscaling_group" "backend_asg" {
  name                = "${var.client_name}-backend-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.backend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 120
}
