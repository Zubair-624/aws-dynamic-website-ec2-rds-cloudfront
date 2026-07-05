# This is REST Endpoint
# REST Endpoint work with the OAC
# OAC helps to cloudfront to access the s3 bucket
# Network Address of the s3 bucket

#---aws_s3_bucket.website.bucket_regional_domain_name → S3 address---

# TWO THINGS THIS OUTPUT DOES:
# 1. Gives CloudFront the ADDRESS of where S3 lives
#    so CloudFront knows where to go to fetch files
# 2. OAC then secures that address — signs every request
#    so S3 knows only OUR CloudFront is knocking
output "aws_s3_bucket_network_address" {

    description = "S3 REST endpoint used as CloudFront origin domain"
    value = aws_s3_bucket.website.bucket_regional_domain_name
  
}

output "aws_s3_bucket_arn_address" {

    description = "Full ARN of the S3 bucket"
    value = aws_s3_bucket.website.arn
  
}