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

  connection {
    type  = "ssh"
    host  = self.network_interface[0].access_config[0].nat_ip
    user  = "appuser"
    agent = false
    # путь до приватного ключа
    private_key = file(var.private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo sed -i 's/^ExecStart.*/& --bind_ip ${self.network_interface[0].network_ip}/' /lib/systemd/system/mongod.service && sudo systemctl daemon-reload && sudo systemctl restart mongod"
    ]
  }

  depends_on = [var.vm_depends_on]
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
