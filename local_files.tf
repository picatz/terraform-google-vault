resource "local_file" "ca_file" {
  content         = tls_self_signed_cert.vault-ca.cert_pem
  filename        = "vault-ca.pem"
  file_permission = "0600"
}

resource "local_file" "cli_cert" {
  content         = tls_locally_signed_cert.vault-cli.cert_pem
  filename        = "vault-cli-cert.pem"
  file_permission = "0600"
}

resource "local_file" "cli_key" {
  content         = tls_private_key.vault-cli.private_key_pem
  filename        = "vault-cli-key.pem"
  file_permission = "0600"
}