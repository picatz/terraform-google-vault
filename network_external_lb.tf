resource "google_compute_global_address" "vault_external" {
  name = "vault-external"
}

resource "google_compute_global_forwarding_rule" "vault_external" {
  name                  = "vault-external"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.vault_external.address
  target                = google_compute_target_tcp_proxy.vault.id
  port_range            = "443"
  # https://github.com/terraform-providers/terraform-provider-google/issues/902#issuecomment-355098390
}

resource "google_compute_target_tcp_proxy" "vault" {
  name            = "vault-proxy"
  backend_service = google_compute_backend_service.vault.id
}

resource "google_compute_backend_service" "vault" {
  name                  = "vault-backend-service"
  load_balancing_scheme = "EXTERNAL"
  session_affinity      = "CLIENT_IP"
  protocol              = "TCP"
  port_name             = "vault-http"
  health_checks         = [google_compute_health_check.vault.self_link]

  // This value cannot be set for TCP backend services
  // security_policy = var.cloud_armor_enabled ? google_compute_security_policy.vault.0.id : ""

  backend {
    // This value used to be set, but backend services that share the same
    // target instance group must have the same value. The optional IAP
    // functionality uses HTTPS, which doesn't seem to support this value?
    //
    // max_connections_per_instance = 10000

    group = google_compute_region_instance_group_manager.vault.instance_group
  }
}

resource "google_compute_health_check" "vault" {
  name                = "vault-backend-service-health-check"
  timeout_sec         = 1
  check_interval_sec  = 1
  healthy_threshold   = 2
  unhealthy_threshold = 5

  ssl_health_check {
    port = 8200
  }
}