resource "google_compute_instance_template" "vault" {
  project      = var.project
  name_prefix  = "vault-"
  region       = var.region
  machine_type = var.machine_type
  tags         = concat(["vault"], var.extra_tags)

  network_interface {
    subnetwork = google_compute_subnetwork.vault.name
  }

  disk {
    source_image = var.source_image
    boot         = true
    mode         = "READ_WRITE"
    type         = "PERSISTENT"
    disk_type    = "pd-ssd"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    google-compute-enable-virtio-rng = true,
    startup-script = data.template_file.startup_script.rendered,
  }

  lifecycle {
    create_before_destroy = true
  }
}
