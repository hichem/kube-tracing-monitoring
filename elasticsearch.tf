resource "helm_release" "elasticsearch" {
  
  name      = "elasticsearch"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "elasticsearch"
  version = "13.1.0"
  namespace = kubernetes_namespace.tracing.metadata.0.name
  atomic = true
  count = var.elk ? 1 : 0
  timeout = 180

  values = [
      <<EOT
        master:
            name: master
            replicas: 1
            heapSize: 128m
            persistence:
                enabled: true
                size: 512Mi
            service:
                type: ClusterIP
                port: 9300
        coordinating:
            replicas: 1
            heapSize: 128m
            service:
                type: ClusterIP
                port: 9200
        data:
            name: data
            replicas: 1
            heapSize: 512m
            persistence:
                enabled: true
                size: 512Mi
        global:
            coordinating:
                name: coordinating-only
            kibanaEnabled: false
        ## Bundled Kibana parameters
        ##
        # kibana:
        #     service:
        #         type: NodePort
        #     elasticsearch:
        #         hosts:
        #         - '{{ include "elasticsearch.coordinating.fullname" . }}'
        #         port: 9200
        # metrics:
        #     enabled: false
        #     name: metrics
        #     service:
        #         type: ClusterIPannotations:
        #             prometheus.io/scrape: "true"
        #             prometheus.io/port: "9114"

      EOT
  ]
}
