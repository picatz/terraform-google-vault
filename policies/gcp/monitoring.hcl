# Create an OAuth2 access token with the ability to write logs and metrics
path "gcp/roleset/monitoring/token" {
  capabilities = ["read"]
}