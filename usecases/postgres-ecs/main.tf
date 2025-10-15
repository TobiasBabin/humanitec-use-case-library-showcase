# Generate a random prefix for resource naming
# TODO This is redundant across use cases and can be outsourced to some central module
resource "random_string" "prefix" {
  length  = 4
  lower   = true
  upper   = false
  numeric = false
  special = false
}
locals {
  prefix = "htc-usecase-${random_string.prefix.result}"
  oidc_provider_arn = "arn:aws:iam::477091544114:oidc-provider/oidc.humanitec.dev"
}

# Module layer: database
module "postgres" {
  source                 = "./module/postgres-instance/aws" # TODO - outsource into public repo
  prefix                 = local.prefix
  project_id             = module.project.project_id
  provider_configuration = jsonencode({})
  runner_iam_role_name   = module.ecs_runner.task_role_arn
}

# Project layer
module "project" {
  source    = "./project" # TODO - outsource into public repo
  prefix    = local.prefix
  runner_id = module.ecs_runner.runner_id
}

# Runner layer
module "ecs_runner" {
  source                     = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  region                     = var.aws_region
  subnet_ids                 = module.base_infra.subnet_ids
  humanitec_org_id           = var.orchestrator_org
  runner_id_prefix           = local.prefix
  existing_oidc_provider_arn = local.oidc_provider_arn
}

# Base infra layer
module "base_infra" {
  source     = "./base-infra/aws/ecs" # TODO - outsource into public repo
  prefix     = local.prefix
  aws_region = var.aws_region
}
