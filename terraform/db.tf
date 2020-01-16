resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-db"]

  # Определение загрузочного диска
  boot_disk {
    initialize_params {
      image = var.db_disk_image
      size  = 10
      type  = "pd-ssd"
    }
  }

  # Определение сетевого интерфейса
  network_interface {
    # Сеть, к которой присоединить данный интерфейс
    network = "default"
    # Использовать ephemeral IP для доступа из Интернет
    access_config {}
  }

  depends_on = [
    google_compute_project_metadata_item.default
  ]
}

resource "google_compute_firewall" "firewall_mongo" {
  name = "allow-mongo-default"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-db"]
  source_tags = ["reddit-app"]
}
