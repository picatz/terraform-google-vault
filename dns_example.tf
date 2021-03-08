# Example public DNS configuration for public.vault.example.com
#
# Ensure the name servers are properly configured in your domain's
# DNS provider.
#
# $ terraform console
# > google_dns_managed_zone.vault.name_servers
#
# resource "google_dns_record_set" "public" {
#   name  = "public.${google_dns_managed_zone.vault.dns_name}"
#   type  = "A"
#   ttl   = 300
#
#   managed_zone = google_dns_managed_zone.vault.name
#
#   rrdatas = [google_compute_global_address.vault_external.address]
# }
#
# resource "google_dns_managed_zone" "vault" {
#   name     = "vault"
#   dns_name = "vault.example.com."
# }