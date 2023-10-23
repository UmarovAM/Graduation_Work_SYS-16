### Ключевая задача — разработать отказоустойчивую инфраструктуру для сайта, включающую мониторинг, сбор логов и резервное копирование основных данных

# Инфраструктура
Инфраструктура должна размещаться в Yandex Cloud и отвечать минимальным стандартам безопасности


## 1. Создаем активный платежный аккаунт,  выбираем каталог, в котором будет работать наша инфраструктура:

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/ddd7659b-4281-4bcd-b521-ba7f857c6c73)



## 2. Установка Terraform. Использую инструкцию из ДЗ с моего GIT 
https://github.com/UmarovAM/my_Terraform/blob/main/READMEold.md

### Из зеркала yandex

 ```bash
 wget https://hashicorp-releases.yandexcloud.net/terraform/1.3.6/terraform_1.3.6_linux_amd64.zip

#После загрузки добавьте путь к папке, в которой находится исполняемый файл, в переменную PATH:

export PATH=$PATH:/path/to/terraform
zcat terraform_1.3.6_linux_amd64.zip > terraformBin
file terraformBin
chmod 744 terraformBin
./terraformBin
./terraformBin --version
# чтобы работал в любом месте
cp terraformBin /usr/local/bin/
# переходим с /home/user на папку root :#
cd ~
```

Добавьте в него следующий блок

```bash
root@aziz-VirtualBox:~# pwd
/root
root@aziz-VirtualBox:~# nano .terraformrc

nano .terraformrc

provider_installation {
  network_mirror {
    url = "https://terraform-mirror.yandexcloud.net/"
    include = ["registry.terraform.io/*/*"]
  }
  direct {
    exclude = ["registry.terraform.io/*/*"]
  }
}
```

### Terraform настройка

Terraform использует конфигурационные файлы с расширением .tf 

```
Для проверки запуска локально

```bash
nano main.tf
# 
terraform {
        required_providers {
                yandex = {
                        source = "yandex-cloud/yandex"
                }
        }
} 
```

Сохраняем конфигурацию, и пробуем подключиться:
Запускать надо там, где находится файл main.tf

```bash
terraform init
terraform apply
```
## 3. Создание инфраструктуры с помощью Terraform.

## 3.1 Создаем 2 ВМ для сайта в разных зонах и настраиваем LB, 2 ВМ для prometheus и grafana
файл main.tf

```terraform
terraform {
  required_providers {
    yandex = {
    source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
 token = "y0_AgAAAAAQB8GdAATuwQAAAADuAUWBLi2C7mV7TEGPvw_-4ecn8bo9Qyc"
 cloud_id = "b1g3e3esaheu3s6on970"
 folder_id = "b1gov3unfr7e8jj3g22v"
 zone = "ru-central1-b"
}


# ВМ 1 для сайта zone 'a'

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
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-1.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metavmsite.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# ВМ 2 для сайта zone 'b'

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
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metavmsite.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# ВМ 3 Для Prometheus zone 'b'

resource "yandex_compute_instance" "vm-3" {
  name        = "my-debian-vm-myshop-vm-3"
  allow_stopping_for_update = true
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metaprometheus.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# ВМ 4 Для Grafana zone 'b'

resource "yandex_compute_instance" "vm-4" {
  name        = "my-debian-vm-myshop-vm-4"
  allow_stopping_for_update = true
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metagrafana.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# ВМ 5 Для Elasticsearch zone 'b'

resource "yandex_compute_instance" "vm-5" {
  name        = "my-debian-vm-myshop-vm-5"
  allow_stopping_for_update = true
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metaelasticsearch.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}

# ВМ 6 Для Kibana zone 'b'

resource "yandex_compute_instance" "vm-6" {
  name        = "my-debian-vm-myshop-vm-6"
  allow_stopping_for_update = true
  zone        = "ru-central1-b"

  resources {
    core_fraction = 20
    cores  = 2
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = "fd8pecdhv50nec1qf9im"
      size = 8
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.subnet-2.id}"
    nat       = true
  }

  metadata = {
    user-data = "${file("./metakibana.yml")}"
  }
  scheduling_policy {
    preemptible = true
  }
}



# Network

resource "yandex_vpc_network" "network-1" {
  name = "network1"
}

# Subnet zone 'a'

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  v4_cidr_blocks = ["192.168.10.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}

# Subnet zone 'b'

resource "yandex_vpc_subnet" "subnet-2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  v4_cidr_blocks = ["192.168.11.0/24"]
  network_id     = "${yandex_vpc_network.network-1.id}"
}



# Load Balancer
# 1. Создайте Target Group, включите в неё две созданных ВМ.
resource "yandex_alb_target_group" "target-1" {
  name      = "target-1"

  target {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address   = yandex_compute_instance.vm-1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.subnet-2.id
    ip_address   = yandex_compute_instance.vm-2.network_interface.0.ip_address
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
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id 
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-2.id 
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

# Outputs VM-1 VM-2

output "internal-vm-1" {
  value = "${yandex_compute_instance.vm-1.network_interface.0.ip_address}"
}
output "external-vm-1" {
  value = "${yandex_compute_instance.vm-1.network_interface.0.nat_ip_address}"
}
output "internal-vm-2" {
  value = "${yandex_compute_instance.vm-2.network_interface.0.ip_address}"
}
output "external-vm-2" {
  value = "${yandex_compute_instance.vm-2.network_interface.0.nat_ip_address}"
}

# Outputs VM-3 (Prometheus) VM-4 (Grafana)

output "internal-vm-3" {
  value = "${yandex_compute_instance.vm-3.network_interface.0.ip_address}"
}
output "external-vm-3" {
  value = "${yandex_compute_instance.vm-3.network_interface.0.nat_ip_address}"
}
output "internal-vm-4" {
  value = "${yandex_compute_instance.vm-4.network_interface.0.ip_address}"
}
output "external-vm-4" {
  value = "${yandex_compute_instance.vm-4.network_interface.0.nat_ip_address}"
}

# Outputs VM-3 (Elasticsearch) VM-4 (Kibana)

output "internal-vm-5" {
  value = "${yandex_compute_instance.vm-5.network_interface.0.ip_address}"
}
output "external-vm-5" {
  value = "${yandex_compute_instance.vm-5.network_interface.0.nat_ip_address}"
}
output "internal-vm-6" {
  value = "${yandex_compute_instance.vm-6.network_interface.0.ip_address}"
}
output "external-vm-6" {
  value = "${yandex_compute_instance.vm-6.network_interface.0.nat_ip_address}"
}


#resource "yandex_compute_snapshot" "snapshot-1" {
#  name = "snap-1"
#  source_disk_id = "${yandex_compute_instance.vm[0].boot_disk[0].disk_id}"
#}

```
```bash
terraform plan
terraform validate
terraform show
terraform apply
terraformBin destroy
```
![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/44cf5025-74f7-4d19-860a-45ce28e6fbe6)



Добавить пользователя на создаваемую ВМ metadata

Для этого создаем файл с мета информацией:
генерируем ssh ключ:
ssh-keygen ./id_rsa
cat id_rsa.pub cp ./meta.txt - ssh-rsa

```bash
nano meta.txt (yml) 

#cloud-config
users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - xxxx(cat id_rsa.pub)
```

```bash
terraform apply
:~/terraform# ssh user@84.252.136.98 -i id_rsa
sudo su -
sudo passwd root
# root@aziz-VirtualBox:~# ssh user@158.160.64.132 -i ./.ssh/id_rsa
# cp /home/user/./.ssh/authorized_keys ~/./.ssh/authorized_keys для входа по root ssh 

```

## 3.2 Установка nginx, prometheus-node-exporter, prometheus-nginx-exporter с помощью Terraform
```yml
#cloud-config  
disable_root: true
timezone: Europe/Moscow
repo_update: true
repo_upgrade: true
apt:
  preserve_sources_list: true
packages:
  - nginx
  - prometheus-node-exporter
  - prometheus-nginx-exporter
runcmd:
  - [ systemctl, nginx-reload ]
  - [ systemctl, enable, nginx.service ]
  - [ systemctl, start, --no-block, nginx.service ]
  - [ sh, -c, "echo $(hostname | cut -d '.' -f 1 ) > /var/www/html/index.html" ]
  - [ sh, -c, "echo $(ip add ) >> /var/www/html/index.html" ]
  - sudo systemctl daemon-reload
  - sudo systemctl enable prometheus-node-exporter
  - sudo systemctl start prometheus-node-exporter
  - sudo systemctl enable prometheus-nginx-exporter
  - sudo systemctl start prometheus-nginx-exporter

users:
  - name: user
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-rsa 

```



## 3.3 Настройка балансировщика

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/e147c533-6642-48e3-97b2-4b3886f873c8)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/5f9ec93a-7302-4bf4-87ce-05e108d1f598)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/51e93d13-86c4-4814-b216-296c61d9d6be)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/bbd0f875-6d52-47e9-9665-5b29d12dc1b3)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/de67d402-9fc6-48ca-a5dd-47db2912be91)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/04a1c5c7-0456-4bed-9a5d-b4ae788fea3f)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/04810dec-1c01-481c-ae60-0b9db943639d)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/f9389a88-8d5c-4398-948e-be4cc6c68b8a)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/c3e3d91a-eb1c-4c15-9514-68a44dd40a8f)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/bdd29ba7-3c21-44e7-af04-19eda6931708)

## 3.3.1 Работа балансировщика

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/710acb63-bb30-4a25-a2f5-7cd6c5b31c17)

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/56d94095-9a80-409b-953f-5b18617647a7)
## 4. Prometheus и grafana
### 4.1 Настройка prometheus и grafana 
```yml
# ansible playbook MyShop

- name: Ping Servers
  hosts: all
  become: yes

  vars:
    packages:
    file_src: ./index.j2
    file_dest: /var/www/html/index.html 
    fileyml_src: ./prometheus.yml.j2
    fileyml_dest: /etc/prometheus/prometheus.yml 
  
  tasks:

  - name: 1. Task ping
    ping:

  - name: 2. Copy index.html to vm1
    template:
      src: "{{file_src}}"
      dest: "{{file_dest}}"
      mode: 0777
    when: ansible_default_ipv4.address == '192.168.10.19'

  - name: 3. Copy index.html to vm2
    template:
      src: "{{file_src}}"
      dest: "{{file_dest}}"
      mode: 0777
    when: ansible_default_ipv4.address == '192.168.11.8'

  - name: 4. Copy prometheus.yml to vm3
    template:
      src: "{{fileyml_src}}"
      dest: "{{fileyml_dest}}"
      mode: 0777
    when: ansible_default_ipv4.address == '192.168.11.9'

#  - name: Edit Targets Site VM ip adress
#    lineinfile:
#      dest: /etc/prometheus/prometheus.yml
#      state: present
#      regexp: "      - targets: ['localhost:9090']"
#      line: "      - targets: ['localhost:9090', '158.160.32.192:9100', '158.160.1.60:9100']"
#    notify: 
#      - restart_prometheus
#    when: ansible_default_ipv4.address == '192.168.11.9'
  handlers:
  - name: restart_prometheus
    service:
      name: prometheus
      state: restarted
      enabled: true
```
### 4.2 Работа prometheus и grafana

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/6c7673b4-9c39-4993-92b2-46182067b260)
![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/bb8a96e9-e83d-4bfa-ae79-3ea0188a6aa6)

# 5 Логи
Cоздайте ВМ, разверните на ней Elasticsearch. Установите filebeat в ВМ к веб-серверам, настройте на отправку access.log, error.log nginx в Elasticsearch.

Создайте ВМ, разверните на ней Kibana, сконфигурируйте соединение с Elasticsearch

![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/22f53d85-f6c5-406b-bd11-63487e5cab78)
![image](https://github.com/UmarovAM/Graduation_Work_SYS-16/assets/118117183/02fffa97-79de-46bd-8ef8-3a40b7324114)













