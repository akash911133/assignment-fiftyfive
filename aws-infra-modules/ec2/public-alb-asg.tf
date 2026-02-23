resource "aws_security_group" "public_alb_sg" {
  name   = "${var.client_name}-public-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_security_group" "frontend_sg" {
  name   = "${var.client_name}-frontend-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id]
  }


  ingress {
      description = "port 22 for ssh access"
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

#### public alb ######

resource "aws_lb" "public_alb" {
  name               = "${var.client_name}-public-alb"
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [aws_security_group.public_alb_sg.id]
}

#####  
resource "aws_lb_target_group" "frontend_tg" {
  name     = "${var.client_name}-frontend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

####  listener  ########
resource "aws_lb_listener" "public_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}


###########

resource "aws_launch_template" "frontend_lt" {
  name_prefix   = "${var.client_name}-frontend"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }
  
  key_name = aws_key_pair.my-key.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.frontend_sg.id]
  }

  tags = merge(var.common_tags, {
    Name                        = "${var.client_name}-frontend-instance"
    Node_Type                  = "frontend"
    Billing_Name               = "${var.client_name}-${var.client_environment}-frontend"
  })

  user_data = base64encode(
    templatefile("${path.module}/../userdata/node-bootstrap.sh", {
      NODE_TYPE           = "frontend"
      S3_BUCKET_NAME      = var.s3_bucket_name
      CLIENT_NAME         = var.client_name
      CLIENT_ENVIRONMENT  = var.client_environment
      AWS_REGION          = var.aws_region
      AWS_ACCOUNT_ID      = var.aws_account_id
    })
  )
}


########## asg

resource "aws_autoscaling_group" "frontend_asg" {
  name                = "${var.client_name}-frontend-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 3
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.frontend_lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend_tg.arn]
}

