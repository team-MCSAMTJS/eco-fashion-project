locals {
  resolved_cluster_name = var.cluster-name != "" ? var.cluster-name : "tsp-cluster-${terraform.workspace}"
}