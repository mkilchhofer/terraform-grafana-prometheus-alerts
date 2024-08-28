resource "grafana_data_source" "prometheus" {
  name = "Prometheus"
  type = "prometheus"
  url  = "https://prometheus.demo.do.prometheus.io" #Shared Services - Observability
}
