#----------Project Name----------
variable "project_name" {

  description = "Default Project Name for the entire project"
  type        = string
  default     = "aws-dynamic-website-ec2-rds-cloudfront"

}

#----------Region----------
variable "aws_region" {

  description = "Default region for the entire project"
  type        = string
  default     = "us-east-1"

}

#----------VPC----------

#VPC CIDR Block
variable "aws_vpc_cidr_block" {

  description = "CIDR Block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

}

# Public Subnet CIDRs
variable "public_subnet_cidrs" {

  description = "CIDR Block for the public subnet cidr"
  type        = list(string)

}

# Private Subnet CIDRs
variable "private_subnet_cidrs" {

  description = "CIDR block for the private subnet"
  type        = list(string)

}

# Availability Zone(AZs)
variable "azs" {

  description = "Availability Zone for the Public and Private Subnets"
  type        = list(string)

}