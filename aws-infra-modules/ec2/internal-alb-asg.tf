resource "aws_security_group" "backend_sg" {
  name   = "${var.client_name}-backend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#################### internal alb 

resource "aws_lb" "internal_alb" {
  name               = "${var.client_name}-internal-alb"
  load_balancer_type = "application"
  internal           = true
  subnets            = var.private_subnet_ids
  security_groups    = [aws_security_group.backend_sg.id]
}


#########  backend TG

resource "aws_lb_target_group" "backend_tg" {
  name     = "${var.client_name}-backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

####### backend launch template


resource "aws_launch_template" "backend_lt" {
  name_prefix   = "${var.client_name}-backend"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.backend_sg.id]
  }
}


###########  backend asg

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
}
