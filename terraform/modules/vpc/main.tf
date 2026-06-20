#----------VPC----------
resource "aws_vpc" "vpc" {

    tags = {
      Name = "${var.project_name}-vpc"
    }

    cidr_block = var.aws_vpc_cidr_block

    enable_dns_support = true
    enable_dns_hostnames = true
    
  
}

#----------IGW----------
resource "aws_internet_gateway" "igw" {
  
  tags = {
    Name = "${var.project_name}-igw"
  }

  vpc_id = aws_vpc.vpc.id


}

#----------Public Subnet----------
resource "aws_subnet" "public_subnets" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index}"
  }

  availability_zone = var.azs[count.index]

  cidr_block = var.public_subnet_cidrs[count.index]
  count = length(var.public_subnet_cidrs)

  # EC2 gets public ip -> so EC2 can reach the internet
  map_public_ip_on_launch = true
  
}

#----------Private Subnet----------
resource "aws_subnet" "private_subnets" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index}"
  }

  availability_zone = var.azs[count.index]

  cidr_block = var.private_subnet_cidrs[count.index]
  count = length(var.private_subnet_cidrs)

  map_public_ip_on_launch = false 
  
}

#----------Public Route Table----------
# Route Table = A set of ruls that tells network traffic where to go
resource "aws_route_table" "public_rt" {

  tags = {
    Name = "${var.project_name}-public-rt"
  }

  vpc_id = aws_vpc.vpc.id

  # All traffic -> Internet Gateway -> Internet Directly
  route {

    # "All traffic" or every "IP Address" on the internet
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id  
  }

}

#----------Route Table Association(Public Subent + Public Route Table)
resource "aws_route_table_association" "public_rt_assoc" {

  subnet_id = aws_subnet.public_subnets[count.index].id

  route_table_id = aws_route_table.public_rt.id
  count = length(var.public_subnet_cidrs)
  
}