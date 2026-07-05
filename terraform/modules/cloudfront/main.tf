#---Step 2: Get Started: Box---
resource "aws_cloudfront_distribution" "main" {

    comment = "${var.project_name}-Dynamic-Website-CDN"
    enabled = true 



    tags = {
        Name = "${var.project_name}-cloudfront"
    }

    web_acl_id = aws_wafv2_web_acl.waf.arn

#-------------------------------------------------------------------

    #---Step 3: Specify Origin: Box---

    #-----Origin (Where CloudFront sends requests)-----
    # Origin = your EC2 server (Elastic IP, port 80)
    #
    origin {

      # the REAL EC2 server
      domain_name = var.fetch_output_ec2_public_ip

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

    #---Settings: Box---

    #---
    # Cache settings
    # select -> Customize cache settings

    #---Default Cache Behavior---
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