#----------AMI ID----------
#AMI ID used for the EC2 instance
output "aws_ami_id" {

    description = "AMI ID used for the EC2 instance"
    value = data.aws_ami.ubuntu_24_04.id
  
}

#----------EC2 instance ID----------
output "aws_instance_id" {

    description = "ID of the EC2 instance"
    value = aws_instance.main.id
  
}

#----------EC2 Public IP (Elastic IP)----------
# Needed for GitHub Actions deployment (EC2_HOST secret) and
# for testing the site in a browser
output "ec2_public_ip" {

    description = "Static public IP address of the EC2 instance"
    value = aws_eip.ec2_eip.public_ip
  
}

#----------EC2 Security Group ID----------
# EC2 Security Group ID
# Used by the RDS module to allow database access
# connections only from our EC2 instance
output "ec2_security_group_id" {

    description = "ID of the EC2 security group"
    value = aws_security_group.ec2_sg.id
  
}


