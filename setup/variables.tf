variable "cloud_id" {
  type    = string
  default = "b1g8q2fhedsa0th69url"
}

variable "folder_id" {
  type    = string
  default = "b1gtud25o2pff6srffhu"
}

variable "student_name" {
  type    = string
  default = "alavidze"
}

variable "yc_access_key" {
  type      = string
  sensitive = true
}

variable "yc_secret_key" {
  type      = string
  sensitive = true
}