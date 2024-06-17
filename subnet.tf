resource "aws_subnet" "subnet_a_a" {
  provider          = aws.dev
  vpc_id            = aws_vpc.cluster_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.1.1.0/24"
}

resource "aws_subnet" "subnet_a_b" {
  provider          = aws.dev
  vpc_id            = aws_vpc.cluster_vpc.id
  availability_zone = "us-east-1a"
  cidr_block        = "10.1.2.0/24"
}

resource "aws_subnet" "subnet_b_a" {
  provider          = aws.dev
  vpc_id            = aws_vpc.cluster_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.1.3.0/24"
}

resource "aws_subnet" "subnet_b_b" {
  provider          = aws.dev
  vpc_id            = aws_vpc.cluster_vpc.id
  availability_zone = "us-east-1b"
  cidr_block        = "10.1.4.0/24"
}