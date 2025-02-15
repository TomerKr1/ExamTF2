resource "aws_vpc" "custom_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = var.Private_VPC_Name
  }
}

data "aws_availability_zones" "available" {}

resource "random_shuffle" "az_random" {
  input        = data.aws_availability_zones.available.names
  result_count = var.subnet_count
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = var.assign_public_ip // true or false/
  availability_zone       = random_shuffle.az_random.result[0]

  tags = {
    Name = var.public_Sunbet_Name
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_random.result[1]

  tags = {
    Name = var.private_Sunbet_Name
  }
}

resource "aws_internet_gateway" "custom_gateWay" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.custom_gateWay.id
  }

  tags = {
    Name = var.Route_Table
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "sg" {
  vpc_id = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  tags = {
    Name = var.sg_name
  }
   lifecycle { // do not destroy when we do changes with those:
   ignore_changes = [egress, ingress]
  }
}
