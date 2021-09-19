resource "google_compute_firewall" "allow_icmp" {
  name    = "allow-icmp"
  network = google_compute_network.vault.name

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  name        = "allow-ssh"
  network     =  google_compute_network.vault.name

  allow {
    protocol = "tcp"
    ports    = [22]
  }
}

resource "google_compute_firewall" "allow_vault" {
  name          = "allow-vault"
  network       =  google_compute_network.vault.name

  allow {
    protocol = "tcp"
    ports    = [8200]
  }
}

resource "google_compute_firewall" "allow_vault_iap" {
  count         = var.iap_enabled ? 1 : 0
  name          = "allow-vault-iap"
  network       = google_compute_network.vault.name

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  allow {
    protocol = "tcp"
    ports    = [8202]
  }
}
