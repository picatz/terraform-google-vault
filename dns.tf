resource "google_dns_record_set" "public" {
  count = var.dns_enabled ? 1 : 0
  name  = format("%s.%s.", var.dns_record_set_name_prefix, var.dns_managed_zone_dns_name)
  type  = "A"
  ttl   = 300

  managed_zone = google_dns_managed_zone.vault.0.name

  rrdatas = [google_compute_global_address.vault_external.address]
}

resource "google_dns_managed_zone" "vault" {
  count    = var.dns_enabled ? 1 : 0
  name     = "vault"
  dns_name = format("%s.", var.dns_managed_zone_dns_name)
}