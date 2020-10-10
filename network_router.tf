resource "google_compute_router" "vault" {
  name    = "vault-router"
  region  = var.region
  network = google_compute_network.vault.name
  bgp {
    asn = var.router_asn
  }
}

resource "google_compute_router_nat" "vault" {
  name                               = "vault-router-nat"
  region                             = google_compute_router.vault.region
  router                             = google_compute_router.vault.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}