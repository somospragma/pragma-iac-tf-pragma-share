##############################################################
# Variables Globales
##############################################################
variable "client" {
  description = "Nombre del cliente"
  type        = string
  validation {
    condition     = length(var.client) >= 3 && length(var.client) <= 10
    error_message = "El nombre del cliente debe tener entre 3 y 10 caracteres."
  }
}

variable "project" {
  description = "Nombre del proyecto"
  type        = string
  validation {
    condition     = length(var.project) >= 3 && length(var.project) <= 15
    error_message = "El nombre del proyecto debe tener entre 3 y 15 caracteres."
  }
}

variable "environment" {
  description = "Entorno de despliegue"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, prod."
  }
}

variable "aws_region" {
  description = "Región de AWS"
  type        = string
  default     = "us-east-1"
}

variable "common_tags" {
  description = "Tags comunes aplicados a todos los recursos"
  type        = map(string)
  default     = {}
}

variable "deploy_role_arn" {
  description = "ARN del rol IAM usado por el pipeline para desplegar"
  type        = string
}

variable "vpc_name" {
  description = "Tag Name de la VPC — usado por el data source"
  type        = string
  default     = "proyecto-vpc"
}

##############################################################
# Variables SG
# vpc_id vacío = los locals inyectan el vpc_id del data source
##############################################################
variable "sg_config" {
  description = "Configuración de Security Groups. vpc_id vacío = los locals inyectan el vpc_id del data source."
  type = map(object({
    description     = string
    vpc_id          = optional(string, "")
    additional_tags = optional(map(string), {})
    ingress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      security_groups = list(string)
      prefix_list_ids = optional(list(string), [])
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
    egress = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      prefix_list_ids = optional(list(string), [])
      security_groups = list(string)
      self            = optional(bool, false)
      description     = optional(string, "")
    }))
  }))
  default = {}
}

##############################################################
# Variables ALB
# subnets y security_groups vacíos
# = los locals los inyectan desde data sources y módulo sg
##############################################################
variable "alb_config" {
  description = "Configuración del ALB base. subnets/security_groups vacíos = locals inyectan desde módulos."
  type = map(object({
    internal                   = optional(bool, false)
    load_balancer_type         = optional(string, "application")
    drop_invalid_header_fields = optional(bool, true)
    idle_timeout               = optional(number, 60)
    enable_deletion_protection = optional(bool, false)
    waf_arn                    = optional(string, "")
    subnets                    = optional(list(string), [])
    security_groups            = optional(list(string), [])
    application_id             = string
    additional_tags            = optional(map(string), {})
  }))
  default = {}
}

##############################################################
# Variables ECS Cluster
##############################################################
variable "ecs_cluster_config" {
  description = "Configuración del cluster ECS. clave = nombre lógico del cluster."
  type = map(object({
    containerInsights       = optional(string, "enabled")
    enableCapacityProviders = optional(bool, true)
    additional_tags         = optional(map(string), {})
  }))
  default = {}
}

##############################################################
# Variables CloudMap
# Tipo HTTP para ECS Service Connect
##############################################################
variable "cloudmap_config" {
  description = "Configuración de namespaces CloudMap. Tipo HTTP para ECS Service Connect."
  type = map(object({
    description     = optional(string, "")
    type            = optional(string, "HTTP")
    vpc_id          = optional(string, "")
    additional_tags = optional(map(string), {})
  }))
  default = {}
}
