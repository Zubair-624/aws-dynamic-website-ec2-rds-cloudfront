#---Project Name---
variable "project_name" {

    description = "Project name will be apply all the resources"
    type = string
  
}

#---VPC ID---
variable "fetch_aws_vpc_id" {

    description = "VPC ID call variable"
    type = string
  
}