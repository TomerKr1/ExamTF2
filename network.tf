resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = var.Private_VPC_Name
  }
}

#query for taking all the az
data "aws_availability_zones" "available" {}

# shuffle the list of az we got ^
resource "random_shuffle" "az_random" {
  input        = data.aws_availability_zones.available.names
  result_count = 2
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_random.result[0]
  tags = {
    Name = var.public_Sunbet_Name
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false  
  availability_zone       = random_shuffle.az_random.result[1] # Lets make the subnet being in df az
  tags = {
    Name = var.private_Sunbet_Name
  }
}

//regular GW.

resource "aws_internet_gateway" "custom_gateWay" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = var.igw_name
  }
}

/*
it was tricky. 
when we create a Route table it doesnt mean it belongs to a subnet
in the beggining it just belongs to a VPC ONLY
with "aws_route_table_association" we are connecting it to the right subnet.

*/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"  
    gateway_id = aws_internet_gateway.custom_gateWay.id  // the VPC will recognized we trying to get to an ip that outsite our VPC ZONE!
  }

  tags = {
    Name = var.Route_Table
  }
}

//the connection with subnet the the route id
resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.new_public.id  
  route_table_id = aws_route_table.public.id  
}


## Should i create NAT GATEWAY??
resource "aws_route_table_association" "private_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public.id
}


resource "aws_security_group" "sg" {
 vpc_id = aws_vpc.custom_vpc.id // this VPC screw up all my code. we are connecting the VPC to the SG so we can put later the EC into the right subnet

 
  // regular ingress
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


// for the LB second subnet.
resource "aws_subnet" "new_public" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_random.result[1]
  tags = {
    Name = "publicSubNet2"
  }
}


