resource "google_compute_global_address" "vault_iap_external" {
  count = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name  = "vault-iap-external"
}

resource "google_compute_global_forwarding_rule" "vault_iap_external" {
  count                 = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name                  = "vault-iap-external"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  target                = google_compute_target_https_proxy.vault_iap.0.id
  ip_address            = google_compute_global_address.vault_iap_external.0.address
  port_range            = "443"
}

resource "google_compute_target_https_proxy" "vault_iap" {
  count            = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name             = "vault-iap-proxy"
  url_map          = google_compute_url_map.vault_iap.0.id
  ssl_certificates = [google_compute_ssl_certificate.vault_iap.0.id]
}

resource "google_compute_ssl_certificate" "vault_iap" {
  count       = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name        = "vault-iap-certificate"
  private_key = tls_private_key.vault-server.private_key_pem
  certificate = tls_locally_signed_cert.vault-server.cert_pem
}

resource "google_compute_url_map" "vault_iap" {
  count           = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name            = "vault-iap-url-map"
  default_service = google_compute_backend_service.vault_iap.0.id
}

resource "google_compute_backend_service" "vault_iap" {
  count                 = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name                  = "vault-iap-backend-service"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"
  protocol              = "HTTPS"
  port_name             = "vault-http-iap"
  health_checks         = [google_compute_health_check.vault_iap.0.self_link]

  security_policy = var.cloud_armor_enabled ? google_compute_security_policy.vault.0.id : ""

  backend {
    group = google_compute_region_instance_group_manager.vault.instance_group
  }

  iap {
      oauth2_client_id     = var.iap_client_id
      oauth2_client_secret = var.iap_client_secret
  }
}

resource "google_compute_health_check" "vault_iap" {
  count               = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name                = "vault-iap-backend-service-health-check"
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 2
  unhealthy_threshold = 5

  ssl_health_check {
    port = 8202
  }
}

// TODO: support other member kinds and maybe conditions?
data "google_iam_policy" "vault_iap" {
  binding {
    role = "roles/iap.httpsResourceAccessor"
    members = formatlist("user:%s", split(",", var.iap_member_emails))
  }
}

resource "google_iap_web_backend_service_iam_policy" "vault_iap" {
  count = (var.iap_enabled && var.dns_enabled && length(var.iap_member_emails) > 0) ? 1 : 0
  web_backend_service = google_compute_backend_service.vault_iap.0.name
  policy_data = data.google_iam_policy.vault_iap.policy_data
}