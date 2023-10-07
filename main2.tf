terraform {
  required_providers {
    yandex = {
    source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
 token = "y0_AgAAAAAQB8GdAATuwQAAAADuAUWBLi2C7mV7TEGPvw_-4ecn8bo9Qy"
 cloud_id = "b1g3e3esaheu3s6on970"
 folder_id = "b1gov3unfr7e8jj3g22v"
 zone = "ru-central1-b"
}

resource "yandex_compute_instance" "vm" {
count = 2
name = "vm${count.index}"
resources{
  core_fraction = 20
  cores = 2
  memory = 2
 }
boot_disk {
  initialize_params{
    image_id = "fd8s17cfki4sd4l6oa59" # fd8pqqqelpfjceogov30"
    size = 5
  }
}
network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
 }

metadata = {
  user-data = file("./meta.yml")
}
}

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.0.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# 1. Создайте Target Group, включите в неё две созданных ВМ.

resource "yandex_alb_target_group" "target-1" {
  name      = "target-1"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address   = yandex_compute_instance.vm[0].network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address   = yandex_compute_instance.vm[1].network_interface.0.ip_address
  }
}

# 2. Создайте Backend Group, настройте backends на target group, ранее созданную. Настройте healthcheck на корень (/) и порт 80, протокол HTTP.

resource "yandex_alb_backend_group" "my-backend-group-1" {
  name                     = "my-backend-group"
  
  http_backend {
    name                   = "my-http-backend"
    weight                 = 1
    port                   = 80
    target_group_ids       = ["${yandex_alb_target_group.target-1.id}"]
    load_balancing_config {
      panic_threshold      = 90
    }    
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthy_threshold    = 10
      unhealthy_threshold  = 15 
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

# 3. Создайте HTTP router. Путь укажите — /, backend group — созданную ранее.

resource "yandex_alb_http_router" "router-1" {
  name          = "my-http-router"
  labels        = {
    tf-label    = "tf-label-value"
    empty-label = ""
  }
}

resource "yandex_alb_virtual_host" "my-virtual-host-1" {
  name                    = "my-virtual-host"
  http_router_id          = yandex_alb_http_router.router-1.id
  route {
    name                  = "my-rout"
    http_route {
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.my-backend-group-1.id
        timeout           = "60s"
      }
    }
  }
} 

# 4. Создайте Application load balancer для распределения трафика на веб-сервера, созданные ранее. 
#Укажите HTTP router, созданный ранее, задайте listener тип auto, порт 80.

resource "yandex_alb_load_balancer" "loadbalancer-1" {
  name        = "my-load-balancer"

  network_id  = yandex_vpc_network.network-1.id
  
    allocation_policy {
    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-1.id 
    }
  }

  listener {
    name = "my-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
        
    http {
      handler {
        http_router_id = yandex_alb_http_router.router-1.id
      }
    }
  }
}


output "internal-vm-1" {
  value = "${yandex_compute_instance.vm[0].network_interface.0.ip_address}"
}
output "external-vm-1" {
  value = "${yandex_compute_instance.vm[0].network_interface.0.nat_ip_address}"
}
output "internal-vm-2" {
  value = "${yandex_compute_instance.vm[1].network_interface.0.ip_address}"
}
output "external-vm-2" {
  value = "${yandex_compute_instance.vm[1].network_interface.0.nat_ip_address}"
}


#resource "yandex_compute_snapshot" "snapshot-1" {
#  name = "snap-1"
#  source_disk_id = "${yandex_compute_instance.vm[0].boot_disk[0].disk_id}"
#}
