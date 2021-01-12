# Kubernetes Provider
provider "kubernetes" {
  version                = "1.13.2"
  load_config_file       = true
}

# Helm Provider
provider "helm" {
  debug = false
  version = "1.3.2"

  kubernetes {
    load_config_file = true
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "tracing" {
  metadata {
    name = "tracing"
  }
}
