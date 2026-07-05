#----------Root Project Name----------
variable "root_project_name" {

  type        = string
  default     = "aws-dynamic-website-ec2-rds-cloudfront"

}

#----------Root Region----------
variable "aws_region" {

  description = "Default region for the entire project"
  type        = string
  default     = "us-east-1"

}

#----------Root VPC Variable----------

# VPC CIDR Block
variable "root_aws_vpc_cidr_block" {

  type        = string
  default     = "10.0.0.0/16"

}

# Public Subnet CIDRs
variable "root_aws_vpc_public_subnet_cidrs" {

  description = "CIDR Block for the public subnet cidr"
  type        = list(string)

}

# Private Subnet CIDRs
variable "root_aws_vpc_private_subnet_cidrs" {

  description = "CIDR block for the private subnet"
  type        = list(string)

}

# Availability Zone(AZs)
variable "root_azs" {

  description = "Availability Zone for the Public and Private Subnets"
  type        = list(string)

}

#----------Root Security Group Variable----------

# fetch_ = do not need variabel

#--------------------Ec2--------------------
variable "ec2_instance_type" {

  type = string
  default = "t3.micro"
  
}

#--------------------SSM Parameter Store--------------------

#---RDS (MySQL) Database Name---
variable "root_db_name" {

  type = string

}

#---RDS (MySQL) Database Username---
variable "root_db_username" {

  type = string
  
}

