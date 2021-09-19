resource "google_compute_security_policy" "vault" {
  count = var.cloud_armor_enabled ? 1 : 0

  provider = google-beta

  name  = "vault-cloud-armor"

  rule {
        action   = "deny(403)"
        priority = "1000"
        match {
            expr {
                expression = "evaluatePreconfiguredExpr('xss-stable')"
            }
        }
  }

  rule {
        action   = "deny(403)"
        priority = "1001"
        match {
            expr {
                expression = "evaluatePreconfiguredExpr('scannerdetection-stable')"
            }
        }
  }

  rule {
        action   = "deny(403)"
        priority = "1002"
        match {
            expr {
                expression = "evaluatePreconfiguredExpr('protocolattack-stable')"
            }
        }
  }

  rule {
        action   = "allow"
        priority = "2147483647"
        match {
            versioned_expr = "SRC_IPS_V1"
            config {
                src_ip_ranges = ["*"]
            }
        }
        description = "default rule"
  }

  adaptive_protection_config {
      layer_7_ddos_defense_config {
        enable = var.cloud_armor_enabled
      }
  }
}