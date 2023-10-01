terraform {                                                                                                                                                           
        required_providers {                                                                                                                                          
                yandex = {                                                                                                                                            
                        source = "yandex-cloud/yandex"                                                                                                                
                }                                                                                                                                                     
        }                                                                                                                                                             
}                                                                                                                                                                     
provider "yandex" {                                                                                                                                                   
    token = "y0_AgAAAAAQB8GdAATuwQAAAADuAUWBLi2C7mV7TEGPvw_-4ecn8bo9Qyc" # Получить OAuth-токен для  Yandex Cloud  с помощью запроса к Яндекс OAuth"                  
    cloud_id = "b1g3e3esaheu3s6on970"                                                                                                                                 
    folder_id = "b1gov3unfr7e8jj3g22v"                                                                                                                                
#    zone = "ru-central1-b"                                                                                                                                           
}                                                                                                                                                                     
                                                                                                                                                                      
# конфигурации ресурсов                                                                                                                                               
                                                                                                                                                                      
# ВМ_1 для сайта zone 'a'                                                                                                                                             
                                                                                                                                                                      
resource "yandex_compute_instance" "vm-1" {                                                                                                                           
  name        = "my-debian-vm-myshop-vm-1"                                                                                                                            
  allow_stopping_for_update = true                                                                                                                                    
  zone        = "ru-central1-a"                                                                                                                                       
                                                                                                                                                                      
  resources {                                                                                                                                                         
    core_fraction = 20                                                                                                                                                
    cores  = 2                                                                                                                                                        
    memory = 1                                                                                                                                                        
  }                                                                                                                                                                   
                                                                                                                                                                      
  boot_disk {                                                                                                                                                         
    initialize_params {                                                                                                                                               
      image_id = "fd8suc83g7bvp2o7edee"                                                                                                                               
      size = 5                                                                                                                                                        
    }                                                                                                                                                                 
  }                                                                                                                                                                   
                                                                                                                                                                      
  network_interface {                                                                                                                                                 
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"                                                                                                                    
    nat       = true                                                                                                                                                  
  }                                                                                                                                                                   
                                                                                                                                                                      
  metadata = {                                                                                                                                                        
    user-data = "${file("./meta.txt")}"                                                                                                                               
  }                                                                                                                                                                   
  scheduling_policy {                                                                                                                                                 
    preemptible = true                                                                                                                                                
  }                                                                                                                                                                   
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                      
# ВМ_2 для сайта deb 10 zone 'b'                                                                                                                                      
                                                                                                                                                                      
resource "yandex_compute_instance" "vm-2" {                                                                                                                           
  name        = "my-debian-vm-myshop-vm-2"                                                                                                                            
  allow_stopping_for_update = true                                                                                                                                    
  zone        = "ru-central1-b"                                                                                                                                       
                                                                                                                                                                      
  resources {                                                                                                                                                         
    core_fraction = 20                                                                                                                                                
    cores  = 2                                                                                                                                                        
    memory = 1                                                                                                                                                        
  }                                                                                                                                                                   
                                                                                                                                                                      
  boot_disk {                                                                                                                                                         
    initialize_params {                                                                                                                                               
      image_id = "fd8suc83g7bvp2o7edee"                                                                                                                               
      size = 5                                                                                                                                                        
    }                                                                                                                                                                 
  }                                                                                                                                                                   
                                                                                                                                                                      
  network_interface {                                                                                                                                                 
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"                                                                                                                    
    nat       = true                                                                                                                                                  
  }                                                                                                                                                                   
                                                                                                                                                                      
  metadata = {                                                                                                                                                        
    user-data = "${file("./meta.txt")}"                                                                                                                               
  }                                                                                                                                                                   
  scheduling_policy {                                                                                                                                                 
    preemptible = true                                                                                                                                                
  }                                                                                                                                                                   
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                  
                                                                                                                                                                      
                                                                                                                                                                      
resource "yandex_vpc_network" "network-1" {                                                                                                                           
#  folder_id = yandex_compute_instance.vm-1.id                                                                                                                        
  name = "network1"                                                                                                                                                   
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                      
#resource "yandex_vpc_network" "network-2" {                                                                                                                          
#  name = "network2"                                                                                                                                                  
#}                                                                                                                                                                    
                                                                                                                                                                      
                                                                                                                                                                      
                                                                                                                                                                      
resource "yandex_vpc_subnet" "subnet-1" {                                                                                                                             
  name           = "subnet1"                                                                                                                                          
  zone           = "ru-central1-a"                                                                                                                                    
  v4_cidr_blocks = ["192.168.10.0/24"]                                                                                                                                
  network_id     = "${yandex_vpc_network.network-1.id}"                                                                                                               
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                      
resource "yandex_vpc_subnet" "subnet-2" {                                                                                                                             
  name           = "subnet2"                                                                                                                                          
  zone           = "ru-central1-b"                                                                                                                                    
  v4_cidr_blocks = ["192.168.11.0/24"]                                                                                                                                
  network_id     = "${yandex_vpc_network.network-1.id}"                                                                                                               
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                      
                                                                                                                                                                      
                                                                                                                                                                      
output "internal-vm-1" {                                                                                                                                              
    value = yandex_compute_instance.vm-1.network_interface.0.ip_address                                                                                               
}                                                                                                                                                                     
                                                                                                                                                                      
output "external-vm-1" {                                                                                                                                              
    value = yandex_compute_instance.vm-1.network_interface.0.nat_ip_address                                                                                           
}                                                                                                                                                                     
                                                                                                                                                                      
output "macAddress-vm-1" {                                                                                                                                            
    value = yandex_compute_instance.vm-1.network_interface.0.mac_address                                                                                              
}                                                                                                                                                                     
                                                                                                                                                                      
                                                                                                                                                                      
                                                                                                                                                                      
                                                                                                                                                                      
output "internal-vm-2" {                                                                                                                                              
    value = yandex_compute_instance.vm-2.network_interface.0.ip_address                                                                                               
}                                                                                                                                                                     
                                                                                                                                                                      
output "external-vm-2" {                                                                                                                                              
    value = yandex_compute_instance.vm-2.network_interface.0.nat_ip_address                                                                                           
}                                                                                                                                                                     
                                                                                                                                                                      
output "macAddress-vm-2" {                                                                                                                                            
    value = yandex_compute_instance.vm-2.network_interface.0.mac_address                                                                                              
} 
