locals {
  create_aws = var.cloud_provider == "aws"
  create_gcp = var.cloud_provider == "gcp"
}

# Geenerate a private key for the
resource "tls_private_key" "runner_private_key" {
  algorithm = "ED25519"
}

locals {
  runner_k8s_namespace       = "humanitec-kubernetes-agent-runner"
  runner_k8s_service_account = "humanitec-kubernetes-agent-runner"
}

# Configure the kubernetes-agent runner
resource "platform-orchestrator_kubernetes_agent_runner" "runner" {
  id          = "${var.prefix}-k8s-agent-runner"
  description = "kubernetes-agent runner for the temporary use case ${var.prefix}"
  runner_configuration = {
    key = tls_private_key.runner_private_key.public_key_pem
    job = {
      namespace       = local.runner_k8s_namespace
      service_account = local.runner_k8s_service_account
    }
  }
  state_storage_configuration = {
    type = "kubernetes"
    kubernetes_configuration = {
      namespace = local.runner_k8s_namespace
    }
  }
}

# Role to allow the runner to manage secrets for state storage
resource "kubernetes_role" "humanitec_runner_kubernetes_stage_storage" {
  metadata {
    name      = "humanitec-runner-kubernetes-stage-storage"
    namespace = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  }
  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "get", "list", "watch", "update", "delete"]
  }
  rule {
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
    verbs      = ["create", "get", "update"]
  }
}

# Bind the role to the service account used by the runner
resource "kubernetes_role_binding" "humanitec_runner_kubernetes_stage_storage" {
  metadata {
    name      = "humanitec-runner-kubernetes-stage-storage"
    namespace = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.humanitec_runner_kubernetes_stage_storage.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = local.runner_k8s_service_account
    namespace = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  }
}

# The namespace for the kubernetes-agent runner
resource "kubernetes_namespace" "humanitec_kubernetes_agent_runner" {
  metadata {
    name = local.runner_k8s_namespace
  }
}

# A Secret for the agent runner private key
resource "kubernetes_secret" "agent_runner_key" {
  metadata {
    name      = "humanitec-kubernetes-agent-runner"
    namespace = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  }
  type = "Opaque"
  data = {
    "private_key" = tls_private_key.runner_private_key.private_key_pem
  }
}

# Install the Kubernetes agent runner Helm chart
resource "helm_release" "humanitec_kubernetes_agent_runner" {
  name             = "humanitec-kubernetes-agent-runner"
  namespace        = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  create_namespace = false

  repository = "oci://ghcr.io/humanitec/charts"
  chart      = "humanitec-kubernetes-agent-runner"

  set = [
    {
      name : "humanitec.orgId"
      value : var.orchestrator_org
    },
    {
      name : "humanitec.runnerId"
      value : platform-orchestrator_kubernetes_agent_runner.runner.id
    },
    {
      name : "humanitec.existingSecret"
      value : kubernetes_secret.agent_runner_key.metadata[0].name
    },
    {
      name : "serviceAccount.name"
      value : local.runner_k8s_service_account
    },
    # AWS only: annotate the service account for IRSA using the prepared role
    {
      name : var.cloud_provider == "aws" ? "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn" : ""
      value : var.cloud_provider == "aws" ? aws_iam_role.agent_runner_irsa_role[0].arn : ""
    },
    # GCP only: annotate the service account for Workload Identity
    {
      name : var.cloud_provider == "gcp" ? "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account" : ""
      value = var.cloud_provider == "gcp" ? google_service_account.runner_gke_service_account[0].email : ""
    }
  ]
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
    name      = local.runner_k8s_service_account
    namespace = kubernetes_namespace.humanitec_kubernetes_agent_runner.metadata[0].name
  }
}
