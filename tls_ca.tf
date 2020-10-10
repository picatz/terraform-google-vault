resource "tls_private_key" "vault-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "vault-ca" {
  is_ca_certificate     = true
  validity_period_hours = 87600

  key_algorithm   = tls_private_key.vault-ca.algorithm
  private_key_pem = tls_private_key.vault-ca.private_key_pem

  subject {
    common_name  = "vault-ca.local"
    organization = var.tls_organization
  }

  allowed_uses = [
    "cert_signing",
    "digital_signature",
    "key_encipherment",
  ]
}