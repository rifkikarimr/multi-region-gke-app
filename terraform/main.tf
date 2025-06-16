// Enable required Google Cloud APIs
resource "google_project_service" "gke_api" {
  project = var.project_id
  service = "container.googleapis.com"
}

# resource "google_project_service" "gcr_api" {
#   project = var.project_id
#   service = "containerregistry.googleapis.com"
# }

resource "google_project_service" "artifactregistry_api" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  // Do not disable the API when destroying resources
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "app_repo" {
  location      = var.artifact_registry_repo_location
  repository_id = var.artifact_registry_repo_name
  format        = "DOCKER"
  description   = "Docker repository for the multi-region GKE app"

  // Ensure the API is enabled before trying to create the repository
  depends_on = [google_project_service.artifactregistry_api]
}

// Create a VPC network
resource "google_compute_network" "vpc" {
  name                    = "gke-network"
  auto_create_subnetworks = false
}

// Create a subnet in the US region
resource "google_compute_subnetwork" "subnet_us" {
  name          = "gke-subnet-us"
  ip_cidr_range = "10.10.10.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.regions[0]
}

// Create a subnet in the EU region
resource "google_compute_subnetwork" "subnet_eu" {
  name          = "gke-subnet-eu"
  ip_cidr_range = "10.20.10.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.regions[1]
}

// Create the GKE cluster in the US region
resource "google_container_cluster" "gke_cluster_us" {
  name       = "gke-cluster-us"
  location   = var.regions[0]
  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet_us.self_link

  initial_node_count = 1

  node_config {
    machine_type = "e2-standard-2"
  }
}

// Create the GKE cluster in the EU region
resource "google_container_cluster" "gke_cluster_eu" {
  name       = "gke-cluster-eu"
  location   = var.regions[1]
  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet_eu.self_link

  initial_node_count = 1

  node_config {
    machine_type = "e2-standard-2"
  }
}
