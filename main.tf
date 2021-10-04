# define variables
variable "credentials_file" {}
variable "project" {}
variable "region" {}
variable "zone" {}
variable "bucket" {}

# define providers source and version
# this property is optional, but recommended.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.86.0"
    }
  }
}

# define provider (credential and more)
provider "google" {
  credentials = file(var.credentials_file)
  project     = var.project
  region      = var.region
  zone        = var.zone
}

# define gcs bucket for tfstate file 
terraform {
  backend "gcs" {
    bucket = var.bucket
    prefix = "terraform/state"
  }
}

# define network
resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

# define gce
resource "google_compute_instance" "vm_instance" {
  name         = "vmmv"
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
  }
}
