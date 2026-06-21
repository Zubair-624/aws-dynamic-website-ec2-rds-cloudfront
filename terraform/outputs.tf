#----------Root Level -> VPC ID Output----------

# VPC CIDR Block
output "main_vpc_id" {

  description = "Main ID of the VPC"
  value       = module.vpc.main_vpc_id

}

# Public Subnet IDs
output "main_public_subnet_ids" {

  description = "Main Ids of the public subnet cidrs"
  value       = module.vpc.public_subnet_ids

}

# Private Subnet IDs
output "main_private_subnet_ids" {

  description = "Main Ids of the private subnet cidrs"
  value       = module.vpc.private_subnet_ids

}

# Public Route Table IDs
output "main_public_route_table_id" {

  description = "Id of the public route table"
  value       = module.vpc.public_route_table_id
}

#--------------------EC2 Output--------------------

#----------EC2 AMI ID----------
output "aws_ami_id" {

  description = "AWS EC2 AMI (OS Image)"
  value = module.ec2.aws_ami_id
  
}

#----------EC2 Instance ID----------
output "aws_instance_id" {

  description = "Instance ID of the EC2"
  value = module.ec2.aws_instance_id
  
}

#----------EC2 Security Group ID----------
output "ec2_security_group_id" {

  value = module.ec2.ec2_security_group_id
  
}

#----------EC2 Public IP (Elastic IP)----------
output "ec2_public_ip" {

  value = module.ec2.ec2_public_ip
  
}
