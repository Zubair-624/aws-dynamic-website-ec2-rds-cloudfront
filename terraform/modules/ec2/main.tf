# ----------Latest Ubuntu 24.04 AMI----------
# Instead of hardcoding an AMI ID (which changes over time and differs per region)
# Get the latest official Ubuntu 24.04 AMI from Canonical
data "aws_ami" "ubuntu_24_04" {

    most_recent = true 

    # this is Canonical's official AWS account ID (Canonical = the company that makes Ubuntu)
    owners = ["099720109477"]

    filter {
      name = "name"
      values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
  
}


#----------Elastic IP (Static Public IP for EC2)----------
# Assign a fixed public IP to the EC2 instance.
# This IP stays the same even if the instance is restarted,
# making it easier for GitHub Actions to connect and deploy.
resource "aws_eip" "ec2_eip" {

    instance = aws_instance.main.id

    domain = "vpc"

    tags = {
        Name = "${var.project_name}-ec2-eip"
    }
  
}

#----------EC2 Instance (Web Server)----------
resource "aws_instance" "main" {

    tags = {
        Name = "${var.project_name}-web-server"
    }

    # AMI (OS Image) - Ubuntu 24.04
    # Above in "data block resource"
    ami = data.aws_ami.ubuntu_24_04.id

    # Instance type — t3.micro = free tier
    instance_type = var.ec2_instance_type

    # Launch the EC2 instance in the public subnet
    # so it can receive traffic from the internet
    subnet_id = var.public_subnet_id

    # Attach the security group we created above
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]

    # Attach the IAM instance profile, so EC2 can talk to SSM and other AWS services
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  
}