#---Project Name---
variable "project_name" {

    type = string

}

#---AWS Account ID---
variable "aws_account_id" {

    type = string
    default = "688025747774"
  
}

#---GitHub Repo Name---
variable "github_repo_name" {

    type = string
    default = "aws-dynamic-website-ec2-rds-cloudfront"
  
}