locals {
  env = "staging"
}

module "networking" {
  source = "../../modules/networking"

  env            = local.env
  vpc_cidr_block = "10.0.0.0/16"

  availability_zones = {
    ap-northeast-1a = {
      order = 0
      id    = "az1"
    }
  }
}

module "database" {
  source = "../../modules/database"

  env                = local.env
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
}
