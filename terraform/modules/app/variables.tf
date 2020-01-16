variable zone {
  description = "Zone"
  default     = "europe-north1-a"
}

variable machine_type {
  description = "Machine type"
  default     = "f1-micro"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable vm_count {
  description = "VM count"
  default     = 1
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "vm_depends_on" {
  type    = any
  default = null
}
