resource "helm_release" "logstash" {
  
  name      = "logstash"
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "logstash"
  version   = "2.0.2"
  namespace = kubernetes_namespace.tracing.metadata.0.name
  atomic = true
  count = var.elk ? 1 : 0
  timeout = 120

  values = [
      <<EOT
        replicaCount: 1
        # httpPort: 9600
        
        service:
            type: NodePort
            ports:
            - name: beats
              port: 5044
              protocol: TCP
              targetPort: 5044
            - name: http
              port: 8080
              protocol: TCP
              targetPort: 8080
        
        # resources:
        #     requests:
        #         cpu: "100m"
        #         memory: "128m"
        #     limits:
        #         cpu: "100"
        #         memory: "128m"
        

        ## Input Plugins configuration
        ## ref: https://www.elastic.co/guide/en/logstash/current/input-plugins.html
        ##
        input: |-
            beats {
                port => 5044
            }
            http { port => 8080 }
        output: |-
            elasticsearch {
              hosts => ["elasticsearch-elasticsearch-coordinating-only:9200"]
              manage_template => false
              index => "%%{[@metadata][beat]}-%%{+YYYY.MM.dd}"
            }
            stdout {}

      EOT
  ]
}
