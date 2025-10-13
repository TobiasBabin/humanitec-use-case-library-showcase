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
  runner_iam_role_name   = module.runner.runner_aws_iam_role_name
  providers = {
    platform-orchestrator = platform-orchestrator
  }
}

# Module layer: workload
module "workload" {
  source     = "./module/workload/simple-k8s-deployment" # TODO - outsource into public repo
  prefix     = local.prefix
  project_id = module.project.project_id
  providers = {
    platform-orchestrator = platform-orchestrator
  }
}

# Project layer
module "project" {
  source    = "./project" # TODO - outsource into public repo
  prefix    = local.prefix
  runner_id = module.runner.runner_id
  providers = {
    platform-orchestrator = platform-orchestrator
  }
}

# Runner layer
module "runner" {
  source            = "./runner/kubernetes-agent" # TODO - outsource into public repo
  prefix            = local.prefix
  cloud_provider    = "aws"
  orchestrator_org  = var.orchestrator_org
  eks_oidc_provider = module.base_infra.k8s_oidc_provider
  providers = {
    platform-orchestrator = platform-orchestrator
    kubernetes            = kubernetes
    helm                  = helm
  }
}

# Base infra layer
module "base_infra" {
  source     = "./base-infra/aws/eks" # TODO - outsource into public repo
  prefix     = local.prefix
  aws_region = var.aws_region
  providers = {
    aws = aws
  }
}
