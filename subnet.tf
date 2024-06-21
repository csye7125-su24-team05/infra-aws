resource "aws_subnet" "subnets" {
  provider                = aws.profile
  for_each                = var.subnets
  vpc_id                  = aws_vpc.cluster_vpc.id
  availability_zone       = each.value.availability_zone
  cidr_block              = each.value.cidr_block
  map_public_ip_on_launch = each.value.map_public_ip_on_launch
  tags = {
    Name = each.key
  }
}
