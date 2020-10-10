resource "google_compute_network" "vault" {
  name                    = "vault"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vault" {
  network       = google_compute_network.vault.name
  name          = "vault"
  region        = var.region
  ip_cidr_range = var.cidr_range
}
