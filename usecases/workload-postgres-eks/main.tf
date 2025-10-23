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

# Resource layer: postgres database
module "postgres" {
  source                 = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/resources/postgres-instance/aws"
  prefix                 = local.prefix
  project_id             = module.project.project_id
  provider_configuration = jsonencode({})
  runner_iam_role_name   = module.runner_irsa_role.iam_role_name
}

# Resource layer: k8s-workload
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

# Assign a pre-existing ClusterRole to the service account used by the runner
# to enable the runner to create deployments in other namespaces
resource "kubernetes_cluster_role_binding" "runner_inner_cluster_admin" {
  metadata {
    name = "humanitec-kubernetes-agent-runner-cluster-edit"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = module.runner_kubernetes_agent.k8s_job_service_account_name
    namespace = module.runner_kubernetes_agent.k8s_job_namespace
  }
}

# Runner layer
module "runner_kubernetes_agent" {
  source           = "github.com/humanitec/platform-orchestrator-tf-modules//orchestrator-configuration/runner/kubernetes-agent?ref=hum-937-kubernetes-agent-runner"
  humanitec_org_id = var.orchestrator_org
  runner_id_prefix = local.prefix
  private_key_path = "./runner_private_key.pem"
  public_key_path  = "./runner_public_key.pem"
  service_account_annotations = {
    "eks.amazonaws.com/role-arn" = module.runner_irsa_role.iam_role_arn
  }
}
# module "runner_kubernetes_agent" {
#   source            = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/runners/kubernetes-agent"
#   prefix            = local.prefix
#   cloud_provider    = "aws"
#   orchestrator_org  = var.orchestrator_org
#   eks_oidc_provider = module.base_infra.k8s_oidc_provider
# }

# Create IAM role for the runner with IRSA
module "runner_irsa_role" {
  source    = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version   = "~> 5.0"
  role_name = "humanitec-runner-role"
  oidc_providers = {
    main = {
      provider_arn               = module.base_infra.k8s_oidc_provider_arn
      namespace_service_accounts = ["humanitec-kubernetes-agent-runner-job-ns:humanitec-kubernetes-agent-runner-job"]
    }
  }
  # Add policies needed by the runner (example: access to AWS resources)
  role_policy_arns = {
    # Add any additional policies your runner needs
    rds_admin       = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
    ecs_full_access = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  }
}

# Base infra layer
# TODO use official AWS modules instead to set up base infra
module "base_infra" {
  source     = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/base-infra/aws/eks"
  prefix     = local.prefix
  aws_region = var.aws_region
}
