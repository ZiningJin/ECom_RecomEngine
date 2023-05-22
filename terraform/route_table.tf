resource "aws_route_table" "pub_subnet" {
  vpc_id = aws_vpc.imba-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.DE-ers-igw.id
  }
  tags = { Name = "DE-ers-imba-rtb-public" }
}

resource "aws_route_table" "private_subnet_1" {
  vpc_id = aws_vpc.imba-vpc.id
  tags   = { Name = "DE-ers-imba-rtb-private-1" }
  # route{
  #     cidr_block = "0.0.0.0/0"
  # }
}

resource "aws_route_table" "private_subnet_2" {
  vpc_id = aws_vpc.imba-vpc.id
  tags   = { Name = "DE-ers-imba-rtb-private-2" }
  # route{
  #     cidr_block = "0.0.0.0/0"
  # }
}

resource "aws_route_table_association" "public_subnet_1" {
  subnet_id      = aws_subnet.DE-ers-public-subnet-1-ap-southeast-2a.id
  route_table_id = aws_route_table.pub_subnet.id
}

resource "aws_route_table_association" "private_subnet_1" {
  subnet_id      = aws_subnet.DE-ers-private-subnet-1-ap-southeast-2a.id
  route_table_id = aws_route_table.private_subnet_1.id
}

resource "aws_route_table_association" "public_subnet_2" {
  subnet_id      = aws_subnet.DE-ers-public-subnet-2-ap-southeast-2b.id
  route_table_id = aws_route_table.pub_subnet.id
}

resource "aws_route_table_association" "private_subnet_2" {
  subnet_id      = aws_subnet.DE-ers-private-subnet-2-ap-southeast-2b.id
  route_table_id = aws_route_table.private_subnet_2.id
}