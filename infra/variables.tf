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

variable "flow" {
  type    = string
  default = "24-01"
}

variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}
