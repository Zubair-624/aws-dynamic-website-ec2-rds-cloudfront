#----------Generate a random, secure password / Auto Generate DB Password----------
# random_password comes from a different provider, not AWS
resource "random_password" "random_db_password" {

    length = 15
    special = true
    override_special = "!#$%^&*"
  
}

#----------SSM Parameter Store----------

#-----DB Name-----
resource "aws_ssm_parameter" "rds_db_name" {

    name = "/web/${var.project_name}/db/name"

    description = "RDS(MySQL Database Name)"

    tier = "Standard"

    type = "String"

    value = var.db_name

    tags = {
        Name = "${var.project_name}/db/name"
    }
  
}

#---DB Username---
resource "aws_ssm_parameter" "rds_db_username" {

    name = "/web/${var.project_name}/db/username"

    description = "RDS(MySQL) Database Username"

    tier = "Standard"

    type = "String"

    value = var.db_username

    tags = {
        Name = "${var.project_name}/db/username"
    }
  
}

#---DB Password---
resource "aws_ssm_parameter" "rds_db_password" {

    name = "/web/${var.project_name}/db/password"

    description = "RDS(MySQL) Database Passowrd"

    tier = "Standard"

    type = "SecureString"

    key_id = "alias/aws/ssm"

    value = random_password.random_db_password.result

    tags = {
        Name = "${var.project_name}/db/password"
    }
  
}

