# General Configuration: Box
resource "aws_s3_bucket" "website" {

    tags = {
        Name = "${project_name}-s3-bucket"
    }
  
}

# Object Ownership: Box
resource "aws_s3_bucket_ownership_controls" "website" {

    bucket = aws_s3_bucket.website.id

    rule {
      object_ownership = "BucketOwnerEnforced"
    }
  
}

# Block Public Access Settings for this bucket: Box
resource "aws_s3_bucket_public_access_block" "website" {

    bucket = aws_s3_bucket.website.id

    block_public_acls = true
    block_public_policy = true 
    ignore_public_acls = true
    restrict_public_buckets = true 
  
}

#-----Click Button ---> Create Bucket-----


# After create the bucket
# Now, upload the website
locals {
  websile_files = fileset("${path.module}/../website", "**")
}

resource "aws_s3_object" "website_upload" {

    bucket = aws_s3_bucket.website.id

    for_each = local.websile_files

    key = each.value
    source = "${path.module}/../website/${each.value}"
  
}

# In the s3 bucket console -> permision tab ->Bucket policy
resource "aws_s3_bucket_policy" "website" {

    bucket = aws_s3_bucket.website.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Sid = "AllowCloudFrontServicePrincipal"
                Effect = "Allow"
                Principal = {
                    Service = "cloudfront.amazonaws.com"
                }
                Action = "S3:GetObject"
                Resource = "${aws_s3_bucket.website.arn}/*"
                Condition = {
                    StringEquals = {
                        "AWS:SourceArn" = var.aws_s3_advanced_cloudfront_distribution_arn
                    }
                }
            }
        ]
    })
  
}









