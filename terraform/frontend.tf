# Frontend security group
resource "aws_security_group" "allow_tls_sudha_ironhack" {
  name        = "allow_tls_sudha-ironhack"
  description = "Allow HTTP and HTTPS inbound traffic"
  vpc_id      = aws_vpc.sudha_ironhack_project1.id

  tags = {
    Name = "allow_tls_sudha-ironhack"
  }
}

# Allow HTTP from the internet
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_80" {
  security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

# Allow HTTPS from the internet
resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4_443" {
  security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

# Allow all outbound IPv4 traffic
resource "aws_vpc_security_group_egress_rule" "frontend_allow_all_outbound_ipv4" {
  security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "frontend_allow_8080" {
  security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"

  description = "Allow Vote application"
}

resource "aws_vpc_security_group_ingress_rule" "frontend_allow_8081" {
  security_group_id = aws_security_group.allow_tls_sudha_ironhack.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8081
  to_port           = 8081
  ip_protocol       = "tcp"

  description = "Allow Result application"
}
