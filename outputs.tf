output "vault_ca_cert" {
  sensitive   = true
  description = "The TLS CA certificate used for CLI authentication."
  value       = tls_self_signed_cert.vault-ca.cert_pem
}

output "vault_cli_cert" {
  sensitive   = true
  description = "The TLS certificate used for CLI authentication."
  value       = tls_locally_signed_cert.vault-cli.cert_pem
}

output "vault_cli_key" {
  sensitive   = true
  description = "The TLS private key used for CLI authentication."
  value       = tls_private_key.vault-cli.private_key_pem
}

output "vault_backend_bucket" {
  description = "The backend storage buket used by Vault."
  value       = google_storage_bucket.vault.name
}

output "load_balancer_ip" {
  description = "The external ip address of the load balacner."
  value       = google_compute_global_address.vault_external.address
}

output "dns_name_servers" {
  description = "Delegate your managed_zone to these virtual name servers if DNS is enabled"
  value       = var.dns_enabled ? google_dns_managed_zone.vault.0.name_servers : []
}

output "dns_url" {
  description = "The mTLS enabled public URL using the configured DNS name"
  value       = (var.dns_enabled) ? format("https://%s", trimsuffix(google_dns_record_set.public.0.name, ".")) : ""
}

output "iap_url" {
  description = "The TLS enabled public URL using Google Cloud IAP as the first layer of authentication"
  value       = (var.iap_enabled && var.dns_enabled) ? format("https://%s", trimsuffix(google_dns_record_set.iap.0.name, ".")) : ""
}