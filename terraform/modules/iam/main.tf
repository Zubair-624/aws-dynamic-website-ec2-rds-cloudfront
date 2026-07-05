#  Step 1: Trusted Entity + Use Case = aws_iam_role
resource "aws_iam_role" "ec2_ssm_role" {

    name = "${var.project_name}-ec2-ssm-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "ec2.amazonaws.com"
            }
        }]
    })

    tags = {
        Name = "${var.project_name}-ec2-role"
    }
  
}

# Step 2: Add Permission
# Permission = Policy
resource "aws_iam_role_policy_attachment" "ssm_policy" {

    role = aws_iam_role.ec2_ssm_role.name

    # Connect to EC2 via SSM Session Manager (no SSH)
    # After this, the EC2 can be accessed via SSM Session Manager - no .pem file, no port 22, no SSH at all
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  
}

# Step 3: Console(Auto), but in terraform need to write manually
resource "aws_iam_instance_profile" "ec2_profile" {

    # question is -> Which Role Goes Inside It?
    # Add our EC2 IAM role to this Instance Profile
    # or, Put the EC2 role inside the Instance Profile so EC2 can use it
    role = aws_iam_role.ec2_ssm_role.name
    
    tags = {
        Name = "${var.project_name}-ec2-profile"
    }
  
}



#--------------------------------------------------------------------

resource "aws_iam_role" "rds_monitoring_role" {

    name = "${var.project_name}-rds-monitoring-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "monitoring.rds.amazonaws.com"
            }

        }]
    })

    tags = {
        Name = "${var.project_name}-rds-monitoring-role"
    }
  
}

resource "aws_iam_role_policy_attachment" "monitoring_policy" {

    role = aws_iam_role.rds_monitoring_role.name

    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
  
}
