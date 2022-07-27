provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_security_group" "egress" {
  name = format("%s-ubuntu-egress", lower(var.owner_name))
  description = "egress"
  vpc_id = aws_vpc.vpc.id
  ingress {
    cidr_blocks = ["10.0.0.0/16"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 0
    to_port = 0
    protocol = "-1"
  }
  tags = {
    Name = format("%s-ubuntu-egress", lower(var.owner_name))
    Owner = var.owner_email
  }
}