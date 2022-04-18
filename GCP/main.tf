terraform {
    backend "gcs" {

    credentials = "/home/diva/.gcp/cred.json"
    bucket  = "dim-for-terraform-itacad"
    prefix  = "terraform.tfstate"
    }
}


provider "google" {
    credentials = "/home/diva/.gcp/cred.json"
    project = "geocitizen-345622"
    region = "europe-west1"
    zone = "europe-west1-b"
}


resource "google_compute_firewall" "geoapp" {
    name    = "geoapp-firewall"
    network = "default"
//    network = "${google_compute_network.geoapp.name}"

    // allow {
    //     protocol = "tcp"
    //     ports    = ["22", "8080", "8081"] 
    // }
    // source_ranges = ["195.34.128.0/18"]

    allow {
        protocol = "tcp"
        ports    = ["22", "25", "8080"] 
    }
    source_ranges = ["0.0.0.0/0"]


// resource "google_compute_subnetwork" "geo-sub" {
//   name          = "subnet-geo"
//   ip_cidr_range = "10.22.0.0/16"
//   network       = google_compute_network.geoapp.id
}


//resource "google_compute_network" "geoapp" {
//    name = "geoapp-network"
 // auto_create_subnetworks = “false”
//}

resource "google_compute_instance" "geoapp-server" {
    name         = "geoapp-server"
    machine_type = "e2-medium"

    boot_disk {
        initialize_params {
            image = "ubuntu-minimal-2004-focal-v20220331"
    }
}

    metadata = {
        ssh-keys = "${var.ssh_user}:${data.google_storage_bucket_object_content.key_server.content}"
    }

  
    network_interface {
        network = "default"
//        network = "${google_compute_network.geoapp.name}"
        access_config {}
    }
}


resource "google_compute_firewall" "db" {
    name    = "db-firewall"
    network = "default"
//    network = "${google_compute_network.db.name}"

    allow {
        protocol = "tcp"
        ports    = ["22", "5432"] 
    }
    
    source_ranges = ["0.0.0.0/0"]
}

// resource "google_compute_subnetwork" "db-sub" {
//   name          = "subnet-db"
//   ip_cidr_range = "10.22.0.0/16"
//   network       = google_compute_network.db.id
// }

//resource "google_compute_network" "db" {
//    name = "db-network"
//  auto_create_subnetworks = “false”
//}


resource "google_compute_instance" "db-server" {
    name         = "db-server"
    machine_type = "e2-medium"

    boot_disk {
        initialize_params {
        image = "centos-7-v20220303"
    }
}

    metadata = {
        ssh-keys = "${var.ssh_user}:${data.google_storage_bucket_object_content.key_server.content}"
    }

    network_interface {
        network = "default"
//        network = "${google_compute_network.db.name}"
    
        access_config {}
    }
}

resource "local_file" "public_ip" {
    content  = <<EOT
[app_servers]
${google_compute_instance.geoapp-server.network_interface.0.access_config.0.nat_ip}

[sql_servers]
${google_compute_instance.db-server.network_interface.0.access_config.0.nat_ip}
  EOT
    file_permission   = "0664"
    filename          = "/home/diva/Ansible/hosts.txt"
}

resource "local_file" "vars_for_Ansible" {
    content  = <<EOT
---
appIP: ${google_compute_instance.geoapp-server.network_interface.0.access_config.0.nat_ip}

sqlIP: ${google_compute_instance.db-server.network_interface.0.access_config.0.nat_ip}
  EOT
    file_permission   = "0664"
    filename          = "/home/diva/Ansible/vars.yml"
}

output "geoapp-ip" {
    value = google_compute_instance.geoapp-server.network_interface.0.access_config.0.nat_ip
}
output "db-ip" {
    value = google_compute_instance.db-server.network_interface.0.access_config.0.nat_ip
}

