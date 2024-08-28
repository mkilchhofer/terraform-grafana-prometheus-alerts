resource "grafana_rule_group" "this" {
#   for_each = local.file_as_yaml.groups
  for_each = local.alertsfile_map

  name             = each.value.name
  folder_uid       = var.folder_uid
  org_id           = var.org_id

  # There is no function supporting Golang's "duration" (format of interval within an alert group)
  # Use timeadd() function which supports it.
  interval_seconds = (
    (parseint(formatdate("s", timeadd("1970-01-01T00:00:00Z", try(each.value.interval, var.default_evaluation_interval_duration))), 10) * 1) +
    (parseint(formatdate("m", timeadd("1970-01-01T00:00:00Z", try(each.value.interval, var.default_evaluation_interval_duration))), 10) * 60) +
    (parseint(formatdate("h", timeadd("1970-01-01T00:00:00Z", try(each.value.interval, var.default_evaluation_interval_duration))), 10) * 3600)
  )

  disable_provenance = var.disable_provenance

  dynamic "rule" {
    for_each = {for rule in each.value.rules:  rule.alert => rule}

    content {
      name      = rule.value.alert
      for       = try(rule.value.for, null)
      condition = "ALERTCONDITION"

      annotations = rule.value.annotations
      labels      = rule.value.labels

      data {
        ref_id = "QUERY"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = var.datasource_uid
        model = jsonencode({
          editorMode    = "code"
          expr          = rule.value.expr
          intervalMs    = 1000
          maxDataPoints = 43200
          refId         = "QUERY"
        })
      }

      ## Reduce
      data {
        ref_id = "QUERY_RESULT"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "__expr__"
        model          = jsonencode({
          "conditions" = [
            {
              "evaluator" = {
                "params" = [0]
                "type"   = "gt"
              }
              "operator" = {
                "type" = "and"
              }
              "query" = {
                "params" = []
              }
              "reducer" = {
                "params" = []
                "type"   = "avg"
              }
              "type" = "query"
            },
          ]
          "datasource" = {
            "name" = "Expression"
            "type" = "__expr__"
            "uid"  = "__expr__"
          }
          "expression"    = "QUERY"
          "intervalMs"    = 1000
          "maxDataPoints" = 43200
          "reducer"       = "last"
          "refId"         = "QUERY_RESULT"
          "type"          = "reduce"
        })
      }

      ## Threshold
      data {
        ref_id = "ALERTCONDITION"
        relative_time_range {
          from = 600
          to   = 0
        }
        datasource_uid = "__expr__"
        model          = jsonencode({
          "conditions" = [
            {
              "evaluator" = {
                "params" = [try(var.overrides[rule.value.alert].alert_threshold, 0)]
                "type"   = "gt"
              }
              "operator" = {
                "type" = "and"
              }
              "query" = {
                "params" = ["QUERY_RESULT"]
              }
              "reducer" = {
                "params" = []
                "type"   = "last"
              }
              "type" = "query"
            },
          ]
          "datasource" = {
            "type" = "__expr__"
            "uid"  = "__expr__"
          }
          "expression"    = "QUERY_RESULT"
          "hide"          = false
          "intervalMs"    = 1000
          "maxDataPoints" = 43200
          "refId"         = "ALERTCONDITION"
          "type"          = "threshold"
        })
      }
    }
  }
}
