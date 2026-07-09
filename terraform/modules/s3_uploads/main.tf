#-----General Configuration: Box-----
resource "aws_s3_bucket" "website" {


    # Bucket namespace
    tags = {
        Name = "${var.project_name}-s3-bucket"
    }
  
}

#-----Object Ownership: Box-----
resource "aws_s3_bucket_ownership_controls" "website" {

    bucket = aws_s3_bucket.website.id

    # Object Ownership
    # select -> Bucket owner enforced (By default)
    rule {
      object_ownership = "BucketOwnerEnforced"
    }
  
}

#-----Block Public Access Settings for this bucket: Box-----
resource "aws_s3_bucket_public_access_block" "website" {

    bucket = aws_s3_bucket.website.id

    # Block all public access
    block_public_acls = true
    block_public_policy = true 
    ignore_public_acls = true
    restrict_public_buckets = true 
  
}

#-----------------------------------------
#-----Click Button ---> Create Bucket-----
#-----------------------------------------

# After create the bucket
# Now, upload the website
locals {
  website_file_path = fileset("${path.module}/../website", "**")
  mime_types = {
    ".html" = "text/html"
    ".css"  = "text/css"
    ".js"   = "application/javascript"
    ".png"  = "image/png"
    ".jpg"  = "image/jpeg"
    ".ico"  = "image/x-icon"
    ".json" = "application/json"
  }
}


resource "aws_s3_object" "website_upload" {

    bucket = aws_s3_bucket.website.id

    #---
    for_each = local.website_file_path
    key = each.value
    source = "${path.module}/../website/${each.value}"
    #---

    #---
    content_type = lookup(
    local.mime_types,
    regex("\\.[^.]+$", each.value),
    "application/octet-stream"
)

    storage_class = "STANDARD"

    etag = filemd5("${path.module}/../website/${each.value}")
    #---
  
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
                Action = "s3:GetObject"
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









