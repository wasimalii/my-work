provider "google" {
  credentials = file("/etc/terraform/gaming.json")
  project     = "gaming"
}

terraform {
  backend "gcs" {
    bucket = "terraform-igaming"
    prefix = "vm"
  }
}


module "gcp_dev_vm" {
  source               = "/home/wasimali/terraform-script/gaming/modules/vm/"
  name                 = "gaming-dev"
  machine_type         = "custom-2-6144"    
  image                = "ubuntu-os-cloud/ubuntu-2204-lts"
  size                 = "15"
  boot_disk_type       = "pd-balanced"
  additional_disk_size = null
  disk_name            = "dev-disk"
  disk_type            = "pd-ssd"
}

module "gcp_ansible_vm" {
  source               = "/home/wasimali/terraform-script/gaming/modules/vm/"
  name                 = "ansible"
  machine_type         = "custom-1-1024"    
  image                = "ubuntu-os-cloud/ubuntu-2204-lts"
  size                 = "15"
  boot_disk_type       = "pd-balanced"
  additional_disk_size = null
  disk_name            = "ansible-disk"
  disk_type            = "pd-ssd"
}
