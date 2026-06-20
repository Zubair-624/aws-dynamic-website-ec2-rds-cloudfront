#----------VPC ID Output----------
output "main_vpc_id" {

    description = "ID of the vpc"
    value = aws_vpc.vpc.id
  
}

#----------Public Subnet IDs Output----------
output "public_subnet_ids" {

    description = "ID of the public subnet"
    value = aws_subnet.public_subnets[*].id
  
}

#----------Private Subnet IDs Output----------
output "private_subnet_ids" {

    description = "ID of the private subnet"
    value = aws_subnet.private_subnets[*].id 
  
}

#----------Public Route Table Output----------
output "public_route_table_id" {

    description = "ID of the public route table"
    value = aws_route_table.public_rt.id 
  
}