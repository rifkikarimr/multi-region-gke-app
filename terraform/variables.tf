variable "project_id" {
  description = "Google Cloud project ID in which resources are created."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "project_id must be a valid Google Cloud project ID."
  }
}

variable "name_prefix" {
  description = "Prefix applied to resource names."
  type        = string
  default     = "multi-region-gke"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name_prefix))
    error_message = "name_prefix must use lowercase letters, numbers, and hyphens."
  }
}

variable "regions" {
  description = "Regional GKE locations keyed by deployment name. Exactly us and eu are expected by the delivery workflow."
  type        = map(string)
  default = {
    us = "us-central1"
    eu = "europe-west1"
  }

  validation {
    condition     = length(var.regions) == 2 && alltrue([for key in ["us", "eu"] : contains(keys(var.regions), key)]) && try(var.regions["us"], "") != try(var.regions["eu"], "")
    error_message = "regions must contain distinct us and eu locations."
  }
}

variable "node_zones" {
  description = "Single node zone per regional cluster. This reduces demo cost but does not provide zonal node redundancy."
  type        = map(string)
  default = {
    us = "us-central1-a"
    eu = "europe-west1-b"
  }

  validation {
    condition     = length(var.node_zones) == 2 && alltrue([for key in ["us", "eu"] : contains(keys(var.node_zones), key)])
    error_message = "node_zones must contain us and eu entries."
  }
}

variable "subnet_cidrs" {
  description = "Primary subnet ranges for cluster nodes."
  type        = map(string)
  default = {
    us = "10.10.0.0/20"
    eu = "10.20.0.0/20"
  }
}

variable "pods_cidrs" {
  description = "Secondary subnet ranges for GKE Pods."
  type        = map(string)
  default = {
    us = "10.100.0.0/16"
    eu = "10.200.0.0/16"
  }
}

variable "services_cidrs" {
  description = "Secondary subnet ranges for GKE Services."
  type        = map(string)
  default = {
    us = "10.30.0.0/20"
    eu = "10.40.0.0/20"
  }
}

variable "artifact_registry_location" {
  description = "Artifact Registry region. Both clusters pull from this single repository."
  type        = string
  default     = "us-central1"
}

variable "artifact_registry_repository" {
  description = "Artifact Registry Docker repository ID."
  type        = string
  default     = "gke-apps"
}

variable "machine_type" {
  description = "Machine type for GKE nodes."
  type        = string
  default     = "e2-standard-2"
}

variable "node_disk_size_gb" {
  description = "Boot disk size for each GKE node."
  type        = number
  default     = 30

  validation {
    condition     = var.node_disk_size_gb >= 20
    error_message = "node_disk_size_gb must be at least 20 GB."
  }
}

variable "node_min_count" {
  description = "Minimum nodes per configured node zone."
  type        = number
  default     = 1

  validation {
    condition     = var.node_min_count >= 1
    error_message = "node_min_count must be at least 1."
  }
}

variable "node_max_count" {
  description = "Maximum nodes per configured node zone."
  type        = number
  default     = 3

  validation {
    condition     = var.node_max_count >= 1
    error_message = "node_max_count must be at least 1."
  }
}

variable "deletion_protection" {
  description = "Protect clusters from accidental Terraform deletion. Keep false for short-lived demos that must be easy to destroy."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "GitHub repository allowed to impersonate the deployment service account, in owner/repository format."
  type        = string
  default     = "rifkikarimr/multi-region-gke-app"

  validation {
    condition     = can(regex("^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$", var.github_repository))
    error_message = "github_repository must use owner/repository format."
  }
}

variable "github_deployer_service_account_id" {
  description = "Account ID for the GitHub Actions deployment service account."
  type        = string
  default     = "github-gke-deployer"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.github_deployer_service_account_id))
    error_message = "github_deployer_service_account_id must be a valid service account ID."
  }
}

variable "gke_node_service_account_id" {
  description = "Account ID for the GKE node runtime service account."
  type        = string
  default     = "gke-node-runtime"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.gke_node_service_account_id))
    error_message = "gke_node_service_account_id must be a valid service account ID."
  }
}

variable "github_workload_identity_pool_id" {
  description = "ID for the GitHub Actions Workload Identity Pool."
  type        = string
  default     = "github-actions"

  validation {
    condition     = can(regex("^[a-z0-9-]{4,32}$", var.github_workload_identity_pool_id))
    error_message = "github_workload_identity_pool_id must contain 4-32 lowercase letters, numbers, or hyphens."
  }
}

variable "labels" {
  description = "Labels applied to supported Google Cloud resources."
  type        = map(string)
  default = {
    application = "multi-region-gke-app"
    managed-by  = "terraform"
    purpose     = "portfolio"
  }
}
