resource "aws_security_group" "encrypto_ec2" {
  name        = "launch-wizard"
  description = "launch-wizard created 2023-05-09T19:05:37.718Z"
  vpc_id      = local.vpc_id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "encrypto" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_pair_name
  subnet_id              = local.subnet_id
  vpc_security_group_ids = [aws_security_group.encrypto_ec2.id]

  tags = {
    Name = "encrypto-api"
  }
}
