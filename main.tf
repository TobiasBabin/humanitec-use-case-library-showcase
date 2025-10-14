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
}

# Module layer: database
module "postgres" {
  source                 = "./module/postgres-instance/aws" # TODO - outsource into public repo
  prefix                 = local.prefix
  project_id             = module.project.project_id
  provider_configuration = jsonencode({})
  runner_iam_role_name   = module.runner_kubernetes_agent.runner_aws_iam_role_name
}

# Module layer: workload
module "workload" {
  source     = "./module/workload/simple-k8s-deployment" # TODO - outsource into public repo
  prefix     = local.prefix
  project_id = module.project.project_id
}

# Project layer
module "project" {
  source    = "./project" # TODO - outsource into public repo
  prefix    = local.prefix
  #runner_id = module.runner_kubernetes_agent.runner_id
  runner_id = module.ecs_runner.runner_id
}

# Runner layer
module "runner_kubernetes_agent" {
  source            = "./runner/kubernetes-agent" # TODO - outsource into public repo
  prefix            = local.prefix
  cloud_provider    = "aws"
  orchestrator_org  = var.orchestrator_org
  eks_oidc_provider = module.base_infra.k8s_oidc_provider
}
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"

  region                     = "eu-north-1"
  subnet_ids                 = module.base_infra.subnet_ids
  humanitec_org_id           = "var.orchestrator_org"
  existing_oidc_provider_arn = "arn:aws:iam::477091544114:oidc-provider/oidc.humanitec.dev"
  runner_id_prefix           = local.prefix
}

# Base infra layer
module "base_infra" {
  source     = "./base-infra/aws/eks" # TODO - outsource into public repo
  prefix     = local.prefix
  aws_region = var.aws_region
}
