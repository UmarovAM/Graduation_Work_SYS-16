terraform {
        required_providers {
                yandex = {
                        source = "yandex-cloud/yandex"
                }
        }
}
provider "yandex" {
    token = "y0_AgAAAAAQB8GdAATuwQAAAADuAUWBLi2C7mV7TEGPvw_-4ecn8bo9Qy" # Получить OAuth-токен для  Yandex Cloud  с помощью запроса >    
    cloud_id = "b1g3e3esaheu3s6on970"
    folder_id = "b1gov3unfr7e8jj3g22v"
    zone = "ru-central1-b"
}

# конфигурации ресурсов

resource "yandex_compute_instance" "vm-1" {
  name        = "my-debian-vm-terraform-ansible"
  allow_stopping_for_update = true
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8suc83g7bvp2o7edee"
# "fd8pqqqelpfjceogov30"
      size = 5
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
