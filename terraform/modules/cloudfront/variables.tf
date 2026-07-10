terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.0"
      configuration_aliases = [aws.us_east_1]
    }
  }
}


#---Project Name---
variable "project_name" {

    type = string
  
}

#---Fetch -> EC2 public IP---
variable "fetch_output_ec2_public_ip" {

    type = string
  
}

#---Fetch -> S3 Bucket Regional Domain Name---
variable "fetch_output_s3_bucket_regional_domain_name" {

    type = string
  
}