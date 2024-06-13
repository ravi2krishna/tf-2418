# Create VPC
resource "aws_vpc" "tcs_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tcs-vpc"
  }
}

# Create Subnet for Web Servers
resource "aws_subnet" "tcs_web_sn" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tcs-web-subnet"
  }
}

# Create Subnet for Database Servers
resource "aws_subnet" "tcs_db_sn" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "tcs-data-subnet"
  }
}

# Create Subnet for Application Servers - Temporary
resource "aws_subnet" "tcs_app_sn" {
  vpc_id     = aws_vpc.tcs_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-west-2c"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "tcs-app-subnet"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "tcs_igw" {
  vpc_id = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-internet-gateway"
  }
}

# Create Public Route Table
resource "aws_route_table" "tcs_pub_rt" {
  vpc_id = aws_vpc.tcs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tcs_igw.id
  }

  tags = {
    Name = "tcs-public-route"
  }
}

# Create Private Route Table
resource "aws_route_table" "tcs_pvt_rt" {
  vpc_id = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-private-route"
  }
}

# Map Public Subnets with Public RT
resource "aws_route_table_association" "tcs_web_rt" {
  subnet_id      = aws_subnet.tcs_web_sn.id
  route_table_id = aws_route_table.tcs_pub_rt.id
}

resource "aws_route_table_association" "tcs_app_rt" {
  subnet_id      = aws_subnet.tcs_app_sn.id
  route_table_id = aws_route_table.tcs_pub_rt.id
}

# Map Private Subnets with Private RT
resource "aws_route_table_association" "tcs_db_rt" {
  subnet_id      = aws_subnet.tcs_db_sn.id
  route_table_id = aws_route_table.tcs_pvt_rt.id
}

# Create Web NACL's
resource "aws_network_acl" "tcs_web_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

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
    Name = "tcs-web-nacl"
  }
}

# Web NACL & Subnet Association
resource "aws_network_acl_association" "tcs_web_nacl_association" {
  network_acl_id = aws_network_acl.tcs_web_nacl.id
  subnet_id      = aws_subnet.tcs_web_sn.id
}

# Create App NACL's
resource "aws_network_acl" "tcs_app_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

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
    Name = "tcs-app-nacl"
  }
}

# Web NACL & Subnet Association
resource "aws_network_acl_association" "tcs_app_nacl_association" {
  network_acl_id = aws_network_acl.tcs_app_nacl.id
  subnet_id      = aws_subnet.tcs_app_sn.id
}

# Create DB NACL's
resource "aws_network_acl" "tcs_db_nacl" {
  vpc_id = aws_vpc.tcs_vpc.id

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
    Name = "tcs-db-nacl"
  }
}

# Web NACL & Subnet Association
resource "aws_network_acl_association" "tcs_db_nacl_association" {
  network_acl_id = aws_network_acl.tcs_db_nacl.id
  subnet_id      = aws_subnet.tcs_db_sn.id
}

# Web Secuirty Group
resource "aws_security_group" "tcs_web_sg" {
  name        = "tcs_web_sg"
  description = "Allow SSH & HTTP Traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-web-firewall"
  }
}

# Web Secuirty Group Rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_web_sg_ssh" {
  security_group_id = aws_security_group.tcs_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# Web Secuirty Group Rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "tcs_web_sg_http" {
  security_group_id = aws_security_group.tcs_web_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# App Secuirty Group
resource "aws_security_group" "tcs_app_sg" {
  name        = "tcs_app_sg"
  description = "Allow SSH & 8080 Traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-app-firewall"
  }
}

# App Secuirty Group Rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_app_sg_ssh" {
  security_group_id = aws_security_group.tcs_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# App Secuirty Group Rule - HTTP
resource "aws_vpc_security_group_ingress_rule" "tcs_app_sg_3000" {
  security_group_id = aws_security_group.tcs_app_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3000
  ip_protocol       = "tcp"
  to_port           = 3000
}

# DB Secuirty Group
resource "aws_security_group" "tcs_db_sg" {
  name        = "tcs_db_sg"
  description = "Allow SSH & Postgres Traffic"
  vpc_id      = aws_vpc.tcs_vpc.id

  tags = {
    Name = "tcs-db-firewall"
  }
}

# DB Secuirty Group Rule - SSH
resource "aws_vpc_security_group_ingress_rule" "tcs_db_sg_ssh" {
  security_group_id = aws_security_group.tcs_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

# DB Secuirty Group Rule - MySQL
resource "aws_vpc_security_group_ingress_rule" "tcs_db_sg_mysql" {
  security_group_id = aws_security_group.tcs_db_sg.id
  cidr_ipv4         = "10.0.0.0/16"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}