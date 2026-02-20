resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.name}-frontend-"
  image_id      = var.frontend_ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-frontend"
    }
  }
}


resource "aws_launch_template" "frontend" {
  name_prefix   = "${var.name}-frontend-"
  image_id      = var.frontend_ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.frontend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-frontend"
    }
  }
}

resource "aws_launch_template" "backend" {
  name_prefix   = "${var.name}-backend-"
  image_id      = var.backend_ami
  instance_type = var.instance_type

  vpc_security_group_ids = [var.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.name}-backend"
    }
  }
}

resource "aws_autoscaling_group" "frontend" {
  name                = "${var.name}-frontend-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.frontend.arn]

  tag {
    key                 = "Name"
    value               = "${var.name}-frontend"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_group" "backend" {
  name                = "${var.name}-backend-asg"
  desired_capacity    = 1
  min_size            = 1
  max_size            = 2
  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.backend.arn]

  tag {
    key                 = "Name"
    value               = "${var.name}-backend"
    propagate_at_launch = true
  }
}

