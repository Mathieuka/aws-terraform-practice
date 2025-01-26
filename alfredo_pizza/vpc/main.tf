resource "aws_vpc" "alfredo_pizza" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "Alfredo Pizza"
  }
}

# ** Internet Gateway **

resource "aws_internet_gateway" "alfredo_pizza" {
  depends_on = [aws_vpc.alfredo_pizza]
  vpc_id = aws_vpc.alfredo_pizza.id

  tags = {
    Name = "Alfredo Pizza"
  }
}

# ** Subnets **

resource "aws_subnet" "dmz_1" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Alfredo Pizza DMZ"
  }
}

resource "aws_subnet" "dmz_2" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Alfredo Pizza DMZ"
  }
}

resource "aws_subnet" "app_1" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Alfredo Pizza App"
  }
}

resource "aws_subnet" "app_2" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Alfredo Pizza App"
  }
}

resource "aws_subnet" "db_1" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Alfredo Pizza DB"
  }
}

resource "aws_subnet" "db_2" {
  vpc_id            = aws_vpc.alfredo_pizza.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Alfredo Pizza DB"
  }
}

resource "aws_eip" "dmz" {
  vpc = true
  tags = {
    Name = "Alfredo Pizza DMZ EIP"
  }
}

resource "aws_nat_gateway" "dmz" {
  subnet_id     = aws_subnet.dmz_1.id
  allocation_id = aws_eip.dmz.id

  tags = {
    Name = "Alfredo Pizza DMZ"
  }
}

# ** Route Table **

# public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.alfredo_pizza.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.alfredo_pizza.id
  }

  tags = {
    Name = "Alfredo Pizza Public"
  }
}

resource "aws_route_table_association" "dmz_1" {
  subnet_id      = aws_subnet.dmz_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "dmz_2" {
  subnet_id      = aws_subnet.dmz_2.id
  route_table_id = aws_route_table.public.id
}

# private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.alfredo_pizza.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dmz.id
  }

  tags = {
    Name = "Alfredo Pizza Private"
  }
}

resource "aws_route_table_association" "app_1" {
  subnet_id      = aws_subnet.app_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "app_2" {
  subnet_id      = aws_subnet.app_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_1" {
  subnet_id      = aws_subnet.db_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db_2" {
  subnet_id      = aws_subnet.db_2.id
  route_table_id = aws_route_table.private.id
}

# ** ACL **

# ACL pour la couche DMZ
resource "aws_network_acl" "dmz" {
  vpc_id = aws_vpc.alfredo_pizza.id

  tags = {
    Name = "Alfredo Pizza DMZ ACL"
  }
}

# ACL pour la couche Application
resource "aws_network_acl" "app" {
  vpc_id = aws_vpc.alfredo_pizza.id

  tags = {
    Name = "Alfredo Pizza App ACL"
  }
}

# ACL pour la couche Base de données
resource "aws_network_acl" "db" {
  vpc_id = aws_vpc.alfredo_pizza.id

  tags = {
    Name = "Alfredo Pizza DB ACL"
  }
}

# Association des ACLs aux sous-réseaux correspondants
resource "aws_network_acl_association" "dmz_1" {
  network_acl_id = aws_network_acl.dmz.id
  subnet_id      = aws_subnet.dmz_1.id
}

resource "aws_network_acl_association" "dmz_2" {
  network_acl_id = aws_network_acl.dmz.id
  subnet_id      = aws_subnet.dmz_2.id
}

resource "aws_network_acl_association" "app_1" {
  network_acl_id = aws_network_acl.app.id
  subnet_id      = aws_subnet.app_1.id
}

resource "aws_network_acl_association" "app_2" {
  network_acl_id = aws_network_acl.app.id
  subnet_id      = aws_subnet.app_2.id
}

resource "aws_network_acl_association" "db_1" {
  network_acl_id = aws_network_acl.db.id
  subnet_id      = aws_subnet.db_1.id
}

resource "aws_network_acl_association" "db_2" {
  network_acl_id = aws_network_acl.db.id
  subnet_id      = aws_subnet.db_2.id
}

# ** ACL Rules **

# Règle entrante pour la DMZ
resource "aws_network_acl_rule" "dmz_inbound" {
  network_acl_id = aws_network_acl.dmz.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Règle sortante pour la DMZ
resource "aws_network_acl_rule" "dmz_outbound" {
  network_acl_id = aws_network_acl.dmz.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Règle entrante pour la couche App
resource "aws_network_acl_rule" "app_inbound" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

# Règle sortante pour la couche App
resource "aws_network_acl_rule" "app_outbound" {
  network_acl_id = aws_network_acl.app.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

# Règle entrante pour la couche DB
resource "aws_network_acl_rule" "db_inbound" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

# Règle sortante pour la couche DB
resource "aws_network_acl_rule" "db_outbound" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
  from_port      = 0
  to_port        = 0
}

# ** Output **

output "vpc_id" {
  value = aws_vpc.alfredo_pizza.id
}
