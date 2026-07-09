#---VPC ID Output---
output "output_aws_vpc_id" {

    value = aws_vpc.vpc.id
  
}

#---Public Subnet IDs Output---
output "output_aws_vpc_public_subnet_ids" {

    value = aws_subnet.aws_vpc_public_subnets[*].id
  
}

#---Private Subnet IDs Output---
output "output_aws_vpc_private_subnet_ids" {

    value = aws_subnet.aws_vpc_private_subnets[*].id 
  
}

#---Public Route Table Output---
output "output_aws_vpc_public_route_table_id" {

    value = aws_route_table.aws_vpc_public_rt.id 
  
}

#---NAT Gateway ID Output---
output "output_aws_vpc_nat_gateway_id" {

    value = aws_nat_gateway.aws_vpc_nat.id
  
}

#---NAT Gateway Public IP Output---
output "output_aws_vpc_nat_eip" {

    value = aws_eip.aws_vpc_nat_eip.public_ip
  
}

#---Private Route Table Output---
output "output_aws_vpc_private_route_table_id" {

    value = aws_route_table.aws_vpc_private_rt.id 
  
}

