resource "google_storage_bucket" "vault" {
  name          = format("%s-vault-backend", var.project)
  location      = var.bucket_location
  force_destroy = true
}