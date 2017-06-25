provider "google" {
  credentials = "${file("secrets/account.json")}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_network" "chambybot_network" {
  name = "chambybot"
}

resource "google_compute_subnetwork" "chambybot_subnetwork" {
  name          = "chambybot-subnetwork"
  network       = "${google_compute_network.chambybot_network.name}"
  ip_cidr_range = "10.240.0.0/24"
}

resource "google_compute_firewall" "allow-external" {
  name          = "allow-external"
  network       = "${google_compute_network.chambybot_network.name}"
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol    = "tcp"
    ports       = ["22"]
  }
}

resource "google_compute_instance" "chambybot" {
  count          = "${var.instance_count}"
  name           = "${var.instance_name}"
  machine_type   = "${var.instance_type}"
  zone           = "${var.instance_zone}"
  can_ip_forward = true
  network_interface {
    subnetwork   = "${google_compute_subnetwork.chambybot_subnetwork.name}"
    address      = "10.240.0.${count.index+10}"
    access_config {
    }
  }
  disk {
    image        = "${var.instance_image}"
  }
  metadata {
    sshKeys      = "${var.gce_ssh_user}:${file(var.gce_ssh_public_key_file)}"
  }
}
