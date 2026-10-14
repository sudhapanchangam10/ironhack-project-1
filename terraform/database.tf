# Database security group
resource "aws_security_group" "postgresql_sudha_ironhack" {
  name        = "sudha-ironhack-postgre"
  description = "Security group for PostgreSQL"
  vpc_id      = aws_vpc.sudha_ironhack_project1.id

  tags = {
    Name = "sudha-ironhack-postgre"
  }
}

# Allow PostgreSQL from the frontend security group
resource "aws_vpc_security_group_ingress_rule" "postgresql_allow_frontend" {
  security_group_id            = aws_security_group.postgresql_sudha_ironhack.id
  referenced_security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

# Allow PostgreSQL from the backend security group
resource "aws_vpc_security_group_ingress_rule" "postgresql_allow_backend" {
  security_group_id            = aws_security_group.postgresql_sudha_ironhack.id
  referenced_security_group_id = aws_security_group.backend_sudha_ironhack.id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

# Allow SSH from the frontend/bastion security group
resource "aws_vpc_security_group_ingress_rule" "database_allow_ssh" {
  security_group_id            = aws_security_group.postgresql_sudha_ironhack.id
  referenced_security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

# Allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "database_allow_all_outbound_ipv4" {
  security_group_id = aws_security_group.postgresql_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}