# Step 2: Get Started: Box
resource "aws_cloudfront_distribution" "main" {

    tags = {
        Name = "${var.project_name}-cloudfront"
    }

    comment = "Cloudfornt for this project"

    
  
}