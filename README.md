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
  datasource_uid              = grafana_data_source.prometheus.uid
}
```

## Requirements

- Grafana 8.0+ (Unified alerting)

## Limitations

- Defining multiple alerts with the same name is not supported in Grafana

## Overriding definitions of Prometheus Alerting file

The alerts defined as [Prometheus Alerting rules] can be overridden without changing the input file.
If your Prometheus Alerting rules YAML contains an alert `alert: TooManyWriteErrors`, you can override it like this:

```hcl
module "cert_manager_rules" {
  source = "github.com/mkilchhofer/terraform-grafana-prometheus-alerts"

  prometheus_alerts_file_path = file("/path/to/alerts/cert-manager.yaml")
  folder_uid                  = grafana_folder.test.uid
  datasource_uid              = grafana_data_source.prometheus.uid

  # Overrides per alert
  overrides = {
    "TooManyWriteErrors" = {
      alert_threshold = 1
      is_paused       = true

      labels = {
        mycustomlabel = "foobar" # Add an extra label
        severity      = "notify" # Override severity
      }
    }
  }
}
```

Every alert supports the following overrides:

| Override parameter | Type          | Description |
|--------------------|---------------|-------------|
| `alert_threshold`  | `number`      | Threshold of the Grafana alert. Defaults to `0` |
| `exec_err_state`   | `string`      | Describes what state to enter when the rule's query is invalid and the rule cannot be executed. Options are `OK`, `Error`, `KeepLast`, and `Alerting`. Defaults to `Error`. |
| `expr`             | `string`      | Use a custom PromQL expression for this Grafana alert. |
| `is_paused`        | `bool`        | Sets whether the alert should be paused or not. Defaults to `false`. |
| `no_data_state`    | `string`      | Describes what state to enter when the rule's query returns No Data. Options are `OK`, `NoData`, `KeepLast`, and `Alerting`. Defaults to `OK`. |
| `annotations`      | `map(string)` | Extra annotations to add. It is also possible to override already defined annotations like `runbook_url`. |
| `labels`           | `map(string)` | Extra labels to add. It is also possible to override already defined labels like `severity`. |


## TF module documentation

<!-- BEGIN_TF_DOCS -->
### Providers

| Name | Version |
|------|---------|
| grafana | ~> 3.2 |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| datasource\_uid | The UID of the Grafana datasource being queried with the expressions inside the Alerting rule file | `string` | n/a | yes |
| default\_evaluation\_interval\_duration | How often is the rule evaluated by default. (When not defined inside your Alerting rules file) | `string` | `"5m"` | no |
| disable\_provenance | Allow modifying the rule group from other sources than Terraform or the Grafana API. | `bool` | `false` | no |
| folder\_uid | The UID of the Grafana folder that the alerts belongs to. | `string` | n/a | yes |
| org\_id | The Organization ID of of the Grafana Alerting rule groups. (Only supported with basic auth, API keys are already org-scoped) | `string` | `null` | no |
| overrides | Overrides per Alert rule | <pre>map(object({<br>    alert_threshold = optional(number)<br>    exec_err_state  = optional(string)<br>    expr            = optional(string)<br>    is_paused       = optional(bool)<br>    no_data_state   = optional(string)<br>    labels          = optional(map(string))<br>    annotations     = optional(map(string))<br>  }))</pre> | `{}` | no |
| prometheus\_alerts\_file\_path | Path to the Prometheus Alerting rules file | `string` | n/a | yes |

### Outputs

No outputs.
<!-- END_TF_DOCS -->

[Grafana-managed alert rules]: https://grafana.com/docs/grafana/latest/alerting/fundamentals/alert-rules/#grafana-managed-alert-rules
[Prometheus Alerting rules]: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
