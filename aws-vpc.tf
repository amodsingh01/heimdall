resource "aws_vpc" "Heimdalldata-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Heimdalldata-vpc-${random_pet.server.id}-${random_id.server.dec}"
  }
}

resource "aws_subnet" "Heimdalldata-public-subnet-1" {
  vpc_id                  = aws_vpc.Heimdalldata-vpc.id
  cidr_block              = var.subnet_cidr[0]
  availability_zone       = var.subnet_az[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Heimdalldata-public-subnet-1-${random_pet.server.id}-${random_id.server.dec}"
  }
}

resource "aws_subnet" "Heimdalldata-private-subnet-1" {
  vpc_id            = aws_vpc.Heimdalldata-vpc.id
  cidr_block        = var.subnet_cidr[1]
  availability_zone = var.subnet_az[1]
  tags = {
    Name = "Heimdalldata-private-subnet-1-${random_pet.server.id}-${random_id.server.dec}"
  }
}

resource "aws_internet_gateway" "Heimdall-igw" {
  vpc_id = aws_vpc.Heimdalldata-vpc.id

  tags = {
    Name = "Heimdall-igw-${random_pet.server.id}-${random_id.server.dec}"
  }
}

resource "aws_route" "route-1" {
  route_table_id         = aws_vpc.Heimdalldata-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.Heimdall-igw.id

}

resource "aws_nat_gateway" "Heimdall-natgw" {
  allocation_id     = aws_eip.publicip-igw.id
  subnet_id         = aws_subnet.Heimdalldata-public-subnet-1.id
  connectivity_type = "public"
  tags = {
    Name = "Heimdall-natgw-${random_pet.server.id}-${random_id.server.dec}"
  }
}

resource "aws_route_table" "Heimdall-route-table1" {
  vpc_id = aws_vpc.Heimdalldata-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Heimdall-natgw.id
  }

  tags = {
    Name = "Heimdall-routes-${random_pet.server.id}-${random_id.server.dec}"
  }
}


resource "aws_route_table_association" "sub_ass" {
  subnet_id      = aws_subnet.Heimdalldata-private-subnet-1.id
  route_table_id = aws_route_table.Heimdall-route-table1.id
}