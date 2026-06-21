#----------Generate a random, secure password----------
# random_password comes from a different provider, not AWS
resource "random_password" "random_db_password" {

    length = 15
    special = true
  
}

#----------Store the generated password into SSM----------
resource "aws_ssm_parameter" "db_password" {

    name = "/app/${var.project_name}/db_password"

    # Store that password inside SSM Parameter Store, as a SecureString (encrypted)
    type = "SecureString"

    value = random_password.random_db_password.result
  
}