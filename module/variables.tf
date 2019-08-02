variable "region" {
}

variable "zone" {
}

variable "instance_password" {
  default = "ucloud_2019"
}

variable "instance_count" {
  default = 2
}

variable "count_format" {
  default = "%02d"
}

variable "image_name" {
  default = "lb-packets-transmit-test"
}
