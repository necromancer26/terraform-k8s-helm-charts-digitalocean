terraform {
  backend "s3" {
    endpoint = "fra1.digitaloceanspaces.com" #endpoint
    key      = "helm/terraform.tfstate"      #path
    bucket   = "green-bubble"                # bucket-name
    region   = "eu-central-1"                #region
    # acl      = # example "bucket-owner-read"
    # skip_requesting_account_id  = true
    skip_credentials_validation = true
    # skip_get_ec2_platforms      = true
    skip_metadata_api_check = true
  }
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.10.1"

    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

}
provider "digitalocean" {
  token = var.do_token
}
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
data "digitalocean_kubernetes_cluster" "primary" {
  name = var.cluster_name

}
# resource "local_file" "kubeconfig" {
#   # depends_on = [var.cluster_id]
#   count    = var.write_kubeconfig ? 1 : 0
#   content  = data.digitalocean_kubernetes_cluster.primary.kube_config[0].raw_config
#   filename = var.config_path
# }
resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true
  version          = "v1.12.0"
  set {
    name  = "installCRDs"
    value = true
  }
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.19"
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  set {
    name  = "defaultRevision"
    value = "default"
  }
}
resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.19"
  set {
    name  = "telemetry.enabled"
    value = "true"
  }
  set {
    name  = "global.istioNamespace"
    value = "istio-system"
  }
  set {
    name  = "meshConfig.ingressService"
    value = "istio-gateway"
  }

  set {
    name  = "meshConfig.ingressSelector"
    value = "gateway"
  }
  depends_on = [helm_release.istio_base, ]
}

resource "helm_release" "gateway" {
  name             = "istio-ingress"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "gateway"
  namespace        = "istio-ingress"
  create_namespace = true
  version          = "1.19"

  depends_on = [
    helm_release.istio_base,
    helm_release.istiod,
  ]
}
# resource "helm_release" "argocd" {
  
# }
# resource "helm_release" "vault" {
#   name       = "vault"
#   repository = "https://helm.releases.hashicorp.com"
#   chart      = "vault"
#   namespace = "vault"
#   create_namespace = true

# }

