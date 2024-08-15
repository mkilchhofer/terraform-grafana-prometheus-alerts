variable "prometheus_alerts_file_path" {
  description = "Path to the Prometheus Alerting rules file"
  type        = string
}

variable "folder_uid" {
  description = "The UID of the Grafana folder that the alerts belongs to."
  type        = string
}

variable "datasource_uid" {
  description = "The UID of the Grafana datasource being queried with the expressions inside the Alerting rule file"
  type        = string
}

variable "default_evaluation_interval_duration" {
  description = "How often is the rule evaluated by default. (When not defined inside your Alerting rules file)"
  type = string
  default = "5m"
}
