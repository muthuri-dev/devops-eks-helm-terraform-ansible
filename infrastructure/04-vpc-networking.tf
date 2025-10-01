resource "aws_vpc" "production_vpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true 

  tags = {
    Name = "production_vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

// two private subnet, two public subnets

resource "aws_subnet" "production_public_subnet" {
  count      = 2
  vpc_id     = aws_vpc.production_vpc.id
  cidr_block = cidrsubnet(aws_vpc.production_vpc.cidr_block, 8, 1 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true 

  tags = {
    Name = "production_public_subnet_${count.index + 1}"
  }
}

resource "aws_subnet" "production_private_subnet" {
  count      = 2
  vpc_id     = aws_vpc.production_vpc.id
  cidr_block = cidrsubnet(aws_vpc.production_vpc.cidr_block, 8, 110 + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "production_private_subnet_${count.index + 1}"
  }
}

//internet gateway for public subnet and nat gateway for private subnets
resource "aws_internet_gateway" "production_igw" {
  vpc_id = aws_vpc.production_vpc.id

  tags = {
    Name = "production_igw"
  }
}

resource "aws_eip" "production_eip" {
   domain = "vpc"
  depends_on                = [aws_internet_gateway.production_igw]
}

resource "aws_nat_gateway" "production_nat_gateway" {
  allocation_id = aws_eip.production_eip.id
  subnet_id     = aws_subnet.production_public_subnet[0].id

  tags = {
    Name = "production_nat_gateway"
  }

  depends_on = [aws_internet_gateway.production_igw]
}

//public and private route tables
resource "aws_route_table" "production_public_rt" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.production_igw.id
  }

  tags = {
    Name = "production_public_rt"
  }
}

resource "aws_route_table" "production_private_rt" {
  vpc_id = aws_vpc.production_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.production_nat_gateway.id
  }

  tags = {
    Name = "production_private_rt"
  }
}

//rt & subnets association
resource "aws_route_table_association" "production_public_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.production_public_subnet[count.index].id
  route_table_id = aws_route_table.production_public_rt.id
}

resource "aws_route_table_association" "production_private_subnet_association" {
  count          = 2  
  subnet_id      = aws_subnet.production_private_subnet[count.index].id
  route_table_id = aws_route_table.production_private_rt.id
}