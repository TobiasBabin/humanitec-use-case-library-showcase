# Generate a random prefix for resource naming
# TODO This is redundant across use cases and can be outsourced to some central module
resource "random_string" "prefix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = false
  special = false
}
data "aws_availability_zones" "available" {}
locals {
  prefix = "htc-usecase-${random_string.prefix.result}"
}

# Resource layer: AWS RDS postgres database
module "postgres" {
  source                 = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/resources/postgres-instance/aws"
  prefix                 = local.prefix
  project_id             = module.project.project_id
  provider_configuration = jsonencode({})
  runner_iam_role_name   = split("/", module.ecs_runner.task_role_arn)[length(split("/", module.ecs_runner.task_role_arn)) - 1]
}

# Project layer
module "project" {
  source    = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/projects"
  prefix    = local.prefix
  runner_id = module.ecs_runner.runner_id
}

# Runner layer
module "ecs_runner" {
  source                     = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  region                     = var.aws_region
  subnet_ids                 = module.vpc.private_subnets
  security_group_ids         = [module.vpc.default_security_group_id]
  humanitec_org_id           = var.orchestrator_org
  runner_id_prefix           = local.prefix
  existing_oidc_provider_arn = var.existing_oidc_provider_arn != null ? var.existing_oidc_provider_arn : null
}

# Base infra layer
# Create a VPC with private subnets for the runner and
# a public routing subnet with internet access for pulling the runner image
module "vpc" {
  source                 = "terraform-aws-modules/vpc/aws"
  name                   = "${local.prefix}-vpc"
  cidr                   = "10.0.0.0/16"
  region                 = var.aws_region
  azs                    = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnets         = ["10.0.0.0/24"]
  private_subnets        = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_dns_hostnames   = true
  enable_dns_support     = true
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  default_security_group_egress = [
    {
      cidr_blocks = "0.0.0.0/0"
      from_port   = 443
      protocol    = "tcp"
      to_port     = 443
    },
  ]
}

