terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6"
    }
    platform-orchestrator = {
      source  = "humanitec/platform-orchestrator"
      version = "~> 2"
    }
  }
}

# aws provider obtains authentication from local CLI
provider "aws" {
  region = var.aws_region
}

# Configure the Platform Orchestrator provider from a service user token
provider "platform-orchestrator" {
  org_id     = var.orchestrator_org
  auth_token = var.orchestrator_auth_token
  api_url    = "https://api.humanitec.dev"
}

# Configure the Kubernetes provider for accessing the base infra cluster
provider "kubernetes" {
  host                   = module.base_infra.k8s_cluster_endpoint
  cluster_ca_certificate = base64decode(module.base_infra.k8s_cluster_ca_certificate)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--output", "json", "--cluster-name", module.base_infra.k8s_cluster_name, "--region", var.aws_region]
    command     = "aws"
  }
}

# Configure the Helm provider for accessing the base infra cluster
provider "helm" {
  kubernetes = {
    host                   = module.base_infra.k8s_cluster_endpoint
    cluster_ca_certificate = base64decode(module.base_infra.k8s_cluster_ca_certificate)
    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--output", "json", "--cluster-name", module.base_infra.k8s_cluster_name, "--region", var.aws_region]
      command     = "aws"
    }
  }
}
