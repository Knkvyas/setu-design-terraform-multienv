resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "setu-design-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets for NAT Gateway

resource "aws_subnet" "public_subnet" {
  count                   = length(var.availability_zones) > 0 ? length(var.availability_zones) : length(data.aws_availability_zones.available.names)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, length(var.availability_zones) + 3 + count.index) # Starting at 10.0.6.0/24
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${var.availability_zones[count.index]}"
  }
}

# Private Subnets for Backend & RDS

resource "aws_subnet" "app_subnet" {
  count             = length(var.availability_zones) > 0 ? length(var.availability_zones) : length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "AppSubnet-${var.availability_zones[count.index]}"
  }
}

resource "aws_subnet" "db_subnet" {
  count             = length(var.availability_zones) > 0 ? length(var.availability_zones) : length(data.aws_availability_zones.available.names)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 3 + count.index)
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "DBSubnet-${var.availability_zones[count.index]}"
  }
}


# NACL for App & RDS Subnet
resource "aws_network_acl" "app_nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "app-nacl"
  }
}

resource "aws_network_acl" "db_nacl" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "db-nacl"
  }
}

resource "aws_network_acl_association" "app_nacl_assoc" {
  count          = length(aws_subnet.app_subnet)
  network_acl_id = aws_network_acl.app_nacl.id
  subnet_id      = aws_subnet.app_subnet[count.index].id
}

resource "aws_network_acl_association" "db_nacl_assoc" {
  count          = length(aws_subnet.db_subnet)
  network_acl_id = aws_network_acl.db_nacl.id
  subnet_id      = aws_subnet.db_subnet[count.index].id
}

# NACL Rules for the Application Subnet

resource "aws_network_acl_rule" "app_inbound_http" {
  for_each       = toset(var.inbound_ports)
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 100 + each.key
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
  cidr_block     = "0.0.0.0/0"
}


resource "aws_network_acl_rule" "app_egress_http" {
  for_each       = toset(var.inbound_ports)
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 140 + each.key
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  from_port      = tonumber(each.value)
  to_port        = tonumber(each.value)
  cidr_block     = "0.0.0.0/0"
}

resource "aws_network_acl_rule" "app_egress" {
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 200
  rule_action    = "allow"
  egress         = true
  protocol       = "-1"
  from_port      = 0
  to_port        = 0
  cidr_block     = aws_vpc.main.cidr_block
}

resource "aws_network_acl_rule" "app_egress_rds" {
  count          = length(aws_subnet.app_subnet)
  network_acl_id = aws_network_acl.app_nacl.id
  rule_number    = 120 + count.index
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  from_port      = var.rds_egress_from_port
  to_port        = var.rds_egress_to_port
  cidr_block     = aws_subnet.db_subnet[count.index].cidr_block
}

# NACL Rules for Database Subnet

resource "aws_network_acl_rule" "db_inbound_from_app" {
  count          = length(aws_subnet.app_subnet)
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 100 + count.index
  rule_action    = "allow"
  egress         = false
  protocol       = "tcp"
  from_port      = var.rds_egress_from_port
  to_port        = var.rds_egress_to_port
  cidr_block     = aws_subnet.app_subnet[count.index].cidr_block
}

resource "aws_network_acl_rule" "db_egress_to_app" {
  count          = length(aws_subnet.app_subnet)
  network_acl_id = aws_network_acl.db_nacl.id
  rule_number    = 110 + count.index
  rule_action    = "allow"
  egress         = true
  protocol       = "tcp"
  from_port      = var.rds_egress_from_port
  to_port        = var.rds_egress_to_port
  cidr_block     = aws_subnet.app_subnet[count.index].cidr_block
}

# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# NAT Gateway
resource "aws_eip" "nat_eip" {
  count  = length(aws_subnet.public_subnet)
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = length(aws_subnet.public_subnet)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = aws_subnet.public_subnet[count.index].id

  tags = {
    Name = "NATGateway-${var.availability_zones[count.index]}"
  }
}

####################### Public Route Table for NAT Gateway #######################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_rta" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

############# Private Route Table for App ################################
resource "aws_route_table" "app_rt" {
  count  = length(aws_subnet.app_subnet)
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "app-rt-${var.availability_zones[count.index]}"
  }
}

resource "aws_route_table_association" "app_rta" {
  count          = length(aws_subnet.app_subnet)
  subnet_id      = aws_subnet.app_subnet[count.index].id
  route_table_id = aws_route_table.app_rt[count.index].id
}

resource "aws_route" "app_route" {
  count                  = length(aws_subnet.app_subnet)
  route_table_id         = aws_route_table.app_rt[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat_gateway[count.index].id
}

############# Private Route Table for DB ################################

resource "aws_route_table" "db_rt" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "db-route-table"
  }
}

resource "aws_route_table_association" "db_rta" {
  count          = length(aws_subnet.db_subnet)
  subnet_id      = aws_subnet.db_subnet[count.index].id
  route_table_id = aws_route_table.db_rt.id
}


############## Security Group Rules for App ##############################################

resource "aws_security_group" "public_app_sg" {
  vpc_id = aws_vpc.main.id
  name   = "public-app-sg"

  dynamic "ingress" {
    for_each = toset(var.inbound_ports)

    content {
      from_port   = tonumber(ingress.value)
      to_port     = tonumber(ingress.value)
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_app_sg" {
  name        = "private-app-sg"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.public_app_sg.id]
  }
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

# resource "aws_security_group_rule" "private_egress_rds" {
#   type              = "egress"
#   to_port           = 0
#   protocol          = "-1"
#   source_security_group_id   = aws_security_group.rds_sg.id
#   from_port         = 0
#   security_group_id = aws_security_group.private_app_sg.id
#   depends_on = [ aws_security_group.rds_sg ]
# } 
resource "aws_security_group_rule" "public_egress_rds" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  source_security_group_id   = aws_security_group.rds_sg.id
  from_port         = 0
  security_group_id = aws_security_group.public_app_sg.id
  depends_on = [ aws_security_group.rds_sg ]
} 


############## Security Group Rules for Database ##############################################

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = var.rds_egress_from_port
    to_port         = var.rds_egress_to_port
    protocol        = "tcp"
    security_groups = [aws_security_group.public_app_sg.id, aws_security_group.private_app_sg.id]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

################# Security Group for VPC Endpoint ##################
resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "vpc-endpoint-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  # Outbound rules: Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC Endpoint SG"
  }
}


resource "aws_security_group" "alb_sg" {
  name        = "elb-sg"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }

  tags = {
    Name = "alb-security-group"
  }
}

################# VPC Endpoint ##########################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.app_subnet[*].id)

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ssm_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.app_subnet[*].id)

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ec2_messages" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"
  subnet_ids        = tolist(aws_subnet.app_subnet[*].id)

  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]

  private_dns_enabled = true
}
