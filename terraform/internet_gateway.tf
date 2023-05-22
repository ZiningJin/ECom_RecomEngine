resource "aws_internet_gateway" "DE-ers-igw" {
  vpc_id = aws_vpc.imba-vpc.id
  tags = {
    Name = "DE-ers-igw"
  }
}