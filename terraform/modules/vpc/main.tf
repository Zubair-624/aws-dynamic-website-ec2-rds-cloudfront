#----------VPC----------
resource "aws_vpc" "vpc" {

    tags = {
      Name = "${var.project_name}-vpc"
      Environment = var.environment
    }

    cidr_block = var.aws_vpc_cidr_block

    enable_dns_support = true
    enable_dns_hostnames = true
    
  
}

#----------IGW----------
resource "aws_internet_gateway" "igw" {
  
  tags = {
    Name = "${var.project_name}-igw"
    Environment = var.environment
  }

  vpc_id = aws_vpc.vpc.id


}

#----------Public Subnet----------
resource "aws_subnet" "public_subnet" {

  tags = {
    Name = "${var.project_name}-"
  }

  vpc_id = 
  
}
