resource "aws_db_subnet_group" "rds_db_subnet_group" {

    tags = {
        Name = "${var.project_name}-subnet"
    }

    description = "Subnet group for RDS"

    # Pass in your EXISTING private subnet IDs from the VPC module or, private subnets from your VPC module output
    # These are the subnets RDS is allowed to use
    # RDS lives in private subnets ONLY, never public
    subnet_ids = var.fetch_output_aws_vpc_private_subnet_id
  
}

resource "aws_db_instance" "main_db" {

    db_subnet_group_name = aws_db_subnet_group.rds_db_subnet_group.name

    #---Engine Option: Box---
    # (select -> mysql)
    engine = "mysql"

    #---Availability and durability: Box---
    # (3 option, select the "single az db instance")
    multi_az = false

    #---Settings: Box---
    # Settings sub option -> "Engine Version", select -> 8.0.42"
    engine_version = "8.0.42"

    # Settings sub option -> "DB instance identifier"
    identifier = "${var.project_name}-rds"

    # Settings sub option -> "Master username"
    # fetech form -> ssm_parameter_store
    username = var.fetch_root_db_name

    # Settings sub section -> "Credentials Management"
    # Credentials Management → "Self managed"
    # We manage the password ourselves via SSM Parameter Store
    # so we do NOT want AWS to auto-manage it via Secrets 
    manage_master_user_password = false # do NOt let AWS manage it
    password = var.fetch_root_db_random_password # comes from SSM module

    # Addition credentials settings
    # Database authentication options -> select -> "Password Authentication"
    iam_database_authentication_enabled = false

    #---Instance Configuration: Box---
    # Instance type -> db.t3.micro
    instance_class = "db.t3.micro"

    #---Storage: Box---
    
    # Storage type
    storage_type = "gp3"

    # Allocated storage
    allocated_storage = 20
    
    # Maximum storage
    # Setting this value automatically ENABLES autoscaling
    # Terraform enables autoscaling simply by setting this field
    max_allocated_storage = 100

    #---Connectivity: Box---

    #--- (look above)
    # Virtual private cloud (vpc) select -> project vpc
    # DB Subnet group
    # DB Subnet Group (alredy create the resource in the above)
    #--- (look above)

    # Public access
    # select -> NO
    # RDS must never be publicly accessible
    publicly_accessible = false

    # VPC Security Group
    # Select -> RDS Security Group
    vpc_security_group_ids = [var.fetech_main_output_rds_security_group]

    # Certificate authority
    ca_cert_identifier = "rds-ca-rsa2048-g1"

    # Database port
    port = 3306

    #---Monitoring: Box---

    # Performance Insights -> Checkmark -> Enable performace insights
    performance_insights_enabled = true
    
    # Retention period -> 7 days
    performance_insights_retention_period = 7

    # AWS kms key
    performance_insights_kms_key_id = "alias/aws/rds"

    #---Additional monitoring settings---

    # OS metrics granularity 
    # select -> 60 seconds
    monitoring_interval = 60

    monitoring_role_arn = var.fetech_output_rds_monitoring_role_arn

    # Log exports
    # checkmar -> Eroor log, Enegeral log, Slow query log
    enabled_cloudwatch_logs_exports = ["error", "general", "slowquery"]

    # Initial database name
    db_name = var.fetch_root_db_username

    # Enable encryption (checkmark this)
    storage_encrypted = true 

    # AWS KMS key
    kms_key_id = "alias/aws/rds"

    #-----Backup-----

    # Backup retention period
    backup_retention_period = 7

    # Backup window 
    # Select -> No preference
    backup_window = "03:00-04:00"

    # Backup tags
    # select -> Copy tags to shnapshots
    copy_tags_to_snapshot = true 

    #-----Backup-----

    #-----Maintenance-----

    #select -> Enable auto version upgrade
    auto_minor_version_upgrade = true 

    # Maintenance window
    maintenance_window = "Mon:04:00-Mon:05:00"

    # select -> unable (false) deletion protection
    # true = terraform destroy will Fail - AWS blocks deletion of protected databse. You would need to manually disable protection first before destroying, for a learning project where I need to run "terraform destroy" regularly to save cost, this is a problem.
    deletion_protection = false

    #-----Maintenance-----

    # "skip_final_snapshot" and "final_snapshot_identifier" are not in the console, They are Terraform-only settings
    skip_final_snapshot = true 


    


    




    
    

    
  
}