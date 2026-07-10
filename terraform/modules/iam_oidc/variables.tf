#---Project Name---
variable "project_name" {
    type = string
}
#---AWS Account ID---
# ← IMPROVED: Removed hardcoded default — account IDs shouldn't sit as plaintext
# defaults in a public repo. Pass this via terraform.tfvars (gitignored) instead.
variable "aws_account_id" {
    type = string
  
}
#---GitHub Repo Name---
variable "github_repo_name" {
    type = string
    default = "aws-dynamic-website-ec2-rds-cloudfront"
  
}