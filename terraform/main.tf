terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.58"
    }
  }
}

provider "google" {
  project = var.project
  region  = "us-east1"
}

resource "google_compute_address" "static" {
  name = "valheim-server-eip"
}

module "gce-container" {
  source  = "terraform-google-modules/container-vm/google"
  version = "~> 2.0"

  container = {
    image = "us.gcr.io/${var.project}/valheim-server:latest"
    env = [
      {
        name  = "VALHEIM_SERVER_DISPLAY_NAME"
        value = var.valheim_server_display_name
      },
      {
        name  = "VALHEIM_SERVER_PASSWORD"
        value = var.valheim_server_password
      },
      {
        name  = "VALHEIM_WORLD_NAME"
        value = var.valheim_world_name
      }
    ],

    volumeMounts = [
      {
        mountPath = "/home/steam/.config/unity3d/IronGate/Valheim/worlds"
        name      = var.persistent_disk_name
        readOnly  = false
      },
    ]
  }

  volumes = [
    {
      name = var.persistent_disk_name

      gcePersistentDisk = {
        pdName = var.persistent_disk_name
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "Always"
}

resource "google_compute_disk" "pd" {
  name = var.persistent_disk_name
  type = "pd-ssd"
  size = 20
  zone = var.zone
}

resource "google_compute_instance" "valheim_server" {
  name = "valheim-server"
  zone = var.zone

  boot_disk {
    initialize_params {
      image = module.gce-container.source_image
    }
  }

  attached_disk {
    source      = google_compute_disk.pd.self_link
    device_name = var.persistent_disk_name
    mode        = "READ_WRITE"
  }

  network_interface {
    network = var.network

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  machine_type = "e2-medium"

  metadata = merge(var.additional_metadata, map("gce-container-declaration", module.gce-container.metadata_value))

  labels = {
    container-vm = module.gce-container.vm_container_label
  }

  tags = ["valheim-server"]

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

resource "google_compute_firewall" "valheim" {
  name = "valheim-udp-ingress"

  network = var.network

  allow {
    protocol = "udp"
    ports    = ["2456-2458"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["valheim-server"]
}

resource "google_dns_managed_zone" "valheim" {
  name     = "valheim"
  dns_name = var.dns_name
}

resource "google_dns_record_set" "valheim" {
  name = "my.${google_dns_managed_zone.valheim.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.valheim.name

  rrdatas = [google_compute_instance.valheim_server.network_interface[0].access_config[0].nat_ip]
}
