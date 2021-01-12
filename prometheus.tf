resource "helm_release" "prometheus" {
  
  name      = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart     = "prometheus"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  atomic = true
  count = var.monitoring_enabled ? 1 : 0

  values = [
      <<EOT
        alertmanager:
          enabled: false
          replicaCount: 1
          persistentVolume:
            enabled: false
            size: 512Mi
        
        server:
          replicaCount: 1
          service:
            type: NodePort
            port: 9090
          persistentVolume:
            enabled: true
            size: 1Gi

        kubeStateMetrics:
          enabled: true
        
        pushgateway:
          enabled: false
          replicaCount: 1
          persistentVolume:
            enabled: true
            size: 1Gi

      EOT
  ]
}
