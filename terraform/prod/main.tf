terraform {
  # Версия terraform
  required_version = "~>0.12.8"
}

provider "google" {
  # Версия провайдера
  version = "~>2.15"

  # ID проекта
  project = var.project

  region = var.region
}

resource "google_compute_project_metadata_item" "default" {
  key     = "ssh-keys"
  value   = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}\nappuser3:${file(var.public_key_path)}"
  project = var.project
}

module "app" {
  source           = "../modules/app"
  zone             = var.zone
  machine_type     = var.machine_type
  private_key_path = var.private_key_path
  vm_count         = var.app_vm_count
  app_disk_image   = var.app_disk_image
  database_url     = "${module.db.db_internal_ip}:27017"

  vm_depends_on = [
    google_compute_project_metadata_item.default,
    module.vpc,
    module.db
  ]
}

module "db" {
  source           = "../modules/db"
  zone             = var.zone
  machine_type     = var.machine_type
  db_disk_image    = var.db_disk_image
  private_key_path = var.private_key_path

  vm_depends_on = [
    google_compute_project_metadata_item.default,
    module.vpc
  ]
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["194.1.156.30/32"]
}
