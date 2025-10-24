# Create VPC for GKE
module "gcp_network" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 12.0"
  project_id   = var.gcp_project_id
  network_name = "humanitec-runner-network"
  subnets = [
    {
      subnet_name   = "humanitec-runner-subnet"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.gcp_region
    }
  ]
  secondary_ranges = {
    humanitec-runner-subnet = [
      {
        range_name    = "gke-pods"
        ip_cidr_range = "10.1.0.0/16"
      },
      {
        range_name    = "gke-services"
        ip_cidr_range = "10.2.0.0/16"
      },
    ]
  }
}
# Create GKE cluster with Workload Identity enabled
module "gke" {
  source            = "terraform-google-modules/kubernetes-engine/google"
  version           = "~> 41.0"
  project_id        = var.gcp_project_id
  name              = "humanitec-runner-cluster"
  region            = var.gcp_region
  network           = module.gcp_network.network_name
  subnetwork        = module.gcp_network.subnets_names[0]
  ip_range_pods     = "gke-pods"
  ip_range_services = "gke-services"
  # Enable Workload Identity
  identity_namespace = "${var.gcp_project_id}.svc.id.goog"
  node_pools = [
    {
      name         = "humanitec-runner-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 3
      disk_size_gb = 100
      auto_upgrade = true
    }
  ]
}
# Create GCP Service Account for the runner
resource "google_service_account" "runner_sa" {
  account_id   = "humanitec-runner"
  display_name = "Humanitec Kubernetes Agent Runner"
  project      = var.gcp_project_id
}
# Grant necessary permissions to the service account
resource "google_project_iam_member" "runner_permissions" {
  for_each = toset([
    # Add the roles your runner needs, for example:
    # "roles/storage.objectViewer",
    # "roles/container.developer",
    "roles/cloudsql.admin"
  ])
  project = var.gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.runner_sa.email}"
}
# Bind Kubernetes service account to GCP service account
resource "google_service_account_iam_member" "workload_identity_binding" {
  service_account_id = google_service_account.runner_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member = "serviceAccount:${var.gcp_project_id}.svc.id.goog[${module.runner_kubernetes_agent.k8s_job_namespace}/${module.runner_kubernetes_agent.k8s_job_service_account_name}]"
}
