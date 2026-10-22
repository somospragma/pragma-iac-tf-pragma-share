##############################################################
# Variables Globales
##############################################################
client      = "pragma"
project     = "transfers"
environment = "dev"
aws_region  = "us-east-1"
vpc_name    = "pragma-transfers-dev-vpc"

common_tags = {
  client      = "pragma"
  project     = "transfers"
  environment = "dev"
  owner       = "cloudops"
  territory   = "peru"
  country     = "pe"
  cost-center = "9952"
  service     = "ms-transfers"
  component   = "transversal"
}

##############################################################
# SG — vpc_id vacío = los locals inyectan el vpc_id del data source
#   nlb → entrada: tráfico TCP desde la VPC (ENIs del API Gateway VPC Link)
#
# Nota: el SG de las tareas ECS NO va aquí. Se crea en la capa de
# funcionalidad (core), junto con los servicios ms-transfers y mocks.
##############################################################
sg_config = {
  "nlb" = {
    description     = "SG for ms-transfers internal NLB - TCP from VPC (API Gateway VPC Link)"
    vpc_id          = ""
    additional_tags = { "application-tier" = "frontend" }
    ingress = [
      {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["10.30.0.0/22"]
        security_groups = []
        description     = "Allow TCP 80 from VPC (VPC Link ENIs)"
      },
      {
        from_port       = 8080
        to_port         = 8080
        protocol        = "tcp"
        cidr_blocks     = ["10.30.0.0/22"]
        security_groups = []
        description     = "Allow TCP 8080 from VPC (listener hacia las task)"
      }
    ]
    egress = [
      {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
        security_groups = []
        description     = "Allow all outbound"
      }
    ]
  }
}

##############################################################
# NLB — Network Load Balancer interno (sin listeners)
# El listener TCP y el target group hacia las tareas van en el core (elb-listener).
# key corta ("trf"): pragma-transfers-dev-nlb-trf = 28 chars.
##############################################################
alb_config = {
  "trf" = {
    internal                   = true
    load_balancer_type         = "network"
    drop_invalid_header_fields = false
    idle_timeout               = 60
    enable_deletion_protection = false
    waf_arn                    = ""
    subnets                    = []
    security_groups            = []
    application_id             = "ms-transfers"
    additional_tags            = { "component" = "transversal" }
  }
}

##############################################################
# ECS Cluster — Cluster compartido Fargate para micro y mocks
##############################################################
ecs_cluster_config = {
  "ms-transfers" = {
    containerInsights       = "enabled"
    enableCapacityProviders = true
    additional_tags         = { "component" = "transversal" }
  }
}

##############################################################
# CloudMap — Namespace HTTP para ECS Service Connect
##############################################################
cloudmap_config = {
  "service-connect" = {
    description     = "Namespace CloudMap para ECS Service Connect — ms-transfers y mocks"
    type            = "HTTP"
    vpc_id          = ""
    additional_tags = { "component" = "transversal" }
  }
}
