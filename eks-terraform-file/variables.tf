#
# Variables Configuration
#

variable "cluster-name" {
  description = "EKS cluster name"
  default     = ""
  type        = string
}
variable "key_pair_name" {
  default = "tspcloud"
}
variable "eks_node_instance_type" {
  default = "t3.medium"
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "profile" {
  description = "AWS CLI profile"
  type        = string
}
