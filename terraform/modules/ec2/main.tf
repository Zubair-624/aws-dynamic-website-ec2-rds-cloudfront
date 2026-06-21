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

#----------Security Group (Firewall Rules)----------
# Controls what traffic is allowed in and out of the EC2 instance
resource "aws_security_group" "ec2_sg" {

    name = "${var.project_name}-ec2-sg"

    description = "Allow HTTP/HTTPS inbound, all outbound"

    vpc_id = var.main_vpc_id

    # Allow inbound HTTP(port 80)
    ingress {
        description = "Allow HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow inbound HTTPS(port 443)
    ingress {
        description = "Allow HTTPS"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Allow ALL outbound traffic (needed so EC2 can reach -> SSM, S3, the internet, etc.)
    egress {
        description = "Allow all outbound traffic"
        from_port = 0
        to_port = 0 
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.project_name}-ec2-sg"
    }

}

#----------IAM Role (Identity EC2 Will Use)----------
#-----This code only says WHO can use the role, It does NOT say what the role can actually do. That part comes next via aws_iam_role_policy_attachment.-----

# This is the "identity" the EC2 instance assumes/assume responsibility, so it can talk to other AWS services like SSM and S3.

# Telling Terraform "create a new IAM Role in AWS
resource "aws_iam_role" "ec2_role" {

    name = "${var.project_name}-ec2-role"

    # This policy says: "EC2 instances are allowed to assume(become) this role"
    assume_role_policy = jsonencode({ #  converts this to JSON because AWS requires JSON
        Version = "2012-10-17"

        # A list of individual permission rules that I can have multiple rules inside this list. Right now I have only have one rule.
        Statement = [
            {
                Action = "sts:AssumeRole" # the act of "picking up" this role
                Effect = "Allow" # yes, allow it
                Principal = { # only EC2 instances can use it
                    
                    Service = "ec2.amazonaws.com"

                }

            }

        ]
    })

    tags = {
        Name = "${var.project_name}-ec2-role"
    }
  
}

#----------Attach AWS Managed Policy for SSM Session Manager----------

# Telling Terraform: "Attach a policy to a role"
resource "aws_iam_role_policy_attachment" "ssm_policy" {

    # question is -> Which Role Gets This Policy?
    # Attach this policy to the EC2 role created earlier
    # or, Get the name of the EC2 IAM role and attach this policy to it
    role = aws_iam_role.ec2_role.name

    # question is -> Which Policy to Attach?
    # Connect to EC2 via SSM Session Manager (no SSH)
    # After this, the EC2 can be accessed via SSM Session Manager - no .pem file, no port 22, no SSH at all
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}

#----------IAM Instance Profile----------

#-----AWS has a rule: EC2 cannot touch a Role directly. It MUST go through an Instance Profile-----

# Telling Terraform: "Create a new Instance Profile"
# or, Create a new Instance Profile (ID card holder)
resource "aws_iam_instance_profile" "ec2_profile" {

    name = "${var.project_name}-ec2-profile"

    # question is -> Which Role Goes Inside It?
    # Add our EC2 IAM role to this Instance Profile
    # or, Put the EC2 role inside the Instance Profile so EC2 can use it
    role = aws_iam_role.ec2_role.name
  
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