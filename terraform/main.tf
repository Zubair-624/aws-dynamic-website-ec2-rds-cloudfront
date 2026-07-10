# Modul fully depends on -> modules/X/variables.tf

#----------VPC Module----------
module "vpc" {

  source = "./modules/vpc"

  # left side "project_name" comes from -> modules/vpc/variables.tf 
  project_name = var.root_project_name

  aws_vpc_cidr_block = var.root_aws_vpc_cidr_block

  azs = var.root_azs

  aws_vpc_public_subnet_cidrs = var.root_aws_vpc_public_subnet_cidrs

  aws_vpc_private_subnet_cidrs = var.root_aws_vpc_private_subnet_cidrs

}

#----------Security Group Module----------
module "security_group" {

  source = "./modules/security_group"

  project_name = var.root_project_name

  # fetch_ = do not need variabel
  fetch_output_aws_vpc_id = module.vpc.output_aws_vpc_id



}

#----------IAM Module----------
module "iam" {

  source = "./modules/iam"

  project_name = var.root_project_name


}



#----------EC2 Module (Web Server)----------
module "ec2" {

  source = "./modules/ec2"

  fetch_output_ec2_security_group_id = module.security_group.output_ec2_id

  project_name = var.root_project_name

  fetch_output_aws_public_subnet_id = module.vpc.output_aws_vpc_public_subnet_ids[0]

  ec2_instance_type = var.ec2_instance_type

  fetch_output_ec2_iam_instance_profile = module.iam.output_ec2_iam_instance_profile



}

#----------SSM Module (Secrets)----------
module "ssm_parameter_store" {

  source = "./modules/ssm_parameter_store"

  project_name = var.root_project_name

  db_name = var.root_db_name

  db_username = var.root_db_username

}

#----------S3 Module----------
module "s3" {

  source = "./modules/s3_uploads"

  project_name = var.root_project_name

  # aws_s3_advanced_cloudfront_distribution_arn = module.cloudfront.output_cloudfront_distribution_id

  aws_s3_advanced_cloudfront_distribution_arn = module.cloudfront.output_cloudfront_distribution_arn

}

#----------Cloudfront Module----------
module "cloudfront" {

  source = "./modules/cloudfront"

  providers = {
    aws.us_east_1 = aws.us_east_1
  }

  project_name = var.root_project_name

  fetch_output_ec2_public_ip = module.ec2.output_ec2_public_ip

  fetch_output_s3_bucket_regional_domain_name = module.s3.aws_s3_bucket_network_address
}


#----------IAM OIDC Module (GitHub Actions)----------
module "iam_oidc" {

  source = "./modules/iam_oidc"

  project_name = var.root_project_name

  aws_account_id = var.root_aws_account_id

  github_repo_name = var.root_github_repo_name

}

#----------RDS Module----------
module "rds" {

  source = "./modules/rds"

  project_name = var.root_project_name

  fetch_root_db_name = var.root_db_name

  fetch_root_db_username = var.root_db_username

  fetch_root_db_random_password = module.ssm_parameter_store.output_random_db_password

  fetch_output_aws_vpc_private_subnet_id = module.vpc.output_aws_vpc_private_subnet_ids

  fetech_main_output_rds_security_group = module.security_group.output_rds_id

  fetech_output_rds_monitoring_role_arn = module.iam.output_rds_monitoring_role_arn

}

