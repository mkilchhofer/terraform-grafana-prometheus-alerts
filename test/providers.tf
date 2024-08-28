terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
    }
  }
}

provider "grafana" {
  # Configuration options
  auth = "admin:Go4it"
  url  = "http://localhost:3000"
}
