#---Cloudfornt Distribution ID---
output "output_cloudfront_distribution_id" {

    value = aws_cloudfront_distribution.main.id
  
}


#---Cloudfront Domain URL---
output "output_cloudfront_domain_url" {

    description = "Cloudfront URL - share this with anyone to visit the site"
    value = aws_cloudfront_distribution.main.domain_name
  
}

