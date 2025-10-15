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

# Workload layer: database
module "postgres" {
  source                 = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/resources/postgres-instance/aws"
  prefix                 = local.prefix
  project_id             = module.project.project_id
  provider_configuration = jsonencode({})
  runner_iam_role_name   = module.runner_kubernetes_agent.runner_aws_iam_role_name
}

# Workload layer: workload
module "workload" {
  source     = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/resources/workload/simple-k8s-deployment"
  prefix     = local.prefix
  project_id = module.project.project_id
}

# Project layer
module "project" {
  source    = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/projects"
  prefix    = local.prefix
  runner_id = module.runner_kubernetes_agent.runner_id
}

# Runner layer
module "runner_kubernetes_agent" {
  source            = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/runners/kubernetes-agent"
  prefix            = local.prefix
  cloud_provider    = "aws"
  orchestrator_org  = var.orchestrator_org
  eks_oidc_provider = module.base_infra.k8s_oidc_provider
}

# Base infra layer
module "base_infra" {
  source     = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/base-infra/aws/eks"
  prefix     = local.prefix
  aws_region = var.aws_region
}
