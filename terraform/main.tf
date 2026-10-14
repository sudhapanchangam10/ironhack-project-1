
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Store Terraform state remotely in S3
  backend "s3" {
    bucket         = "sudha-s3bucket-ironhack-project1"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "sudha-statelock-irohack-project1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "sudha_ironhack_project1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "sudha-ironhack-project1"
  }
}

# Create a public subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.sudha_ironhack_project1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "sudha-public-subnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "internetgateway" {
  vpc_id = aws_vpc.sudha_ironhack_project1.id

  tags = {
    Name = "sudha-internet-gateway"
  }
}

# Create a route table for the public subnet
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.sudha_ironhack_project1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internetgateway.id
  }

  tags = {
    Name = "sudha_ironhack_project1_routetable"
  }
}

# Associate the public subnet with its route table
resource "aws_route_table_association" "routeassociation" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}

# Create a private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.sudha_ironhack_project1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "sudha-private-subnet"
  }
}

# Create a route table for the private subnet
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.sudha_ironhack_project1.id

  tags = {
    Name = "sudha_ironhack_project1_private_routetable"
  }
}

# Associate the private subnet with its route table
resource "aws_route_table_association" "routeassociation_private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_table_private.id
}
# Instance A: Frontend in the public subnet
resource "aws_instance" "web_server" {
  ami                    = var.ami_image_name
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_tls_sudha_ironhack.id]
  key_name               = "sudhaironhack"

  tags = {
    Name = "sudha-ironhack-project1-frontend"
  }
}

# Instance B: Backend in the private subnet
resource "aws_instance" "backend_server" {
  ami                    = var.ami_image_name
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.backend_sudha_ironhack.id]
  key_name               = "sudhaironhack"

  tags = {
    Name = "sudha-ironhack-project1-backend"
  }
}

# Instance C: Database in the private subnet
resource "aws_instance" "database_server" {
  ami                    = var.ami_image_name
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.postgresql_sudha_ironhack.id]
  key_name               = "sudhaironhack"

  tags = {
    Name = "sudha-ironhack-project1-database"
  }
}