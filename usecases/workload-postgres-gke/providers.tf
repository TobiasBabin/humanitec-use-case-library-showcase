terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 7"
    }
    platform-orchestrator = {
      source  = "humanitec/platform-orchestrator"
      version = "~> 2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3"
    }
  }
}
