resource "google_compute_instance" "app" {
  count        = var.vm_count
  name         = "reddit-app${count.index + 1}-${trimspace(var.env)}"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["reddit-app-${trimspace(var.env)}"]

  # Определение загрузочного диска
  boot_disk {
    initialize_params {
      image = var.app_disk_image
      size  = 10
      type  = "pd-ssd"
    }
  }

  # Определение сетевого интерфейса
  network_interface {
    # Сеть, к которой присоединить данный интерфейс
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip[count.index].address
    }
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
      var.enable_provision ? "cat /dev/null" : "echo Provision disabled!"
    ]
  }

  provisioner "file" {
    content     = templatefile("${path.module}/puma.service.tmpl", { database_url = var.database_url })
    destination = var.enable_provision ? "/tmp/puma.service" : "/dev/null"
  }

  provisioner "remote-exec" {
    script = var.enable_provision ? "${path.module}/deploy.sh" : null
  }

  depends_on = [var.vm_depends_on]
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default-${trimspace(var.env)}"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app-${trimspace(var.env)}"]
}

resource "google_compute_address" "app_ip" {
  count = var.vm_count
  name  = "reddit-app-ip${count.index + 1}-${trimspace(var.env)}"
}

resource "google_compute_firewall" "firewall_nginx_puma" {
  name = "allow-nginx-puma-default-${trimspace(var.env)}"
  # Название сети, в которой действует правило
  network = "default"
  # Какой доступ разрешить
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  # Каким адресам разрешаем доступ
  source_ranges = ["0.0.0.0/0"]
  # Правило применимо для инстансов с перечисленными тэгами
  target_tags = ["reddit-app-${trimspace(var.env)}"]
}
