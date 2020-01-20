variable "zone" {
  description = "Zone"
  default     = "europe-north1-a"
}

variable "machine_type" {
  description = "Machine type"
  default     = "f1-micro"
}

variable "db_disk_image" {
  description = "Disk image for reddit db"
  default     = "reddit-db"
}

variable "vm_depends_on" {
  type    = any
  default = null
}

variable "private_key_path" {
  description = "Path to the private key used for ssh access"
}

variable "enable_provision" {
  default = true
}

variable "env" {
  description = "Environment name: e.g., stage, prod"
  default     = ""
}
