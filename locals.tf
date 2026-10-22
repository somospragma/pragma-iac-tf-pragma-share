locals {
  # SG: inyecta el vpc_id dinámico del data source en cada Security Group
  sg_config = {
    for key, config in var.sg_config : key => merge(config, {
      vpc_id = config.vpc_id != "" ? config.vpc_id : data.aws_vpc.vpc.id
    })
  }

  # NLB: inyecta subnets privadas y el SG desde data source / módulo sg
  # (NLB interno para integración privada vía API Gateway VPC Link)
  alb_config = {
    for key, config in var.alb_config : key => merge(config, {
      subnets         = length(config.subnets) > 0 ? config.subnets : data.aws_subnets.private.ids
      security_groups = length(config.security_groups) > 0 ? config.security_groups : [module.sg.sg_ids["nlb"]]
    })
  }
}
