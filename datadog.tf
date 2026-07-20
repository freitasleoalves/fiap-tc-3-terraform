# ============================================
# Datadog - Alertas Inteligentes + ChatOps + Self-Healing
# ============================================
# Fluxo (requisito 4 do Tech Challenge Fase 4):
#   Monitor dispara (taxa de erros 5xx > 5%)
#        │
#        ├──► @pagerduty-<service>        -> abre incidente no PagerDuty
#        ├──► @webhook-discord-alerts     -> notifica o canal do Discord
#        └──► @webhook-github-selfheal-<service> -> repository_dispatch no
#             GitHub, que roda .github/workflows/self-heal.yml e executa
#             `kubectl rollout restart deployment/<service>` no AKS.

# --- Integração com PagerDuty (uma "Service Object" por microsserviço) ---
resource "datadog_integration_pagerduty_service_object" "svc" {
  for_each     = toset(var.monitored_services)
  service_name = each.value
  service_key  = pagerduty_service_integration.datadog[each.value].integration_key
}

# --- ChatOps: notificação detalhada no Discord ---
# O sufixo "/slack" no webhook do Discord faz o Discord aceitar o payload no
# formato do Slack (compatibilidade nativa), que é o formato suportado pelo
# campo `payload` do datadog_webhook.
resource "datadog_webhook" "discord_alerts" {
  name      = "discord-alerts"
  url       = "${var.discord_webhook_url}/slack"
  encode_as = "json"
  payload = jsonencode({
    text = "🚨 *$ALERT_TITLE*\n$EVENT_MSG\nStatus: *$ALERT_TRANSITION* | Prioridade: $ALERT_PRIORITY\nVer no Datadog: $LINK"
  })
}

# --- Self-Healing: dispara o workflow do GitHub Actions (repository_dispatch) ---
# Um webhook por serviço, para que o payload enviado ao GitHub já contenha o
# nome exato do Deployment a ser reiniciado.
resource "datadog_webhook" "github_selfheal" {
  for_each  = toset(var.monitored_services)
  name      = "github-selfheal-${each.value}"
  url       = "https://api.github.com/repos/${var.gitops_repo}/dispatches"
  encode_as = "json"

  custom_headers = jsonencode({
    Authorization = "Bearer ${var.github_selfheal_token}"
    Accept        = "application/vnd.github+json"
  })

  payload = jsonencode({
    event_type = "self-heal"
    client_payload = {
      service     = each.value
      alert_title = "$ALERT_TITLE"
      alert_id    = "$ID"
    }
  })
}

# --- Alerta Inteligente: taxa de erros HTTP 5xx > 5% (métricas de APM) ---
# Métricas trace.http.server.{hits,errors} são geradas automaticamente pelo
# Datadog a partir dos traces recebidos via OTel Collector (exporter
# "datadog"), agregadas por tag "service". Ajuste o nome da métrica na
# Metrics Explorer do Datadog caso a operação HTTP raiz tenha outro nome.
resource "datadog_monitor" "http_5xx_error_rate" {
  for_each = toset(var.monitored_services)

  name  = "[ToggleMaster] Taxa de erros 5xx alta - ${each.value}"
  type  = "metric alert"
  query = "sum(last_5m):( sum:trace.http.server.errors{service:${each.value}}.as_count() / sum:trace.http.server.hits{service:${each.value}}.as_count() ) * 100 > 5"

  message = <<-EOT
    {{#is_alert}}
    🔥 A taxa de erros HTTP 5xx do **${each.value}** está acima de 5% nos
    últimos 5 minutos. Isso pode indicar falha silenciosa (ex.: dependência
    fora do ar, exaustão de recursos).

    Ação automática: o self-healing vai executar
    `kubectl rollout restart deployment/${each.value}` para tentar mitigar.
    {{/is_alert}}
    {{#is_recovery}}
    ✅ Taxa de erros do ${each.value} normalizada (< 5%).
    {{/is_recovery}}

    @pagerduty-${each.value} @webhook-discord-alerts @webhook-github-selfheal-${each.value}
  EOT

  monitor_thresholds {
    critical = 5
  }

  notify_no_data      = false
  renotify_interval   = 10
  require_full_window = false

  tags = [
    "service:${each.value}",
    "env:prod",
    "team:togglemaster",
    "fase:4",
  ]

  depends_on = [
    datadog_integration_pagerduty_service_object.svc,
    datadog_webhook.discord_alerts,
    datadog_webhook.github_selfheal,
  ]
}
