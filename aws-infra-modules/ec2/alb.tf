resource "aws_lb" "public" {
  name               = "${var.name}-public-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnets
  security_groups    = [var.public_alb_sg_id]

  tags = {
    Name = "${var.name}-public-alb"
  }
}


resource "aws_lb" "internal" {
  name               = "${var.name}-internal-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.private_subnets
  security_groups    = [var.internal_alb_sg_id]

  tags = {
    Name = "${var.name}-internal-alb"
  }
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "${var.name}-backend-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

