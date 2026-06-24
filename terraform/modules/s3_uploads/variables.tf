# Project Name
variable "project_name" {

    description = "Project Name that will be for all resources"
    type = string
  
}

# The bucket policy needs the CloudFront ARN to write this rule
# Advanced Cloudfront ARN variable
# ---Only allow THIS specific CloudFront distribution into S3---
variable "aws_s3_advanced_cloudfront_distribution_arn" {

    description = "ARN of the CloudFront distribution allowed to access this bucket"
    type = string
  
}