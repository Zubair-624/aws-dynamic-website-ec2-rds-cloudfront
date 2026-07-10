#----------Security Group (Firewall Rules)----------

#-----EC2 Security Group-----
# Controls what traffic is allowed in and out of the EC2 instance
# No SSH ingress needed - access is via AWS SSM Session Manager (outbound-only, covered by egress below)

resource "aws_security_group" "ec2_sg" {

    tags = {
        Name = "${var.project_name}-ec2-sg"
    }

    description = "Allow HTTP/HTTPS inbound, all outbound (SSM Session Manager used for shell access)"

    vpc_id = var.fetch_output_aws_vpc_id

    # Allow inbound HTTP(port 80)
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "HTTP port access"
    }

    # Allow inbound HTTPS(port 443)
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        description = "Allow HTTPS"
    }

    # Allow ALL outbound traffic (needed so EC2 can reach -> SSM Session Manager, SSM Parameter Store, S3, etc)
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        description = "allow all"
    }
  
}

#-----RDS Security Group-----
resource "aws_security_group" "rds_sg" {

    tags = {
        Name = "${var.project_name}-rds-sg"
    }

    description = "Security Group for RDS"

    vpc_id = var.fetch_output_aws_vpc_id 

    # With ingress rule, the EC2 instance connect to RDS on port 3306 at all -> ingress rule (allowing EC2 → RDS on 3306) 
    # Allow inbound MySQL(port 3306) only from EC2 security group
    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = [aws_security_group.ec2_sg.id]
        description = "MySQL access from EC2 only"
    }

    #---
    # RDS does not need internet access because it only receives database connections
    # or, No internet access needed because RDS only handles database traffic
    #---
}

