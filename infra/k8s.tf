locals {
  sa_id = jsondecode(file("~/.authorized_key.json"))["service_account_id"]
}

resource "yandex_kubernetes_cluster" "diploma_k8s" {
  name        = "${var.student_name}-k8s-cluster-${var.flow}"
  network_id  = yandex_vpc_network.develop.id
  folder_id   = var.folder_id

  master {
    zonal {
      zone      = var.zones[0]
      subnet_id = yandex_vpc_subnet.public[var.zones[0]].id
    }
    public_ip = true
  }

  service_account_id      = local.sa_id
  node_service_account_id = local.sa_id
}

resource "yandex_kubernetes_node_group" "diploma_k8s_ng" {
  cluster_id = yandex_kubernetes_cluster.diploma_k8s.id
  name       = "${var.student_name}-k8s-ng-${var.flow}"

  instance_template {
    platform_id = "standard-v3"
    
    resources {
      cores         = 2
      memory        = 4
      core_fraction = 20
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    network_interface {
      subnet_ids = [
        yandex_vpc_subnet.public[var.zones[0]].id,
        yandex_vpc_subnet.public[var.zones[1]].id,
        yandex_vpc_subnet.public[var.zones[2]].id
      ]
      nat = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 2
    }
  }

  allocation_policy {
    location { zone = var.zones[0] }
    location { zone = var.zones[1] }
    location { zone = var.zones[2] }
  }
}

output "k8s_cluster_id" {
  value = yandex_kubernetes_cluster.diploma_k8s.id
}

# Yandex Container Registry
resource "yandex_container_registry" "diploma_registry" {
  name      = "${var.student_name}-diploma-registry-${var.flow}"
  folder_id = var.folder_id
}

output "registry_id" {
  value = yandex_container_registry.diploma_registry.id
}

output "registry_name" {
  value = yandex_container_registry.diploma_registry.name
}
