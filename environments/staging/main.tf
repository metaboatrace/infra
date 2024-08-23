locals {
  env = "staging"
}

module "networking" {
  source = "../../modules/networking"

  env = local.env
  availability_zones = {
    ap-northeast-1a = {
      order = 1
      id    = "az1"
    }
    ap-northeast-1c = {
      order = 2
      id    = "az2"
    }
  }
}

module "iam" {
  source = "../../modules/iam"

  env = local.env
}

module "lb" {
  source = "../../modules/lb"

  env                   = local.env
  vpc_id                = module.networking.vpc_id
  public_subnet_ids     = module.networking.public_subnet_ids
  alb_security_group_id = module.networking.alb_security_group_id
}

module "database" {
  source = "../../modules/database"

  env                          = local.env
  aurora_security_group_id     = module.networking.aurora_security_group_id
  private_subnet_ids           = module.networking.private_subnet_ids
  aurora_cluster_instance_size = 1
  availability_zones           = ["ap-northeast-1a", "ap-northeast-1c"]
  serverless_v2_min_capacity   = 1
  serverless_v2_max_capacity   = 2
}

module "container_management" {
  source = "../../modules/container_management"

  env                         = local.env
  crawler_security_group_id   = module.networking.crawler_security_group_id
  subnet_ids                  = module.networking.private_subnet_ids
  crawler_target_group_arn    = module.lb.crawler_target_group_arn
  ecs_task_role_arn           = module.iam.ecs_task_role_arn
  ecs_task_execution_role_arn = module.iam.ecs_task_execution_role_arn
}
