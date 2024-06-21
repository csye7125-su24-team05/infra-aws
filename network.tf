resource "aws_vpc" "cluster_vpc" {
  provider   = aws.profile
  cidr_block = var.vpc.cidr_block
}

resource "aws_internet_gateway" "cluster_vpc_igw" {
  provider = aws.profile
  vpc_id   = aws_vpc.cluster_vpc.id
}

resource "aws_security_group" "cluster_vpc_secruity_group" {
  provider   = aws.profile
  vpc_id     = aws_vpc.cluster_vpc.id
  name       = "cluster_vpc_secruity_group"
  depends_on = [aws_vpc.cluster_vpc]
}

resource "aws_route_table" "subnet_route_table" {
  provider = aws.profile
  for_each = var.subnets
  vpc_id   = aws_vpc.cluster_vpc.id
  tags = {
    Name = "${each.key}_route_table"
  }
  depends_on = [aws_vpc.cluster_vpc]
}

resource "aws_eip" "nat_eips" {
  provider = aws.profile
  for_each = { for idx, subnet in var.subnets : idx => subnet if subnet.map_public_ip_on_launch == false }
  domain   = "vpc"
  tags = {
    Name = "${each.key}_nat_eip"
  }
  depends_on = [aws_subnet.subnets]
}

resource "aws_nat_gateway" "nat_gateways" {
  provider      = aws.profile
  for_each      = { for idx, subnet in var.subnets : idx => subnet if subnet.map_public_ip_on_launch == false }
  allocation_id = aws_eip.nat_eips[each.key].id
  subnet_id     = aws_subnet.subnets["${substr(each.key, 0, length(each.key) - 2)}-b"].id
  tags = {
    Name = "${each.key}_nat_gateway"
  }
  depends_on = [aws_eip.nat_eips]
}

resource "aws_route" "routes" {
  provider               = aws.profile
  for_each               = aws_subnet.subnets
  route_table_id         = aws_route_table.subnet_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = each.value.map_public_ip_on_launch ? aws_internet_gateway.cluster_vpc_igw.id : null
  nat_gateway_id         = each.value.map_public_ip_on_launch ? null : aws_nat_gateway.nat_gateways[each.key].id
  depends_on             = [aws_internet_gateway.cluster_vpc_igw, aws_nat_gateway.nat_gateways]
}

resource "aws_route_table_association" "subnet_route_table_association" {
  provider       = aws.profile
  for_each       = aws_subnet.subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.subnet_route_table[each.key].id
  depends_on     = [aws_subnet.subnets, aws_route_table.subnet_route_table]
}