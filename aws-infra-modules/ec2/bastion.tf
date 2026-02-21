# key-pair
# default-vpc
# security-group
# ec2-instance


resource "aws_key_pair" "my-key" {
  key_name   = "terra-automate-key"
  public_key = file("/home/ubuntu/.ssh/id_rsa.pub")
}

resource "aws_security_group" "my-bastion-sg" {
    name = "MyBastionSG"
    description = "this is creating for deploying httpd server"
    vpc_id = aws_vpc.this.id

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
  ami = "ami-0ef0fafba270833fc" 
  instance_type = "t2.micro"
  key_name = aws_key_pair.my-key.key_name
  subnet_id = var.public_subnet_ids[*]
  security_groups = [aws_security_group.my-bastion-sg.name]

  root_block_device {
    volume_size = 15
    volume_type = "gp3"
  }

  tags = {
    Name = "EC-2_Instance_Bastion"
  }
}
