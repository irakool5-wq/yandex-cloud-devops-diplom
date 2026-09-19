terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.129"
    }
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = file("~/.authorized_key.json")
}

# Создаем S3 бакет для хранения tfstate
resource "yandex_storage_bucket" "tf_state" {
  bucket = "${var.student_name}-tf-state-${var.folder_id}"
  force_destroy = true

  # Используем credentials из текущего контекста yc
  access_key = var.yc_access_key
  secret_key = var.yc_secret_key


  versioning {
    enabled = true
  }
}

output "bucket_name" {
  value = yandex_storage_bucket.tf_state.bucket
}