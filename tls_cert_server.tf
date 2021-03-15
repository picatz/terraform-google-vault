resource "tls_private_key" "vault-server" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "vault-server" {
  key_algorithm   = tls_private_key.vault-server.algorithm
  private_key_pem = tls_private_key.vault-server.private_key_pem

  ip_addresses = [
    google_compute_global_address.vault_external.address,
    "127.0.0.1",
  ]

  dns_names = var.dns_enabled ? [
    "localhost",
    "server.global.vault",
    trimsuffix(google_dns_record_set.public.0.name, "."),
  ] : [
    "localhost",
    "server.global.vault",
  ]

  subject {
    common_name  = "server.global.vault"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "vault-server" {
  cert_request_pem = tls_cert_request.vault-server.cert_request_pem

  ca_key_algorithm   = tls_private_key.vault-ca.algorithm
  ca_private_key_pem = tls_private_key.vault-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.vault-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "server_auth",
    "client_auth",
  ]
}