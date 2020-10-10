# resource "google_compute_health_check" "vault_internal" {
#   project             = var.project
#   name                = "vault-health-internal"
#   check_interval_sec  = 15
#   timeout_sec         = 5
#   healthy_threshold   = 2
#   unhealthy_threshold = 2
#
#   tcp_health_check {
#     port = 8200
#   }
# }
#
# resource "google_compute_region_backend_service" "vault_internal" {
#   project       = var.project
#   name          = "vault-backend-service"
#   region        = var.region
#   health_checks = [google_compute_health_check.vault_internal.self_link]
#
#   backend {
#     group = google_compute_region_instance_group_manager.vault.instance_group
#   }
# }
#
# resource "google_compute_forwarding_rule" "vault_internal" {
#   project               = var.project
#   name                  = "vault-internal"
#   region                = var.region
#   ip_protocol           = "TCP"
#   load_balancing_scheme = "INTERNAL"
#   network_tier          = "PREMIUM"
#   allow_global_access   = true
#   subnetwork            = google_compute_subnetwork.vault.name
#   backend_service       = google_compute_region_backend_service.vault_internal.self_link
#   ports                 = [8200]
# }