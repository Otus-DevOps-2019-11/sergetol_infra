variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  # Значение по умолчанию
  default = "europe-north1"
}

variable zone {
  description = "Zone"
  default     = "europe-north1-a"
}

variable machine_type {
  description = "Machine type"
  default     = "f1-micro"
}

variable disk_image {
  description = "Disk image"
}

variable public_key_path {
  # Описание переменной
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable vm_count {
  description = "VM count"
  default     = 1
}
