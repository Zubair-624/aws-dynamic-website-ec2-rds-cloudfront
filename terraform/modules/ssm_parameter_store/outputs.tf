#---DB Name Output---
output "output_db_name_arn" {

    value = aws_ssm_parameter.rds_db_name.arn
  
}

#---DB Username Output---
output "output_db_username_arn" {

    value = aws_ssm_parameter.rds_db_username.arn
  
}

#---DB Password---
output "output_db_password_arn" {

    value = aws_ssm_parameter.rds_db_password
  
}

#---Random Auto Generated Password (Actual Value)---
output "output_random_db_password" {

    value = random_password.random_db_password.result
    sensitive = true
  
}