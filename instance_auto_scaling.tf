resource "google_compute_region_autoscaler" "vault" {
  project = var.project
  name    = "vault-auto-scaling"
  region  = var.region
  target  = google_compute_region_instance_group_manager.vault.self_link

  autoscaling_policy {
    min_replicas    = var.min_num_servers
    max_replicas    = var.max_num_servers
    cooldown_period = 300

    cpu_utilization {
      target = 0.8
    }
  }
}