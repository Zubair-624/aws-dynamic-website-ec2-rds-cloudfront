#---Step 2: Get Started: Box---
resource "aws_cloudfront_distribution" "main" {

  provider = aws.us_east_1 

    comment = "${var.project_name}-Dynamic-Website-CDN"
    enabled = true 



    tags = {
        Name = "${var.project_name}-cloudfront"
    }

    web_acl_id = aws_wafv2_web_acl.waf.arn

#-------------------------------------------------------------------

    #---Step 3: Specify Origin: Box---

    #-----Origin 1 (EC2 - Dynamic content: pages, DB-driven routes)-----
    # Origin = your EC2 server (Elastic IP, port 80)
    origin {

      # Raw IP wrapped in nip.io wildcard DNS —
      # CloudFront's custom_origin_config requires a real domain name, not a bare IP
      domain_name = "${replace(var.fetch_output_ec2_public_ip, ".", "-")}.nip.io"

    # origin_id = target_origin_id , need to match each other
      origin_id = "${var.project_name}-ec2-origin"

      custom_origin_config {

        # CloudFront talks to EC2 on port 80 (Nginx)
        http_port = 80
        https_port = 443

        # Use HTTP to talk to EC2 origin
        # Cloudfront handals HTTPS with visitors externally
        origin_protocol_policy = "http-only"

        origin_ssl_protocols = ["TLSv1.2"]
      }

    }

    #-----Origin 2 (S3 - Publicly viewable user-uploaded content)-----
    # Serves things like shared images that users uploaded through the app
    origin {
      domain_name = var.fetch_output_s3_bucket_regional_domain_name
      origin_id                = "${var.project_name}-s3-origin"
      origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    }

    #---Settings: Box---

    #---
    # Cache settings
    # select -> Customize cache settings

    #---Default Cache Behavior (EC2 - all pages, forms, DB-driven routes)---
    # TTL = 0 everywhere because this is a DYNAMIC website
    # Caching would show wrong/outdated data from the database
    default_cache_behavior {

        # origin_id = target_origin_id , need to match each other
        target_origin_id = "${var.project_name}-ec2-origin"
      
        #---

        # Always redirect HTTP to HTTPS
        # Visitors get HTTPS even through EC2 uses HTTP internally
        # Viewer protocol policy
        viewer_protocol_policy = "redirect-to-https"

        # Allow all HTTP methods
        # Dynamic site needs POST (form submit), DELETE, PUT, PATCH
        # Allow HTTP methods
        allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
        # cached_methods is not vm
        cached_methods = ["GET", "HEAD"]

        #---

        #---

        # Forward EVERYTHING to EC2
        # Flask needs cookies (sessions), query strings (search/filter),
        # and headers (proper request handling)
        # Cache policy
        # select -> CachingDisabled

        forwarded_values {
          
          cookies {
            forward = "all"
          }

          query_string = true 

          headers = ["*"]
        }

        # TTL = 0 means NO caching at all
        # Every request goes straight through to EC2/Flask
        min_ttl = 0
        default_ttl = 0
        max_ttl = 0

        # Compress responses (speeds up page loads)
        compress = true 

    }

    #---Ordered Cache Behavior (S3 - user-uploaded public images)---
    # ← IMPROVED: path changed from /static/* to /uploads/* — this bucket holds
    # user-uploaded publicly viewable content, not build-time CSS/JS assets
    ordered_cache_behavior {
      path_pattern     = "/uploads/*"
      target_origin_id = "${var.project_name}-s3-origin"

      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD"]
      cached_methods  = ["GET", "HEAD"]

      forwarded_values {
        cookies {
          forward = "none"
        }
        query_string = false
      }

      # Uploaded images rarely change once uploaded — safe to cache
      min_ttl     = 0
      default_ttl = 86400
      max_ttl     = 31536000

      compress = true
    }

    #----------SSL Certificate----------
    # Use CloudFront's default certificate
    # This gives you free HTTPS at xxxxx.cloudfront.net
    # No custom domain or ACM certificate needed
    viewer_certificate {
      cloudfront_default_certificate = true
    }
    
    #----------Price Class----------
    # PriceClass_100 = cheapest option
    # Serves from US and Europe edge locations only
    # Good enough for a portfolio project
    price_class = "PriceClass_100"

    #----------Geo Restriction----------
    # No restrictions — allow visitors from any country
    restrictions {
      geo_restriction {
        restriction_type = "none"
      }
    }
    
}

#----------------------------------------------------------------------------------

#-----Origin Access Control (for S3)-----
# Required so CloudFront can securely sign requests to S3.
# Without this, the S3 bucket policy's "AWS:SourceArn" condition has nothing valid to check against.
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  provider = aws.us_east_1

  name                              = "${var.project_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

#-----Step 4: Enable security-----

#[---Web Application Firewall (WAF): Box---]

# Rate limiting
# Select -> Toggle On
resource "aws_wafv2_web_acl" "waf" {

  provider = aws.us_east_1
  
  name = "${var.project_name}-waf"

  scope = "CLOUDFRONT"
    

    default_action {
      allow {
        
      }
    }

    rule {
      name = "rate-limiting"
      priority = 1

      action {
        block {
          
        }
      }

      statement {
        rate_based_statement {
          limit = 2000
          aggregate_key_type = "IP"
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name = "rate-limiting"
        sampled_requests_enabled = true
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true 
      metric_name = "${var.project_name}-waf"
      sampled_requests_enabled = true
    }

    tags = {
        Name = "${var.project_name}-waf"
    }
  
}