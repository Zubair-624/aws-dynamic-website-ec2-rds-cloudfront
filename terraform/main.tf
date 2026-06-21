#----------VPC Module----------
module "vpc" {

  source = "./modules/vpc"

  project_name         = var.project_name
  aws_vpc_cidr_block   = var.aws_vpc_cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  azs                  = var.azs


}

#----------EC2 Module (Web Server)----------
module "ec2" {

  source = "./modules/ec2"

  project_name = var.project_name

  main_vpc_id = module.vpc.main_vpc_id

  public_subnet_id = module.vpc.public_subnet_ids[0]

}

#----------SSM Module (Secrets)----------
module "ssm" {

  source = "./modules/ssm"

  # Simple - SSM module only needs project_name, nothing else, since it doesn't depend on VPC or EC2 at all.
  project_name = var.project_name

}