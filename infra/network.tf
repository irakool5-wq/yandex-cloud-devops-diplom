resource "yandex_vpc_network" "develop" {
  name = "${var.student_name}-develop-${var.flow}"
}

resource "yandex_vpc_subnet" "public" {
  for_each       = toset(var.zones)
  name           = "public-${each.key}"
  zone           = each.key
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.10.${index(var.zones, each.key) * 64}/26"]
}

resource "yandex_vpc_subnet" "private" {
  for_each       = toset(var.zones)
  name           = "private-${each.key}"
  zone           = each.key
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = ["192.168.20.${index(var.zones, each.key) * 64}/26"]
}
