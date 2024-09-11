locals {
  file_as_yaml   = yamldecode(var.prometheus_alerts_file_path)
  alertsfile_map = { for group in local.file_as_yaml.groups : group.name => group }
}
