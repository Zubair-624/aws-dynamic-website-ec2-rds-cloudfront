#----------Project Name----------
variable "project_name" {

    description = "Default Project Name for the entire project"
    type = string
    default = "aws-dynamic-website-ec2-rds-cloudfront"
  
}

#----------Region----------
variable "aws_region" {

    description = "Default region for the entire project"
    type = string
    default = "us-east-1"
  
}