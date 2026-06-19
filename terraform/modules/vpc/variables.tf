#----------Project Name----------
variable "project_name" {

    description = "Project name used in the vpc all resources"
    type = string
  
}

#----------Environment----------
variable "environment" {

    description = "Environment(dev)"
    type = string
  
}

#----------VPC CIDR Block----------
variable "aws_vpc_cidr_block" {

    description = "CIDR Block for the aws vpc"
    type = string
    default = "10.0.0.0/16"
  
}

