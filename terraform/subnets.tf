resource "aws_subnet" "DE-ers-public-subnet-1-ap-southeast-2a" {
  vpc_id            = aws_vpc.imba-vpc.id
  cidr_block        = "10.0.0.0/24"
  tags              = { Name = "DE-ers-imba-public-subnet-1-ap-southeast-2a" }
  availability_zone = "ap-southeast-2a"
}

resource "aws_subnet" "DE-ers-private-subnet-1-ap-southeast-2a" {
  vpc_id            = aws_vpc.imba-vpc.id
  cidr_block        = "10.0.1.0/24"
  tags              = { Name = "DE-ers-imba-private-subnet-1-ap-southeast-2a" }
  availability_zone = "ap-southeast-2a"
}

resource "aws_subnet" "DE-ers-public-subnet-2-ap-southeast-2b" {
  vpc_id            = aws_vpc.imba-vpc.id
  cidr_block        = "10.0.2.0/24"
  tags              = { Name = "DE-ers-imba-public-subnet-2-ap-southeast-2a" }
  availability_zone = "ap-southeast-2b"
}

resource "aws_subnet" "DE-ers-private-subnet-2-ap-southeast-2b" {
  vpc_id            = aws_vpc.imba-vpc.id
  cidr_block        = "10.0.3.0/24"
  tags              = { Name = "DE-ers-imba-private-subnet-2-ap-southeast-2a" }
  availability_zone = "ap-southeast-2b"
}

