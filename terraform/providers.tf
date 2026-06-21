terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "aws" {

  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      CostCenter  = "learning"
      ManagedBy   = "terraform"
      Project     = "aws-dynamic-website-ec2-rds-cloudfront"
      Owner       = "zubair mazumder"
    }
  }

}