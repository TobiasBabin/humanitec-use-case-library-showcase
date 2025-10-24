# TODO - this should be in the sample code (?)
provider "platform-orchestrator" {
  org_id     = var.orchestrator_org
  auth_token = var.orchestrator_auth_token
  api_url    = "https://api.humanitec.dev"
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "gke-gcloud-auth-plugin"
  }
}
# Configure Helm provider
provider "helm" {
  kubernetes = {
    host                   = "https://${module.gke.endpoint}"
    cluster_ca_certificate = base64decode(module.gke.ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
  }
}

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

# Get current GCP client config
data "google_client_config" "default" {}

# Resource layer: postgres database
module "postgres" {
  source     = "github.com/TobiasBabin/humanitec-use-case-library-showcase//public-modules/resources/postgres-instance/gcp"
  prefix     = local.prefix
  project_id = module.project.project_id
  provider_configuration = jsonencode({
    project = var.gcp_project_id
    region  = var.gcp_region
  })
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

# Deploy the Humanitec runner
module "runner_kubernetes_agent" {
  source           = "github.com/humanitec/platform-orchestrator-tf-modules//orchestrator-configuration/runner/kubernetes-agent?ref=hum-937-kubernetes-agent-runner"
  humanitec_org_id = var.orchestrator_org
  private_key_path = "./runner_private_key.pem"
  public_key_path  = "./runner_public_key.pem"
  # GKE Workload Identity configuration - link to the GCP service account created above
  service_account_annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.runner_sa.email
  }
  depends_on = [
    module.gke
  ]
}
