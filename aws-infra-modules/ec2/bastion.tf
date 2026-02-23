# key-pair
# default-vpc
# security-group
# ec2-instance


resource "aws_key_pair" "my-key" {
  key_name   = "terra-automate-key"
  public_key = var.ec2_public_key
}

resource "aws_security_group" "my-bastion-sg" {
    name = "MyBastionSG"
    description = "this is creating for deploying httpd server"
    vpc_id = var.vpc_id

    ingress {
        description = "port 22 for ssh access"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "for http request"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    egress {
        description = " allow all outgoing traffic "
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_instance" "my-bastion-instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.my-key.key_name
  subnet_id                   = var.public_subnet_ids[0]
  vpc_security_group_ids      = [aws_security_group.my-bastion-sg.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion_profile.name
  associate_public_ip_address  = true

  user_data = base64encode(
    templatefile("${path.module}/../userdata/bastion-fetch-key.sh", {
      SECRET_NAME      = var.bastion_private_key_secret_name
      SECRET_REGION    = var.bastion_private_key_secret_region
      SECRET_JSON_KEY  = var.bastion_private_key_secret_json_key
    })
  )

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "EC-2_Instance_Bastion"
  }
}
