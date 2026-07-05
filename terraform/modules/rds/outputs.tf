#---RDS Endpoint---
output "output_rds_endpoint" {

    value = aws_db_instance.main_db.endpoint
  
}

#---RDS Database Name---
output "output_rds_db_name" {

    value = aws_db_instance.main_db.db_name

}

#---RDS Port---
output "output_rds_port" {

    value = aws_db_instance.main_db.port
  
}