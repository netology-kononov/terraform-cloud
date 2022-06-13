provider "yandex" {
  cloud_id  = "b1g33rnkdgjohcdl2ks7"
  folder_id = "b1gjk81mhc94gj788sq9"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "default" {
  name = "net"
}

resource "yandex_vpc_subnet" "default" {
  name           = "subnet"
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.101.0/24"]
}

resource "yandex_compute_instance" "test-7-3" {
  name                      = "test-7-3-${count.index}"
  zone                      = "ru-central1-a"
  hostname                  = "test-7-3-${count.index}.netology.cloud"
  allow_stopping_for_update = true
  count                     = local.instance_count[terraform.workspace]
  platform_id               = local.instance_platform[terraform.workspace]

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.image.id
      name        = "root-test-7-3-${count.index}"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }
}

resource "yandex_compute_instance" "test-7-3-foreach" {
  name                      = "test-7-3-${each.key}"
  zone                      = "ru-central1-a"
  hostname                  = "test-7-3-${each.key}.netology.cloud"
  for_each                  = local.instances_by_platform
  platform_id               = each.key

  lifecycle {
    create_before_destroy = true
  }

  resources {
    cores  = each.value
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id    = data.yandex_compute_image.image.id
      name        = "root-test-7-3-${each.key}"
      type        = "network-nvme"
      size        = "50"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.default.id}"
    nat       = true
  }
}

locals {
  instance_count = {
    stage = 1
    prod = 2
  }
  instance_platform = {
    stage = "standard-v1"
    prod = "standard-v2"
  }
  instances_by_platform = {
    "standard-v1" = 2
    "standard-v2" = 4
  }
}
