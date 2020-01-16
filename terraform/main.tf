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
