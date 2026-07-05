#---Project Name---
variable "project_name" {

    description = "Project name used for naming all resources"
    type = string
  
}

#---VPC ID---
variable "fetch_output_aws_vpc_id" {

    description = "VPC ID will callup to the modules/vpc/outputs.tf"
    type = string
  
}

#---Fetch -> EC2 security group---
variable "fetch_output_ec2_security_group_id" {

    type = string
  
}

#---Public Subnet ID---
variable "fetch_output_aws_public_subnet_id" {

    description = "ID of the public subnet where EC2 will be launched"
    type = string
  
}

#---EC2 Instance Type---
variable "ec2_instance_type" {

    type = string
    default = "t3.micro"
  
}

#---EC2 IAM Instance Profile Attache---
variable "fetch_output_ec2_iam_instance_profile" {

    type = string
  
}