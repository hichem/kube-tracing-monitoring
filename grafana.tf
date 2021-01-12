resource "kubernetes_secret" "grafana_admin" {
  
  metadata {
    name = "grafana-admin"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }

  data = {
    user = "admin"
    password = "admin"
  }
  type = "Opaque"
}

# Install Grafana
resource "helm_release" "grafana" {
  name      = "grafana"
  chart     = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  namespace = kubernetes_namespace.monitoring.metadata.0.name
  atomic    = true
  count     = var.monitoring_enabled ? 1 : 0

  values = [
    <<EOT
    replicas: 1
    #image:
    #  tag: 7.0.3
    service:
      type: NodePort
      port: 3030
    persistence:
      enabled: true
      size: 512Mi
    admin:
      existingSecret: ${kubernetes_secret.grafana_admin.metadata.0.name}
      userKey: user
      passwordKey: password
    ingress:
      enabled: false
      hosts:
        - grafana.domain
      tls:
      - hosts:
        - grafana.domain
        secretName: grafana-tls
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-production
    datasources: 
      datasources.yaml:
        apiVersion: 1
        datasources:
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server
          access: proxy
          isDefault: true
    dashboards:
      default:
        kube-dash:
          gnetId: 6663
          revision: 1
          datasource: Prometheus
        prometheus-stats:
          gnetId: 2
          revision: 2
          datasource: Prometheus
        minio:
          gnetId: 13502
          revision: 4
          datasource: Prometheus
        keycloak:
          gnetId: 10441
          revision: 1
          datasource: Prometheus
        zookeeper:
          gnetId: 10465
          revision: 4
          datasource: Prometheus
        kafka:
          gnetId: 721
          revision: 1
          datasource: Prometheus
    dashboardProviders:
      dashboardproviders.yaml:
        apiVersion: 1
        providers:
        - name: 'default'
          orgId: 1
          folder: ''
          type: file
          disableDeletion: false
          editable: true
          options:
            path: /var/lib/grafana/dashboards
    grafana.ini:
      server:
        domain: grafana.domain
        root_url: https://grafana.domain
      ## https://grafana.com/docs/grafana/latest/auth/generic-oauth/#set-up-oauth2-with-azure-active-directory
      auth.generic_oauth:
        name: Keycloak
        enabled: false
        allow_sign_up: true
        client_id: 
        client_secret:
        scopes: openid email name groups
        role_attribute_path: contains(groups[*], 'TO BE COMPLETED') && 'Admin'
        auth_url: /oauth2/authorize
        token_url: /oauth2/token
        api_url: /openid/userinfo
    EOT
  ]
}
