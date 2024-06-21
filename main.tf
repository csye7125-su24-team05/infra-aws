terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  alias   = "profile"
  profile = var.aws_profile.profile
  region  = var.aws_profile.region
}