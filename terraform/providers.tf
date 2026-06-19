terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 6.0"
    }
  }
}

provider "aws" {

    region = var.aws_region

    default_tags {
      tags = {
        Environmet = "dev"
        CostCenter = "learning"
        ManagedBy = "terraform"
        Project = "aws-dynamic-website-ec2-rds-cloudfront"
        Owner = "zubair mazumder"
      }
    }
  
}