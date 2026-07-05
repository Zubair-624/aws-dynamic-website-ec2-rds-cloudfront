#----------VPC ID----------

# VPC CIDR Block
output "main_output_aws_vpc_id" {

  value       = module.vpc.output_aws_vpc_id

}

# Public Subnet IDs
output "main_output_aws_vpc_public_subnet_ids" {

  value       = module.vpc.output_aws_vpc_public_subnet_ids

}

# Private Subnet IDs
output "main_output_aws_vpc_private_subnet_ids" {

  value       = module.vpc.output_aws_vpc_private_subnet_ids

}

# Public Route Table IDs
output "main_output_aws_vpc_public_route_table_id" {

  value       = module.vpc.output_aws_vpc_public_route_table_id
}

#----------Security Group ID----------
# root output.tf depends on -> modules/X/outputs.tf

#---EC2 Root Output---
output "main_output_ec2_id" {
  
  value = module.security_group.output_ec2_id
}

#---RDS Root Output---
output "main_output_rds_id" {

  value = module.security_group.output_rds_id
  
}

#----------IAM ID Output----------
output "main_output_ec2_iam_instance_profile" {

  value = module.iam.output_ec2_iam_instance_profile

}

output "main_output_rds_monitoring_role_arn" {

  value = module.iam.output_rds_monitoring_role_arn
  
}

#--------------------EC2 ID Output--------------------

#---EC2 AMI ID---
output "main_output_aws_ami_id" {

  value       = module.ec2.output_aws_ami_id

}

# #---EC2 Instance ID---
# output "main_output_aws_instance_id" {

#   value       = module.ec2.output_aws_instance_id

# }

# #---EC2 Security Group ID---
# output "main_output_ec2_security_group_id" {

#   value = module.ec2.output_ec2_security_group_id

# }

#---EC2 Public IP (Elastic IP)---
output "main_output_ec2_public_ip" {

  value = module.ec2.output_ec2_public_ip

}


#--------------------SSM Parameter Store ID Output--------------------

#---DB Name Output---
output "main_output_db_name_arn" {

  value = module.ssm_parameter_store.output_db_name_arn
  
}

#---DB Username Output---
output "main_output_db_username" {

  value = module.ssm_parameter_store.output_db_username
  
}

#----DB Password Output---
output "main_output_db_password" {

  value = module.ssm_parameter_store.output_db_password
  
}

#---Rnadom Auto Generated Password output---
output "main_output_random_db_passsword" {

  value = module.ssm_parameter_store.output_random_db_password
  
}

#--------------------RDS ID Output--------------------

#---RDS Endpoint---
output "main_output_rds_endpoint" {

  value = module.rds.output_rds_endpoint
  
}

#---RDS Database Name---
output "main_output_rds_db_name" {

  value = module.rds.output_rds_db_name
  
}

#---RDS Port---
output "main_output_rds_port" {

  value = module.rds.output_rds_port
}

#----------Cloudfront ID----------
output "main_output_cloudfront_distribution_id" {

  value = module.cloudfront.output_cloudfront_distribution_id
  
}

output "main_output_cloudfront_domain_url" {

  value = module.cloudfront.output_cloudfront_domain_url
  
}