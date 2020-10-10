api_addr         = "https://{PRIVATE-IPV4}:8200"
cluster_addr     = "https://{PRIVATE-IPV4}:8201"
log_level        = "DEBUG"
ui               = true
plugin_directory = "/vault/plugins"

# Enable auto-unsealing with Google Cloud KMS
# seal "gcpckms" {
#   # project    = "${kms_project}"
#   # region     = "${kms_location}"
#   # key_ring   = "${kms_keyring}"
#   # crypto_key = "${kms_crypto_key}"
# }

storage "gcs" {
  bucket     = "{BUCKET}"
  ha_enabled = "true"
}

# storage "inmem" {}

listener "tcp" {
  address     = "127.0.0.1:8200"
  tls_disable = 1
}

listener "tcp" {
  address                            = "{PRIVATE-IPV4}:8200"
  tls_cert_file                      = "/vault/config/server.pem"
  tls_key_file                       = "/vault/config/server-key.pem"
  tls_client_ca_file                 = "/vault/config/vault-ca.pem"
  tls_disable_client_certs           = false
  tls_require_and_verify_client_cert = true
}
