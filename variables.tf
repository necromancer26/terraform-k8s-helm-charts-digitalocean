## K8s variables

variable "application_name" {
  type    = string
  default = "bluenest-cluster"
}

# doctl k8s options regions
variable "k8s_region" {
  type    = string
  default = "fra1"
}

variable "do_token" {
  type    = string
  default = "your do token here"
}

variable "k8s_node_count" {
  type    = number
  default = 2
}

# doctl k8s options sizes
variable "k8s_size" {
  type    = string
  default = "s-2vcpu-4gb"
}

#  doctl k8s options versions
variable "k8s_version" {
  type    = string
  default = "1.27.4-do.0"
}
variable "config_path" {
  type    = string
  default = "~/.kube/config"

}
variable "cluster_name" {
  type = string
  default = "bluenest-cluster"
}

# variable "cluster_id" {
#   type = string
# #   default = digitalocean_kubernetes_cluster.bluenest.id
# }
variable "write_kubeconfig" {
  type        = bool
  default     = false
}
## END K8s Variables
