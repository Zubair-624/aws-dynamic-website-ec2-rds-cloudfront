#---Project Name---
variable "project_name" {
    
    type = string
}

#---VPC CIDR Block---
variable "aws_vpc_cidr_block" {

    type = string
    default = "10.0.0.0/16"
}

#---Availability Zone---
variable "azs" {
    
    type = list(string)
}

#---Public Subnet CIDR---
variable "aws_vpc_public_subnet_cidrs" {
    
    type = list(string)
}

#---Private Subnet CIDR---
variable "aws_vpc_private_subnet_cidrs" {
    
    type = list(string)
}