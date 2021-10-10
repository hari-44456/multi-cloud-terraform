provider "google" {
  project     = var.app_project
  credentials = file(var.gcp_auth_file)
  region      = var.gcp_region_1
  zone        = var.gcp_zone_1
}

resource "google_compute_network" "vpc" {
  name = "${var.app_name}-vpc"
  auto_create_subnetworks = "false" 
  routing_mode = "GLOBAL"
}
resource "google_compute_subnetwork" "public_subnet_1" {
  name = "${var.app_name}-public-subnet-1"
  ip_cidr_range = var.public_subnet_cidr_1
  network = google_compute_network.vpc.name
  region = var.gcp_region_1
}

resource "google_compute_firewall" "allow-http" {
  name = "${var.app_name}-fw-allow-http"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  target_tags = ["http"]
}

resource "google_compute_firewall" "allow-https" {
  name = "${var.app_name}-fw-allow-https"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["443"]
  }
  target_tags = ["https"]
}

resource "google_compute_firewall" "allow-ssh" {
  name = "${var.app_name}-fw-allow-ssh"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["ssh"]
}

resource "google_compute_firewall" "allow-rdp" {
  name = "${var.app_name}-fw-allow-rdp"
  network = "${google_compute_network.vpc.name}"
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  target_tags = ["rdp"]
}

resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.app_project
  region = var.gcp_region_1
}
resource "random_id" "instance_id" {
  byte_length = 4
}

resource "google_compute_instance" "vm_instance_public" {
  name = "${var.app_name}-vm-${random_id.instance_id.hex}"
  machine_type = "f1-micro"
  zone = var.gcp_zone_1
  hostname = "${var.app_name}vm-${random_id.instance_id.hex}.${var.app_domain}"
  tags = ["ssh","http"]
  
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-1804-lts"
    }
  }
  metadata_startup_script = "sudo apt-get update,sudo apt-get install -yq build-essential apache2"
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public_subnet_1.name
  
     access_config { 
          nat_ip = google_compute_address.static.address
      }
  }
  
  connection {
      type     ="ssh"    
      host     = google_compute_address.static.address
      user     =var.user
      private_key = file("~/.ssh/id_rsa")
      timeout     = "500s"
    }
  
 provisioner "remote-exec" {
    
    inline = [
      "mkdir prathamesh2"
    ]
  }
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.user}   -i ${google_compute_address.static.address}, --private-key ${var.private_key_gcp} playbook.yml"
  }
  metadata={
    ssh-keys = "${var.user}:${file("~/.ssh/id_rsa.pub")}"
  }
  
}