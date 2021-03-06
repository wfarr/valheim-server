variable "persistent_disk_name" {
  type    = string
  default = "valheim-worlds"
}

variable "network" {
  type    = string
  default = "default"
}

variable "zone" {
  type    = string
  default = "us-east1-c"
}

variable "valheim_server_display_name" {
  type = string
}

variable "valheim_server_password" {
  type = string
}

variable "valheim_world_name" {
  type = string
}

variable "additional_metadata" {
  type        = map(string)
  description = "Additional metadata to attach to the instance"
  default = {
    "startup-script" = "mkdir -m ugo=rwx /mnt/disks/gce-containers-mounts/gce-persistent-disks/valheim-worlds"
  }
}
