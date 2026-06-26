#----------Security Group (Firewall Rules)----------
# Controls what traffic is allowed in and out of the EC2 instance
resource "aws_security_group" "ec2_sg" {

    tags = {
        Name = "${var.project_name}-ec2-sg"
    }

    description = "Allow HTTP/HTTPS inbound, all outbound"

    vpc_id = var.fetch_aws_vpc_id

    # Allow inbound HTTP(port 80)
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP pory access"
    }

    # Allow inbound HTTPS(port 443)
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS"
    }

    # Allow ALL outbound traffic (needed so EC2 can reach -> SSM, S3, the internet, etc)
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow all"
    }
  
}

