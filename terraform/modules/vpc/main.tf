#----------VPC----------
resource "aws_vpc" "vpc" {

    tags = {
      Name = "${var.project_name}-aws-vpc"
    }

    cidr_block = var.aws_vpc_cidr_block

    instance_tenancy = "default"

    enable_dns_support = true
    enable_dns_hostnames = true
    
}

#----------IGW----------
resource "aws_internet_gateway" "igw" {
  
  tags = {
    Name = "${var.project_name}-aws-vpc-igw"
  }

  vpc_id = aws_vpc.vpc.id


}

#----------Public Subnet----------
resource "aws_subnet" "aws_vpc_public_subnets" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-aws-vpc-public-subnet-${count.index}"
  }

  availability_zone = var.azs[count.index]

  cidr_block = var.aws_vpc_public_subnet_cidrs[count.index]
  count = length(var.aws_vpc_public_subnet_cidrs)

  # EC2 gets public ip -> so EC2 can reach the internet
  map_public_ip_on_launch = true
  
}

#----------Private Subnet----------
resource "aws_subnet" "aws_vpc_private_subnets" {

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-aws-vpc-private-subnet-${count.index}"
  }

  availability_zone = var.azs[count.index]

  cidr_block = var.aws_vpc_private_subnet_cidrs[count.index]
  count = length(var.aws_vpc_private_subnet_cidrs)

  map_public_ip_on_launch = false 
  
}

#----------Elastic IP (for NAT Gateway)----------
# Creates a static public IP that will be attached to the NAT Gateway so private subnets can access the internet
resource "aws_eip" "aws_vpc_nat_eip" {

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-aws-vpc-nat-eip"
  }

}

#----------NAT Gateway----------
# Allows private subnets to access the internet
# Lets resources in private subnets access the internet without giving them public IPs
# Without Nat Gateway, private subnets (EKS nodes, etc.) have NO internet route, they can't pull container images, hit AWS APIs, or download packages
resource "aws_nat_gateway" "aws_vpc_nat" {

  allocation_id = aws_eip.aws_vpc_nat_eip.id

  # NAT Gateway must live in a Public subnet (it needs the IGW route to reach the internet)
  subnet_id = aws_subnet.aws_vpc_public_subnets[0].id

  tags = {
    Name = "${var.project_name}-aws-vpc-nat"
  }

  # Wait until the Internet Gateway is created before creating the NAT Gateway
  depends_on = [aws_internet_gateway.igw]
}

#----------Public Route Table----------
# Route Table = A set of ruls that tells network traffic where to go
resource "aws_route_table" "aws_vpc_public_rt" {

  tags = {
    Name = "${var.project_name}-aws-vpc-public-rt"
  }

  vpc_id = aws_vpc.vpc.id

  # All traffic -> Internet Gateway -> Internet Directly
  route {

    # "All traffic" or every "IP Address" on the internet
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.igw.id  
  }

}

#----------Private Route Table----------
# Used by private subnets to access the internet through the NAT Gateway
# Gives private subnets internet access without exposing them to inbound internet traffic
# Send all outbound internet traffic through the NAT Gateway.
resource "aws_route_table" "aws_vpc_private_rt" {
  tags = {
    Name = "${var.project_name}-aws-vpc-private-rt"
  }
  vpc_id = aws_vpc.vpc.id

  # Send all internet traffic through the NAT Gateway
  # All traffic -> NAT Gateway -> Internet (outbound only, nothing can initiate inbound)
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.aws_vpc_nat.id
  }
}

#----------Public Route Table Association(Public Subent + Public Route Table)----------
resource "aws_route_table_association" "aws_vpc_public_rt_assoc" {

  subnet_id = aws_subnet.aws_vpc_public_subnets[count.index].id

  route_table_id = aws_route_table.aws_vpc_public_rt.id
  count = length(var.aws_vpc_public_subnet_cidrs)
  
}

#----------Private Route Table Association(Private Subnet + Private Route Table)----------
resource "aws_route_table_association" "aws_vpc_private_rt_assoc" {
  subnet_id = aws_subnet.aws_vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.aws_vpc_private_rt.id
  count = length(var.aws_vpc_private_subnet_cidrs)
  
}

