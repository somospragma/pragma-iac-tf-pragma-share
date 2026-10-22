##############################################################
# Data Sources
# La VPC y subnets las crea la capa de networking (pragma-iac-tf-pragma-networking).
# Aquí solo se leen por tag:Name.
##############################################################
data "aws_caller_identity" "current" {
  provider = aws.principal
}

data "aws_vpc" "vpc" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# Subnets privadas — usadas por el ALB interno (integración privada vía API Gateway VPC Link)
data "aws_subnets" "private" {
  provider = aws.principal
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*private*"]
  }
}
