resource "tls_private_key" "vault-cli" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "vault-cli" {
  key_algorithm   = tls_private_key.vault-cli.algorithm
  private_key_pem = tls_private_key.vault-cli.private_key_pem

  ip_addresses = [
    "127.0.0.1",
  ]

  dns_names = [
    "localhost",
    "client.global.vault",
  ]

  subject {
    common_name  = "client.global.vault"
    organization = var.tls_organization
  }
}

resource "tls_locally_signed_cert" "vault-cli" {
  cert_request_pem = tls_cert_request.vault-cli.cert_request_pem

  ca_key_algorithm   = tls_private_key.vault-ca.algorithm
  ca_private_key_pem = tls_private_key.vault-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.vault-ca.cert_pem

  validity_period_hours = 87600

  allowed_uses = [
    "client_auth",
  ]
}