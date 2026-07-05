#---IAM Instance Profile Output---
# EC2 module needs this to attach the profile to the instance
output "output_ec2_iam_instance_profile" {

    value = aws_iam_instance_profile.ec2_profile.name
  
}

# RDS Output
output "output_rds_monitoring_role_arn" {

    value = aws_iam_role.rds_monitoring_role.arn
  
}

