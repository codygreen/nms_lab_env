#
# Create the VPC
#
# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name                 = format("%s-vpc", lower(var.owner_name) )
#   cidr                 = "10.0.0.0/16"
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#   enable_nat_gateway   = true
#   single_nat_gateway   = false
#   one_nat_gateway_per_az = false

#   #azs = var.availabilityZones

#   tags = {
#     Name        = format("%s-vpc", lower(var.owner_name))
#     Terraform   = "true"
#     Environment = "dev"
#     Owner       = var.owner_email
#   }
# }
# resource "aws_internet_gateway" "gw" {
#   vpc_id = module.vpc.vpc_id

#   tags = {
#     Name = "default"
#     Owner = var.owner_email
#   }
# }

# resource "aws_route_table" "nat-gw" {
#   vpc_id = module.vpc.vpc_id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = module.vpc.natgw_ids[0]
#   }
# }

# resource "aws_subnet" "public" {
#   vpc_id            = module.vpc.vpc_id
#   cidr_block        = cidrsubnet("10.0.0.0/16", 8, 1)
#   availability_zone = format("%sa", var.region)

#   tags = {
#     Name = "public"
#     Owner = var.owner_email
#   }
# }

# resource "aws_route_table_association" "route_table_public" {
#   subnet_id      = aws_subnet.public.id
# #   route_table_id = aws_route_table.nat-gw.id
#   route_table_id = module.vpc.private_nat_gateway_route_ids[0]
# }

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = format("%s-nms-vpc", lower(var.owner_name) )
    Owner = var.owner_email
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "private" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-nms-private", lower(var.owner_name))
  }
}

resource "aws_subnet" "public" {
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = format("%s-nms-public", lower(var.owner_name))
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "default"
    Owner = var.owner_email
  }
}

resource "aws_eip" "nat_gateway" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id = aws_subnet.public.id
  tags = {
    "Name" = format("%s-nms-ngw", lower(var.owner_name) )
    Owner = var.owner_email
  }
  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "igw" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table" "ngw" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "igw" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.igw.id
}

resource "aws_route_table_association" "ngw" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.ngw.id
}