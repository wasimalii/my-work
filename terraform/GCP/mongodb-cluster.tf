# mongodb terraform
provider "google" {
    credentials = file("/etc/terraform/webapp.json")
    project = "webapp"
  }


  # Creating VM instances in us-central
  resource "google_compute_instance" "mongodb-iowa-1" {
    name         = "mongodb-iowa-1"
    machine_type = "n1-highmem-4"
    zone         = "us-central1-c"
    tags = ["http-server", "https-server"]
    boot_disk {
      initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2204-lts"
        size  = 20
      }
    }
    network_interface {
      network = "projects/webapp/global/networks/default"
      subnetwork = "default"
      access_config {
      }
    }
    service_account {
      email  = "terraform-test@webapp.iam.gserviceaccount.com"
      scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    }
  }

  resource "google_compute_disk" "mongodb-iowa-1-disk" {
      name  = "mongodb-iowa-1-disk"
      type  = "pd-ssd"
      size  = 100
      zone  = "us-central1-c"
  }

  resource "google_compute_attached_disk" "mongo_1_attached_disk" {
    disk      = google_compute_disk.mongodb-iowa-1-disk.self_link
    instance  = google_compute_instance.mongodb-iowa-1.self_link
    mode      = "READ_WRITE"
    device_name = "mongodb-iowa-1-disk"
  }



 # Creating VM instances in europe
resource "google_compute_instance" "mongodb-eu-1" {
  name         = "mongodb-eu-1"
  machine_type = "n1-highmem-4"
  zone         = "europe-west1-c"
  tags = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }
  network_interface {
    network = "projects/webapp/global/networks/default"
    subnetwork = "default"
    access_config {
    }
  }

  service_account {
    email  = "terraform-test@webapp.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

resource "google_compute_disk" "mongodb-eu-1-disk" {
    name  = "mongodb-eu-1-disk"
    type  = "pd-ssd"
    size  = 100
    zone  = "europe-west1-c"
}

resource "google_compute_attached_disk" "mongo_2_attached_disk" {
  disk      = google_compute_disk.mongodb-eu-1-disk.self_link
  instance  = google_compute_instance.mongodb-eu-1.self_link
  mode      = "READ_WRITE"
  device_name = "mongodb-eu-1-disk"
}



 # Creating VM instances in south
resource "google_compute_instance" "mongodb-south-1" {
  name         = "mongodb-south-1"
  machine_type = "n1-highmem-4"
  zone         = "asia-south1-c"
  tags = ["http-server", "https-server"]
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }
  network_interface {
    network = "projects/webapp/global/networks/default"
    subnetwork = "default"
    access_config {
    }
  }

  service_account {
    email  = "terraform-test@webapp.iam.gserviceaccount.com"
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}


resource "google_compute_disk" "mongodb-south-1-disk" {
    name  = "mongodb-south-1-disk"
    type  = "pd-ssd"
    size  = 100
    zone  = "asia-south1-c"
}

resource "google_compute_attached_disk" "mongo_3_attached_disk" {
  disk      = google_compute_disk.mongodb-south-1-disk.self_link
  instance  = google_compute_instance.mongodb-south-1.self_link
  mode      = "READ_WRITE"
  device_name = "mongodb-south-1-disk"
}
