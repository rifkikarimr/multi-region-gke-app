variable "project_id" {
  default     = "karim-dev404"
  description = "GCP Project ID"
  type        = string
}

variable "regions" {
  description = "The GCP regions to deploy the GKE clusters in."
  type        = list(string)
  default     = ["us-central1", "europe-west1"]
}

variable "artifact_registry_repo_name" {
  description = "gke-tf-project"
  type        = string
}

variable "artifact_registry_repo_location" {
  description = "us-central1"
  type        = string
}
