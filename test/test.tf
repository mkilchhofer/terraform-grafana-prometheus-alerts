# Test the module against well-known cert-manager alert rules
module "test_cert_manager" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-cert-manager.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = "dummy"

  # Allow editing the rule within Grafana UI
  disable_provenance = true
}

# Test the module against well-known kubernetes alert rules
module "test_kubernetes" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-kubernetes.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = "dummy"
}

# Test the module against alert rules of VMagent (VictoriaMetrics)
module "test_vmagent" {
  source = "../"

  prometheus_alerts_file_path = file("./alerts-vmagent.yml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = "dummy"

  # Overrides per alert
  overrides = {
    "TooManyWriteErrors" = {
      alert_threshold = 1
    }
  }
}

# output "file_as_yaml" {
#   value = module.test.file_as_yaml
# }

# output "alertsfile_map" {
#   value = module.test.alertsfile_map
# }
