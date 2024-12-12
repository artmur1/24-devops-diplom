resource "yandex_storage_object" "cute-cat-picture2" {
  bucket = "murchin-bucket1"
  key    = "kitten1.jpg"
  source = "./images/kitten1.jpg"
  tags = {
    test = "value"
  }
}

resource "yandex_vpc_network" "murchin-net" {
  name = local.network_name
}

resource "yandex_vpc_subnet" "public-a" {
  name           = local.subnet_name_a
  zone           = var.default_zone_a
  network_id     = yandex_vpc_network.murchin-net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_vpc_subnet" "public-b" {
  name           = local.subnet_name_b
  zone           = var.default_zone_b
  network_id     = yandex_vpc_network.murchin-net.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}

resource "yandex_vpc_subnet" "public-d" {
  name           = local.subnet_name_d
  zone           = var.default_zone_d
  network_id     = yandex_vpc_network.murchin-net.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

