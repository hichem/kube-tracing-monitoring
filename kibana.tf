resource "helm_release" "kibana" {
  
  name      = "kibana"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "kibana"
  version   = "6.2.3"
  namespace = kubernetes_namespace.tracing.metadata.0.name
  atomic = true
  count = var.elk ? 1 : 0
  timeout = 120

  values = [
      <<EOT
        replicaCount: 1
        persistence:
            enabled: true
            size: 512Mi
        
        service:
            type: NodePort
            port: 5601

        # resources:
        #     requests:
        #         cpu: "100m"
        #         memory: "128m"
        #     limits:
        #         cpu: "100"
        #         memory: "128m"
        
        metrics:
            enabled: false
            service:
                annotations:
                prometheus.io/scrape: "true"
                prometheus.io/port: "80"
                prometheus.io/path: "_prometheus/metrics"

        ## Properties for Elasticsearch
        ##
        elasticsearch:
            hosts:
            - elasticsearch-elasticsearch-coordinating-only
            port: 9200

      EOT
  ]
}
