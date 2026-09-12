output "artifact_registry_image_prefix" {
  description = "Artifact Registry path prefix used by the deployment workflow."
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}/multi-region-gke-app"
}

output "gke_clusters" {
  description = "Regional GKE cluster names and locations."
  value = {
    for key, cluster in google_container_cluster.regional : key => {
      name     = cluster.name
      location = cluster.location
    }
  }
}

output "github_workload_identity_provider" {
  description = "Set this value as the GitHub Actions variable WIF_PROVIDER."
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "github_deployer_service_account" {
  description = "Set this value as the GitHub Actions variable WIF_SERVICE_ACCOUNT."
  value       = google_service_account.github_deployer.email
}
