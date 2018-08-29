variable "region" {
  default = "us-central1"
}

variable "clustername" {
  default = "sample-plattform-cluster"
}

variable "kubernetes_version" {
  default = "1.10.5-gke.4"
}

variable "node_count" {
  default = "3"
}

variable "gcp_project" {
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "preemptible" {
  default = "false"
}

variable "username" {}
variable "password" {}