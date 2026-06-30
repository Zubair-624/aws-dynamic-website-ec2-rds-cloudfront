#--------------------VPC ID Output--------------------
output "output_aws_vpc_id" {

    description = "ID of the vpc"
    value = aws_vpc.vpc.id
  
}

#----------Public Subnet IDs Output----------
output "output_aws_vpc_public_subnet_ids" {

    description = "ID of the public subnet"
    value = aws_subnet.aws_vpc_public_subnets[*].id
  
}

#----------Private Subnet IDs Output----------
output "output_aws_vpc_private_subnet_ids" {

    description = "ID of the private subnet"
    value = aws_subnet.aws_vpc_private_subnets[*].id 
  
}

#----------Public Route Table Output----------
output "output_aws_vpc_public_route_table_id" {

    description = "ID of the public route table"
    value = aws_route_table.aws_vpc_public_rt.id 
  
}

