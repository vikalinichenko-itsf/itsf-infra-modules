variable "yaml" {
  type = any
}

variable "company" {
  type = string
}

variable "project" {
  type = string
}

variable "org" {
  type    = string
  default = ""
}

variable "org_vdc" {
  type    = string
  default = ""
}

variable "catalog_name" {
  type = string
}

variable "s3_rs_bucket" {
  type    = string
  default = ""
}

variable "s3_rs_key" {
  type    = string
  default = ""
}

variable "s3_rs_secret_key" {
  type    = string
  default = ""
}

variable "s3_rs_access_key" {
  type    = string
  default = ""
}