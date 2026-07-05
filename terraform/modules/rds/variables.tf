#---Project Name---
variable "project_name" {

    type = string
  
}

#---Fetech -> Database Name---
variable "fetch_root_db_name" {

    type = string
  
}

#---Fetech -> Database Username---
variable "fetch_root_db_username" {

    type = string
  
}

#---Fetch -> Database Password (Random Password)---
variable "fetch_root_db_random_password" {
  type = string
  sensitive = true
}

#---Fetch -> AWS VPC Private Subnet ID---
variable "fetch_output_aws_vpc_private_subnet_id" {

    type = list(string)
  
}


#---Fetech -> RDS Security Group---
variable "fetech_main_output_rds_security_group" {

    type = string
  
}

# Fetch -> IAM RDS Role---
variable "fetech_output_rds_monitoring_role_arn" {

    type = string
  
}

