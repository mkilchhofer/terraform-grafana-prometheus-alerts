# Test the module against well-known cert-manager alert rules
module "test_cert_manager" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-cert-manager.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = grafana_data_source.prometheus.uid

  # Allow editing the rule within Grafana UI
  disable_provenance = true

  # Overrides per alert
  overrides = {
    "CertManagerAbsent" = {
      annotations = {
        my_custom_annotation = "foobar"
        runbook_url          = "https://example.com"
      }

      labels = {
        my_custom_label = "foobar"
      }
    }
  }
}

# Test the module against well-known kubernetes alert rules
module "test_kubernetes" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-kubernetes.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = grafana_data_source.prometheus.uid
}

# Test the module against alert rules of VMagent (VictoriaMetrics)
module "test_vmagent" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-vmagent.yml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = grafana_data_source.prometheus.uid

  # Allow editing the rule within Grafana UI
  disable_provenance = true

  # Overrides per alert
  overrides = {
    "TooManyWriteErrors" = {
      alert_threshold = 1
      is_paused       = true

      labels = {
        mycustomlabel = "foobar"
      }
    }
  }
}
