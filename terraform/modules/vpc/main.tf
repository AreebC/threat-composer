resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_subnet_cidrs[0]
  availability_zone = var.availability_zones1

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-1"
    Tier = "Public"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id = aws_vpc.main.id

  cidr_block        = var.public_subnet_cidrs[1]
  availability_zone = var.availability_zones2

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-2"
    Tier = "Public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt"
  }
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id

  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}








