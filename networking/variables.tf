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

variable "edge_gateway_default" {
  type    = string
  default = ""
}

variable "edge_cluster_default" {
  type    = string
  default = ""
}