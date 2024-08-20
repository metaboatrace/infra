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

module "database" {
  source = "../../modules/database"

  env                          = local.env
  aurora_security_group_id     = module.networking.aurora_security_group_id
  private_subnet_ids           = module.networking.private_subnet_ids
  aurora_cluster_instance_size = 1
  availability_zones           = ["ap-northeast-1a", "ap-northeast-1c"]
}
