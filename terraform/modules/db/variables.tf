variable zone {
  description = "Zone"
  default     = "europe-north1-a"
}

variable machine_type {
  description = "Machine type"
  default     = "f1-micro"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}

variable "vm_depends_on" {
  type    = any
  default = null
}
