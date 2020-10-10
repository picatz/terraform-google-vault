data "template_file" "startup_script" {
  template = file("${path.module}/templates/server.sh")

  vars = {
    project                   = var.project
    bucket                    = format("%s-vault-backend", var.project)
    vault_ca_cert             = tls_self_signed_cert.vault-ca.cert_pem
    vault_server_cert         = tls_locally_signed_cert.vault-server.cert_pem
    vault_server_private_key  = tls_private_key.vault-server.private_key_pem
  }
}
