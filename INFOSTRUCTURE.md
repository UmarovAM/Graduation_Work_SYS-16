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

## Terraform настройка

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
### 3. Создание инфраструктуры с помощью Terraform.

## 3.1 Создаем 2 ВМ для сайта в разных зонах
файл main.tf

```bash
terraform {
        required_providers {
                yandex = {
                        source = "yandex-cloud/yandex"
                }
        }
}
provider "yandex" {
    token = "y0_AgAAAAAQB8GdAATuwQAAAADuAUWBLi2C7mV7TEGPvw_-4ecn8bo9Qy" # Получить OAuth-токен для  Yandex Cloud  с помощью запроса к Яндекс OAuth"
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

## Ansible use whith terraform

