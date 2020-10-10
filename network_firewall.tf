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
