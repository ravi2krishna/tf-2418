# Create VPC
resource "aws_vpc" "ibm_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "ibm-vpc"
  }
}

# Create Subnet for Web Servers
resource "aws_subnet" "ibm_web_sn" {
  vpc_id     = aws_vpc.ibm_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm-web-subnet"
  }
}

# Create Subnet for Database Servers
resource "aws_subnet" "ibm_db_sn" {
  vpc_id     = aws_vpc.ibm_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "ibm-data-subnet"
  }
}

# Create Subnet for Application Servers - Temporary
resource "aws_subnet" "ibm_app_sn" {
  vpc_id     = aws_vpc.ibm_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "ibm-app-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "ibm_igw" {
  vpc_id = aws_vpc.ibm_vpc.id

  tags = {
    Name = "ibm-internet-gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "ibm_pub_rt" {
  vpc_id = aws_vpc.ibm_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ibm_igw.id
  }

  tags = {
    Name = "ibm-public-route"
  }
}

# Create Private Route Table
resource "aws_route_table" "ibm_pvt_rt" {
  vpc_id = aws_vpc.ibm_vpc.id

  tags = {
    Name = "ibm-private-route"
  }
}

# Map Public Subnets with Public RT
resource "aws_route_table_association" "ibm_web_rt" {
  subnet_id      = aws_subnet.ibm_web_sn.id
  route_table_id = aws_route_table.ibm_pub_rt.id
}

resource "aws_route_table_association" "ibm_app_rt" {
  subnet_id      = aws_subnet.ibm_app_sn.id
  route_table_id = aws_route_table.ibm_pub_rt.id
}

# Map Private Subnets with Private RT
resource "aws_route_table_association" "ibm_db_rt" {
  subnet_id      = aws_subnet.ibm_db_sn.id
  route_table_id = aws_route_table.ibm_pvt_rt.id
}

# Create Web NACL's
resource "aws_network_acl" "ibm_web_nacl" {
  vpc_id = aws_vpc.ibm_vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "ibm-web-nacl"
  }
}