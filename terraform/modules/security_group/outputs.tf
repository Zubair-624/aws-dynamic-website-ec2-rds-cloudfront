#---EC2 Output ID---
output "output_ec2_id" {

    value = aws_security_group.ec2_sg.id 
  
}

#---RDS Output ID---
output "output_rds_id" {

    value = aws_security_group.rds_sg.id
  
}