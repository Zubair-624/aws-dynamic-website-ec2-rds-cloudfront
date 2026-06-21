#----------Randomly generated database password----------
output "db_password" {
    description = "Random generated password"
    value = random_password.random_db_password.result
    
    # sensitive = true tells Terraform: "hide this one value on screen, show (sensitive value) instead."
    sensitive = true
}