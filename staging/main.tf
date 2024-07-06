locals {
  env = "staging"
}

module "networking" {
  source = "../modules/networking"

  env            = local.env
  vpc_cidr_block = "10.0.0.0/16"

  availability_zones = {
    ap-northeast-1a = {
      order = 0
      id    = "az1"
    }
  }
}
