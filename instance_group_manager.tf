resource "google_compute_region_instance_group_manager" "vault" {
  project = var.project
  name    = "vault-instance-group-manager"
  region  = var.region

  base_instance_name = format("vault-%s", var.region)
  wait_for_instances = false

  # target_pools = [google_compute_target_pool.vault.id]

  named_port {
    name = "vault-http"
    port = 8200
  }

  version {
    instance_template = google_compute_instance_template.vault.self_link
  }
}
