# terraform-grafana-prometheus-alerts

Terraform module to convert [Prometheus Alerting rules] to [Grafana-managed alert rules]

## Motivation / Why using this module

There are plenty of apps (mostly out of CNCF's ecosystem) where the vendor or the community provides monitoring dashboards
and alerts. Dashboards are normally provided as a JSON file which can be loaded into Grafana. Alerts are mostly provided
as [Prometheus Alerting rules].

There are users who already operate a Grafana instance or use a managed Grafana instance from a cloud provider (Grafana
Cloud, Amazon Managed Grafana, Azure Managed Grafana, etc.). Why not using this Grafana instance for the
alerting?

The problem is that Grafana's unified alerting uses another format for the alert definition but the concept with labels,
annotations (provide description and runbook URLs) is almost identical.
This module allows you to reuse the [Prometheus Alerting rules] and configure them inside Grafana.

## Example usage

```hcl
module "cert_manager_rules" {
  source = "github.com/mkilchhofer/terraform-grafana-prometheus-alerts"

  prometheus_alerts_file_path = file("/path/to/alerts/cert-manager.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = grafana_data_source.victoria_metrics.uid
}
```

## Requirements

- Grafana 8.0+ (Unified alerting)

## Limitations

- Defining multiple alerts with the same name is not supported in Grafana

## Overriding definitions of Prometheus Alerting file

TODO

## TF module documentation

<!-- BEGIN_TF_DOCS -->
### Providers

| Name | Version |
|------|---------|
| grafana | 3.7.0 |
| time | n/a |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| datasource\_uid | The UID of the Grafana datasource being queried with the expressions inside the Alerting rule file | `string` | n/a | yes |
| default\_evaluation\_interval\_duration | How often is the rule evaluated by default. (When not defined inside your Alerting rules file) | `string` | `"5m"` | no |
| disable\_provenance | Allow modifying the rule group from other sources than Terraform or the Grafana API. | `bool` | `false` | no |
| folder\_uid | The UID of the Grafana folder that the alerts belongs to. | `string` | n/a | yes |
| org\_id | The Organization ID of of the Grafana Alerting rule groups. (Only supported with basic auth, API keys are already org-scoped) | `string` | `null` | no |
| overrides | Overrides per Alert rule | <pre>map(object({<br>    alert_threshold = optional(number)<br>    exec_err_state  = optional(string)<br>    is_paused       = optional(bool)<br>    no_data_state   = optional(string)<br>  }))</pre> | `{}` | no |
| prometheus\_alerts\_file\_path | Path to the Prometheus Alerting rules file | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| alertsfile\_map | n/a |
| file\_as\_yaml | n/a |
<!-- END_TF_DOCS -->

[Grafana-managed alert rules]: https://grafana.com/docs/grafana/latest/alerting/fundamentals/alert-rules/#grafana-managed-alert-rules
[Prometheus Alerting rules]: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
