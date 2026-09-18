data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "./modules/vpc"
  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones1 = var.availability_zones1
  availability_zones2 = var.availability_zones2
  public_subnet_cidrs      = var.public_subnet_cidrs
}

module "ecr" {
  source = "./modules/ecr"
  project_name = var.project_name
  environment  = var.environment
}

module "alb" {
  source = "./modules/alb"
  project_name = var.project_name
  environment  = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  application_port = 8000
}

module "ecs" {
  source = "./modules/ecs"
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  vpc_id           = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  alb_security_group_id = module.alb.alb_security_group_id
  target_group_arn      = module.alb.target_group_arn
  container_image = "${module.ecr.repository_url}:${var.image_tag}"
  container_name     = "threat-composer"
  application_port   = 8000
  task_cpu           = 256
  task_memory        = 512
  desired_task_count = 1
  depends_on = [
    module.alb
  ]
}
