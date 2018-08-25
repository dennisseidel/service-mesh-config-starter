# https://www.terraform.io/docs/providers/google/r/container_cluster.html
# https://github.com/terraform-providers/terraform-provider-kubernetes/blob/master/_examples/google-gke-cluster/main.tf
data "google_compute_zones" "available" {}

variable "region" {
  default = "us-central1"
}

variable "cluster_name" {
  default = "sample-plattform-cluster"
}

variable "kubernetes_version" {
  default = "1.10.5-gke.4"
}

variable "username" {}
variable "password" {}

resource "google_container_node_pool" "primary_pool" {
  name       = "primary-pool"
  zone       = "${data.google_compute_zones.available.names[0]}"
  cluster    = "${google_container_cluster.primary.name}"
  node_count = "3"

  node_config {
    machine_type = "n1-standard-1"
    preemptible = "true"
  }
}

resource "google_container_cluster" "primary" {
  name               = "${var.cluster_name}"
  zone               = "${data.google_compute_zones.available.names[0]}"
  remove_default_node_pool = true

  node_pool {
    name = "default-pool"
  }

  node_version       = "${var.kubernetes_version}"
  min_master_version = "${var.kubernetes_version}"

  master_auth {
    username = "${var.username}"
    password = "${var.password}"
  }
}

output "cluster_name" {
  value = "${google_container_cluster.primary.name}"
}

output "primary_zone" {
  value = "${google_container_cluster.primary.zone}"
}

output "additional_zones" {
  value = "${google_container_cluster.primary.additional_zones}"
}

output "endpoint" {
  value = "${google_container_cluster.primary.endpoint}"
}

output "node_version" {
  value = "${google_container_cluster.primary.node_version}"
}
