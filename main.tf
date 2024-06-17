provider "aws" {
  alias = "dev"
  profile = "dev"
  region = "us-east-1"
}

resource "aws_vpc" "cluster_vpc" {
    provider = aws.dev
    cidr_block = "10.1.0.0/16"
}