provider "aws" {
  alias   = "dev"
  profile = "dev"
  region  = "us-east-1"
}

resource "aws_vpc" "cluster_vpc" {
  provider   = aws.dev
  cidr_block = "10.1.0.0/16"
}

resource "aws_security_group" "cluster_vpc_secruity_group" {
  provider = aws.dev
  vpc_id   = aws_vpc.cluster_vpc.id
  name     = "cluster_vpc_secruity_group"
}