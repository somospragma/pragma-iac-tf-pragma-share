##############################################################
# Capa transversal (share) — recursos compartidos de ms-transfers
#
# Solo 4 módulos: SG (ALB + ECS), ALB base, ECS Cluster y CloudMap.
# La red (VPC/subnets) viene de pragma-iac-tf-pragma-networking (data source).
# El core (servicios, listeners, task definitions) va en pragma-iac-tf-pragma-transfer.
##############################################################

##############################################################
# Módulo SG — Security Groups: ALB y ECS
# v1.0.2 — vpc_id inyectado por locals desde el data source
##############################################################
module "sg" {
  source = "github.com/somospragma/cloudops-ref-repo-aws-sg-terraform?ref=v1.0.2"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  sg_config = local.sg_config
}

##############################################################
# Módulo NLB — Network Load Balancer interno (sin listeners)
# v1.0.0 — subnets privadas y SG inyectados por locals.
# El listener TCP y el target group hacia las tareas van en el core.
##############################################################
module "alb" {
  source = "github.com/somospragma/cloudops-ref-repo-aws-elb-terraform?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  lb_config = local.alb_config

  depends_on = [module.sg]
}

##############################################################
# Módulo ECS Cluster — Cluster compartido Fargate
# v1.0.1
##############################################################
module "ecs_cluster" {
  source = "github.com/somospragma/cloudops-ref-repo-aws-ecs-cluster-terraform?ref=v1.0.1"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  cluster_config = var.ecs_cluster_config
}

##############################################################
# Módulo CloudMap — Namespace HTTP para ECS Service Connect
# v1.0.0
##############################################################
module "cloudmap" {
  source = "github.com/somospragma/cloudops-ref-repo-aws-cloudmap-terraform?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  client      = var.client
  project     = var.project
  environment = var.environment

  namespaces = var.cloudmap_config
}
