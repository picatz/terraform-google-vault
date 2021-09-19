resource "google_compute_ssl_policy" "vault" {
  count            = (var.iap_enabled && var.dns_enabled) ? 1 : 0
  name            = "vault-ssl-policy"
  profile         = var.iap_ssl_policy_profile
  min_tls_version = var.iap_ssl_policy_min_tls_version
}