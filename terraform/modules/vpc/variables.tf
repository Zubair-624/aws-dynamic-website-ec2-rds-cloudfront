#----------Project Name----------
variable "project_name" {
    description = "Project name used in the vpc all resources"
    type = string
}

#----------VPC CIDR Block----------
variable "aws_vpc_cidr_block" {
    description = "CIDR Block for the aws vpc"
    type = string
    default = "10.0.0.0/16"
}

#----------Availability Zone----------
variable "azs" {
    description = "AZ for public and private subnets"
    type = list(string)
}

#----------Public Subnet CIDR----------
variable "aws_vpc_public_subnet_cidrs" {
    description = "CIDR Block for the public subnet"
    type = list(string)
}

#----------Private Subnet CIDR----------
variable "aws_vpc_private_subnet_cidrs" {
    description = "CIDR Block for the private subnet"
    type = list(string)
}