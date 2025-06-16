output "gke_cluster_us_name" {
  value = google_container_cluster.gke_cluster_us.name
}

output "gke_cluster_us_endpoint" {
  value = google_container_cluster.gke_cluster_us.endpoint
}

output "gke_cluster_eu_name" {
  value = google_container_cluster.gke_cluster_eu.name
}

output "gke_cluster_eu_endpoint" {
  value = google_container_cluster.gke_cluster_eu.endpoint
}

output "artifact_registry_repository_name" {
  description = "GKE Terraform Project."
  value       = google_artifact_registry_repository.app_repo.name
}
