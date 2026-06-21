#----------Project Name----------
variable "project_name" {

    description = "Project name used for naming all resources"
    type = string
  
}

#----------VPC ID----------
variable "main_vpc_id" {

    description = "VPC ID will callup to the modules/vpc/outputs.tf"
    type = string
  
}

#----------Public Subnet ID----------
variable "public_subnet_id" {

    description = "ID of the public subnet where EC2 will be launched"
    type = string
  
}

#----------EC2 Instance Type----------
variable "ec2_instance_type" {

    description = "EC2 Instance type"
    type = string
    default = "t3.micro"
  
}