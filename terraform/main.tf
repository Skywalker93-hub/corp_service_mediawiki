// Сreate VPS 
resource "yandex_vpc_network" "my_net" {
  name = "wikimedia-network"
}

// Create Subnet-1
resource "yandex_vpc_subnet" "subnet1" {
  v4_cidr_blocks = ["10.10.1.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.my_net.id
}

// Create Subnet-2
resource "yandex_vpc_subnet" "subnet2" {
  v4_cidr_blocks = ["10.10.2.0/28"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.my_net.id
}

// Create Subnet-3
resource "yandex_vpc_subnet" "subnet3" {
  v4_cidr_blocks = ["10.10.3.0/28"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.my_net.id
}

// Get image ID for Ubuntu 26.04 LTS 
data "yandex_compute_image" "ubuntu_2604" {
  family = "ubuntu-2604-lts"
}

// Create disk-1
resource "yandex_compute_disk" "boot" {
  name = "ubuntu-2604-boot"
  zone = "ru-central1-a"
  type = "network-ssd"
  size = 12

  image_id = data.yandex_compute_image.ubuntu_2604.id
}

// Rules in Security Group for three VMs
resource "yandex_vpc_security_group" "sg_openvpn" {
  description = "sg-openvpn"
  network_id  = yandex_vpc_network.my_net.id

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "UDP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 1194
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 943
  }

  ingress {
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}

// New instance "OpenVPN"
resource "yandex_compute_instance" "openvpn" {
  name        = "openvpn"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    disk_id     = yandex_compute_disk.boot.id
    auto_delete = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet1.id
    nat       = true

    security_group_ids = [
      yandex_vpc_security_group.sg_openvpn.id
   ]
  }
  
  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}