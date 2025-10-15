# GCP only: Workload identity on GKE
# Google IAM service account for the runner
resource "google_service_account" "runner_gke_service_account" {
  count = local.create_gcp ? 1 : 0

  account_id   = "${var.prefix}-gke-runner"
  display_name = "GKE workload identity for the Humanitec Orchestrator K8s agent runner"
}
