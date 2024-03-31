# This terraform file is used as a module for deploying VM's in GCP
provider "google" {
    credentials = file("/etc/terraform/webapp.json")
    project = "webapp"
  }

resource "google_compute_address" "static_ip" {
  name = "dev-ip"
  region = "europe-west1"

}

# Creating VM instances in us-central
  resource "google_compute_instance" "vm_instance" {
    name         = var.name
    machine_type =  var.machine_type
    zone         = "us-west1-c"
    allow_stopping_for_update = true
    tags = ["http-server", "https-server"]
    boot_disk {
    device_name = var.name
      initialize_params {
        image = var.image
        size  = var.size
        type  = var.boot_disk_type
      }
    }
    network_interface {
      network = "projects/webapp/global/networks/default"
      subnetwork = "dev-private-sub"
      access_config {
          nat_ip = google_compute_address.static_ip.address
        }
    }

    service_account {
      email  = "dev@developer.gserviceaccount.com"
      scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }

  }
