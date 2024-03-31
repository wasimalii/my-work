# webapp-tracker-loadbalancer
// terraform apply -var="instance_template_name=webapp-20231201-1"
// terraform apply -var="instance_template_name=webapp-20231201-1" -var="ssl_certificate_name=webapp-1700634962"

provider "google" {
  credentials = file("/etc/terraform/webapp.json")
  project     = "webapp"
}

variable "instance_template_name" {
  description = "Name of the instance template"
  type        = string
  default     = "webapp-20231201-1"
}

variable "ssl_certificate_name" {
  description = "Name of the SSL certificate"
  type        = string
  default     = "webapp-1700634962"
}


resource "google_compute_health_check" "autohealing" {
  name                = "terraform-webapp-hc"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 1
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/ping"
    port         = "80"
  }
}

resource "google_compute_autoscaler" "foobar" {
  name   = "terraform-webapp-autoscaler"
  zone   = "europe-west1-c"
  target = google_compute_instance_group_manager.terraform_instance_group.id

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 1
    cooldown_period = 60

    cpu_utilization {
      target = 0.8
    }
  }
}


resource "google_compute_instance_group_manager" "terraform_instance_group" {
  name = "terraform-webapp"

  base_instance_name = "terraform-webapp-instance"

  version {
    instance_template = "projects/webapp/global/instanceTemplates/${var.instance_template_name}"
  }
  zone        = "europe-west1-c"
  target_size = 1

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.autohealing.id
    initial_delay_sec = 150
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_percent     = 100
    max_unavailable_fixed = 0
  }
}

resource "google_compute_global_address" "lb_ip" {
  name         = "terraform-webapp-lb-ip"
  purpose      = "GLOBAL"
  address_type = "EXTERNAL"
}

resource "google_compute_backend_service" "backend_service" {
  depends_on = [
    google_compute_health_check.autohealing,
    google_compute_instance_group_manager.terraform_instance_group,
  ]
  name        = "terraform-webapp-bs"
  description = "Backend service for instance group"
  backend {
    group           = "projects/webapp/zones/europe-west1-c/instanceGroups/terraform-webapp"
    max_utilization = 0.8
  }
  health_checks = ["projects/webapp/global/healthChecks/terraform-webapp-hc"]
  port_name     = "http"
  timeout_sec   = 90
  enable_cdn    = false # Cloud CDN Disabled

  log_config {
    enable      = true
    sample_rate = 1
  }
}

resource "google_compute_url_map" "url_map" {
  depends_on      = [google_compute_instance_group_manager.terraform_instance_group]
  name            = "terraform-webapp"
  default_service = google_compute_backend_service.backend_service.self_link

}

resource "google_compute_target_http_proxy" "target_proxy" {
  name    = "terraform-webapp-target-proxy"
  url_map = google_compute_url_map.url_map.self_link
}

resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  name       = "terraform-webapp-forwarding-rule"
  target     = google_compute_target_http_proxy.target_proxy.self_link
  port_range = "80"
  ip_address = google_compute_global_address.lb_ip.address
}

# New HTTPS resources
data "google_compute_ssl_certificate" "existing_ssl_certificate" {
  name = var.ssl_certificate_name 
}

resource "google_compute_target_https_proxy" "target_proxy_https" {
  name    = "terraform-webapp-target-proxy-https"
  url_map = google_compute_url_map.url_map.self_link

  ssl_certificates = [
    data.google_compute_ssl_certificate.existing_ssl_certificate.self_link,
  ]
}

resource "google_compute_global_forwarding_rule" "forwarding_rule_https" {
  name       = "terraform-webapp-forwarding-rule-https"
  target     = google_compute_target_https_proxy.target_proxy_https.self_link
  port_range = "443"
  ip_address = google_compute_global_address.lb_ip.address
}


# Execute a local script after resources are created
resource "null_resource" "execute_script" {
  provisioner "local-exec" {
    command = "./update_proxy.sh"
  }

  depends_on = [
    google_compute_global_forwarding_rule.forwarding_rule,
    google_compute_global_forwarding_rule.forwarding_rule_https,
  ]
}
