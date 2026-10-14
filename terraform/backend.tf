# Backend security group
resource "aws_security_group" "backend_sudha_ironhack" {
  name        = "sudha-ironhack-backend"
  description = "Security group for Redis and Worker"
  vpc_id      = aws_vpc.sudha_ironhack_project1.id

  tags = {
    Name = "sudha-ironhack-backend"
  }
}

# Allow Redis traffic from the frontend security group
resource "aws_vpc_security_group_ingress_rule" "backend_allow_redis" {
  security_group_id            = aws_security_group.backend_sudha_ironhack.id
  referenced_security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  from_port                    = 6379
  ip_protocol                  = "tcp"
  to_port                      = 6379
}

# Allow SSH from the frontend/bastion security group
resource "aws_vpc_security_group_ingress_rule" "backend_allow_ssh" {
  security_group_id            = aws_security_group.backend_sudha_ironhack.id
  referenced_security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  from_port                    = 22
  ip_protocol                  = "tcp"
  to_port                      = 22
}

# Allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "backend_allow_all_outbound_ipv4" {
  security_group_id = aws_security_group.backend_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}