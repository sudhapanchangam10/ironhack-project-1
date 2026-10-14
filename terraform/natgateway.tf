# Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "sudha-ironhack-nat-eip"
  }
}

# NAT Gateway in the existing public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "sudha-ironhack-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.internetgateway
  ]
}

# Route private subnet internet traffic through NAT Gateway
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.route_table_private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}