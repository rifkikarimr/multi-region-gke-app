locals {
  required_services = toset([
    "artifactregistry.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
  ])

  regions = {
    for key, region in var.regions : key => {
      region        = region
      node_zone     = var.node_zones[key]
      subnet_cidr   = var.subnet_cidrs[key]
      pods_cidr     = var.pods_cidrs[key]
      services_cidr = var.services_cidrs[key]
    }
  }
}

check "node_scaling_range" {
  assert {
    condition     = var.node_max_count >= var.node_min_count
    error_message = "node_max_count must be greater than or equal to node_min_count."
  }
}

resource "google_project_service" "required" {
  for_each = local.required_services

  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_compute_network" "gke" {
  name                    = "${var.name_prefix}-network"
  auto_create_subnetworks = false

  depends_on = [google_project_service.required["compute.googleapis.com"]]
}

resource "google_compute_subnetwork" "gke" {
  for_each = local.regions

  name                     = "${var.name_prefix}-${each.key}"
  ip_cidr_range            = each.value.subnet_cidr
  region                   = each.value.region
  network                  = google_compute_network.gke.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.name_prefix}-${each.key}-pods"
    ip_cidr_range = each.value.pods_cidr
  }

  secondary_ip_range {
    range_name    = "${var.name_prefix}-${each.key}-services"
    ip_cidr_range = each.value.services_cidr
  }
}

resource "google_artifact_registry_repository" "app" {
  project       = var.project_id
  location      = var.artifact_registry_location
  repository_id = var.artifact_registry_repository
  format        = "DOCKER"
  description   = "Container images for the multi-region GKE reference application"
  labels        = var.labels

  depends_on = [google_project_service.required["artifactregistry.googleapis.com"]]
}

resource "google_service_account" "gke_nodes" {
  project      = var.project_id
  account_id   = var.gke_node_service_account_id
  display_name = "GKE node runtime"
  description  = "Least-privilege runtime identity shared by the portfolio GKE node pools"
}

resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/artifactregistry.reader",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_nodes.email}"
}

resource "google_container_cluster" "regional" {
  for_each = local.regions

  name     = "${var.name_prefix}-${each.key}"
  location = each.value.region
  project  = var.project_id

  network    = google_compute_network.gke.id
  subnetwork = google_compute_subnetwork.gke[each.key].id

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = var.deletion_protection

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.name_prefix}-${each.key}-pods"
    services_secondary_range_name = "${var.name_prefix}-${each.key}-services"
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = "REGULAR"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]

    managed_prometheus {
      enabled = true
    }
  }

  resource_labels = merge(var.labels, { region-key = each.key })

  depends_on = [google_project_service.required["container.googleapis.com"]]
}

resource "google_container_node_pool" "primary" {
  for_each = local.regions

  name               = "${var.name_prefix}-${each.key}-primary"
  project            = var.project_id
  location           = google_container_cluster.regional[each.key].location
  cluster            = google_container_cluster.regional[each.key].name
  node_locations     = [each.value.node_zone]
  initial_node_count = var.node_min_count

  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.node_disk_size_gb
    disk_type    = "pd-balanced"
    image_type   = "COS_CONTAINERD"

    service_account = google_service_account.gke_nodes.email
    oauth_scopes    = ["https://www.googleapis.com/auth/cloud-platform"]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    labels = merge(var.labels, { region-key = each.key })
    tags   = ["${var.name_prefix}-${each.key}-node"]
  }

  depends_on = [google_project_iam_member.gke_node_roles]
}
